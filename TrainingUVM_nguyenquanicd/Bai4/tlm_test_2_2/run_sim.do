#---------------------------------------------
#Compilation
#---------------------------------------------
vlog -work work \
  +define+UVM_CMDLINE_NO_DPI \
  +define+UVM_REGEX_NO_DPI \
  +define+UVM_NO_DPI \
  +define+INTERRUPT_COM \
  +incdir+C:/questasim64_10.2c/uvm-1.2/src \
  -sv \
  tlm_test.sv \
  -timescale 1ns/1ns \
  +cover
  
#---------------------------------------------
#Simulation
#---------------------------------------------
vsim -novopt work.tlm_test \
  +UVM_TESTNAME=cTest \
  +UVM_VERBOSITY=UVM_LOW \

#---------------------------------------------
#Add waveform
#---------------------------------------------
do add_wave.do

#---------------------------------------------
#Run
#---------------------------------------------
run 1000ns