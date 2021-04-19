interface interfacetest(input reg clk);

  reg [8:0]   datain ;
  reg [31:0]	dataout ;
  reg pushin,startin,pushout,startout,reset;

	modport dut(input clk, input datain,input startin, input pushin, input reset,
		output startout,output pushout,output dataout);

endinterface
