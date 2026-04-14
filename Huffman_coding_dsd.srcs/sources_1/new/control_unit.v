module control_unit(
    input clk,
    input reset,
    input valid_in,
    input [7:0] symbol,         // 8-bit ASCII Input
    input [7:0] f0, f1, f2, f3, // 8-bit Frequencies
    input [7:0] mem_dout,       // 8-bit Memory Read
    input alu_lt,
    input zero_flag,
    
    output reg count_enable,
    output reg mem_we,
    output reg [6:0] mem_addr,
    output reg [7:0] mem_din,
    output reg [7:0] alu_a,
    output reg [7:0] alu_b,
    output reg load_enable,
    output reg shift_enable,
    output reg done,
    output [2:0] current_rank
);

    localparam IDLE           = 5'd0;
    localparam COUNT          = 5'd1;
    localparam MEM_INIT_F0    = 5'd2;
    localparam MEM_INIT_F1    = 5'd3;
    localparam MEM_INIT_F2    = 5'd4;
    localparam MEM_INIT_F3    = 5'd5;
    localparam MEM_INIT_C0    = 5'd6;
    localparam MEM_INIT_C1    = 5'd7;
    localparam MEM_INIT_C2    = 5'd8;
    localparam MEM_INIT_C3    = 5'd9;
    localparam SORT_START     = 5'd10;
    localparam SORT_READ_F_J  = 5'd11;
    localparam SORT_READ_F_J1 = 5'd12;
    localparam SORT_CMP_F     = 5'd13;
    localparam SORT_READ_C_J  = 5'd14;
    localparam SORT_READ_C_J1 = 5'd15;
    localparam SORT_SWAP_F_A  = 5'd16;
    localparam SORT_SWAP_F_B  = 5'd17;
    localparam SORT_SWAP_C_A  = 5'd18;
    localparam SORT_SWAP_C_B  = 5'd19;
    localparam SORT_NEXT_J    = 5'd20;
    localparam FETCH_C1       = 5'd21;
    localparam FETCH_C2       = 5'd22;
    localparam FETCH_C3       = 5'd23;
    localparam FETCH_C4       = 5'd24;
    localparam ENCODE_READ    = 5'd25;
    localparam ASSIGN         = 5'd26;
    localparam LOAD           = 5'd27;
    localparam SHIFT          = 5'd28;
    localparam DONE           = 5'd29;

    reg [4:0] state, next_state;
    reg [6:0] input_write_ptr;
    reg [6:0] input_read_ptr;
    reg [2:0] sort_i, sort_j;
    reg [7:0] reg_f_a, reg_f_b;
    reg [7:0] reg_c_a, reg_c_b;
    reg [7:0] rank_sym_1, rank_sym_2, rank_sym_3, rank_sym_4;
    reg [7:0] fetched_symbol;

    always @(*) begin
        // default outputs
        count_enable = 0;
        mem_we = 0;
        mem_addr = 0;
        mem_din = 0;
        alu_a = reg_f_a;
        alu_b = reg_f_b; // Used exclusively for frequency comparing!
        load_enable = 0;
        shift_enable = 0;
        done = 0;
        next_state = state;

        case (state)
            IDLE: begin
                if (valid_in) begin
                    count_enable = 1; mem_we = 1; mem_addr = input_write_ptr; mem_din = symbol; next_state = COUNT;
                end
            end
            COUNT: begin
                count_enable = valid_in;
                if (valid_in) begin
                    mem_we = 1; mem_addr = input_write_ptr; mem_din = symbol;
                end else begin
                    next_state = MEM_INIT_F0;
                end
            end
            
            // Populate exact frequencies to Mem indexes 0-3
            MEM_INIT_F0: begin mem_we = 1; mem_addr = 0; mem_din = f0; next_state = MEM_INIT_F1; end
            MEM_INIT_F1: begin mem_we = 1; mem_addr = 1; mem_din = f1; next_state = MEM_INIT_F2; end
            MEM_INIT_F2: begin mem_we = 1; mem_addr = 2; mem_din = f2; next_state = MEM_INIT_F3; end
            MEM_INIT_F3: begin mem_we = 1; mem_addr = 3; mem_din = f3; next_state = MEM_INIT_C0; end
            
            // Populate exactly corresponding ASCII chars to Mem indexes 4-7
            MEM_INIT_C0: begin mem_we = 1; mem_addr = 4; mem_din = 8'h41; next_state = MEM_INIT_C1; end
            MEM_INIT_C1: begin mem_we = 1; mem_addr = 5; mem_din = 8'h42; next_state = MEM_INIT_C2; end
            MEM_INIT_C2: begin mem_we = 1; mem_addr = 6; mem_din = 8'h43; next_state = MEM_INIT_C3; end
            MEM_INIT_C3: begin mem_we = 1; mem_addr = 7; mem_din = 8'h44; next_state = SORT_START; end

            // Hardware Bubble Sort Sub-Routine
            SORT_START: begin next_state = SORT_READ_F_J; end
            SORT_READ_F_J: begin mem_addr = sort_j; next_state = SORT_READ_F_J1; end
            SORT_READ_F_J1: begin mem_addr = sort_j + 1; next_state = SORT_CMP_F; end
            SORT_CMP_F: begin
                if (alu_lt) next_state = SORT_READ_C_J; // Descending Sort: Swap Needed! Fetch characters.
                else next_state = SORT_NEXT_J; // Stable sort: Ties naturally ignore so Alphabetical remains intact!
            end
            
            // Parallel Fetch and Swap operation mapping the characters!
            SORT_READ_C_J: begin mem_addr = sort_j + 4; next_state = SORT_READ_C_J1; end
            SORT_READ_C_J1: begin mem_addr = sort_j + 5; next_state = SORT_SWAP_F_A; end
            
            SORT_SWAP_F_A: begin mem_we = 1; mem_addr = sort_j; mem_din = reg_f_b; next_state = SORT_SWAP_F_B; end
            SORT_SWAP_F_B: begin mem_we = 1; mem_addr = sort_j + 1; mem_din = reg_f_a; next_state = SORT_SWAP_C_A; end
            SORT_SWAP_C_A: begin mem_we = 1; mem_addr = sort_j + 4; mem_din = reg_c_b; next_state = SORT_SWAP_C_B; end
            SORT_SWAP_C_B: begin mem_we = 1; mem_addr = sort_j + 5; mem_din = reg_c_a; next_state = SORT_NEXT_J; end
            
            SORT_NEXT_J: begin
                if (sort_j + 1 < sort_i) next_state = SORT_READ_F_J;
                else if (sort_i == 1) next_state = FETCH_C1;
                else next_state = SORT_READ_F_J;
            end

            // Reverse Lookup Population using sorted Character Arrays (Addresses 4-7)
            FETCH_C1: begin mem_addr = 4; next_state = FETCH_C2; end
            FETCH_C2: begin mem_addr = 5; next_state = FETCH_C3; end
            FETCH_C3: begin mem_addr = 6; next_state = FETCH_C4; end
            FETCH_C4: begin mem_addr = 7; next_state = ENCODE_READ; end

            // Output Encoding Cycle pulling ASCII straight from pointer
            ENCODE_READ: begin
                if (input_read_ptr == input_write_ptr) next_state = DONE;
                else begin mem_addr = input_read_ptr; next_state = ASSIGN; end
            end
            ASSIGN: begin next_state = LOAD; end
            LOAD: begin load_enable = 1; next_state = SHIFT; end
            SHIFT: begin
                if (zero_flag) next_state = ENCODE_READ;
                else shift_enable = 1;
            end
            DONE: begin done = 1; next_state = IDLE; end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            input_write_ptr <= 7'd8; // Begin inserting at Index 8 (leaving 0-7 exclusively for Sort arrays)
            input_read_ptr <= 7'd8;
            sort_i <= 0;
            sort_j <= 0;
        end else begin
            state <= next_state;

            // Input sequence pointers
            if (state == IDLE && valid_in) input_write_ptr <= input_write_ptr + 1;
            if (state == COUNT && valid_in) input_write_ptr <= input_write_ptr + 1;

            // Sorting Iterators and Data Storage Registers!
            if (state == SORT_START) begin sort_i <= 3; sort_j <= 0; end
            if (state == SORT_READ_F_J) reg_f_a <= mem_dout;
            if (state == SORT_READ_F_J1) reg_f_b <= mem_dout;
            if (state == SORT_READ_C_J) reg_c_a <= mem_dout;
            if (state == SORT_READ_C_J1) reg_c_b <= mem_dout;
            
            if (state == SORT_NEXT_J) begin
                if (sort_j + 1 < sort_i) sort_j <= sort_j + 1;
                else begin sort_j <= 0; sort_i <= sort_i - 1; end
            end

            // Storing the results into comb table natively parsing 8-bits!
            if (state == FETCH_C1) rank_sym_1 <= mem_dout; 
            if (state == FETCH_C2) rank_sym_2 <= mem_dout;
            if (state == FETCH_C3) rank_sym_3 <= mem_dout;
            if (state == FETCH_C4) rank_sym_4 <= mem_dout;

            if (state == ENCODE_READ) fetched_symbol <= mem_dout;
            if (state == LOAD) input_read_ptr <= input_read_ptr + 1;
        end
    end

    // Reverse lookup comparing the 8-bit ASCII exactly to return 3-bit assigned rank
    assign current_rank = (fetched_symbol == rank_sym_1) ? 3'd1 :
                          (fetched_symbol == rank_sym_2) ? 3'd2 :
                          (fetched_symbol == rank_sym_3) ? 3'd3 : 3'd4;

endmodule
