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
	randc logic [8:0] data;
	constraint c1 {data inside {9'h11C,9'h13C,9'h15C,9'h17C,9'h19C,9'h1DC,
								9'h1F7,9'h1FB,9'h1FD,9'h1FE,[9'h000:9'h100]};}
	logic pushin,startin;
	function new(string name="testsi");
		super.new(name);
	endfunction : new
	
endclass : testsi
