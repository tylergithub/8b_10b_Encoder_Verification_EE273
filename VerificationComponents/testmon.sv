// This monitors the bus inputs

class testmon extends uvm_monitor;
`uvm_component_utils(testmon)

virtual interfacetest dut_intf;
uvm_analysis_port #(msg) pdat;
uvm_analysis_port #(msg) output10bit;
uvm_analysis_port #(msg) outputonly;
uvm_analysis_port #(msg) statuswrite;
reg [4:0]counter=0;
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
	output10bit= new("out",this);
	outputonly= new("datout",this);
	statuswrite = new("StatSB",this);
endfunction : build_phase

task run_phase(uvm_phase phase);
	forever @(posedge(dut_intf.clk)) begin
			m=new();
			m.datain=dut_intf.datain;
			m.dataout=dut_intf.dataout;
            m.pushout=dut_intf.pushout;
            m.startout=dut_intf.startout;
			pdat.write(m);
			statuswrite.write(m);
			if(m.dataout !=0) begin
				output10bit.write(m);
				outputonly.write(m);
				counter =0;
			end
			else begin
				counter = counter+1;
				if(counter ==20) begin
						`uvm_fatal("ZeroOutput",$sformatf("Missing output for 20 clock cycle"))
						counter =0;
				end
			end
		end

endtask : run_phase





endclass : testmon
