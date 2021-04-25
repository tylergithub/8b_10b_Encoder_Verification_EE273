interface interfacetest(input reg clk);

  reg [8:0] datain ;
  reg [9:0]	dataout ;
  reg pushin;
  reg startin;
  reg pushout;
  reg startout;
  reg reset;

	modport dut(input clk, input datain,input startin, input pushin, input reset,
		output startout,output pushout,output dataout);

endinterface
