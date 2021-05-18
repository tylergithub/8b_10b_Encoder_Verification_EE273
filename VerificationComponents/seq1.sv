

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
		finish_item(si);
endtask : resetx

task pushx(input reg[8:0] data);
		start_item(si);
		si.cmd=push;
		si.data=data;
		finish_item(si);
endtask : pushx

task startx();
		start_item(si);
		si.cmd=startin;
		finish_item(si);
endtask : startx


task busyx();
		start_item(si);
		si.cmd=waitbusy;
		finish_item(si);
endtask : busyx

task body();
	si=testsi::type_id::create("sequence_item");
	repeat (5000) begin
		resetx();
		repeat(4) begin
			pushx(9'b100111100); //4 packet of 28.1
			startx();
		end
		repeat(2) begin
			si.randomize(); //change it to inside...
			pushx(si.data);
			startx();
		end
		pushx(9'h1BC); // 28.5
		startx();
		busyx(); //wait for 10 clock cycle
		resetx();
	end
endtask : body


endclass : seq1
