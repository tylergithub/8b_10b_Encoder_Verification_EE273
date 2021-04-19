// The great and very cool driver for 2/15/21

class testdrv extends uvm_driver #(testsi);
`uvm_component_utils(testdrv)
testsi mr;


virtual interfacetest xx;

function new(string name="testdrv",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void connect_phase(uvm_phase phase);
	if(uvm_config_db#(virtual interfacetest)::get(null,"daron","intf", xx)); else begin
		`uvm_fatal("config","Didn't get daron intf")
	end


endfunction : connect_phase

task doReset(testsi m);
	xx.reset=1;
	xx.datain=0;
	xx.pushin=m.pushin;
	xx.startin=m.startin;
	@(posedge(xx.clk)) #1;
	xx.reset=0;
	
endtask : doReset

task doPush(testsi m);

	xx.datain=m.data;
	xx.pushin=m.pushin;
	xx.startin=m.startin;
	@(posedge(xx.clk)) #1;
endtask : doPush

task doStart(testsi m);
	xx.pushin=m.pushin;
	xx.startin=m.startin;
	@(posedge(xx.clk)) #1;
endtask : doStart

task doBusy(testsi m);
	xx.pushin=m.pushin;
	xx.startin=m.startin;

	repeat(10) begin
		@(posedge(xx.clk)) #1;
	end
endtask : doBusy



task run_phase(uvm_phase phase);
	forever begin
		seq_item_port.get_next_item(mr);
		case(mr.cmd)
			reset:doReset(mr);
			push:doPush(mr);
			start:doStart(mr);
			busy:doBusy(mr);
		endcase
		seq_item_port.item_done();
	end

endtask : run_phase


endclass : testdrv
