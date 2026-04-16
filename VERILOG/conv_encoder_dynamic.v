module conv_encoder_dynamic (
    input wire clk,
    input wire rst,
    input wire in_bit,
    input wire [1:0] sel,
    output wire out0,
    output wire out1
);
    reg [6:0] state;
    always @(posedge clk or posedge rst) begin
        if (rst) state <= 7'b0;
        else state <= {state[5:0], in_bit};
    end

    wire [6:0] mask0, mask1;
    assign mask0 = (sel == 2'd0) ? 7'b1011011 :  // 133
                   (sel == 2'd1) ? 7'b1101011 :  // 135
                   (sel == 2'd2) ? 7'b1010111 :  // 151
                                   7'b1110011;   // 163
    assign mask1 = (sel == 2'd0) ? 7'b1001111 :  // 171
                   (sel == 2'd1) ? 7'b1011011 :  // 173
                   (sel == 2'd2) ? 7'b1111111 :  // 177
                                   7'b1001111;   // 171

    assign out0 = ^(state & mask0);
    assign out1 = ^(state & mask1);
endmodule