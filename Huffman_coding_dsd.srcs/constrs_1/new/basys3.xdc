## ============================================================
## Basys3 Artix-7 (XC7A35T-1CPG236) Constraints File
## Project: Huffman Coding Hardware
##
## HOW TO USE:
##   1. Set SW7:SW0 to ASCII value of symbol  (A=01000001, B=01000010, C=01000011, D=01000100)
##   2. Press BTNL (valid) once per symbol to register it
##   3. Press BTNC (reset) to restart
##   4. LED15 (done) goes HIGH when encoding is complete
##   5. LED0 (serial_out) shows the Huffman bitstream output
## ============================================================

## -------------------------------------------------------
## Clock - W5 (100 MHz onboard oscillator)
## -------------------------------------------------------
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## -------------------------------------------------------
## Buttons
## -------------------------------------------------------
## BTNC (Center) - Reset
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## BTNL (Left) - Valid: press ONCE per symbol to register it
set_property PACKAGE_PIN W19 [get_ports valid]
set_property IOSTANDARD LVCMOS33 [get_ports valid]

## BTNR (Right) - Encode: press ONCE after all symbols entered to start encoding
set_property PACKAGE_PIN T17 [get_ports encode]
set_property IOSTANDARD LVCMOS33 [get_ports encode]

## -------------------------------------------------------
## Switches - Symbol Input (SW7:SW0 = symbol[7:0])
## Set to 8-bit ASCII:
##   'A' = 0100_0001 -> SW6 ON, SW0 ON
##   'B' = 0100_0010 -> SW6 ON, SW1 ON
##   'C' = 0100_0011 -> SW6 ON, SW1 ON, SW0 ON
##   'D' = 0100_0100 -> SW6 ON, SW2 ON
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
## LEDs - Outputs
## -------------------------------------------------------
## LED0 - serial_out (Huffman encoded bitstream, MSB first)
set_property PACKAGE_PIN U16 [get_ports serial_out]
set_property IOSTANDARD LVCMOS33 [get_ports serial_out]

## LED15 - done (HIGH when encoding of all input symbols is complete)
set_property PACKAGE_PIN L1 [get_ports done]
set_property IOSTANDARD LVCMOS33 [get_ports done]

## -------------------------------------------------------
## Configuration / Bitstream properties
## -------------------------------------------------------
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
