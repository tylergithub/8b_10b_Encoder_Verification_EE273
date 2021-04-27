// Checks the transmitted data against the number of bits per xmit,
// and the xmit data register

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

typedef enum reg[2:0] {
	Reset,
	Control_28_1,
	Data,
	Control_28_5,
	Wait 
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
	fork
		forever begin
			din_to_dut.get(msg);
			case(CS)
				Reset : if(msg.reset==1) begin
						NS = Reset;
					end else begin
						`uvm_error("Error: Expected K.28.1")
						NS = Reset;
					end

				Control_28_1 :

				Data :

				Control_28_5 :

				Wait :
			endcase // CS
		end
	join
endtask : run_phase



endclass : data_frame_scoreboard
