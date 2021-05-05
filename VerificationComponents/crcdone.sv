

class crcdone extends uvm_scoreboard;
`uvm_component_utils(crcdone)
uvm_tlm_analysis_fifo #(reg[31:0]) expected;
uvm_tlm_analysis_fifo #(reg[31:0]) crcport;

reg [31:0]i;
reg [31:0]j;

function new(string name="crcdone",uvm_component parent=null);
	super.new(name,parent); //base class
endfunction : new

function void build_phase(uvm_phase phase);
	expected=new("crcexpected1",this);
	crcport=new("crcp",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	forever begin
		fork
			expected.get(i);
			crcport.get(j);

		join

		if(i !=0 && j !=0) begin
			if(i==j) begin
				`uvm_info("crcchecked",$sformatf("crc from dut is same as expected"),UVM_MEDIUM)
			end
			else begin
				`uvm_error("crc",$sformatf("expected CRC %h is not same as from dut CRC %h " ,i,j))
			end
		end
	end
endtask : run_phase


endclass : crcdone
