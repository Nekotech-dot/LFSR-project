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
    output wire [7:0] B       // ONLY output the Keystream (Secure Design)
);

    // ====================================================================
    // BỘ NHÂN GF(2^4) - TỐI ƯU HÓA PHẦN CỨNG 0-CLOCK 
    // ====================================================================
    function [3:0] gf16_mul;
        input [3:0] Symbol_in;
        input [3:0] C_i;
        
        reg [3:0] P0, P1, P2, P3;
        reg [3:0] S0, S1, S2, S3;
        begin
            // TẦNG 1: Dịch bit và Rút gọn Modulo
            P0 = Symbol_in;
            P1 = (P0 << 1) ^ (P0[3] ? RED_POLY : 4'b0000);
            P2 = (P1 << 1) ^ (P1[3] ? RED_POLY : 4'b0000);
            P3 = (P2 << 1) ^ (P2[3] ? RED_POLY : 4'b0000);

            // TẦNG 2: Mạng chọn lọc Vector MUX
            S0 = C_i[0] ? P0 : 4'b0000;
            S1 = C_i[1] ? P1 : 4'b0000;
            S2 = C_i[2] ? P2 : 4'b0000;
            S3 = C_i[3] ? P3 : 4'b0000;

            // TẦNG 3: Cây XOR cộng dồn
            gf16_mul = S0 ^ S1 ^ S2 ^ S3;
        end
    endfunction

    // ====================================================================
    // KHAI BÁO 4 THANH GHI 4-BIT ĐỘC LẬP (Internal State - Hidden)
    // ====================================================================
    reg [3:0] reg3; 
    reg [3:0] reg2; 
    reg [3:0] reg1; 
    reg [3:0] reg0; 

    // Tín hiệu phản hồi (Feedback/Tap)
    wire [3:0] tap = reg0;

    // ====================================================================
    // CẬP NHẬT TRẠNG THÁI LFSR MỖI XUNG CLOCK
    // ====================================================================
    always @(posedge clk) begin
        if (!rst_n) begin
            reg3 <= 4'h0;
            reg2 <= 4'h0;
            reg1 <= 4'h0;
            reg0 <= 4'h1;
        end 
        else if (load) begin
            reg3 <= seed[15:12];
            reg2 <= seed[11:8];
            reg1 <= seed[7:4];
            reg0 <= seed[3:0];
        end 
        else if (en) begin
            reg3 <= gf16_mul(tap, C3);
            reg2 <= reg3 ^ gf16_mul(tap, C2);
            reg1 <= reg2 ^ gf16_mul(tap, C1);
            reg0 <= reg1 ^ gf16_mul(tap, C0);
        end
    end

    // ====================================================================
    // TRÍCH XUẤT BIT-SLICING VÀ TÍNH TOÁN ĐẦU RA B (Keystream)
    // ====================================================================
    wire [3:0] slice0 = {reg3[0], reg2[0], reg1[0], reg0[0]};
    wire [3:0] slice1 = {reg3[1], reg2[1], reg1[1], reg0[1]};
    wire [3:0] slice2 = {reg3[2], reg2[2], reg1[2], reg0[2]};
    wire [3:0] slice3 = {reg3[3], reg2[3], reg1[3], reg0[3]};

    reg [7:0] B_reg;
    assign B = B_reg;

    always @(posedge clk) begin
        if (!rst_n)
            B_reg <= 8'd0;
        else
            // Thêm ngoặc để gợi ý cho Synthesis Tool tổng hợp thành cây Adder song song
            B_reg <= (slice0 + slice1) + (slice2 + slice3);
    end

endmodule
