// This is the message item for the seq-seqr-driver path in sdd
typedef enum {
	reset,
	push,
	startin,
	waitbusy
} Dcmd;


class testsi extends uvm_sequence_item;
`uvm_object_utils(testsi)

	Dcmd cmd;
	randc logic [7:0] data;
	logic pushin,startin;
	function new(string name="testsi");
		super.new(name);
	endfunction : new
	
endclass : testsi
