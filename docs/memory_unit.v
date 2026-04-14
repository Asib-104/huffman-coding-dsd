module memory_unit(
    input clk,
    input write_en,
    input [6:0] addr,
    input [7:0] data_in,
    output [7:0] data_out
);
    reg [7:0] mem [0:127];

    always @(posedge clk) begin
        if (write_en) begin
            mem[addr] <= data_in;
        end
    end

    // Asynchronous read so the FSM can capture it swiftly
    assign data_out = mem[addr];

endmodule
