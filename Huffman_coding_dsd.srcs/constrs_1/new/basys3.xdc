## ============================================================
## Basys3 Artix-7 (XC7A35T-1CPG236) Constraints File
## Project: Huffman Coding Hardware
##
## QUICK USAGE:
##   Set SW7:SW0 to ASCII (A=01000001 B=01000010 C=01000011 D=01000100)
##   BTNL  = register one symbol     → AN3 shows symbol letter
##   BTNR  = start encoding          → AN2-AN0 show Huffman code bits
##   BTNC  = reset
##   LED15 = HIGH when encoding done
## ============================================================

## -------------------------------------------------------
## Clock — W5 (100 MHz onboard oscillator)
## -------------------------------------------------------
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## -------------------------------------------------------
## Buttons
## -------------------------------------------------------
## BTNC (Center) — Reset
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## BTNL (Left) — Valid: press once per symbol
set_property PACKAGE_PIN W19 [get_ports valid]
set_property IOSTANDARD LVCMOS33 [get_ports valid]

## BTNR (Right) — Encode: press once when done entering all symbols
set_property PACKAGE_PIN T17 [get_ports encode]
set_property IOSTANDARD LVCMOS33 [get_ports encode]

## -------------------------------------------------------
## Switches — Symbol input SW7:SW0 = symbol[7:0]
## -------------------------------------------------------
set_property PACKAGE_PIN V17 [get_ports {symbol[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {symbol[0]}]

set_property PACKAGE_PIN V16 [get_ports {symbol[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {symbol[1]}]

set_property PACKAGE_PIN W16 [get_ports {symbol[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {symbol[2]}]

set_property PACKAGE_PIN W17 [get_ports {symbol[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {symbol[3]}]

set_property PACKAGE_PIN W15 [get_ports {symbol[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {symbol[4]}]

set_property PACKAGE_PIN V15 [get_ports {symbol[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {symbol[5]}]

set_property PACKAGE_PIN W14 [get_ports {symbol[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {symbol[6]}]

set_property PACKAGE_PIN W13 [get_ports {symbol[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {symbol[7]}]

## -------------------------------------------------------
## 7-Segment Display — Cathodes (active LOW)
## seg[6:0] = {CG, CF, CE, CD, CC, CB, CA}
##          = { g,  f,  e,  d,  c,  b,  a}
## -------------------------------------------------------
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]

set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]

set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]

set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]

set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]

set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]

set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

## -------------------------------------------------------
## 7-Segment Display — Anodes (active LOW, 0 = digit ON)
##   an[3] = leftmost digit  (AN3) — shows input symbol
##   an[0] = rightmost digit (AN0) — shows code LSB bit
## -------------------------------------------------------
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

## -------------------------------------------------------
## LED — done indicator
## -------------------------------------------------------
## LED15 — goes HIGH when all encoding is complete
set_property PACKAGE_PIN L1 [get_ports done]
set_property IOSTANDARD LVCMOS33 [get_ports done]

## -------------------------------------------------------
## Configuration / Bitstream properties
## -------------------------------------------------------
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
