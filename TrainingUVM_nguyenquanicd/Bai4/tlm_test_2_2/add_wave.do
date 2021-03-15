onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider -height 27 {DUT signals}
add wave -noupdate /tlm_test/myDut_inst/clk
add wave -noupdate /tlm_test/myDut_inst/read_en
add wave -noupdate /tlm_test/myDut_inst/write_en
add wave -noupdate /tlm_test/myDut_inst/wdata
add wave -noupdate /tlm_test/myDut_inst/rdata
add wave -noupdate -divider -height 27 INTERFACE
add wave -noupdate /tlm_test/myIf_inst/clk
add wave -noupdate /tlm_test/myIf_inst/read_en
add wave -noupdate /tlm_test/myIf_inst/write_en
add wave -noupdate /tlm_test/myIf_inst/wdata
add wave -noupdate /tlm_test/myIf_inst/rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {12841 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 213
configure wave -valuecolwidth 102
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {154 ns}
