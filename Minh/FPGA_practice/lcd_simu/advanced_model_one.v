module advanced_model_one
#(
    parameter [3:0] C0 = 4'h1,
    parameter [3:0] C1 = 4'h0,
    parameter [3:0] C2 = 4'h1,
    parameter [3:0] C3 = 4'h4,
    parameter [3:0] RED_POLY = 4'b0011
)
(
    input wire clk,
    input wire rst_n,
    input wire en,
    input wire load,
    input wire [15:0] seed,
    output reg  [15:0] state,
    output wire [7:0]  B          // now registered (matches simulation)
);

    // ====================== GF(16) multiplier ======================
    function [3:0] gf16_mul;
        input [3:0] a, b;
        reg [3:0] aa, bb, res;
        integer i;
        begin
            aa = a; bb = b; res = 0;
            for (i = 0; i < 4; i = i + 1) begin
                if (bb[0]) res = res ^ aa;
                if (aa[3]) aa = ((aa << 1) & 4'hF) ^ RED_POLY;
                else       aa = (aa << 1) & 4'hF;
                bb = bb >> 1;
            end
            gf16_mul = res;
        end
    endfunction

    // ====================== Next state ======================
    wire [3:0] tap = state[3:0];
    wire [15:0] next_state = {
        gf16_mul(tap, C3),
        state[15:12] ^ gf16_mul(tap, C2),
        state[11: 8] ^ gf16_mul(tap, C1),
        state[ 7: 4] ^ gf16_mul(tap, C0)
    };

    // ====================== Slices (exactly like your Python) ======================
    wire [3:0] symbol0 = state[ 3: 0];
    wire [3:0] symbol1 = state[ 7: 4];
    wire [3:0] symbol2 = state[11: 8];
    wire [3:0] symbol3 = state[15:12];

    wire [3:0] slice0 = {symbol3[0], symbol2[0], symbol1[0], symbol0[0]};
    wire [3:0] slice1 = {symbol3[1], symbol2[1], symbol1[1], symbol0[1]};
    wire [3:0] slice2 = {symbol3[2], symbol2[2], symbol1[2], symbol0[2]};
    wire [3:0] slice3 = {symbol3[3], symbol2[3], symbol1[3], symbol0[3]};

    // ====================== REGISTERED B (this fixes the mismatch) ======================
    reg [7:0] B_reg;
    assign B = B_reg;

    always @(posedge clk) begin
        if (!rst_n)
            B_reg <= 8'd0;
        else
            B_reg <= slice0 + slice1 + slice2 + slice3;
    end

    // ====================== State update ======================
    always @(posedge clk) begin
        if (!rst_n)
            state <= 16'h0001;
        else if (load)
            state <= seed;
        else if (en)
            state <= next_state;
    end

endmodule