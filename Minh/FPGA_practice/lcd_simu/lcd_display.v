module lcd_display (
    input wire clk_10mhz,
    input wire clk_1hz,
    input wire rst_n,
    input wire [7:0] B,
    output reg lcd_en,
    output reg lcd_rs,
    output reg lcd_rw,
    output reg [7:0] lcd_data
);

    localparam LCD_DELAY_US = 50;
    localparam CLK_FREQ     = 10000000;
    localparam DELAY_CNT    = (LCD_DELAY_US * CLK_FREQ) / 1000000;

    localparam S_INIT_POWER   = 0;
    localparam S_INIT_FUNC    = 1;
    localparam S_INIT_ENTRY   = 2;
    localparam S_INIT_DISPLAY = 3;
    localparam S_CLEAR        = 4;
    localparam S_SET_ADDR     = 5;
    localparam S_WRITE_LINE1  = 6;
    localparam S_WRITE_LINE2  = 7;
    localparam S_IDLE         = 8;

    reg [3:0]  state      = S_INIT_POWER;
    reg [7:0]  char_index = 0;
    reg [15:0] delay_cnt  = 0;

    // ────────────────────────────────────────────────
    // History of last 4 B values (updated every 1 Hz)
    // ────────────────────────────────────────────────
    reg [7:0] b3, b2, b1, b0;  // b3 = oldest, b0 = newest
    always @(posedge clk_1hz or negedge rst_n) begin
        if (!rst_n) begin
            b3 <= 8'd0; b2 <= 8'd0; b1 <= 8'd0; b0 <= 8'd0;
        end else begin
            b3 <= b2;
            b2 <= b1;
            b1 <= b0;
            b0 <= B;
        end
    end

    // ────────────────────────────────────────────────
    // Cycle counter (increments every time a new 4-tuple is unique)
    // ────────────────────────────────────────────────
    reg [15:0] cycle = 0;
    reg        repeat_detected = 0;
    reg [7:0]  pattern_history [0:31][0:3];  // 32 patterns × 4 bytes
    reg [4:0]  pattern_ptr = 0;
    reg        match;

    integer i;
    always @(posedge clk_1hz or negedge rst_n) begin
        if (!rst_n) begin
            cycle           <= 16'd0;
            pattern_ptr     <= 5'd0;
            repeat_detected <= 1'b0;
            for (i = 0; i < 32; i = i + 1) begin
                pattern_history[i][0] <= 8'hFF;
                pattern_history[i][1] <= 8'hFF;
                pattern_history[i][2] <= 8'hFF;
                pattern_history[i][3] <= 8'hFF;
            end
        end
        else if (!repeat_detected) begin
            match = 1'b0;
            for (i = 0; i < 32; i = i + 1) begin
                if (pattern_history[i][0] == b3 &&
                    pattern_history[i][1] == b2 &&
                    pattern_history[i][2] == b1 &&
                    pattern_history[i][3] == b0) begin
                    match = 1'b1;
                end
            end

            if (match) begin
                repeat_detected <= 1'b1;
            end else begin
                pattern_history[pattern_ptr][0] <= b3;
                pattern_history[pattern_ptr][1] <= b2;
                pattern_history[pattern_ptr][2] <= b1;
                pattern_history[pattern_ptr][3] <= b0;
                pattern_ptr <= (pattern_ptr == 31) ? 0 : pattern_ptr + 1;
                cycle <= cycle + 1;
            end
        end
    end

    // ────────────────────────────────────────────────
    // Display content (32 characters = 16 + 16)
    // ────────────────────────────────────────────────
    wire [7:0] str [0:31];

    // Line 1: "B=  xx  xx  xx  xx"   (right-aligned 3-char fields)
    assign str[0] = "B"; assign str[1] = "="; assign str[2] = " ";

    // b3 (oldest)
    assign str[3]  = (b3 >= 100) ? (b3 / 100 + "0") : " ";
    assign str[4]  = (b3 >=  10) ? (b3 /  10 % 10 + "0") : " ";
    assign str[5]  = b3 % 10 + "0";

    // b2
    assign str[6]  = (b2 >= 100) ? (b2 / 100 + "0") : " ";
    assign str[7]  = (b2 >=  10) ? (b2 /  10 % 10 + "0") : " ";
    assign str[8]  = b2 % 10 + "0";

    // b1
    assign str[9]  = (b1 >= 100) ? (b1 / 100 + "0") : " ";
    assign str[10] = (b1 >=  10) ? (b1 /  10 % 10 + "0") : " ";
    assign str[11] = b1 % 10 + "0";

    // b0 (newest)
    assign str[12] = (b0 >= 100) ? (b0 / 100 + "0") : " ";
    assign str[13] = (b0 >=  10) ? (b0 /  10 % 10 + "0") : " ";
    assign str[14] = b0 % 10 + "0";

    assign str[15] = " ";

    // Line 2: "CYCLE=xxxx" with leading zeros
    assign str[16] = "C"; assign str[17] = "Y"; assign str[18] = "C"; assign str[19] = "L";
    assign str[20] = "E"; assign str[21] = "=";
    assign str[22] = (cycle / 1000 % 10) + "0";
    assign str[23] = (cycle /  100 % 10) + "0";
    assign str[24] = (cycle /   10 % 10) + "0";
    assign str[25] = (cycle        % 10) + "0";
    assign str[26] = " "; assign str[27] = " "; assign str[28] = " ";
    assign str[29] = " "; assign str[30] = " "; assign str[31] = " ";

    // ────────────────────────────────────────────────
    // LCD FSM (unchanged except small delay tuning)
    // ────────────────────────────────────────────────
    always @(posedge clk_10mhz or negedge rst_n) begin
        if (!rst_n) begin
            lcd_en     <= 1'b0;
            lcd_rs     <= 1'b0;
            lcd_rw     <= 1'b0;
            lcd_data   <= 8'h00;
            delay_cnt  <= 16'd0;
            char_index <= 8'd0;
            state      <= S_INIT_POWER;
        end else begin
            lcd_rw <= 1'b0;
            lcd_en <= 1'b0;

            if (delay_cnt > 0) begin
                delay_cnt <= delay_cnt - 1;
            end else begin
                case (state)
                    S_INIT_POWER:   begin delay_cnt <= DELAY_CNT * 200; state <= S_INIT_FUNC;    end  // increased for safety
                    S_INIT_FUNC:    begin lcd_rs<=0; lcd_data<=8'h38; lcd_en<=1; delay_cnt<=DELAY_CNT*2; state<=S_INIT_ENTRY; end
                    S_INIT_ENTRY:   begin lcd_rs<=0; lcd_data<=8'h06; lcd_en<=1; delay_cnt<=DELAY_CNT;   state<=S_INIT_DISPLAY; end
                    S_INIT_DISPLAY: begin lcd_rs<=0; lcd_data<=8'h0C; lcd_en<=1; delay_cnt<=DELAY_CNT;   state<=S_CLEAR; end
                    S_CLEAR:        begin lcd_rs<=0; lcd_data<=8'h01; lcd_en<=1; delay_cnt<=DELAY_CNT*40; state<=S_SET_ADDR; end
                    S_SET_ADDR: begin
                        lcd_rs     <= 0;
                        lcd_data   <= 8'h80;  // line 1 start
                        lcd_en     <= 1;
                        delay_cnt  <= DELAY_CNT;
                        char_index <= 0;
                        state      <= S_WRITE_LINE1;
                    end
                    S_WRITE_LINE1: begin
                        if (char_index < 16) begin
                            lcd_rs     <= 1;
                            lcd_data   <= str[char_index];
                            lcd_en     <= 1;
                            delay_cnt  <= DELAY_CNT;
                            char_index <= char_index + 1;
                        end else begin
                            char_index <= 0;
                            state      <= S_WRITE_LINE2;
                        end
                    end
                    S_WRITE_LINE2: begin
                        if (char_index == 0) begin
                            lcd_rs     <= 0;
                            lcd_data   <= 8'hC0;  // line 2 start
                            lcd_en     <= 1;
                            delay_cnt  <= DELAY_CNT;
                            char_index <= 1;
                        end else if (char_index <= 16) begin
                            lcd_rs     <= 1;
                            lcd_data   <= str[15 + char_index];
                            lcd_en     <= 1;
                            delay_cnt  <= DELAY_CNT;
                            char_index <= char_index + 1;
                        end else begin
                            state <= S_IDLE;
                        end
                    end
                    S_IDLE: begin
                        if (clk_1hz) state <= S_CLEAR;  // refresh every second
                    end
                    default: state <= S_IDLE;
                endcase
            end
        end
    end

endmodule