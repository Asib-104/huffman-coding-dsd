`include "frequency_counter.v"
`include "code_assigner.v"
`include "shift_register.v"
`include "bit_counter.v"
`include "control_unit.v"
`include "memory_unit.v"
`include "alu.v"

module top_module(
    input clk,
    input reset,
    input valid,
    input [7:0] symbol,  // Symbol is now officially 8-bit ASCII.
    output serial_out,
    output done
);

    wire count_enable, mem_we, load_enable, shift_enable;
    wire zero_flag, alu_lt, alu_gt, alu_eq;
    wire [6:0] mem_addr;
    wire [7:0] mem_din, mem_dout, alu_a, alu_b; // Pure 8-bit Datapath connections
    wire [7:0] f0, f1, f2, f3; // Pure 8-bit frequencies!
    wire [2:0] huff_code, current_rank;
    wire [1:0] huff_len;

    control_unit cu (
        .clk(clk),
        .reset(reset),
        .valid_in(valid),
        .symbol(symbol),
        .f0(f0), .f1(f1), .f2(f2), .f3(f3),
        .mem_dout(mem_dout),
        .alu_lt(alu_lt),
        .zero_flag(zero_flag),
        .count_enable(count_enable),
        .mem_we(mem_we),
        .mem_addr(mem_addr),
        .mem_din(mem_din),
        .alu_a(alu_a),
        .alu_b(alu_b),
        .load_enable(load_enable),
        .shift_enable(shift_enable),
        .done(done),
        .current_rank(current_rank)
    );

    memory_unit mem_block (
        .clk(clk),
        .write_en(mem_we),
        .addr(mem_addr),
        .data_in(mem_din),
        .data_out(mem_dout)
    );
    
    alu sorting_alu (
        .a(alu_a),
        .b(alu_b),
        .a_eq_b(alu_eq),
        .a_gt_b(alu_gt),
        .a_lt_b(alu_lt)
    );

    frequency_counter fc (
        .clk(clk),
        .reset(reset),
        .valid(count_enable),
        .symbol(symbol),
        .f0(f0), .f1(f1), .f2(f2), .f3(f3)
    );

    code_assigner ca (
        .rank(current_rank),
        .code(huff_code),
        .length(huff_len)
    );

    bit_counter bc (
        .clk(clk),
        .load(load_enable),
        .length(huff_len),
        .zero_flag(zero_flag)
    );

    shift_register sr (
        .clk(clk),
        .load(load_enable),
        .shift_enable(shift_enable),
        .data_in(huff_code),
        .length(huff_len),
        .serial_out(serial_out)
    );

endmodule
