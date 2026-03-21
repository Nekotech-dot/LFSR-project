// ========================================================
// Submodule: seven_seg — FIFO push from LEFT to RIGHT
// New B enters leftmost digit, old digits shift right
// ========================================================
module seven_seg (
    input wire clk_10mhz,
    input wire clk_1hz,
    input wire clk_scan,
    input wire rst_n,
    input wire [7:0] B,           // ← from advanced_model_one
    output reg [7:0] seg,
    output reg [2:0] de
);

reg [23:0] digit_history = 24'h000000; // 6 digits (4-bit each)

// FIFO shift: new B enters LEFT, everything shifts RIGHT every 1 Hz
always @(posedge clk_10mhz or negedge rst_n) begin
    if (!rst_n) begin
        digit_history <= 24'h000000;
    end else if (clk_1hz) begin
        digit_history <= { (B % 10), digit_history[23:4] };  // new digit on left
    end
end

// Extract digits (0 = leftmost = newest)
wire [3:0] digits [5:0];
assign digits[0] = digit_history[23:20]; // newest
assign digits[1] = digit_history[19:16];
assign digits[2] = digit_history[15:12];
assign digits[3] = digit_history[11:8];
assign digits[4] = digit_history[7:4];
assign digits[5] = digit_history[3:0];   // oldest

// Multiplexing (scan from left to right)
reg [3:0] current_digit;
always @(*) begin
    current_digit = digits[scan_cnt];
    de = scan_cnt;                     // digit enable

    case (current_digit)
        4'd0: seg[6:0] = 7'b0111111;
        4'd1: seg[6:0] = 7'b0000110;
        4'd2: seg[6:0] = 7'b1011011;
        4'd3: seg[6:0] = 7'b1001111;
        4'd4: seg[6:0] = 7'b1100110;
        4'd5: seg[6:0] = 7'b1101101;
        4'd6: seg[6:0] = 7'b1111101;
        4'd7: seg[6:0] = 7'b0000111;
        4'd8: seg[6:0] = 7'b1111111;
        4'd9: seg[6:0] = 7'b1101111;
        default: seg[6:0] = 7'b0000000;
    endcase
    seg[7] = 1; // DP off
end

// Scan counter (unchanged)
reg [2:0] scan_cnt = 0;
always @(posedge clk_10mhz or negedge rst_n) begin
    if (!rst_n) begin
        scan_cnt <= 0;
    end else if (clk_scan) begin
        scan_cnt <= (scan_cnt == 5) ? 0 : scan_cnt + 1;
    end
end

endmodule