

class statussb extends uvm_scoreboard;
`uvm_component_utils(statussb)
uvm_tlm_analysis_fifo #(msg) statusreg;

msg m;

function new(string name="statussb",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	statusreg=new("mi_imp",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	forever begin
		statusreg.get(m);
		if(m.startout && m.dataout==0) `uvm_fatal("status",$sformatf("startout turns 1 without output"));
		if(!m.pushout && m.startout) `uvm_fatal("status",$sformatf("startout turns 1 without pushout turns 1"));
	end

endtask : run_phase



endclass : statussb
