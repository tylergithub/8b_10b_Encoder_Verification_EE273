// checks the frame of input data to the DUT

class data_frame_scoreboard extends uvm_scoreboard;
`uvm_component_utils(data_frame_scoreboard)
uvm_tlm_analysis_fifo #(mimsg) din_to_dut; // testbench input to the DUT which connected to a monitor
//uvm_tlm_analysis_fifo #(mimsg) wm;

// reg [15:0] xdata;
// int bit_cntr;
// reg [3:0] nbits;
// mimsg m;
// reg tbit;
mimsg msg; // the message placeholder for recived "input message"
reg [7:0] counter=0;
reg [7:0] counter_28_5=0;

typedef enum reg[2:0] {
	Reset,
	Control_28_1,
	Data,
	Control_28_5
} CS,NS;

function new(string name="data_frame_scoreboard",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	din_to_dut=new("din_to_dut",this);
	// din=new("dinchk0",this);
	// wm=new("wmchk0",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	// bit_cntr=0;
	// nbits=0;
	// xdata=16'h42;
	CS = Reset;
	fork
		forever begin
			din_to_dut.get(msg);
			case(CS)
				Reset : 
					counter = 0;
					counter_28_5 = 0;
					if(msg.datain==9'b100111100) begin //datain = K28.1
						NS = Control_28_1;
						counter = counter + 1;
						`uvm_info($sformatf("Everything is normal"),UVM_MEDIUM)
					end else begin
						//`uvm_error("Error: Expected K.28.1")
						NS = Reset;
					end

				Control_28_1 : 
					if(counter < 5 && msg.datain==9'b100111100) begin
						counter = counter + 1;
						NS = Control_28_1;
					if(counter==5) NS = Data;
					end begin
						`uvm_error("Error: Expected K28.1")
					end

				// illegal inputs: control signals that are not in the control symbols table.
				// illegal inputs: 28.1    28.5    23.7
				Data : 
					if(msg.datain[8]==1) begin // this is control code
						if(msg.datain==9'b110111100) begin
							NS = Control_28_5; // K28.5
							counter_28_5 = 0;
						end else if(msg.datain==9'b100111100) `uvm_error("Error: 28.1 not allowed") // K28.1
						else if(msg.datain==9'b111110111) `uvm_error("Error: 23.7 not allowed") // K23.7
						else if(sg.datain==9'b100011100 || sg.datain==9'b101011100 || sg.datain==9'b101111100 || sg.datain==9'b110011100 || sg.datain==9'b111011100 || sg.datain==9'b111111100 || sg.datain==9'b111111011 || sg.datain==9'b111111101 || sg.datain==9'b111111110) begin // too much case may lead to a compile error!!!!!!!!!!!!!!!!!!!
							`uvm_info($sformatf("Everything is normal"),UVM_MEDIUM)
						end else `uvm_error("Error: This data is not allowed")
					end else NS = Data; // this is normal data input

				Control_28_5 :
					if(counter_28_5 < 11) begin
						if(msg.pushin==0) begin
							counter_28_5 = counter_28_5 + 1;
							`uvm_info($sformatf("Everything is normal"),UVM_MEDIUM)
						end else `uvm_error("Error: This data is not allowed")
					end else NS = Reset;
				
			endcase // CS
			CS = NS;
		end
	join
endtask : run_phase



endclass : data_frame_scoreboard
