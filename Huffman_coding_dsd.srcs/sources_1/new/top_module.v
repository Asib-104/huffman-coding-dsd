// ============================================================
// Huffman Coding Hardware - Top Module
// Target: Basys3 (Artix-7 XC7A35T-1CPG236)
//
// HOW TO USE:
//   1. Press BTNC to reset the board
//   2. Set SW7:SW0 to ASCII value of first symbol
//      A=01000001, B=01000010, C=01000011, D=01000100
//   3. Press BTNL once to register that symbol
//   4. Change switches to next symbol, press BTNL again
//   5. Repeat steps 3-4 for every symbol in your input
//   6. When all symbols are entered, press BTNR to start encoding
//   7. Watch LED0 (serial_out) blink the Huffman bits, MSB first
//   8. LED15 (done) goes HIGH when encoding is complete
//
// I/O Mapping:
//   clk        -> W5   (100MHz onboard oscillator)
//   reset      -> U18  (BTNC - Center)
//   valid      -> W19  (BTNL - Left,  press once per symbol)
//   encode     -> T17  (BTNR - Right, press to start encoding)
//   symbol     -> SW7:SW0 (set to 8-bit ASCII of symbol)
//   serial_out -> U16  (LED0)
//   done       -> L1   (LED15)
// ============================================================

module top_module(
    input clk,
    input reset,
    input valid,          // BTNL: press once per symbol to register it
    input encode,         // BTNR: press once when done entering symbols
    input [7:0] symbol,   // SW7:SW0 = 8-bit ASCII of current symbol
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

    // -------------------------------------------------------
    // BTNL: 3-stage synchronizer + rising-edge detector
    // One clock-cycle pulse per button press (registers 1 symbol)
    // -------------------------------------------------------
    reg valid_s1, valid_s2, valid_s3;
    always @(posedge clk or posedge reset) begin
        if (reset) begin valid_s1 <= 0; valid_s2 <= 0; valid_s3 <= 0; end
        else       begin valid_s1 <= valid; valid_s2 <= valid_s1; valid_s3 <= valid_s2; end
    end
    wire valid_pulse = valid_s2 & ~valid_s3;   // rising edge only

    // -------------------------------------------------------
    // BTNR: 3-stage synchronizer + rising-edge detector
    // One clock-cycle pulse when user presses "start encoding"
    // -------------------------------------------------------
    reg enc_s1, enc_s2, enc_s3;
    always @(posedge clk or posedge reset) begin
        if (reset) begin enc_s1 <= 0; enc_s2 <= 0; enc_s3 <= 0; end
        else       begin enc_s1 <= encode; enc_s2 <= enc_s1; enc_s3 <= enc_s2; end
    end
    wire encode_pulse = enc_s2 & ~enc_s3;      // rising edge only

    // -------------------------------------------------------
    // Module instantiations
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

endmodule
