// checks the frame of input data to the DUT

class data_frame_out_scoreboard extends uvm_scoreboard;
`uvm_component_utils(data_frame_out_scoreboard)
uvm_tlm_analysis_fifo #(msg) dout_from_dut; // signals output from the DUT which connected to a monitor
//uvm_tlm_analysis_fifo #(msg) wm;

// reg [15:0] xdata;
// int bit_cntr;
// reg [3:0] nbits;
// msg m;
// reg tbit;
msg msg; // the message placeholder for recived "input message"
reg [7:0] counter=0;
reg [2:0] crc_counter=0;

typedef enum reg[2:0] {
	Control_28_1,
	Data,
//	Control_23_7,
	CRC_result,
	Control_28_5
} State;

State CS,NS;

function new(string name="data_frame_out_scoreboard",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	dout_from_dut=new("dout_from_dut",this);
	// din=new("dinchk0",this);
	// wm=new("wmchk0",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	// bit_cntr=0;
	// nbits=0;
	// xdata=16'h42;
	CS = Control_28_1;
	fork
		forever begin
			dout_from_dut.get(msg);
			case (CS)
				Control_28_1 : begin
					counter = 0;
					crc_counter = 0;
					if(msg.pushout==1) begin
						if(msg.dataout==10'b1001111100 || msg.dataout==10'b0110000011) begin // K28.1
							NS = Data;
							`uvm_info(get_type_name(),$sformatf("DUT output jumps to Data state."),UVM_MEDIUM)
						end else `uvm_info(get_type_name(),$sformatf("Error: DUT output received code other than expected K28.1"),UVM_MEDIUM)
					end else begin
						NS = Control_28_1;
						`uvm_info(get_type_name(),$sformatf("DUT output waiting for DUT output..."),UVM_MEDIUM)
					end
				end

				Data : begin
					if(msg.pushout==1) begin
						counter = counter + 1;
						`uvm_info(get_type_name(),$sformatf("DUT output data counter = %d",counter),UVM_MEDIUM)
						if(msg.dataout==10'b0001010111 || msg.dataout==10'b1110101000) begin // K23.7
							NS = CRC_result;
							`uvm_info(get_type_name(),$sformatf("DUT output jumps to CRC_result state."),UVM_MEDIUM)
						end else `uvm_info(get_type_name(),$sformatf("DUT output outputing data..."),UVM_MEDIUM)
					end else begin
						NS = Data;
						crc_counter = 0;
						`uvm_info(get_type_name(),$sformatf("DUT output waiting for data..."),UVM_MEDIUM)
					end
				end

				CRC_result : begin
					// Is there any illegal 10-bit output for CRC data???
					if(msg.pushout==1) begin
						if(crc_counter==3) begin // move to next state
							NS = Control_28_5;
							crc_counter = crc_counter + 1;
							`uvm_info(get_type_name(),$sformatf("DUT output moves to Control_28_5 state on crc_counter of: %d",crc_counter),UVM_MEDIUM)
						end else if(crc_counter < 3) begin // keep in CRC state
							NS = CRC_result;
							crc_counter = crc_counter + 1;
							`uvm_info(get_type_name(),$sformatf("DUT output still in CRC state on crc_counter of: %d",crc_counter),UVM_MEDIUM)
						end else `uvm_fatal("Failed",$sformatf("CRC state failed on crc_counter of: %d",crc_counter))
					end else begin
						NS = CRC_result;
						`uvm_info(get_type_name(),$sformatf("DUT output waiting... at crc_counter: %d",crc_counter),UVM_MEDIUM)
					end
				end
				Control_28_5 : begin
					if(msg.pushout==1) begin
						if(msg.dataout==10'b0101111100 || msg.dataout==10'b1010000011) begin // K28.5
							NS = Control_28_1;
							`uvm_info(get_type_name(),$sformatf("DUT output has completed for 1 packet."),UVM_MEDIUM)
						end else `uvm_fatal("DUT output: something went wrong...",$sformatf("Expecting the final K28.1"))
					end else begin
						NS = Control_28_5;
						`uvm_info(get_type_name(),$sformatf("DUT output waiting for the final K28.5..."),UVM_MEDIUM)
					end
				end
			
				default : NS = Control_28_1;
			endcase
			CS = NS; // update SM
		end
	join
endtask : run_phase



endclass : data_frame_out_scoreboard
















