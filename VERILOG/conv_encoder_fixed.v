module conv_encoder_fixed (
    input wire clk,
    input wire rst,
    input wire in_bit,
    output wire out0,
    output wire out1
);
    reg [6:0] state;
    always @(posedge clk or posedge rst) begin
        if (rst) state <= 7'b0;
        else state <= {state[5:0], in_bit};
    end
    // G1 = 133 octal = 1 + D^2 + D^3 + D^5 + D^6
    // G2 = 171 octal = 1 + D^1 + D^2 + D^3 + D^6
    assign out0 = state[6] ^ state[4] ^ state[3] ^ state[1] ^ state[0];
    assign out1 = state[6] ^ state[5] ^ state[4] ^ state[3] ^ state[0];
endmodule