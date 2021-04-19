// This monitors the bus inputs

class testmon extends uvm_monitor;
`uvm_component_utils(testmon)

virtual interfacetest dut_intf;
uvm_analysis_port #(msg) pdat;
msg m;

function new(string name="testmon",uvm_component parent=null);
	super.new(name,parent);
endfunction : new

function void connect_phase(uvm_phase phase);
	if(uvm_config_db#(virtual interfacetest)::get(null,"daron","intf", dut_intf)); else begin
		`uvm_fatal("config","Didn't get daron intf")
	end
endfunction : connect_phase

function void build_phase(uvm_phase phase);
	pdat=new("msg",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	forever @(posedge(dut_intf.clk)) begin
			m=new();
			m.datain=dut_intf.datain;
			m.dataout=dut_intf.dataout;
            m.pushout=dut_intf.pushout;
            m.startout=dut_intf.startout;
			pdat.write(m);
		end

endtask : run_phase





endclass : testmon
