

class crcsb extends uvm_scoreboard;
`uvm_component_utils(crcsb)
uvm_tlm_analysis_fifo #(reg[8:0]) indata;
uvm_analysis_port #(reg[31:0]) crcexpected;

reg [8:0] m;
reg [31:0] crc = 32'hFFFFFFFF;
reg [31:0] crcdata=0;
function new(string name="crcsb",uvm_component parent=null);
	super.new(name,parent); //base class
endfunction : new

function void build_phase(uvm_phase phase);
	indata=new("crcin_imp",this);
	crcexpected=new("crcoutport",this);
endfunction : build_phase

function bit [31:0] crc32;
	input [7:0] datain2;
	int j,k;
	reg [31:0]mask;
	crc = crc^ datain2;
	for(j=7;j>=0;j--) begin
		mask = -(crc&1);
		crc = (crc>>1)^(32'hEDB88320 & mask);
	end
	crc32 = ~crc;
endfunction :crc32
	
task run_phase(uvm_phase phase);
	forever begin
		indata.get(m);
		
			if(m==9'h1BC) begin
				crcexpected.write(crcdata);
				crc=32'hFFFFFFFF;
				`uvm_info("crc",$sformatf("expected CRC: %h",crcdata),UVM_MEDIUM)
			end
			else begin
				crcdata = crc32(m[7:0]);
			end
		

	end
endtask : run_phase


endclass : crcsb
