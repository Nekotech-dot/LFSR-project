module clock_div (
    input wire clk_10mhz,
    input wire rst_n,
    output reg clk_1hz,
    output reg clk_scan
);

localparam DIV_1HZ = 10000000;    // 10M / 10M = 1 Hz
localparam DIV_SCAN = 10000;      // 10M / 10K = 1 kHz

reg [23:0] div_cnt = 0;

always @(posedge clk_10mhz or negedge rst_n) begin
    if (!rst_n) begin
        div_cnt <= 0;
        clk_1hz <= 0;
        clk_scan <= 0;
    end else begin
        div_cnt <= div_cnt + 1;
        
        // 1 Hz pulse
        if (div_cnt == DIV_1HZ - 1) begin
            div_cnt <= 0;
            clk_1hz <= 1;
        end else begin
            clk_1hz <= 0;
        end
        
        // Scan clk pulse every DIV_SCAN cycles
        if (div_cnt % DIV_SCAN == 0) begin
            clk_scan <= 1;
        end else begin
            clk_scan <= 0;
        end
    end
end

endmodule

// ========================================================
// Submodule: clock_div
// Generates shared 1 Hz and scan clk (~1 kHz) from 10 MHz
// ========================================================