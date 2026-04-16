module chaos_gen (
    input wire clk,
    input wire rst,
    input wire en,
    output wire [7:0] chaos_out,   // changed from reg to wire
    output wire [1:0] sel_bits     // changed from reg to wire
);
    reg [15:0] x;
    parameter R = 16'd1022;  // 3.99 * 256 = 1022

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x <= 16'd77;     // seed = 0.3001 * 256
        end else if (en) begin
            x <= (R * x * (256 - x[15:8])) >> 16;
        end
    end

    assign chaos_out = x[15:8];
    assign sel_bits = chaos_out[7:6];
endmodule