// ============================================================
// 7-Segment Display Controller — Huffman Encoder (Basys3)
//
// Display layout (4-digit common-anode display):
//
//   [AN3]     [AN2]  [AN1]  [AN0]
//   Symbol    code   code   code
//    A/b/C/d  MSB   MID    LSB
//
//   Example encoding A → rank1 → code '0':
//     AN3='A'  AN2='-'  AN1='-'  AN0='0'
//
//   Example encoding B → rank2 → code '10':
//     AN3='b'  AN2='-'  AN1='1'  AN0='0'
//
//   Example encoding C → rank3 → code '110':
//     AN3='C'  AN2='1'  AN1='1'  AN0='0'
//
// Segment encoding: seg[6:0] = {CG,CF,CE,CD,CC,CB,CA}
//                              = { g, f, e, d, c, b, a}
// Active LOW (0 = segment ON), common-anode (an: 0 = digit ON)
// ============================================================

module seg7_display(
    input        clk,
    input        reset,
    // Symbol input side
    input        valid_pulse,   // 1-cycle HIGH when a symbol is registered (BTNL)
    input  [7:0] symbol,        // 8-bit ASCII of the registered symbol
    // Huffman code output side
    input        load_pulse,    // 1-cycle HIGH at LOAD state (code ready for output)
    input  [2:0] huff_code,     // 3-bit Huffman code, MSB-first (from code_assigner)
    input  [1:0] huff_len,      // Code length in bits: 1, 2, or 3
    // 7-segment display pins
    output reg [6:0] seg,       // Cathodes {g,f,e,d,c,b,a}, active LOW
    output reg [3:0] an         // Digit anodes, active LOW (0 = digit enabled)
);

    // ---------------------------------------------------------
    // Segment pattern constants (0=ON, common anode)
    //  seg [6:0] = {g,f,e,d,c,b,a}
    // ---------------------------------------------------------
    //      Segments ON:               Pattern
    localparam SEG_0     = 7'b1000000; // a,b,c,d,e,f   → digit 0
    localparam SEG_1     = 7'b1111001; // b,c            → digit 1
    localparam SEG_A     = 7'b0001000; // a,b,c,e,f,g    → Letter A
    localparam SEG_b     = 7'b0000011; // c,d,e,f,g      → Letter b (lowercase)
    localparam SEG_C     = 7'b1000110; // a,d,e,f        → Letter C
    localparam SEG_d     = 7'b0100001; // b,c,d,e,g      → Letter d (lowercase)
    localparam SEG_DASH  = 7'b0111111; // g only         → Dash -
    localparam SEG_BLANK = 7'b1111111; // all OFF        → blank

    // ---------------------------------------------------------
    // Refresh counter — drives 4-digit time-multiplexing
    // 100 MHz / 2^17 = ~763 Hz full cycle → ~191 Hz per digit (no flicker)
    // ---------------------------------------------------------
    reg [16:0] refresh_cnt;
    always @(posedge clk or posedge reset)
        if (reset) refresh_cnt <= 0;
        else       refresh_cnt <= refresh_cnt + 1;

    wire [1:0] digit_sel = refresh_cnt[16:15];

    // ---------------------------------------------------------
    // Latch the last registered input symbol
    // ---------------------------------------------------------
    reg [7:0] last_sym;
    always @(posedge clk or posedge reset) begin
        if (reset)            last_sym <= 8'h00;
        else if (valid_pulse) last_sym <= symbol;
    end

    // ---------------------------------------------------------
    // Latch the last Huffman code (updated on each LOAD pulse)
    // ---------------------------------------------------------
    reg [2:0] lat_code;
    reg [1:0] lat_len;
    reg       code_valid;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lat_code   <= 3'b000;
            lat_len    <= 2'b00;
            code_valid <= 1'b0;
        end else if (load_pulse) begin
            lat_code   <= huff_code;
            lat_len    <= huff_len;
            code_valid <= 1'b1;
        end
    end

    // ---------------------------------------------------------
    // AN3 pattern — input symbol
    // ---------------------------------------------------------
    reg [6:0] sym_pat;
    always @(*) begin
        case (last_sym)
            8'h41:   sym_pat = SEG_A;
            8'h42:   sym_pat = SEG_b;
            8'h43:   sym_pat = SEG_C;
            8'h44:   sym_pat = SEG_d;
            default: sym_pat = SEG_DASH;  // nothing entered yet
        endcase
    end

    // ---------------------------------------------------------
    // AN2 / AN1 / AN0 patterns — Huffman code bits
    //
    //  lat_len=1  (code '0'):    AN2='-'        AN1='-'        AN0=bit2
    //  lat_len=2  (code '10'):   AN2='-'        AN1=bit2       AN0=bit1
    //  lat_len=3  (code '110'):  AN2=bit2       AN1=bit1       AN0=bit0
    // ---------------------------------------------------------
    reg [6:0] an2_pat, an1_pat, an0_pat;
    always @(*) begin
        if (!code_valid) begin
            an2_pat = SEG_BLANK;
            an1_pat = SEG_BLANK;
            an0_pat = SEG_BLANK;
        end else begin
            case (lat_len)
                2'd1: begin
                    an2_pat = SEG_DASH;
                    an1_pat = SEG_DASH;
                    an0_pat = lat_code[2] ? SEG_1 : SEG_0;
                end
                2'd2: begin
                    an2_pat = SEG_DASH;
                    an1_pat = lat_code[2] ? SEG_1 : SEG_0;
                    an0_pat = lat_code[1] ? SEG_1 : SEG_0;
                end
                2'd3: begin
                    an2_pat = lat_code[2] ? SEG_1 : SEG_0;
                    an1_pat = lat_code[1] ? SEG_1 : SEG_0;
                    an0_pat = lat_code[0] ? SEG_1 : SEG_0;
                end
                default: begin
                    an2_pat = SEG_BLANK;
                    an1_pat = SEG_BLANK;
                    an0_pat = SEG_BLANK;
                end
            endcase
        end
    end

    // ---------------------------------------------------------
    // Time-multiplexed output
    // ---------------------------------------------------------
    always @(*) begin
        case (digit_sel)
            2'b00: begin an = 4'b1110; seg = an0_pat; end  // AN0 rightmost: code LSB
            2'b01: begin an = 4'b1101; seg = an1_pat; end  // AN1: code middle
            2'b10: begin an = 4'b1011; seg = an2_pat; end  // AN2: code MSB
            2'b11: begin an = 4'b0111; seg = sym_pat; end  // AN3 leftmost: symbol
        endcase
    end

endmodule
