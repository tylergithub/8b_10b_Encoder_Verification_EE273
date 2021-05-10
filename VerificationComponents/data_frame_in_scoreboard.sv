// checks the frame of input data to the DUT
// Need to add pushin conditions***************************************

class data_frame_in_scoreboard extends uvm_scoreboard;
`uvm_component_utils(data_frame_in_scoreboard)
uvm_tlm_analysis_fifo #(msg) din_to_dut; // testbench input to the DUT which connected to a monitor
//uvm_tlm_analysis_fifo #(msg) wm;

msg msg; // the message placeholder for recived "input message"
reg [7:0] counter=0;
reg [7:0] counter_28_5=0;
reg [7:0] everyCycle=0;

typedef enum reg[2:0] {
	Reset,
	Control_28_1,
	Data,
	Control_28_5
} State;

State CS,NS;

function new(string name="data_frame_in_scoreboard",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	din_to_dut=new("din_to_dut",this);
	// din=new("dinchk0",this);
	// wm=new("wmchk0",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	CS = Reset;
	fork
		forever begin
			everyCycle = everyCycle + 1;
			din_to_dut.get(msg);
			case(CS)
				Reset : begin
					counter = 0;
					counter_28_5 = 0;
					if(msg.pushin==1) begin
						if(msg.datain==9'b100111100) begin //datain = K28.1
							NS = Control_28_1;
							counter = counter + 1;
							`uvm_info(get_type_name(),$sformatf("Detected the 1st K28.1; Data received: %h; This is round: %d",msg.datain,everyCycle),UVM_MEDIUM)
						end else begin
							`uvm_error(get_type_name(),$sformatf("Error: Expected K.28.1; Data received: %h; This is round: %d",msg.datain,everyCycle))
							NS = Reset;
						end
					end else begin
						NS = Reset;
						`uvm_info(get_type_name(),$sformatf("waiting for K28.1 at Reset state...; Data received: %h; This is round: %d",msg.datain,everyCycle),UVM_MEDIUM)
					end
				end

				Control_28_1 : begin
					if(msg.pushin==1) begin
						if(counter < 4 && msg.datain==9'b100111100) begin
							NS = Control_28_1;
							`uvm_info(get_type_name(),$sformatf("Detected the %d nd/rd/th K28.1; Data received: %h; This is round: %d",counter+1,msg.datain,everyCycle),UVM_MEDIUM)
							counter = counter + 1;
							if(counter==4) begin
								NS = Data;
								`uvm_info(get_type_name(),$sformatf("Entering the Data state...; Data received: %h; This is round: %d",msg.datain,everyCycle),UVM_MEDIUM)
							end
						end else begin
							`uvm_error(get_type_name(),$sformatf("Error: Expected K28.1; Data received: %h; This is round: %d",msg.datain,everyCycle))
						end
					end else begin
						NS = Control_28_1;
						`uvm_info(get_type_name(),$sformatf("waiting for K28.1...; Data received: %h; This is round: %d",msg.datain,everyCycle),UVM_MEDIUM)
					end
				end

				// illegal inputs: control signals that are not in the control symbols table.
				// illegal inputs: 28.1    28.5    23.7
				Data : begin
					if(msg.pushin==1) begin
						if(msg.datain[8]==1) begin // this is control code
							if(msg.datain==9'b110111100) begin
								NS = Control_28_5; // K28.5
								counter_28_5 = 0;
								`uvm_info(get_type_name(),$sformatf("entering Control_28_5 state...; Data received: %h; This is round: %d",msg.datain,everyCycle),UVM_MEDIUM)
							end else if(msg.datain==9'b100111100) `uvm_error(get_type_name(),$sformatf("Error: 28.1 not allowed; Data received: %h; This is round: %d",msg.datain,everyCycle)) // K28.1
							else if(msg.datain==9'b111110111) `uvm_error(get_type_name(),$sformatf("Error: 23.7 not allowed; Data received: %h; This is round: %d",msg.datain,everyCycle)) // K23.7
							else if(msg.datain==9'b100011100 || msg.datain==9'b101011100 || msg.datain==9'b101111100 || msg.datain==9'b110011100 || msg.datain==9'b111011100 || msg.datain==9'b111111100 || msg.datain==9'b111111011 || msg.datain==9'b111111101 || msg.datain==9'b111111110) begin // too much case may lead to a compile error!!!!!!!!!!!!!!!!!!!
								NS = Data;
								`uvm_info(get_type_name(),$sformatf("Everything is normal; Data received: %h; This is round: %d",msg.datain,everyCycle),UVM_MEDIUM)
							end else `uvm_error(get_type_name(),$sformatf("Error: This data is not allowed; Data received: %h; This is round: %d",msg.datain,everyCycle))
						end else begin
							NS = Data; // this is normal data input
							`uvm_info(get_type_name(),$sformatf("Everything is normal; Data received: %h; This is round: %d",msg.datain,everyCycle),UVM_MEDIUM)
						end
					end else begin
						NS = Data;
						`uvm_info(get_type_name(),$sformatf("waiting for data...; Data received: %h; This is round: %d",msg.datain,everyCycle),UVM_MEDIUM)
					end
				end

				Control_28_5 : begin
					if(counter_28_5 < 10) begin
						if(msg.pushin==0) begin
							if(counter_28_5==9) begin
								NS = Reset;
								`uvm_info(get_type_name(),$sformatf("Has been busy for %d cycles, now reseting...; Data received: %h; This is round: %d",counter_28_5,msg.datain,everyCycle),UVM_MEDIUM)
							end else begin
								counter_28_5 = counter_28_5 + 1;
								`uvm_info(get_type_name(),$sformatf("Busy cycle......counter = %d; Data received: %h; This is round: %d",counter_28_5,msg.datain,everyCycle),UVM_MEDIUM)
								NS = Control_28_5;
							end
						end else `uvm_error(get_type_name(),$sformatf("Error: This data is not allowed while inside busy state; Data received: %h; This is round: %d",msg.datain,everyCycle))
					end else NS = Reset;
				end

				default : NS = Reset;

			endcase // CS
			CS = NS;
		end
	join
endtask : run_phase



endclass : data_frame_in_scoreboard
