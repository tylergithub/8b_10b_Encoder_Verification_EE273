

class seq1 extends uvm_sequence #(testsi);
`uvm_object_utils(seq1)
testsi si;

function new(string name="seq1");
	super.new(name);
endfunction : new

task resetx();
		start_item(si);
		si.cmd=reset;
		si.data=0;
		si.pushin=0;
		si.startin=0;
		finish_item(si);
endtask : resetx

task pushx(input reg[8:0] data);
		start_item(si);
		si.cmd=push;
		si.data=data;
		si.pushin=1;
		si.startin=0;
		finish_item(si);
endtask : pushx

task startx();
		start_item(si);
		si.cmd=startin;
		si.pushin=0;
		si.startin=1;
		finish_item(si);
endtask : startx

task busyx();
		start_item(si);
		si.cmd=waitbusy;
		si.pushin=0;
		finish_item(si);
endtask : busyx

task body();
	si=testsi::type_id::create("sequence_item");
	repeat(5) resetx();
	repeat(10) begin
		si.randomize();
		pushx(si.data);
		startx();
		busyx();
	end

endtask : body


endclass : seq1
