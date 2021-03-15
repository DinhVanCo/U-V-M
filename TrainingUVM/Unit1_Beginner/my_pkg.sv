//Include UVM library
`include "uvm.sv"
import uvm_pkg::*;
// my define======================================================================
typedef reg[7:0] int8;

function int8 Add (int8 a, int8 b);
  Add = a + b;
  endfunction : Add
`define GPIO_Setup(dir, in, out)      \
          {                           \
          dir,                        \
          in,                         \
          out                         \
          }
typedef struct
{
  int8 Dirtection;
  int8 RegRead;
  int8 RegWrite;
}GPIO_TYPE;

GPIO_TYPE GPIO1 = `GPIO_Setup(1, 2, 3);
GPIO_TYPE GPIO2 = `GPIO_Setup(1, 2, 3);
GPIO_TYPE GPIO3 = `GPIO_Setup(1, 2, 3);

class RandomData;
  rand int8 Data1;
  rand int8 Data2;
  rand int8 Data3;
  endclass
RandomData RandomData_Obj;

// my define======================================================================
//Create the example class
class hello_world1 extends uvm_test;
  //Register hello_world to Factory
  `uvm_component_utils (hello_world1);
  int8 test = 5;


  //constructor
  function new (string name = "test 1", uvm_component parent);
    super.new(name, parent);
  endfunction  //
  //
  virtual task run_phase (uvm_phase phase);
    `uvm_info("", "\n\n\nLearning UVM basic\n", UVM_LOW);
    `uvm_info("", $sformatf("Tong hai so la: S = %5d", Add(1, 2)), UVM_LOW);
    `uvm_info("",$sformatf("Test struct: p1 = %d, p2 = %d, p3 = %d", GPIO1.Dirtection, GPIO1.RegRead, GPIO1.RegWrite),UVM_LOW);
    // sequence 1
    RandomDataForGPIO1();
    // sequence 2
    RandomDataForGPIO2();
    // sequence 3
    RandomDataForGPIO3();
    `uvm_info("", "\n\n\n\n", UVM_LOW);
  endtask: run_phase

endclass: hello_world1
//=================================================================================
task RandomDataForGPIO1();
    `uvm_info("", "random gpio 1", UVM_LOW);
    RandomData_Obj = new();
    repeat(10) begin
    if(RandomData_Obj.randomize()) begin
      GPIO1 = `GPIO_Setup(RandomData_Obj.Data1, RandomData_Obj.Data2, RandomData_Obj.Data3);
      end 
    `uvm_info("",$sformatf("Random data GPIO1: p1 = %d, p2 = %d, p3 = %d", GPIO1.Dirtection, GPIO1.RegRead, GPIO1.RegWrite),UVM_LOW);
    end  
endtask : RandomDataForGPIO1
//=================================================================================
task RandomDataForGPIO2();
    `uvm_info("", "random gpio 2", UVM_LOW);
    RandomData_Obj = new();
    repeat(10) begin
    if(RandomData_Obj.randomize()) begin
      GPIO2 = `GPIO_Setup(RandomData_Obj.Data1, RandomData_Obj.Data2, RandomData_Obj.Data3);
      end 
    `uvm_info("",$sformatf("Random data GPIO2: p1 = %d, p2 = %d, p3 = %d", GPIO2.Dirtection, GPIO2.RegRead, GPIO2.RegWrite),UVM_LOW);
    end  
endtask : RandomDataForGPIO2
task RandomDataForGPIO3();
    `uvm_info("", "random gpio 3", UVM_LOW);
    RandomData_Obj = new();
    repeat(10) begin
    if(RandomData_Obj.randomize()) begin
      GPIO3 = `GPIO_Setup(RandomData_Obj.Data1, RandomData_Obj.Data2, RandomData_Obj.Data3);
      end 
    `uvm_info("",$sformatf("Random data GPIO3: p1 = %d, p2 = %d, p3 = %d", GPIO3.Dirtection, GPIO3.RegRead, GPIO3.RegWrite),UVM_LOW);
    end  
endtask : RandomDataForGPIO3
//=================================================================================
//=================================================================================
//=================================================================================

//Create the example class
class hello_world2 extends uvm_test;
  //Register hello_world to Factory
  `uvm_component_utils (hello_world2);
  //constructor
  function new (string name = "test 2", uvm_component parent);
    super.new(name, parent);
  endfunction  //
  virtual task run_phase (uvm_phase phase);
    `uvm_info("WARNING", "xin chao cac ban, this is the first", UVM_LOW);
  endtask: run_phase

endclass: hello_world2
