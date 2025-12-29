`timescale 1ns/1ps

module tb_LFSR8bit;

    reg clk;
    reg rst;
    wire [7:0] lfsr;
    wire [7:0] random_num;

    // Instantiate the DUT (Device Under Test)
    LFSR8bit uut (
        .clk(clk),
        .rst(rst),
        .lfsr(lfsr),
        .random_num(random_num)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // toggle every 5ns → 10ns period
    end

    // Stimulus
    initial begin
        // Dump waveforms for simulation (optional, for GTKWave or similar)
        $dumpfile("LFSR8bit.vcd");
        $dumpvars(0, tb_LFSR8bit);

        // Apply reset
        rst = 1;
        #10;          // hold reset for 10ns
        rst = 0;

        // Run for 40 cycles and print outputs
        repeat (40) begin
            @(posedge clk);
            $display("Time=%0t | LFSR=%b | random_num=%b",
                     $time, lfsr, random_num);
        end

        $finish;
    end

endmodule
