# ============================================================
# Vivado Project Rebuild Script
# Project : Huffman Coding Hardware
# Target  : Basys3 - Artix-7 XC7A35T-1CPG236
# Tool    : Vivado 2023.1 (or later)
#
# USAGE (in Vivado Tcl Console or batch mode):
#   source create_project.tcl
#   - OR -
#   vivado -mode batch -source create_project.tcl
# ============================================================

set project_name "Huffman_coding_dsd"
set project_dir  [file dirname [file normalize [info script]]]
set part         "xc7a35tcpg236-1"
set board_part   "digilentinc.com:basys3:part0:1.1"

# --------------------------------------------------------
# 1. Create / overwrite the project
# --------------------------------------------------------
create_project $project_name $project_dir -part $part -force

set_property board_part   $board_part     [current_project]
set_property target_language  Verilog     [current_project]
set_property default_lib xil_defaultlib  [current_project]

# --------------------------------------------------------
# 2. Add design source files (order matters for elaboration)
# --------------------------------------------------------
set src_dir "$project_dir/${project_name}.srcs/sources_1/new"

set src_files [list \
    [file normalize "$src_dir/alu.v"]              \
    [file normalize "$src_dir/bit_counter.v"]      \
    [file normalize "$src_dir/code_assigner.v"]    \
    [file normalize "$src_dir/control_unit.v"]     \
    [file normalize "$src_dir/frequency_counter.v"]\
    [file normalize "$src_dir/memory_unit.v"]      \
    [file normalize "$src_dir/seg7_display.v"]     \
    [file normalize "$src_dir/shift_register.v"]   \
    [file normalize "$src_dir/top_module.v"]       \
]

add_files -norecurse $src_files
set_property file_type {Verilog} [get_files {*.v}]

# Set the top module explicitly
set_property top top_module [current_fileset]
update_compile_order -fileset sources_1

# --------------------------------------------------------
# 3. Add XDC constraints
# --------------------------------------------------------
set xdc_file [file normalize \
    "$project_dir/${project_name}.srcs/constrs_1/new/basys3.xdc"]

add_files -fileset [get_filesets constrs_1] -norecurse $xdc_file

# --------------------------------------------------------
# 4. Configure synthesis run
# --------------------------------------------------------
set_property strategy            "Vivado Synthesis Defaults" [get_runs synth_1]
set_property part                $part [get_runs synth_1]
set_property constrset           constrs_1 [get_runs synth_1]

# --------------------------------------------------------
# 5. Configure implementation run
# --------------------------------------------------------
set_property strategy "Vivado Implementation Defaults" [get_runs impl_1]
set_property part     $part [get_runs impl_1]
set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

# --------------------------------------------------------
# 6. Save and report
# --------------------------------------------------------
update_compile_order -fileset sources_1

puts ""
puts "============================================================"
puts "  Project '$project_name' is ready."
puts "  Part   : $part"
puts "  Board  : $board_part"
puts "  Top    : top_module"
puts ""
puts "  Next steps in Vivado:"
puts "  1. Run Synthesis : launch_runs synth_1 -wait"
puts "  2. Run Impl      : launch_runs impl_1 -to_step write_bitstream -wait"
puts "  3. Program board : File -> Program Device (connect Basys3 first)"
puts "============================================================"
puts ""
