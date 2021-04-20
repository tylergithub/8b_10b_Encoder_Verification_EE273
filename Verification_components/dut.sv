

module dut (interfacetest.dut m);
  reg [8:0]   datain1 =0; 
  reg [31:0] crc= 32'hFFFFFFFF;
  reg [9:0] dataout1;
  reg [31:0] crcdata;
  reg [7:0] crcencode;
  reg [9:0] crcencoded;
  logic [9:0] K285_1 = 10'b1100000101;
  logic [9:0] K285_2 = 10'b0011111010;
  logic [7:0] K237 = 8'b11110111;
  reg code;
  reg [7:0] msg;
  reg RD;

typedef enum reg[2:0] {
	reset,
	push,
	start,
	transmit,
	crctransmit,
	done
} State;

State cur,nxt;

	always@* begin
		code = datain1[8];
		msg = datain1[7:0];
		nxt = cur;
		case(cur) 
			reset: begin
				nxt = push;
				m.pushout=0;
			end

			push: begin
				if(m.pushin)begin	
					nxt = start;
					datain1= m.datain;
				end
			end
			start: begin
				if(m.startin)begin
					dataout1 = encoder(code,msg,RD);
					nxt = transmit;
				end
				else nxt = start;
				if(!code) begin
					crc32(msg,crc,crcdata);
				end

				if (dataout1 != 0) m.pushout = 1;
				
			end
			transmit: begin
				m.startout =1;
				m.dataout= dataout1;
				if((dataout1 ==K285_1 )| (dataout1 ==K285_2 )) begin
					m.dataout = encoder(1,K237,RD);
					nxt = crctransmit;

				end
				else nxt = start;
			end
			crctransmit: begin
				
				for(int i=0;i<4;i++) begin
					crcencode = crcdata[8*i + 7 -: 8];
					crcencoded = encoder(0,crcencode,RD);
					m.dataout = #1 crcencoded; 				
				end
				nxt = done;
			end
			done: begin
				
				m.dataout = encoder(1,8'b10111100,RD);
				nxt = reset;
			end
		endcase
	end

	always@(posedge m.clk or posedge(m.reset)) begin
		if(m.reset) begin
			cur <= reset;
			dataout1 <=0;
			crc= 32'hFFFFFFFF;
			RD = 0;
		end
		else begin
			cur <= #1 nxt;
		end
	end
	task crc32;
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
    
    endtask

function [9:0] encoder;
	input control_bit;
	input [7:0] d8;
	input running_disparity_input;
	reg [5:0] b6;
	reg [3:0] b4;
	reg [9:0] b10;
	reg k28, l13, l31, a, b, c, d, e;
	reg DXA7_P7;
	reg running_disparity_after_5b6b;
	integer I;

	begin
		a = d8[0];
		b = d8[1];
		c = d8[2];
		d = d8[3];
		e = d8[4];

		l13 = (((a ^ b) & !(c | d)) | ((c ^ d) & !(a | b)));	// contains one "1", and three "0"
   		l31 = (((a ^ b) & (c & d)) | ((c ^ d) & (a & b)));		// contains three "1", and three "1"

   		k28 = control_bit && (d8[4:0] === 5'b11100);

   		// variable that indicate if we should use A7 or P7:
   		DXA7_P7 = control_bit | ((l31 & d & !e & running_disparity_input) | (l13 & !d & e & !running_disparity_input));

//********************************************* Encode 5b -> 6b ************************************************************************************
		if(k28) begin 				// all case for K.28.x control code
			if(!running_disparity_input) begin
				b6 = 6'b111100;		// RD = -1, and we want to reverse the order from LSB to MSB !!!
			end else begin
				b6 = 6'b000011;		// RD = +1, reverse order at here as well !!!
			end
		end else begin				// data case: D.x
			case (d8[4:0])
				5'b00000:							// D.00
					if(running_disparity_input)
						b6 = 6'b000110;
					else
						b6 = 6'b111001;
				5'b00001:							// D.01
					if(running_disparity_input)
						b6 = 6'b010001;
					else
						b6 = 6'b101110;
				5'b00010:							// D.02
					if(running_disparity_input)
						b6 = 6'b010010;
					else
						b6 = 6'b101101;
				5'b00011:							// D.03
					
						b6 = 6'b100011;

				5'b00100:							// D.04
					if(running_disparity_input)
						b6 = 6'b010100;
					else
						b6 = 6'b101011;
				5'b00101:							// D.05

						b6 = 6'b100101;
					
				5'b00110:							// D.06
					
						b6 = 6'b100110;
				
				5'b00111:							// D.07
					if(running_disparity_input)
						b6 = 6'b111000;
					else
						b6 = 6'b000111;
				5'b01000:							// D.08
					if(running_disparity_input)
						b6 = 6'b011000;
					else
						b6 = 6'b100111;
				5'b01001:							// D.09
					
						b6 = 6'b101001;
					
				5'b01010:							// D.10
					
						b6 = 6'b101010;
					
				5'b01011:							// D.11
					
						b6 = 6'b001011;
					
				5'b01100:							// D.012
					
						b6 = 6'b101100;
					
				5'b01101:							// D.13
					
						b6 = 6'b001101;
					
				5'b01110:							// D.14
					
						b6 = 6'b001110;
					
				5'b01111:							// D.15
					if(running_disparity_input)
						b6 = 6'b000101;
					else
						b6 = 6'b111010;
				5'b10000:							// D.16
					if(running_disparity_input)
						b6 = 6'b001001;
					else
						b6 = 6'b110110;
				5'b10001:							// D.17
					
						b6 = 6'b110001;
				5'b10010:							// D.18
					
						b6 = 6'b110010;
				5'b10011:							// D.19
					
						b6 = 6'b010011;
				5'b10100:							// D.20
					
						b6 = 6'b110100;
				5'b10101:							// D.21
					
						b6 = 6'b010101;
				5'b10110:							// D.22
					
						b6 = 6'b010110;
				5'b10111:							// D.23 & K.23.7
					if(running_disparity_input)
						b6 = 6'b101000;
					else
						b6 = 6'b010111;
				5'b11000:							// D.24
					if(running_disparity_input)
						b6 = 6'b001100;
					else
						b6 = 6'b110011;
				5'b11001:							// D.25
					
						b6 = 6'b011001;
				5'b11010:							// D.26
					
						b6 = 6'b011010;
				5'b11011:							// D.27 & K.27.7
					if(running_disparity_input)
						b6 = 6'b100100;
					else
						b6 = 6'b011011;
				5'b11100:							// D.28
					
						b6 = 6'b011100;
				5'b11101:							// D.29 & K.29.7
					if(running_disparity_input)
						b6 = 6'b100010;
					else
						b6 = 6'b011101;
				5'b11110:							// D.30 & K.30.7
					if(running_disparity_input)
						b6 = 6'b100001;
					else
						b6 = 6'b011110;
				5'b11111:							// D.31
					if(running_disparity_input)
						b6 = 6'b001010;
					else
						b6 = 6'b110101;

				default : b6 = 6'bXXXXXX;
			endcase
		end

		// pass the result of 5b/6b to the LSBs of the final result:
		for (I = 0; I < 6; I = I + 1) begin
			b10[I] = b6[I];
		end
		
		// Calculate RD after 5b/6b:
		if(k28) begin
			running_disparity_after_5b6b = !running_disparity_input;	// RD has to alternate after K.28 control code
		end else begin
			case (d8[4:0])															// "*" means neutral disparity
				5'b00000: running_disparity_after_5b6b = !running_disparity_input;	// D.00
				5'b00001: running_disparity_after_5b6b = !running_disparity_input;	// D.01
				5'b00010: running_disparity_after_5b6b = !running_disparity_input;	// D.02
				5'b00011: running_disparity_after_5b6b = running_disparity_input;	// D.03*
				5'b00100: running_disparity_after_5b6b = !running_disparity_input;	// D.04
				5'b00101: running_disparity_after_5b6b = running_disparity_input;	// D.05*
				5'b00110: running_disparity_after_5b6b = running_disparity_input;	// D.06*
				5'b00111: running_disparity_after_5b6b = running_disparity_input;	// D.07*
				5'b01000: running_disparity_after_5b6b = !running_disparity_input;	// D.08
				5'b01001: running_disparity_after_5b6b = running_disparity_input;	// D.09*
				5'b01010: running_disparity_after_5b6b = running_disparity_input;	// D.10*
				5'b01011: running_disparity_after_5b6b = running_disparity_input;	// D.11*
				5'b01100: running_disparity_after_5b6b = running_disparity_input;	// D.12*
				5'b01101: running_disparity_after_5b6b = running_disparity_input;	// D.13*
				5'b01110: running_disparity_after_5b6b = running_disparity_input;	// D.14*
				5'b01111: running_disparity_after_5b6b = !running_disparity_input;	// D.15
				5'b10000: running_disparity_after_5b6b = !running_disparity_input;	// D.16
				5'b10001: running_disparity_after_5b6b = running_disparity_input;	// D.17*
				5'b10010: running_disparity_after_5b6b = running_disparity_input;	// D.18*
				5'b10011: running_disparity_after_5b6b = running_disparity_input;	// D.19*
				5'b10100: running_disparity_after_5b6b = running_disparity_input;	// D.20*
				5'b10101: running_disparity_after_5b6b = running_disparity_input;	// D.21*
				5'b10110: running_disparity_after_5b6b = running_disparity_input;	// D.22*
				5'b10111: running_disparity_after_5b6b = !running_disparity_input;	// D.23
				5'b11000: running_disparity_after_5b6b = !running_disparity_input;	// D.24
				5'b11001: running_disparity_after_5b6b = running_disparity_input;	// D.25*
				5'b11010: running_disparity_after_5b6b = running_disparity_input;	// D.26*
				5'b11011: running_disparity_after_5b6b = !running_disparity_input;	// D.27
				5'b11100: running_disparity_after_5b6b = running_disparity_input;	// D.28*
				5'b11101: running_disparity_after_5b6b = !running_disparity_input;	// D.29
				5'b11110: running_disparity_after_5b6b = !running_disparity_input;	// D.30
				5'b11111: running_disparity_after_5b6b = !running_disparity_input;	// D.31
				default : running_disparity_after_5b6b = running_disparity_input;
			endcase
		end



//********************************************** 3B -> 4B *******************************************************
		// start 3b/4b encode:
		case (d8[7:5])
			3'b000:										// D.x.0 & K.x.0
				if(running_disparity_after_5b6b)
					b4 = 4'b0010;
				else
					b4 = 4'b1101;
			3'b001:										// D.x.1 & K.x.1
				if(k28 && running_disparity_after_5b6b) // Need to verify this************************
					b4 = 4'b0110;
				else
					b4 = 4'b1001;
			3'b010:										// D.x.2 & K.x.2
				if(k28 && running_disparity_after_5b6b) // Need to verify this************************
					b4 = 4'b0101;
				else
					b4 = 4'b1010;
			3'b011:										// D.x.3 & K.x.3
				if(running_disparity_after_5b6b) 		// Need to verify this************************
					b4 = 4'b1100;
				else
					b4 = 4'b0011;
			3'b100:										// D.x.4 & K.x.4
				if(running_disparity_after_5b6b) // Need to verify this************************
					b4 = 4'b0100;
				else
					b4 = 4'b1011;
			3'b101:										// D.x.5 & K.x.5
				if(k28 && running_disparity_after_5b6b) // Need to verify this************************
					b4 = 4'b1010;
				else
					b4 = 4'b0101;
			3'b110:										// D.x.6 & K.x.6
				if(k28 && running_disparity_after_5b6b) // Need to verify this************************
					b4 = 4'b1001;
				else
					b4 = 4'b0110;

			3'b111:										// D.x.P7 & K.x.P7
				if(!DXA7_P7)
					if(!running_disparity_after_5b6b)
						b4 = 4'b0111;
					else
						b4 = 4'b1000;
				else
					if(!running_disparity_after_5b6b)
						b4 = 4'b1110;
					else
						b4 = 4'b0001;

			default: b4 = 4'bXXXX;
		endcase

		// assign the result of 3b/4b to MSBs of b10:
		for (I = 0; I < 4; I = I + 1) begin
			b10[I+6] = b4[I];
		end

		// Calculate the RD for the next input:
		case (d8[7:5])
			3'b000 : RD = ~running_disparity_after_5b6b;
			3'b001 : RD = running_disparity_after_5b6b;
			3'b010 : RD = running_disparity_after_5b6b;
			3'b011 : RD = running_disparity_after_5b6b;
			3'b100 : RD = ~running_disparity_after_5b6b;
			3'b101 : RD = running_disparity_after_5b6b;
			3'b110 : RD = running_disparity_after_5b6b;
			3'b111 : RD = ~running_disparity_after_5b6b;
			default: RD = running_disparity_after_5b6b;
		endcase

		// function output:
		encoder = b10;

	end

endfunction

	
endmodule
/* 	function bit [31:0] crc32;
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
	endfunction */
