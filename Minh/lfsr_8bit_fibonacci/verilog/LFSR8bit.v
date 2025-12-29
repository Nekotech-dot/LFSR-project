//poly: 1 + x^4 + x^5 + x^6 + x^8
module LFSR8bit(
	input wire clk,
	input wire rst,
	output reg [7:0] lfsr,
	output reg [7:0] random_num
);

	wire feedback;
	
	assign feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];
	always@(posedge clk or posedge rst) begin
		if (rst) begin 
			lfsr <= 8'b10101101;
		end else begin
			lfsr <= {feedback, lfsr[7:1]};
		end
	end
	
	always @(*) begin //update immediately
		random_num = lfsr;
	end
endmodule
	