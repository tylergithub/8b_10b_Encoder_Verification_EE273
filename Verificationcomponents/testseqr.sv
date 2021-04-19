// The sequencer for sdd

class testseqr extends uvm_sequencer#(testsi);
`uvm_component_utils(testseqr)

function new(string name="testseqr",uvm_component parent=null);
	super.new(name,parent);
endfunction : new


endclass : testseqr
