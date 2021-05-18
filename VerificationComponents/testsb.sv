// check that register 0 reads the same as was written (32 bits)

class testsb extends uvm_scoreboard;
`uvm_component_utils(testsb)
uvm_tlm_analysis_fifo #(msg) message_in;

msg m;

function new(string name="testsb",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	message_in=new("mi_imp",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	forever begin
		message_in.get(m);
		if(m.dataout!=0) 
		`uvm_info("debug",$sformatf("pushout: %h startout: %h",m.pushout,m.startout),UVM_MEDIUM);
		///.dataout,m.pushout,m.startout),UVM_MEDIUM)
		
	end

endtask : run_phase



endclass : testsb
