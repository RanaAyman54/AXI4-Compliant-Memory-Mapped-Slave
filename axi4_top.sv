`timescale 1ns/1ps
module axi4_top;

    bit clk;

    always #5 clk = ~clk;

    axi4_if axi4If (clk);
    axi4_tb TEST (axi4If);
    axi4 DUT (axi4If);
    bind axi4 axi4_sva sva (axi4If);
    
    
endmodule