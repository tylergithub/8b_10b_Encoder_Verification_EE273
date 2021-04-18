`timescale 1ns/10ps

`include "encoder.sv"


module top();
reg clk;
reg reset;
reg pushin;
reg [8:0] datain;
reg r_en_crc;
reg [7:0] datain_crc;

wire pushout;
wire [9:0] dataout;

decoder d(clk, reset, pushin, datain, r_en_crc, datain_crc, pushout, dataout);

initial begin
	clk = 0;
	reset = 1;
	#30;
	pushin = 1;
	datain = 9'b100011100;
	r_en_crc = 0;
	datain_crc = 0;
	reset = 0;
end

initial begin
	$dumpfile("perm.vcd");
    $dumpvars(9,d);
    repeat(100) @(posedge(clk));
    #5;
    $dumpoff;
end

initial begin
	repeat(100) begin
		#5 clk = ~clk;
	end
end

endmodule
