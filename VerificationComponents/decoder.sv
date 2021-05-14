

class decoder extends uvm_scoreboard;
`uvm_component_utils(decoder)
uvm_tlm_analysis_fifo #(msg)tenbit;
uvm_analysis_port #(reg[31:0]) crcsent;

msg n;
reg illegal;
reg crcflag;
reg [31:0]crcdata;
reg [7:0]decodedone;
reg [9:0] reversed;
reg controlbit;
reg [2:0] count=0;
typedef enum reg[2:0] {
	start,
	crc
} State;
State cur,nxt;
function new(string name="decoder",uvm_component parent=null);
	super.new(name,parent); //base class
endfunction : new

function void build_phase(uvm_phase phase);
	tenbit=new("decoder_imp",this);
	crcsent=new("crcsend",this);
endfunction : build_phase

function [7:0] decode10to8;
	input [9:0] data;
	reg [2:0]b3=0;
	reg [4:0]b5=0;
	reg [2:0]b3rd=0;
	
	if(controlbit | data[5:0] == 6'b000011 | data[5:0] == 6'b111100) begin
		case(data[5:0])
			6'b111100: begin //iedcba
					b5 = 5'b11100;
					case(data[9:6])
					4'b0010: b3 = 3'b000; //jhgf 
					4'b1001: b3 = 3'b001;
					4'b1010: b3 = 3'b010;			 
					4'b1100: b3 = 3'b011;
					4'b0100: b3 = 3'b100;						 
					4'b0101: b3 = 3'b101;
					4'b0110: b3 = 3'b110;
					4'b0001: b3 = 3'b111;
					default: begin
						illegal =1;
					end
					endcase
					end
			6'b000011: begin
					b5 = 5'b11100;
					case(data[9:6])
					4'b1101: b3 = 3'b000;
					4'b0110: b3 = 3'b001;
					4'b0101: b3 = 3'b010;			 
					4'b0011: b3 = 3'b011;
					4'b1011: b3 = 3'b100;						 
					4'b1010: b3 = 3'b101;
					4'b1001: b3 = 3'b110;
					4'b1110: b3 = 3'b111;
					default: begin
						illegal =1;
					end
					endcase
					end
			6'b010111: begin
						if(data[9:6]==4'b0001) begin
							b5 = 5'b10111;
							b3 = 3'b111;
						end
						else illegal =1;
					end
			6'b101000: begin
						if(data[9:6]==4'b1110) begin
							b5 = 5'b10111;
							b3 = 3'b111;
						end
						else illegal =1;
					end
			6'b011011: begin
						if(data[9:6]==4'b0001) begin
							b5 = 5'b11011;
							b3 = 3'b111;
						end
						else illegal =1;
					end
			6'b100100: begin
						if(data[9:6]==4'b1110) begin
							b5 = 5'b11011;
							b3 = 3'b111;
						end
						else illegal =1;
					end	
			6'b011101: begin
						if(data[9:6]==4'b0001) begin
							b5 = 5'b11101;
							b3 = 3'b111;
						end
						else illegal =1;
					end
			6'b100010: begin
						if(data[9:6]==4'b1110) begin
							b5 = 5'b11101;
							b3 = 3'b111;
						end
						else illegal =1;
					end
			6'b011110: begin
						if(data[9:6]==4'b0001) begin
							b5 = 5'b11110;
							b3 = 3'b111;
						end
						else illegal =1;
					end
			6'b100001: begin
						if(data[9:6]==4'b1110) begin
							b5 = 5'b11110;
							b3 = 3'b111;
						end
						else illegal =1;
					end															
		endcase
	end
	else begin
		case(data[5:0])
			6'b111001: begin 			//D.00 RD-
					b5 = 5'b00000;
					b3rd = 0;
				    end
			6'b000110: begin			//D.00 RD+
					b5 = 5'b00000;
					b3rd = 1;
				   end
			6'b101110: begin			//D.01 RD-
					b5 = 5'b00001;
					b3rd = 0;
				   end
			6'b010001: begin			//D.01 RD+
					b5 = 5'b00001;
					b3rd = 1;
				   end
			6'b101101: begin			//D.02 RD-
					b5 = 5'b00010;
					b3rd = 0;
					end
			6'b010010: begin			//D.02 RD+
					b5 = 5'b00010;
					b3rd = 1;
					end
			6'b100011: begin			//D.03 
					b5 = 5'b00011;
					b3rd = 4;
					end
			6'b101011: begin			//D.04 RD-
					b5 = 5'b00100;
					b3rd = 0;
					end
			6'b010100: begin			//D.04 RD+
					b5 = 5'b00100;
					b3rd = 1;
				   end
			6'b100101: begin			//D.05
					b5 = 5'b00101;	
					b3rd = 4;
				   end
			6'b100110: begin			//D.06
					b5 = 5'b00110;	
					b3rd = 4;
					end
						
			6'b000111: begin			//D.07 RD-
					b5 = 5'b00111;
					b3rd = 1;
					end
			6'b111000: begin			//D.07 RD+
					b5 = 5'b00111;
					b3rd = 0;
					end	
			6'b100111: begin			//D.08 RD-
					b5 = 5'b01000;
					b3rd = 0;
					end
			6'b011000: begin			//D.08 RD+
					b5 = 5'b01000;
					b3rd = 1;
					end
			6'b101001: begin			//D.09
					b5 = 5'b01001;
					b3rd = 4;
					end
			6'b101010: begin			//D.10
					b5 = 5'b01010;	
					b3rd = 4;
					end	
			6'b001011: begin			//D.11
					b5 = 5'b01011;
					b3rd = 2;
					end
			6'b101100: begin			//D.12
					b5 = 5'b01100;
					b3rd = 4;
					end
			6'b001101: begin			//D.13
					b5 = 5'b01101;
					b3rd = 2;
					end
			6'b001110: begin			//D.14
					b5 = 5'b01110;
					b3rd = 2;
			       end
			6'b111010: begin			//D.15 RD-
					b5 = 5'b01111;
					b3rd = 0;
					end
			6'b000101: begin			//D.15 RD+
					b5 = 5'b01111;
					b3rd = 1;
					end
			6'b110110: begin			//D.16 RD-
					b5 = 5'b10000;
					b3rd = 0;
					end
			6'b001001: begin			//D.16 RD+
					b5 = 5'b10000;
					b3rd = 1;
					end
			6'b110001: begin			//D.17
					b5 = 5'b10001;
					b3rd = 3;
					end
			6'b110010: begin			//D.18
					b5 = 5'b10010;
					b3rd = 3;
					end
			6'b010011: begin			//D.19
					b5 = 5'b10011;
					b3rd = 4;
					end
			6'b110100: begin			//D.20
					b5 = 5'b10100;
					b3rd = 3;
					end
			6'b010101: begin			//D.21
					b5 = 5'b10101;
					b3rd = 4;
					end
			6'b010110: begin			//D.22
					b5 = 5'b10110;
					b3rd = 4;
					end
			6'b010111: begin			//D.23 RD-
					b5 = 5'b10111;
					b3rd = 0;
					end
			6'b101000: begin			//D.23 RD+
					b5 = 5'b10111;
					b3rd = 1;
					end
			6'b110011: begin			//D.24 RD-
					b5 = 5'b11000;
					b3rd = 0;
					end	
			6'b001100: begin			//D.24 RD+
					b5 = 5'b11000;
					b3rd = 1;
					end
			6'b011001: begin			//D.25
					b5 = 5'b11001;
					b3rd = 4;
					end
			6'b011010: begin			//D.26
					b5 = 5'b11010;
					b3rd = 4;
					end
			6'b011011: begin			//D.27 RD-
					b5 = 5'b11011;
					b3rd = 0;
					end
			6'b100100: begin			//D.27 RD+
					b5 = 5'b11011;
					b3rd = 1;
					end
			6'b011100: begin			//D.28
					b5 = 5'b11100;
					b3rd = 4;
					end
			6'b011101: begin			//D.29 RD-
					b5 = 5'b11101;
					b3rd = 0;
					end	
			6'b100010: begin			//D.29 RD+
					b5 = 5'b11101;
					b3rd = 1;
					end
			6'b011110: begin			//D.30 RD-
					b5 = 5'b11110;
					b3rd = 0;
					end
			6'b100001: begin			//D.30 RD+
					b5 = 5'b11110;
					b3rd = 1;
					end
			6'b110101: begin			//D.31 RD-
					b5 = 5'b11111;
					b3rd = 0;
					end
			6'b001010: begin			//D.31 RD+
					b5 = 5'b11111;
					b3rd = 1;
					end
		default: begin 
			illegal =1;
		end
		endcase
	end
	if(!controlbit) begin
	case(b3rd) 
		0: begin
			case(data[9:6])
				4'b0010: b3 = 3'b000;
				4'b1001: b3 = 3'b001;
				4'b1010: b3 = 3'b010;			 
				4'b1100: b3 = 3'b011;
				4'b0100: b3 = 3'b100;						 
				4'b0101: b3 = 3'b101;
				4'b0110: b3 = 3'b110;
				4'b1000: b3 = 3'b111;
				default: begin
					illegal =1;
				end
			endcase
			end
		1: begin
			case(data[9:6])
					4'b1101: b3 = 3'b000;
					4'b1001: b3 = 3'b001;
					4'b1010: b3 = 3'b010;			 
					4'b0011: b3 = 3'b011;
					4'b1011: b3 = 3'b100;						 
					4'b0101: b3 = 3'b101;
					4'b0110: b3 = 3'b110;
					4'b0111: b3 = 3'b111;
					default: begin
						illegal =1;
					end
					endcase
			end
		2: begin
		case(data[9:6])
				4'b0010: b3 = 3'b000;
				4'b1101: b3 = 3'b000;
				4'b1001: b3 = 3'b001;
				4'b1010: b3 = 3'b010;			 
				4'b1100: b3 = 3'b011;
				4'b0011: b3 = 3'b011;
				4'b0100: b3 = 3'b100;
				4'b1011: b3 = 3'b100;						 
				4'b0101: b3 = 3'b101;
				4'b0110: b3 = 3'b110;
				4'b0001: b3 = 3'b111;
				4'b0111: b3 = 3'b111;
				default: begin
					illegal =1;
				end
				endcase
			end
		3: begin
			case(data[9:6])
					4'b1101: b3 = 3'b000;
					4'b0010: b3 = 3'b000;
					4'b1001: b3 = 3'b001;
					4'b1010: b3 = 3'b010;
					4'b1100: b3 = 3'b011;			 
					4'b0011: b3 = 3'b011;
					4'b1011: b3 = 3'b100;
					4'b0100: b3 = 3'b100;						 
					4'b0101: b3 = 3'b101;
					4'b0110: b3 = 3'b110;
					4'b1000: b3 = 3'b111;
					4'b1110: b3 = 3'b111;
					default: begin
						illegal =1;
					end
					endcase
			end
		4: begin
			case(data[9:6])
				4'b0010: b3 = 3'b000;
				4'b1101: b3 = 3'b000;
				4'b1001: b3 = 3'b001;
				4'b1010: b3 = 3'b010;			 
				4'b0011: b3 = 3'b011;
				4'b1100: b3 = 3'b011;
				4'b1011: b3 = 3'b100;
				4'b0100: b3 = 3'b100;						 
				4'b0101: b3 = 3'b101;
				4'b0110: b3 = 3'b110;			
				4'b0111: b3 = 3'b111;
				4'b1000: b3 = 3'b111;
			default: begin
				illegal =1;
			end
		endcase
		end
	endcase
	end

	decode10to8 = {b3,b5};

endfunction: decode10to8



task run_phase(uvm_phase phase);
	cur=start;
	forever begin
		tenbit.get(n);
		if(n.startout!=0 && n.dataout !=0) begin
		case(cur) 
			start: begin
				controlbit= n.datain[8];
				decodedone = decode10to8(n.dataout);
				if(decodedone == 8'hFC) begin
					`uvm_fatal("ILLEGAL",$sformatf("K28.7 is ILLEGAL"));
				end
				nxt=start;
				if(n.datain == 9'h1BC) nxt = crc;
				else if(decodedone != n.datain[7:0]) `uvm_fatal("decoder",$sformatf("Wrong 10 bit-8bit output: %h vs original input: %h",decodedone,n.datain[7:0]));
	
			end
			crc: begin
				controlbit= 0;
				decodedone = decode10to8(n.dataout);
				crcdata[8*count +: 8] = decodedone;
				count = count+1;
				if(count == 5) begin
					crcsent.write(crcdata);
					count=0;
					crcflag=0;
					nxt = start;
				end
				else nxt = crc;
			end			
			endcase
			cur=nxt;
			`uvm_info("10to8bit",$sformatf("output result: %h", n.dataout),UVM_MEDIUM);
			`uvm_info("10to8bit",$sformatf("After decode, the result: %h", decodedone),UVM_MEDIUM);
			if(illegal) `uvm_fatal("decoder",$sformatf("Illegal 10 Bit: %h",decodedone));	
		end

	end
endtask : run_phase


endclass : decoder
