// Our top level test for playing

class main extends uvm_test;
`uvm_component_utils(main)
seq1 sq1;
testseqr sqr;
testdrv  drv;

testmon monout;
testsb sb;
crcdone crcd;
decoder decode;
K237 K23_7;
checkK281 K28_1;
crcsb crc32sb;

monin monin1;


function new(string name="main",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void build_phase(uvm_phase phase);
	sqr = testseqr::type_id::create("sqr",this);
	drv = testdrv::type_id::create("drv",this);
	monout = testmon::type_id::create("monout",this);
	monin1 = monin::type_id::create("monin1",this);
	sb = testsb::type_id::create("sb",this);
	K28_1 = checkK281::type_id::create("K28_1",this);
	decode = decoder::type_id::create("decode",this);
	crc32sb = crcsb::type_id::create("crc32sb",this);
	crcd = crcdone::type_id::create("crcd",this);
	K23_7 = K237::type_id::create("jin",this);
endfunction : build_phase


function void connect_phase(uvm_phase phase);
	drv.seq_item_port.connect(sqr.seq_item_export);
	monin1.dat.connect(K28_1.K281_in.analysis_export);
	monin1.data8bit.connect(crc32sb.indata.analysis_export);

	monout.pdat.connect(sb.message_in.analysis_export);
	monout.output10bit.connect(decode.tenbit.analysis_export);
	monout.outputonly.connect(K23_7.datout.analysis_export);
	crc32sb.crcexpected.connect(crcd.expected.analysis_export);
	decode.crcsent.connect(crcd.crcport.analysis_export);
endfunction : connect_phase

task run_phase(uvm_phase phase);
	sq1=seq1::type_id::create("seq1");
	phase.raise_objection(this);
	sq1.start(sqr);
	#100;
	phase.drop_objection(this);
endtask : run_phase

endclass : main
