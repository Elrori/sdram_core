# -----------------------------------------------------------------
# de0_nano.sdc
#
# 8/19/2014 D. W. Hawkins (dwh@ovro.caltech.edu)
#
# Quartus II synthesis TimeQuest SDC timing constraints.
#
# -----------------------------------------------------------------
# Notes:
# ------
#
# 1. The results of this script can be analyzed using the
#    TimeQuest GUI
#
#    a) From Quartus, select Tools->TimeQuest Timing Analyzer
#    b) In TimeQuest, Netlist->Create Timing Netlist, Ok
#    c) Run any of the analysis tasks
#       eg. 'Check Timing' and 'Report Unconstrained Paths'
#       show the design is constrained.
#
# -----------------------------------------------------------------
# References
# ----------
#
# Altera's "Basic Source Synchronous Output" TimeQuest example
#
# http://www.altera.com/support/examples/timequest/exm-tq-basic-source-sync.html
#
# -----------------------------------------------------------------

# -----------------------------------------------------------------
# Clock
# -----------------------------------------------------------------
#
# External 50MHz clock
set clk clk_50M
create_clock -period 20 -name $clk [get_ports $clk]

# 100MHz PLL for the Qsys system logic and SDRAM controller
derive_pll_clocks

# Rename the PLL output clocks
set sys_clk   "pll_0|altpll_component|auto_generated|pll1|clk[0]"
set sdram_pll "pll_0|altpll_component|auto_generated|pll1|clk[1]"

# SDRAM clock at the FPGA pin
#
# * NOTE: Quartus generates a warning message indicating that the
#   SDRAM clock does not use a dedicated PLL output.
#
create_generated_clock \
	-name sdram_clk \
	-source $sdram_pll \
	[get_ports {S_CLK}]

# Derive the clock uncertainty parameter
derive_clock_uncertainty

# -----------------------------------------------------------------
# JTAG
# -----------------------------------------------------------------
#
set ports [get_ports -nowarn {altera_reserved_tck}]
if {[get_collection_size $ports] == 1} {

	# JTAG must be in use
	#
	# Exclusive clock domain
	set_clock_groups -exclusive -group altera_reserved_tck

	# Altera JTAG signal names
	set tck altera_reserved_tck
	set tms altera_reserved_tms
	set tdi altera_reserved_tdi
	set tdo altera_reserved_tdo

	# Cut all JTAG timing paths
	set_false_path -from *                -to [get_ports $tdo]
	set_false_path -from [get_ports $tms] -to *
	set_false_path -from [get_ports $tdi] -to *

}

# -----------------------------------------------------------------
# SDRAM Constraints
# -----------------------------------------------------------------
#
# SDRAM timing parameters
# * command/address/data all have the same setup/hold time
# * data tco(min) = tOH, tco(max) = tAC
# TODO:
set sdram_tsu       1.5
set sdram_th        0.8
set sdram_tco_min   3.0 
set sdram_tco_max   5.4

# FPGA timing constraints
set sdram_input_delay_min        $sdram_tco_min
set sdram_input_delay_max        $sdram_tco_max
set sdram_output_delay_min      -$sdram_th
set sdram_output_delay_max       $sdram_tsu

# PLL to FPGA output (clear the unconstrained path warning)
set_min_delay -from $sdram_pll -to [get_ports {S_CLK}] 1
set_max_delay -from $sdram_pll -to [get_ports {S_CLK}] 6

# FPGA Outputs
set sdram_outputs [get_ports {
	S_CKE
	S_CS_N
	S_RAS_N
	S_CAS_N
	S_WE_N
	S_DQM[*]
	S_BA[*]
	S_ADDR[*]
	S_DQ[*]
}]
set_output_delay \
	-clock sdram_clk \
	-min $sdram_output_delay_min \
	$sdram_outputs
set_output_delay \
	-clock sdram_clk \
	-max $sdram_output_delay_max \
	$sdram_outputs

# FPGA Inputs
set sdram_inputs [get_ports {
	S_DQ[*]
}]
set_input_delay \
	-clock sdram_clk \
	-min $sdram_input_delay_min \
	$sdram_inputs
set_input_delay \
	-clock sdram_clk \
	-max $sdram_input_delay_max \
	$sdram_inputs

# SDRAM-to-FPGA multi-cycle constraint
#
# * The PLL is configured so that SDRAM clock leads the system
#   clock by 90-degrees (0.25 period or 2.5ns).
#
# * The PLL phase-shift of -90-degrees was selected so that
#   the timing margin for read setup/hold was fairly symmetric,
#   i.e., the sdram_dq FPGA input setup slack is ~2.3ns and
#   hold slack is ~2.9ns
#
# * The following multi-cycle constraint adds an extra clock
#   period to the read path to ensure that the latch clock that
#   occurs 1.25 periods after the launch clock is used in the
#   timing analysis.
#
set_multicycle_path -setup -end -from sdram_clk -to $sys_clk 2

# -----------------------------------------------------------------
# Cut timing paths
# -----------------------------------------------------------------
#
# The timing for the following I/Os is arbitrary, so cut the paths.
#

# External asynchronous reset
set_false_path -from [get_ports rst_n] -to *

# LED output path
set_false_path -from * -to [get_ports LED*]

