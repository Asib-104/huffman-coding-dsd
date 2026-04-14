module bit_counter(
    input clk,
    input load,
    input [1:0] length,
    output zero_flag
);

    reg [1:0] count;

    always @(posedge clk) begin
        if (load) begin
            count <= length;
        end else if (count > 0) begin
            count <= count - 1'b1;
        end
    end

    assign zero_flag = (count == 0);

endmodule
