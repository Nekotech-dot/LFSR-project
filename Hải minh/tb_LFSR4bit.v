`timescale 1ns/1ps

module tb_LFSR4bit;

    reg clk;
    reg rst;
    wire [3:0] lfsr;
    wire [3:0] random_num;
    wire output_bit;

    // Instantiate the DUT (Device Under Test)
    LFSR4bit uut (
        .clk(clk),
        .rst(rst),
        .lfsr(lfsr),
        .random_num(random_num),
        .output_bit(output_bit)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // toggle every 5ns â†’ 10ns period
    end

    // Stimulus
    initial begin
        // Dump waveforms for simulation (optional, for GTKWave or similar)
        $dumpfile("LFSR4bit.vcd");
        $dumpvars(0, tb_LFSR4bit);
        rst = 1;
        #10;
        rst = 0;

        // Run for 35 cycles and print outputs
        repeat (35) begin
            @(posedge clk);
            $display("Time=%0t | LFSR=%b | random_num=%b | output_bit=%b",
                     $time, lfsr, random_num, output_bit);
        end
        $finish;
    end

endmodule
