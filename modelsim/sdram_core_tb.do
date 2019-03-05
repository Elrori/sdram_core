# modelsim do file
# helrori
# 190203
vlib work
vlog +define+_DEBUG_ ../rtl/*.v
vsim sdram_core_tb
add wave /sdram_core_tb/sdram_core_0/*
radix hex
run -all