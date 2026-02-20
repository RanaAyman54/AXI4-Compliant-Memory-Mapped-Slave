module axi4_memory_tb;

    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 10;    // For 1024 locations
    parameter DEPTH = 1024;

    logic                    clk;
    logic                    rst_n;
    
    logic                    mem_en;
    logic                    mem_we;
    logic[ADDR_WIDTH-1:0]    mem_addr;
    logic[DATA_WIDTH-1:0]    mem_wdata;
    logic  [DATA_WIDTH-1:0]    mem_rdata;

    axi4_memory #(.DATA_WIDTH(DATA_WIDTH),
                 .ADDR_WIDTH(ADDR_WIDTH),
                 .DEPTH(DEPTH)) DUT (.*);

    int correct_count = 0, error_count = 0;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        mem_en = 0;
        mem_we = 0;
        mem_addr = 0;
        mem_wdata = 0;
        rst_n = 1;

        @(negedge clk);
        rst_n = 0;//assert rst
        @(negedge clk);
        rst_n = 1;//deassert rst

        //enable memory and start write
        mem_en = 1;
        mem_we = 1;

        for (mem_addr=0 ; mem_addr <DEPTH-1 ; mem_addr++)begin
            mem_wdata = $random();
            @(negedge clk);
            if (DUT.memory[mem_addr] !== mem_wdata)begin
                error_count++;
                $display("ERROR  mem[%d] = %h while intended wr_data = %h ",mem_addr,DUT.memory[mem_addr],mem_wdata);
            end
            else begin
                correct_count ++;
            end
        end

        //read data
        mem_we = 0;

        for (mem_addr=0 ; mem_addr < DEPTH-1 ; mem_addr++)begin
             @(negedge clk);
            if (mem_rdata !== DUT.memory[mem_addr])begin
                error_count++;
                $display("ERROR read data = %h while mem[%d] = %h ",mem_rdata,mem_addr,DUT.memory[mem_addr]);
            end
            else begin
                correct_count ++;
            end
           
        end

        //check when mem_en = 0 mem doesn't work
        mem_en = 0;
        mem_we = 1;
        mem_addr = 5;
        mem_wdata = 200;

        $display("check if 200 is ignored while mem_en = 0 mem[%d] = %d  ",mem_addr,DUT.memory[mem_addr]);

        @(negedge clk);
        $display("at the end of simulation correct count = %d error count = %d ",correct_count,error_count);

        $stop();

    end
    
endmodule