vlog -work work -sv hello_world.sv +incdir+C:/questasim64_10.2c/uvm-1.2/src +define+UVM_CMDLINE_NO_DPI +define+UVM_REGEX_NO_DPI +define+UVM_NO_DPI
vsim -novopt work.tb
run 1ns