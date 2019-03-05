iverilog -D _DEBUG_ -y. -y../rtl/ -o sdram_core.vvp ../rtl/sdram_core_tb.v
vvp sdram_core.vvp
gtkwave wave.vcd