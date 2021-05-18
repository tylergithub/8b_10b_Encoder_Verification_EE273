// checks the DUT output disparity

class disparity_scoreboard extends uvm_scoreboard;
`uvm_component_utils(disparity_scoreboard)
uvm_tlm_analysis_fifo #(msg) dout_from_dut; // signals output from the DUT which connected to a monitor

msg msg; // the message placeholder for recived "input message"
reg [9:0] dataout10;
int disparity;
int RD = -1;

int ones;
int zeros;
int diff;


// constructor:
function new(string name="disparity_scoreboard",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

//build phase:
function void build_phase(uvm_phase phase);
	dout_from_dut=new("dout_from_dut",this);
endfunction : build_phase

//run_phase:
task run_phase(uvm_phase phase);
	fork
		forever begin
			dout_from_dut.get(msg);
			dataout10 = msg.dataout;
			if(msg.pushout==1) begin
				ones = $countones(dataout10);
				zeros = $countbits(dataout10 ,'0);
				diff = ones - zeros;
				if(diff!=-2 && diff!=0 && diff!=2) begin
					`uvm_error(get_type_name(),$sformatf("Error: disparity=%d is out of bound from {-2,0,+2}",diff))
				end else begin
					`uvm_info(get_type_name(),$sformatf("Disparity is inside the correct range with a value of%d", diff),UVM_MEDIUM)
				end
				if(dataout10==10'h17c) begin
					RD = -1;
				end else begin
					RD = RD + diff;
				end
				
				if(RD!=-1 && RD!=1) begin
					`uvm_error(get_type_name(),$sformatf("Error: Running disparity=%d; It is out of bound from {-1, +1}",RD))
				end else begin
					`uvm_info(get_type_name(),$sformatf("Running Disparity is inside the correct range with a value of%d",RD),UVM_MEDIUM)
				end
			end
			
			
		end
	join
endtask : run_phase



endclass : disparity_scoreboard
