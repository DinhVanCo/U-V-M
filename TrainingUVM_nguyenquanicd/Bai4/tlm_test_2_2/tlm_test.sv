//--------------------------------------
//Project: The UVM environemnt for UART (Universal Asynchronous Receiver Transmitter)
//Function:
// - An example or connecting TLM port and export in UVM
//          In this case, a TLM export/port is used to connect Sequencer and Driver
// - An example for converting a transaction to signal level
// - An example for the relationship of Transaction, Sequence, Sequencer, Driver, Agent in Env
//Module/Class:
// tlm_test is TOP module to call run_test 
// 
//Author: Pham Thanh Tram, Nguyen Sinh Ton, Doan Duc Hoang, Truong Cong Hoang Viet, Nguyen Hung Quan
//Page:    VLSI Technology
//--------------------------------------
//---------------------------------------
// Import UVM package
//---------------------------------------
`include "uvm_pkg.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;
//---------------------------------------
// The interface is drived by a driver
// and connected to a DUT
//---------------------------------------
interface myIf;
  logic clk;
  logic read_en;
  logic write_en;
  logic [31:0] wdata;
  logic [31:0] rdata;
endinterface: myIf
//---------------------------------------
// DUT
//---------------------------------------
module myDut (
  input clk,
  input read_en,
  input write_en,
  input [31:0] wdata,
  output reg [31:0] rdata
  );
  initial begin
    rdata[31:0] = 32'd0;
  end
  always @ (posedge clk) begin
    if (read_en) rdata[31:0] <= rdata[31:0] + 1;
  end
endmodule
//---------------------------------------
// Top of Test
//---------------------------------------
module tlm_test;
  //Declare the interface
  myIf myIf_inst();
  //Create clock
  reg clk = 1'b0;
  always #5ns clk = ~clk;
  //Connect TOP DUT to the Interface instance
  myDut myDut_inst (
    .clk(clk),
    .read_en(myIf_inst.read_en),
    .write_en(myIf_inst.write_en),
    .wdata(myIf_inst.wdata[31:0]),
    .rdata(myIf_inst.rdata[31:0])
    );
  //
  assign myIf_inst.clk = clk;
  initial begin
    //Connect the interface instance to UVM components (Driver)
    uvm_config_db#(virtual interface myIf)::set(null,"uvm_test_top.OmyEnv.OmyAgent*","vmyIf",myIf_inst);
    //This method will get the test name from UVM_TESTNAME
    //which is assigned in the RUN command
    run_test();
  end
endmodule
//---------------------------------------
// Transaction is got by a Sequencer
//---------------------------------------
class myTransaction extends uvm_sequence_item;
  //
  rand logic write_enable; //Driver send a write or read access
  rand logic [31:0] wdata; //Write data from Driver to DUT 
  logic [31:0] rdata; //Read data from DUT to Driver
  //
  `uvm_object_utils_begin (myTransaction)
    //`uvm_field_int(data member, flag)
    //allow access to the functions copy, compare, pack, unpack, record, print, and sprint
    `uvm_field_int(write_enable, UVM_ALL_ON)
    `uvm_field_int(wdata, UVM_ALL_ON)
    `uvm_field_int(rdata, UVM_ALL_ON)
  `uvm_object_utils_end
  //Constructor
  function new (string name = "myTransaction");
    super.new(name);
  endfunction: new
  //
endclass: myTransaction
//---------------------------------------
// Sequence
//---------------------------------------
//`define MyCode
`ifdef MyCode
class mySequence extends uvm_sequence#(myTransaction);
  //Register to Factory
  `uvm_object_utils(mySequence);
  `uvm_declare_p_sequencer(mySequencer);
  //Declare a transaction instance
  myTransaction OmyTransaction;
  //Constructor - create a transaction object
  function new (string name = "mySequence");
    super.new(name);
    OmyTransaction = myTransaction::type_id::create("OmyTransaction");
  endfunction
  //
  //TEST PATTERN is written at here
  //
  task body();
    //Execute 5 transactions
    repeat (8) begin
      #10ns //Execute a new transaction after 10ns
      `uvm_do_on(OmyTransaction, p_sequencer);
      `uvm_info("--- myTransaction: ", $sformatf("\n write_enable=%h \n wdata=%h\n rdata=%h\n", OmyTransaction.write_enable, OmyTransaction.wdata, OmyTransaction.rdata), UVM_LOW);
    end
    #10ns //Delay to be able to see the end transaction on waveform
    `uvm_info("--- COMPLETED SIMULATION ---\n", "", UVM_LOW);
  endtask
endclass: mySequence
`else 
class mySequence extends uvm_sequence#(myTransaction);
  //Register to Factory
  `uvm_object_utils(mySequence);
  //`uvm_declare_p_sequencer(mySequencer);
  //Declare a transaction instance
  myTransaction OmyTransaction;
  //Constructor - create a transaction object
  function new (string name = "mySequence");
    super.new(name);
    OmyTransaction = myTransaction::type_id::create("OmyTransaction");
  endfunction
  //
  //TEST PATTERN is written at here
  //
  task body();
  repeat (100) begin
  #5;
  start_item(OmyTransaction);
      OmyTransaction.write_enable = $random;
      OmyTransaction.wdata        = $random;
  finish_item(OmyTransaction); 
  end 
  endtask: body

endclass: mySequence

`endif
//---------------------------------------
// Sequencer
//---------------------------------------
class mySequencer extends uvm_sequencer#(myTransaction);
  //Register to Factory
  `uvm_component_utils(mySequencer)
  //Constructor
	function new (string name = "mySequencer", uvm_component parent = null);
		super.new(name,parent);
	endfunction
endclass: mySequencer
//---------------------------------------
// Driver
//---------------------------------------
class myDriver extends uvm_driver #(myTransaction);
  //1. Declare the virtual interface
  virtual myIf myIf_inst;
  myTransaction myPacket;
  //2. Register to the factory
  //`uvm_component_utils is for non-parameterized classes
  `uvm_component_utils(myDriver)
  //3. Class constructor with two arguments
  // - A string "name"
  // - A class object with data type uvm_component
  function new (string name, uvm_component parent);
    //Call the function new of the base class "uvm_driver"
    super.new(name, parent);
  endfunction: new
  //4. Build phase
  // - super.build_phase is called and executed first
  // - Configure the component before creating it
  // - Create the UVM component
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    //All of the functions in uvm_config_db are static, using :: to call them
    //If the call "get" is unsuccessful, the fatal is triggered
    if (!uvm_config_db#(virtual interface myIf)::get(.cntxt(this),
          .inst_name(""),
          .field_name("vmyIf"),
          .value(myIf_inst))) begin
       //`uvm_fatal(ID, MSG)
       //ID: message tag
       //MSG message text
       //get_full_name returns the full hierarchical name of the driver object
       `uvm_fatal("NON-myIF", {"A virtual interface must be set for: ", get_full_name(), ".myIf_inst"})
     end
      //
      `uvm_info(get_full_name(), "Build phase completed.", UVM_LOW)
  endfunction
  //5. Run phase
  //Execute methods of Driver in run_phase
  virtual task run_phase (uvm_phase phase);
    fork
      get_seq_and_drive ();
    join
  endtask
  //
  //Driver Methods
  //
  //Get a transaction -> convert to signal level (Drive DUT) -> wait for completing
  virtual task get_seq_and_drive();
    forever begin
      @ (posedge myIf_inst.clk)
      //The seq_item_port.get_next_item is used to get items from the sequencer
      seq_item_port.get_next_item(myPacket);
      //req is assigned to convert_seq2signal to drive the APB interface
      convert_seq2signal(myPacket);
      //Report the done execution
      seq_item_port.item_done();
    end
  endtask: get_seq_and_drive
  //Convert the sequence (a transaction) to signal level
  virtual task convert_seq2signal (myTransaction userTransaction);
    //For write access
    if (userTransaction.write_enable) begin
      myIf_inst.read_en    = 1'b0;
      myIf_inst.write_en   = 1'b1;
      myIf_inst.wdata[31:0] = userTransaction.wdata[31:0];
    end
    //For read access
    else begin
      myIf_inst.read_en  = 1'b1;
      myIf_inst.write_en = 1'b0;
      userTransaction.rdata[31:0] = myIf_inst.rdata[31:0];
    end
  endtask: convert_seq2signal
  //
endclass: myDriver
//---------------------------------------
// Agent
//---------------------------------------
class myAgent extends uvm_agent;
  //Register to Factory
  `uvm_component_utils(myAgent)
  //Declare Sequencer and Driver
  myDriver    OmyDriver;
  mySequencer OmySequencer;
  //Constructor
  function new(string name = "myAgent", uvm_component parent);
      super.new(name, parent);
  endfunction
  //Build Driver and Sequencer objects
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      OmyDriver    = myDriver::type_id::create("OmyDriver",this);
      OmySequencer = mySequencer::type_id::create("OmySequencer",this);
  endfunction
  //Connect Driver and Sequencer via a couple export/port
  function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      OmyDriver.seq_item_port.connect(OmySequencer.seq_item_export);
  endfunction
  //
endclass: myAgent
//---------------------------------------
// Top environment
//---------------------------------------
class myEnv extends uvm_env;
  //Register to Factory
	`uvm_component_utils(myEnv)
  //Declare Agent
	myAgent OmyAgent;
  //Constructor
	function new (string name = "myEnv", uvm_component parent = null);
		super.new(name,parent);
	endfunction
  //Create the objects for Agent
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		OmyAgent = myAgent::type_id::create("OmyAgent",this);
	endfunction
  //Connect UVM components
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction
  //
endclass: myEnv
//---------------------------------------
// Top Testbench
//---------------------------------------
class cTest extends uvm_test;
  //Register to Factory
	`uvm_component_utils(cTest)
  //Declare all instances
	myEnv OmyEnv;
  mySequence OmySequence; 
  //Constructor
	function new (string name = "cTest", uvm_component parent = null);
		super.new(name,parent);
	endfunction
  //Build phase
  //Create all objects by the method type_id::create()
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		OmyEnv = myEnv::type_id::create("OmyEnv",this);
    OmySequence = mySequence::type_id::create("OmySequence",this);
	endfunction
  //Run phase
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
    phase.raise_objection(this);
		fork
      begin
			  OmySequence.start(OmyEnv.OmyAgent.OmySequencer);
      end
			begin
				#1ms;
				`uvm_error("TEST SEQUENCE", "TIMEOUT!!!")
			end
		join_any
		disable fork;
		phase.drop_objection(this);
	endtask
  //
endclass: cTest
