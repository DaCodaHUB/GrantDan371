onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Pound_Testbench/clk
add wave -noupdate /Pound_Testbench/KEY
add wave -noupdate /Pound_Testbench/SW
add wave -noupdate /Pound_Testbench/dut/ledState
add wave -noupdate /Pound_Testbench/dut/stateIncreasingWater
add wave -noupdate /Pound_Testbench/dut/stateDecreasingWater
add wave -noupdate /Pound_Testbench/dut/waterLevelHeight
add wave -noupdate /Pound_Testbench/dut/HEX5
add wave -noupdate /Pound_Testbench/dut/feetOnes
add wave -noupdate /Pound_Testbench/dut/feetOnesDec
add wave -noupdate /Pound_Testbench/dut/muxHexSel
add wave -noupdate /Pound_Testbench/dut/increasingHEX4
add wave -noupdate /Pound_Testbench/dut/decreasingHEX4
add wave -noupdate /Pound_Testbench/dut/HEX4
add wave -noupdate /Pound_Testbench/dut/feetDecimal
add wave -noupdate /Pound_Testbench/dut/feetDecimalDec
add wave -noupdate /Pound_Testbench/HEX2
add wave -noupdate /Pound_Testbench/dut/minutes
add wave -noupdate /Pound_Testbench/HEX1
add wave -noupdate /Pound_Testbench/dut/tens
add wave -noupdate /Pound_Testbench/HEX0
add wave -noupdate /Pound_Testbench/dut/ones
add wave -noupdate /Pound_Testbench/LEDR
add wave -noupdate /Pound_Testbench/dut/timeCounter
add wave -noupdate /Pound_Testbench/dut/stateLevelLow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49850 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 251
configure wave -valuecolwidth 100
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {861 ps}
