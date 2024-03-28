set testbench irReceiver_tb
vsim -gui work.$testbench 
add wave -r sim:/$testbench/*
run -all
property wave -radix unsigned /$testbench/dut_0/counter
property wave -radix unsigned /$testbench/dut_0/count
property wave -radix unsigned /$testbench/dut_0/bit_count
property wave -radix hexadecimal /$testbench/word
property wave -radix hexadecimal /$testbench/iroutput