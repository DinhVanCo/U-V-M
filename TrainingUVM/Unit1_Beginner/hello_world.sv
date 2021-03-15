//Include UVM library
`include "my_pkg.sv";
`include "uvm.sv"
import uvm_pkg::*;

module tb;
  //
  initial begin  
    run_test ("hello_world1");
    //run_test ("hello_world2");
  end  // 
endmodule: tb
