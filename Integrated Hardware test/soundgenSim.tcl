set testbench soundgen_tb
vsim -gui work.$testbench 
add wave -r sim:/$testbench/*
run -all
property wave -radix unsigned /$testbench/dut_0/freq
property wave -radix unsigned /$testbench/dut_0/count
property wave -radix unsigned /$testbench/dut_0/notes
property wave -radix unsigned /$testbench/dut_0/freqgen_0/countup