//--------------------------------------
//Project:  The UVM environemnt for UART (Universal Asynchronous Receiver Transmitter)
//Function: An example for TLM port connection
//Authors:  Pham Thanh Tram, Doan Duc Hoang, Truong Cong Hoang Viet, Nguyen Sinh Ton, Nguyen Hung Quan
//Page:     VLSI Technology
//--------------------------------------
`include "uvm_pkg.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
//
module tlm_test;
  initial begin
    //This method will get thes test name from UVM_TESTNAME
    //which is assigned in the RUN command
    run_test();
  end
endmodule

class my_monitor extends uvm_monitor;
	`uvm_component_utils(my_monitor)
  
	uvm_analysis_port #(int) my_ap;
	
	function new (string name = "my_monitor", uvm_component parent = null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
    my_ap = new("my_ap", this);	
	endfunction

	virtual task run_phase(uvm_phase phase);
		super.run_phase(phase);
    for (int my_data = 0; my_data < 3; my_data++) begin
      $display("Monitor sends: %d", my_data);
		  my_ap.write(my_data);
    end
  endtask
  
endclass

`uvm_analysis_imp_decl(_frmMonitor)

class my_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(my_scoreboard)
  
  uvm_analysis_imp_frmMonitor #(int, my_scoreboard) imp_frmMonitor;
  
  function new (string name = "my_scoreboard", uvm_component parent);
    super.new(name, parent);
    imp_frmMonitor = new ("imp_frmMonitor", this);
  endfunction
  
  virtual function void write_frmMonitor (int in_frmMonitor);
    $display("Scoreboard receives: %d", in_frmMonitor);
  endfunction
  
endclass

class cEnv extends uvm_env;
  //Register to Factory
	`uvm_component_utils_begin(cEnv)
	`uvm_component_utils_end
  //Declare Agent, Scoreboard and Sequencer
	my_scoreboard sb_inst;
	my_monitor mon_inst;
  //Constructor
	function new (string name = "cEnv", uvm_component parent = null);
		super.new(name,parent);
	endfunction
  //Create the objects
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		sb_inst = my_scoreboard::type_id::create("sb_inst",this);
		mon_inst = my_monitor::type_id::create("mon_inst",this);
	endfunction
  //Connect UVM components
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
    //Connect Monitor and Scoreboard by TLM port
		mon_inst.my_ap.connect(sb_inst.imp_frmMonitor);
	endfunction
endclass

class cTest extends uvm_test;
  //Register to Factory
	`uvm_component_utils(cTest)
  //Declare all instances
	cEnv coEnv;
  //Constructor
	function new (string name = "cTest", uvm_component parent = null);
		super.new(name,parent);
	endfunction
  //Build phase
  //Create all objects by the method type_id::create()
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		coEnv = cEnv::type_id::create("coEnv",this);
	endfunction
  //Run phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		fork
			begin
				#1ms;
				`uvm_error("TEST SEQUENCE", "TIMEOUT!!!")
			end
		join_any
		disable fork;
	endtask
endclass
