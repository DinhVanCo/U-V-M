//Include UVM library
`include "uvm.sv"
import uvm_pkg::*;
//Create the example class
class hello_world extends uvm_test;
  //Register hello_world to Factory
  `uvm_component_utils (hello_world)
  //constructor
  function new (string name = "hello_world", uvm_component parent);
    super.new(name, parent);
  endfunction  //
  virtual task run_phase (uvm_phase phase);
    `uvm_info("WARNING", "HELLO WORLD", UVM_LOW);
  endtask: run_phase

endclass: hello_world
//
//Call and run hello_world
//
module tb;
  //
  initial begin  
    run_test ("hello_world");
  end  // 
endmodule: tb