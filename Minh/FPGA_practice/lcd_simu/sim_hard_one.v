// ========================================================
// Top Module: sim_hard_one (fixed version)
// Key change: LFSR advances only once per second
// ========================================================
module sim_hard_one (
    input wire clk_10mhz,
    input wire rst_n,
   
    // 7-Segment Outputs
    output wire [7:0] seg,
    output wire [2:0] de,
   
    // LCD Outputs
    output wire lcd_en,
    output wire lcd_rs,
    output wire lcd_rw,
    output wire [7:0] lcd_data,
   
    // UART Output
    output wire uart_tx_pin
);

    // Clock signals from divider
    wire clk_1hz;
    wire clk_scan;

    // ────────────────────────────────────────────────
    // Slow enable pulse for LFSR (once per second)
    // ────────────────────────────────────────────────
    reg lfsr_en_pulse = 0;

    // We need the counter from clock_div to create a pulse
    // Option 1: Modify clock_div to output the terminal count
    // Option 2: Replicate a similar counter here (simpler for now)
    reg [23:0] slow_cnt = 0;

    always @(posedge clk_10mhz or negedge rst_n) begin
        if (!rst_n) begin
            slow_cnt      <= 24'd0;
            lfsr_en_pulse <= 1'b0;
        end else begin
            lfsr_en_pulse <= 1'b0;
            if (slow_cnt == 24'd9999999) begin   // 10M counts = 1 second
                slow_cnt      <= 24'd0;
                lfsr_en_pulse <= 1'b1;           // single-cycle pulse
            end else begin
                slow_cnt <= slow_cnt + 1;
            end
        end
    end

    // LFSR output
    wire [15:0] lfsr_state_new;
    wire [7:0]  B_decimal;

    // ────────────────────────────────────────────────
    // LFSR instance – now advances only once per second
    // ────────────────────────────────────────────────
    advanced_model_one new_lfsr_inst (
        .clk    (clk_10mhz),
        .rst_n  (rst_n),
        .en     (lfsr_en_pulse),      // ← FIXED: pulse once per second
        .load   (1'b0),
        .seed   (16'h0001),
        .state  (lfsr_state_new),
        .B      (B_decimal)
    );

    // Clock divider (for clk_1hz and clk_scan)
    clock_div clk_div_inst (
        .clk_10mhz (clk_10mhz),
        .rst_n     (rst_n),
        .clk_1hz   (clk_1hz),
        .clk_scan  (clk_scan)
    );

    // 7-segment display
    seven_seg seg_inst (
        .clk_10mhz (clk_10mhz),
        .clk_1hz   (clk_1hz),
        .clk_scan  (clk_scan),
        .rst_n     (rst_n),
        .B         (B_decimal),
        .seg       (seg),
        .de        (de)
    );

    // LCD display – now receives slowly changing B
    lcd_display lcd_inst (
        .clk_10mhz (clk_10mhz),
        .clk_1hz   (clk_1hz),
        .rst_n     (rst_n),
        .B         (B_decimal),
        .lcd_en    (lcd_en),
        .lcd_rs    (lcd_rs),
        .lcd_rw    (lcd_rw),
        .lcd_data  (lcd_data)
    );

    // UART – sends current B every second
    uart_tx uart_inst (
        .clk_10mhz    (clk_10mhz),
        .rst_n        (rst_n),
        .send_trigger (clk_1hz),
        .count        (B_decimal),
        .uart_tx      (uart_tx_pin)
    );

endmodule