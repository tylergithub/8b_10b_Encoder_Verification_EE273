// Our top level test for playing

class main extends uvm_test;
`uvm_component_utils(main)
seq1 sq1;
testseqr sqr;
testdrv  drv;
testmon monin;
testsb sb;


function new(string name="main",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	sqr = testseqr::type_id::create("sqr",this);
	drv = testdrv::type_id::create("drv",this);
	monin = testmon::type_id::create("monin",this);
	sb = testsb::type_id::create("sb",this);
endfunction : build_phase


function void connect_phase(uvm_phase phase);
	drv.seq_item_port.connect(sqr.seq_item_export);
	monin.pdat.connect(sb.message_in.analysis_export);
endfunction : connect_phase

task run_phase(uvm_phase phase);
	sq1=seq1::type_id::create("seq1");
	phase.raise_objection(this);
	sq1.start(sqr);
	#100;
	phase.drop_objection(this);
endtask : run_phase

endclass : main
