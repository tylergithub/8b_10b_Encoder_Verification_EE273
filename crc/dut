

module dut (interfacetest.dut m);
  reg [7:0]   datain1 =0; 
  reg [31:0] crc= 32'hFFFFFFFF;

	always@(posedge m.clk or posedge(m.reset)) begin
		if(m.reset) begin
			datain=0;
			dataout=0;
		end
		else begin
			datain1<= #1 m.datain;
			m.dataout<= #1 crc32(crc,datain1);
		end
	end

	function bit [31:0] crc32;
	input [31:0] crc;
	input [7:0] datain2;
	int j,k;
	reg [31:0]mask;
	crc = crc^ datain2;
	for(j=7;j>=0;j--) begin
		mask = -(crc&1);
		crc = (crc>>1)^(32'hEDB88320 & mask);
	end
	crc32 = ~crc;
	endfunction
	
endmodule
/*  	task crc32;
    	input [7:0] datain2;
    	inout [31:0]crc;
      	output [31:0]dataout2;
	int j,k;
	reg [31:0]mask;
	crc = crc^ datain2;
		for(j=7;j>=0;j--) begin
			mask = -(crc&1);
			crc = (crc>>1)^(32'hEDB88320 & mask);
		end
	dataout2 = ~crc;
    
    endtask*/
