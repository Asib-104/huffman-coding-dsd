module frequency_counter(
    input clk,
    input reset,
    input valid,
    input [7:0] symbol,
    output reg [7:0] f0,
    output reg [7:0] f1,
    output reg [7:0] f2,
    output reg [7:0] f3
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            f0 <= 0; f1 <= 0; f2 <= 0; f3 <= 0;
        end else if (valid) begin
            if (symbol == 8'h41) f0 <= f0 + 1'b1;      // 'A'
            else if (symbol == 8'h42) f1 <= f1 + 1'b1; // 'B'
            else if (symbol == 8'h43) f2 <= f2 + 1'b1; // 'C'
            else if (symbol == 8'h44) f3 <= f3 + 1'b1; // 'D'
        end
    end
endmodule
