module LFSR4bit (
    input wire clk,          // clock
    input wire rst,          // reset (active high)
    output reg [3:0] lfsr,   // LFSR state
    output reg [3:0] random_num, // random output
	output wire output_bit
);

    wire feedback;

    // poly: 1 + x + x^4
    assign feedback = lfsr[3] ^ lfsr[0];
	assign output_bit = lfsr[0];
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= 4'b0110; // avoid 0000 to avoid stuck situation 
        end else begin
            // shift right, insert feedback at MSB
            lfsr <= {feedback, lfsr[3:1]};
        end
    end

    always @(*) begin
        random_num = lfsr;
    end
	

endmodule
