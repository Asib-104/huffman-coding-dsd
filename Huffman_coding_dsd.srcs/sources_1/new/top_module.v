// ============================================================
// Huffman Coding Hardware — Top Module
// Target : Basys3 (Artix-7 XC7A35T-1CPG236)
//
// HOW TO USE:
//   1. Press BTNC  → reset the board
//   2. Set SW7:SW0 → ASCII value of symbol to enter
//         A = 01000001  B = 01000010  C = 01000011  D = 01000100
//   3. Press BTNL  → registers that symbol (AN3 shows symbol letter)
//   4. Repeat steps 2-3 for each symbol in your input string
//   5. Press BTNR  → starts Huffman encoding
//   6. 7-segment shows the Huffman code of the last encoded symbol:
//         AN3 = symbol  (A / b / C / d)
//         AN2 = code MSB  (1 / 0 / -)
//         AN1 = code MID  (1 / 0 / -)
//         AN0 = code LSB  (1 / 0 / -)
//   7. LED15 goes HIGH when encoding is complete
//
// Pin assignments:
//   clk    → W5   (100 MHz oscillator)
//   reset  → U18  (BTNC – Center)
//   valid  → W19  (BTNL – Left,  press once per symbol)
//   encode → T17  (BTNR – Right, press to start encoding)
//   symbol → SW7:SW0
//   seg    → W7,W6,U8,V8,U5,V5,U7  (7-seg cathodes)
//   an     → U2,U4,V4,W4           (7-seg anodes)
//   done   → L1 (LED15)
// ============================================================

module top_module(
    input        clk,
    input        reset,
    input        valid,        // BTNL — press once per symbol to register it
    input        encode,       // BTNR — press once to start encoding
    input  [7:0] symbol,       // SW7:SW0 — 8-bit ASCII of current symbol
    output       done,
    output [6:0] seg,          // 7-segment cathodes {CG,CF,CE,CD,CC,CB,CA} active LOW
    output [3:0] an            // 7-segment anodes, active LOW
);

    wire count_enable, mem_we, load_enable, shift_enable;
    wire zero_flag, alu_lt, alu_gt, alu_eq;
    wire [6:0] mem_addr;
    wire [7:0] mem_din, mem_dout, alu_a, alu_b;
    wire [7:0] f0, f1, f2, f3;
    wire [2:0] huff_code, current_rank;
    wire [1:0] huff_len;
    wire       serial_out;     // internal only — fed to seg7_display indirectly

    // -------------------------------------------------------
    // BTNL: 3-stage synchronizer + rising-edge detector
    // Converts button press → exactly 1 clock-cycle pulse
    // -------------------------------------------------------
    reg vs1, vs2, vs3;
    always @(posedge clk or posedge reset) begin
        if (reset) begin vs1 <= 0; vs2 <= 0; vs3 <= 0; end
        else       begin vs1 <= valid;  vs2 <= vs1; vs3 <= vs2; end
    end
    wire valid_pulse  = vs2 & ~vs3;

    // -------------------------------------------------------
    // BTNR: 3-stage synchronizer + rising-edge detector
    // -------------------------------------------------------
    reg es1, es2, es3;
    always @(posedge clk or posedge reset) begin
        if (reset) begin es1 <= 0; es2 <= 0; es3 <= 0; end
        else       begin es1 <= encode; es2 <= es1; es3 <= es2; end
    end
    wire encode_pulse = es2 & ~es3;

    // -------------------------------------------------------
    // Core modules
    // -------------------------------------------------------
    control_unit cu (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_pulse),
        .encode_start(encode_pulse),
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

    // -------------------------------------------------------
    // 7-Segment Display Controller
    // AN3 = last registered symbol letter
    // AN2-AN0 = Huffman code bits, latched at LOAD state
    // -------------------------------------------------------
    seg7_display disp (
        .clk(clk),
        .reset(reset),
        .valid_pulse(valid_pulse),
        .symbol(symbol),
        .load_pulse(load_enable),
        .huff_code(huff_code),
        .huff_len(huff_len),
        .done(done),
        .seg(seg),
        .an(an)
    );

endmodule
