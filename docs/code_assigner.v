module code_assigner(
    input [2:0] rank,
    output reg [2:0] code,
    output reg [1:0] length
);

    // Codes shift starting from MSB.
    always @(*) begin
        case (rank)
            3'd1: begin code = 3'b000; length = 2'd1; end // '0'
            3'd2: begin code = 3'b100; length = 2'd2; end // '10'
            3'd3: begin code = 3'b110; length = 2'd3; end // '110'
            3'd4: begin code = 3'b111; length = 2'd3; end // '111'
            default: begin code = 3'b000; length = 2'd0; end
        endcase
    end

endmodule
