

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
		si.startin=1;
		finish_item(si);
endtask : pushx

task startx();
		start_item(si);
		si.cmd=startin;
		si.pushin=1;
		si.startin=1;
		finish_item(si);
endtask : startx


task busyx();
		start_item(si);
		si.cmd=waitbusy;
		si.pushin=0;
		si.startin=0;
		finish_item(si);
endtask : busyx

task body();
	si=testsi::type_id::create("sequence_item");
	repeat (5) begin
		repeat (2) resetx();
		repeat(4) begin
			pushx(9'b100111100); //4 packet of 28.1
		end
		repeat(2) begin
			si.randomize(); //change it to inside...
			pushx(si.data);
		end
		pushx(9'h1BC); // 28.5
		busyx(); //wait for 10 clock cycle
	end
endtask : body


endclass : seq1
