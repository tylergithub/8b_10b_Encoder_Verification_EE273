

class K237 extends uvm_scoreboard;
`uvm_component_utils(K237)
uvm_tlm_analysis_fifo #(msg) datout;


msg l;


function new(string name="K237",uvm_component parent=null);
	super.new(name,parent); //base class
endfunction : new

function void build_phase(uvm_phase phase);
	datout=new("yolo",this);
	
endfunction : build_phase

task run_phase(uvm_phase phase);
	forever begin
		datout.get(l);
		if(l.datain !=0) begin
			if(l.datain == 9'h1BC) begin
				if(l.dataout == 10'h057 | l.dataout == 10'h3A8) begin
					`uvm_info("K237",$sformatf("K23.7 is received"),UVM_MEDIUM)
				end
				else begin
					`uvm_fatal("K237",$sformatf("K23.7 is missing and We received %h when 28.5 is sent", l))
				end
			end
		end
	end
endtask : run_phase


endclass : K237
