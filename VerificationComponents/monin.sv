
class monin extends uvm_monitor;
`uvm_component_utils(monin)

virtual interfacetest dut_intf;
uvm_analysis_port #(reg[7:0]) dat;
uvm_analysis_port #(reg[8:0]) data8bit;

msg m;


function new(string name="monin",uvm_component parent=null);
	super.new(name,parent); //base class
endfunction : new

function void connect_phase(uvm_phase phase);
	if(uvm_config_db#(virtual interfacetest)::get(null,"daron","intf",dut_intf)); else begin
		`uvm_fatal("config","Didn't get daron intf")
	end
endfunction : connect_phase

function void build_phase(uvm_phase phase);
	dat=new("inputmsg",this);
	data8bit=new("data8bit",this);

endfunction : build_phase

task run_phase(uvm_phase phase);
	forever @(posedge (dut_intf.clk)) begin	
	if(!dut_intf.reset) begin
		m=new();  //u cant use the message u made in sequence item cause its not connected
		m.datain=dut_intf.datain;

		if(m.datain[8]) begin
			dat.write(m.datain[7:0]);
		end 
		if (!m.datain[8] | dut_intf.datain == 9'h1BC) begin
			data8bit.write(m.datain);
		end
		
	end	
	
	end
endtask : run_phase

endclass : monin

