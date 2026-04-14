module shift_register(
    input clk,
    input load,
    input shift_enable,
    input [2:0] data_in,
    input [1:0] length,
    output serial_out
);

    reg [2:0] shift_reg;

    always @(posedge clk) begin
        if (load) begin
            shift_reg <= data_in;
        end else if (shift_enable) begin
            shift_reg <= {shift_reg[1:0], 1'b0}; // Shift left
        end
    end

    // Use combinational assignment so the MSB immediately shows up on the wire!
    assign serial_out = shift_reg[2];

endmodule
