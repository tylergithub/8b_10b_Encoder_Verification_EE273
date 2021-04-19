

class seq1 extends uvm_sequence #(testsi);
`uvm_object_utils(seq1)
testsi si;

function new(string name="seq1");
	super.new(name);
endfunction : new

task reset();
		start_item(si);
		si.cmd=reset;
		si.data=0;
		si.pushin=0;
		si.startin=0;
		finish_item(si);
endtask : reset

task push(input reg[8:0] data);
		start_item(si);
		si.cmd=push;
		si.data=data;
		si.pushin=1;
		si.startin=0;
		finish_item(si);
endtask : push

task start();
		start_item(si);
		si.cmd=start;
		si.pushin=0;
		si.startin=1;
		finish_item(si);
endtask : start

task busy();
		start_item(si);
		si.cmd=busy;
		si.pushin=0;
		finish_item(si);
endtask : busy

task body();
	si=testsi::type_id::create("sequence_item");
	repeat(5) reset();
	repeat(10) begin
		si.randomize();
		push(si.data);
		start();
		busy();
	end

endtask : body


endclass : seq1
