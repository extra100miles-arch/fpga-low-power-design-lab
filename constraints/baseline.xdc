#==============================================================================
# File        : baseline.xdc
# Project     : FPGA Low Power Design Lab
# Version     : V1 - Baseline
#
# Purpose:
#   Baseline timing constraints.
#
# IMPORTANT:
#   Physical pin assignments are intentionally omitted because the target
#   FPGA/board has not yet been specified.
#
#   Add PACKAGE_PIN and IOSTANDARD constraints after selecting the actual
#   FPGA device/board.
#==============================================================================


#------------------------------------------------------------------------------
# Primary clock
#------------------------------------------------------------------------------
#
# 100 MHz clock
# Period = 10 ns
#

create_clock -name sys_clk -period 10.000 [get_ports clk]


#------------------------------------------------------------------------------
# Clock uncertainty
#------------------------------------------------------------------------------
#
# Keep the initial experiment simple.
# Vivado will use its default clock uncertainty.
#


#------------------------------------------------------------------------------
# Physical IO constraints
#------------------------------------------------------------------------------
#
# Add these after the FPGA board/device is selected.
#
# Example:
#
# set_property PACKAGE_PIN <CLOCK_PIN> [get_ports clk]
# set_property IOSTANDARD LVCMOS33 [get_ports clk]
#
# set_property PACKAGE_PIN <RESET_PIN> [get_ports rst_n]
# set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
#
# set_property PACKAGE_PIN <PIN> [get_ports pixel_valid]
# set_property IOSTANDARD LVCMOS33 [get_ports pixel_valid]
#
# etc.
#
# DO NOT copy random pin numbers from another board.
#==============================================================================
