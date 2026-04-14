// ============================================================
// Huffman Coding Hardware - Top Module
// Target: Basys3 (Artix-7 XC7A35T-1CPG236)
//
// I/O Mapping:
//   clk       -> W5  (100MHz onboard oscillator)
//   reset     -> U18 (BTNC - Center button)
//   valid     -> W19 (BTNL - Left button, press once per symbol)
//   symbol    -> SW7:SW0 (Set switches to 8-bit ASCII value)
//               'A'=0x41, 'B'=0x42, 'C'=0x43, 'D'=0x44
//   serial_out-> U16 (LED0  - observe Huffman bitstream LSB)
//   done      -> L1  (LED15 - HIGH when encoding complete)
// ============================================================

module top_module(
    input clk,
    input reset,
    input valid,
    input [7:0] symbol,  // 8-bit ASCII input via switches
    output serial_out,
    output done
);

    wire count_enable, mem_we, load_enable, shift_enable;
    wire zero_flag, alu_lt, alu_gt, alu_eq;
    wire [6:0] mem_addr;
    wire [7:0] mem_din, mem_dout, alu_a, alu_b;
    wire [7:0] f0, f1, f2, f3;
    wire [2:0] huff_code, current_rank;
    wire [1:0] huff_len;

    // Button synchronizer + single-pulse edge detector
    // Prevents metastability and ensures 1 clock-cycle valid pulse per press
    reg valid_s1, valid_s2, valid_s3;
    wire valid_pulse;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            valid_s1 <= 0; valid_s2 <= 0; valid_s3 <= 0;
        end else begin
            valid_s1 <= valid;
            valid_s2 <= valid_s1;
            valid_s3 <= valid_s2;
        end
    end
    // Rising edge = first cycle button is seen as HIGH
    assign valid_pulse = valid_s2 & ~valid_s3;

    control_unit cu (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_pulse),
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
