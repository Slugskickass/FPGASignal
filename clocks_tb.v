`timescale 1ns/1ps

module example_tb();
  // Declare signals
  reg clk;
  wire P1_1;
  wire P1_2;
  wire P1_4;

  pmod_counter dut (
    .CLK (clk),
    .P1_1 (P1_1),     // Fixed signal name
    .P1_2 (P1_2),   // Fixed signal name
    .P1_4 (P1_4)
  );

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
$monitor("Time: %0t, P1_1: %b, P1_2: %b, P1_4: %b", 
             $time, P1_1, P1_2, P1_4);

    #1000000;
    $finish;  // Added $finish to end simulation
  end

initial begin
    $dumpfile("clock_tb.vcd");
    $dumpvars(0, example_tb);
  end

endmodule  // Added endmodule statement
