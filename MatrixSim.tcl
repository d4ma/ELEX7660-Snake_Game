set testbench MatrixDisplay_tb
vsim -gui work.MatrixDisplay_tb 
add wave -r sim:/MatrixDisplay_tb/*
run -all