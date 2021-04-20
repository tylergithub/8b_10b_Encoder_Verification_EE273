`timescale 1ns/10ps

`include "interfacetest.sv"
package tada;
import uvm_pkg::*;

`include "testsi.sv"
`include "msg.sv"
`include "testmon.sv"
`include "testsb.sv"
`include "seq1.sv"
`include "testseqr.sv"
`include "testdrv.sv"

`include "main.sv"


endpackage: tada



import uvm_pkg::*;
module top();

reg clk;
interfacetest intf(clk);

initial begin
	uvm_config_db #(virtual interfacetest)::set(null,"daron","intf",intf);
	run_test("main"); 
end

initial begin
	clk=0;
	forever begin
		#5 clk=~clk;
	end
end

initial begin
	$dumpfile("test.vcd");
	$dumpvars(9,top);
end
	
dut gs0(intf.dut);

endmodule :top 

`include "dut.sv"
