`timescale 1ns/1ps
module axi4_tb (axi4_if.TEST axi4If);

    import axi4_transaction_pkg::*;
    import axi4_coverage_pkg::*;

    axi4_transaction tb_item;
    axi4_coverage tb_coverage;


    logic [8:0] wlen;
    logic [15:0] waddr;
    logic out_of_bound_write;
    logic out_of_bound_read;

    logic [8:0] rlen;
    logic [15:0] raddr;


    int collected_data [$];

    logic [7:0] collected_len_for_read [$];
    logic [15:0] collected_addr_for_read [$];


    int error_count = 0;
    int correct_count = 0;

    initial begin
        //for coverage
        forever begin
            @(axi4If.ACLK);
                tb_item.ARREADY = axi4If.ARREADY;
                tb_item.RDATA = axi4If.RDATA;
                tb_item.RRESP = axi4If.RRESP;
                tb_item.RLAST = axi4If.RLAST;
                tb_item.RVALID = axi4If.RVALID;
                tb_item.ARADDR = axi4If.ARADDR;
                tb_item.ARLEN = axi4If.ARLEN;
                tb_item.AWREADY = axi4If.AWREADY;
                tb_item.WREADY = axi4If.WREADY;
                tb_item.BRESP = axi4If.BRESP;
                tb_item.BVALID = axi4If.BVALID;
                tb_item.WLAST = axi4If.WLAST;

            tb_coverage.sample(tb_item);

        end
    end

    

    initial begin

        tb_item = new(); 
        tb_coverage = new();

        axi4If.ARESETn = 1'b1;
        axi4If.AWVALID = 1'b0;
        axi4If.WVALID = 1'b0;
        axi4If.BREADY = 1'b0;
        axi4If.ARVALID = 1'b0;
        axi4If.RREADY = 1'b0;
        axi4If.WLAST = 1'b0;
        axi4If.AWADDR = '0;
        axi4If.AWLEN  = '0;
        axi4If.AWSIZE = '0;
        axi4If.WDATA  = '0;
        axi4If.ARADDR = '0;
        axi4If.ARLEN  = '0;
        axi4If.ARSIZE = '0;

        #1;
        axi4If.ARESETn = 0;//assert reset
        @(negedge axi4If.ACLK);
        axi4If.ARESETn = 1;//deassert reset


        tb_item.address_out_of_bound.constraint_mode(0);
        tb_item.len_big_range.constraint_mode(0);
        //write 
        repeat (100) begin 
            write_burst_of_data();                                         
        end

        //to stop writing
        axi4If.AWVALID = 1'b0;
        axi4If.WVALID = 1'b0;

        //read 
        repeat (100) begin
            read_burst_of_data();       
        end

        //to stop reading
        axi4If.RREADY = 0;
        axi4If.ARVALID = 0;

        //////////////////////////////////////test long burst///////////////////////////////////////////
        axi4If.ARESETn = 0;//assert reset
        @(negedge axi4If.ACLK);
        @(negedge axi4If.ACLK);
        axi4If.ARESETn = 1;//deassert reset

        tb_item.len_range.constraint_mode(0);
        tb_item.len_big_range.constraint_mode(1);
        repeat (20) begin
            write_burst_of_data();
        end

        //to stop writing
        axi4If.AWVALID = 1'b0;
        axi4If.WVALID = 1'b0;

        repeat(20) begin
            read_burst_of_data();
        end

        //to stop reading
        axi4If.RREADY = 0;
        axi4If.ARVALID = 0;


        ////////////////////////////////////////test out of bound address ////////////////////////////
       tb_item.len_range.constraint_mode(1);
        tb_item.len_big_range.constraint_mode(0);
        tb_item.address.constraint_mode(0);
        tb_item.address_out_of_bound.constraint_mode(1);
        repeat (20) begin
            write_burst_of_data();
        end

        //to stop writing
        axi4If.AWVALID = 1'b0;
        axi4If.WVALID = 1'b0;

        repeat (20) begin
            read_burst_of_data();
        end




       $display("at the end of simulation, correct_count = %0d, error_count = %0d", correct_count, error_count);

       $stop();
    end
////////////////////////////////////////////////// Write ////////////////////////////////////////////////////////////
    task write_burst_of_data ;
        assert(tb_item.randomize()) else $fatal("Failed to randomize transaction");
                    @(negedge axi4If.ACLK);
                    axi4If.ARESETn = tb_item.ARESETn;
                    axi4If.AWADDR = tb_item.AWADDR ;
                    axi4If.AWLEN  = tb_item.AWLEN; 
                    axi4If.AWSIZE = tb_item.AWSIZE;
                    axi4If.AWVALID = 1'b1;
                    axi4If.BREADY = tb_item.BREADY ;

                    wlen = axi4If.AWLEN + 1;
                    waddr = axi4If.AWADDR >> 2;

                    out_of_bound_write = (waddr + wlen >= axi4If.MEMORY_DEPTH) ? 1 : 0;

                    collected_addr_for_read.push_back(axi4If.AWADDR);
                    collected_len_for_read.push_back(axi4If.AWLEN);

                    if(tb_item.ARESETn) begin
                    $display("========================================================================");
                    $display("burst write of wlength %0d from byte waddress %0d (word waddress %0d)", tb_item.AWLEN + 1, tb_item.AWADDR, waddr );
                    end

                    while (wlen > 0) begin
                        if(!axi4If.ARESETn) begin
                            break;
                        end
                        @(negedge axi4If.ACLK);
                       
                        assert(tb_item.randomize()) else $fatal("Failed to randomize transaction");
                        axi4If.WDATA = tb_item.WDATA;
                        axi4If.WVALID = tb_item.WVALID;
                        axi4If.BREADY = tb_item.BREADY;

                        if (axi4If.WVALID && axi4If.WREADY) begin
                            wlen--;
                            if(!out_of_bound_write) begin
                                collected_data.push_back(tb_item.WDATA);
                            end
                           
                        end

                        if (wlen == 0) begin
                            axi4If.WLAST = 1'b1;
                            check_write_response ();      
                        end

                        else begin
                            axi4If.WLAST = 1'b0;
                        end


                    end
                    if (axi4If.ARESETn && !out_of_bound_write) begin
                        $display(" check that if data burst written successfully in memory ");                       
                    end 
                                       
                    //@(negedge axi4If.ACLK);
                    axi4If.WLAST = 1'b0;
                    @(negedge axi4If.ACLK);
                    if(!out_of_bound_write) begin
                        write_check ();
                    end
                     

    endtask

     task  write_check ;
        foreach (collected_data[i]) begin
            if(axi4_top.DUT.mem_inst.memory[waddr] !== collected_data[i]) begin
                $display(" time = %t Write error: Expected %0h, Got %0h waddr %0d",$time(), collected_data[i], axi4_top.DUT.mem_inst.memory[waddr], waddr);
                error_count ++;
            end
            else begin
                $display("time = %t Write success: Expected %0h, Got %0h waddr %0d", $time(),collected_data[i], axi4_top.DUT.mem_inst.memory[waddr], waddr);
                correct_count ++;
            end
            waddr += 1;  
        end
        collected_data.delete();
     endtask

     task check_write_response ;
        @(posedge axi4If.ACLK);
        @(negedge axi4If.ACLK);
        if(axi4If.BREADY) begin
            if (out_of_bound_write) begin
                if(axi4If.BRESP === 2'b10 && axi4If.BVALID === 1) begin
                    $display ("time = %t  out of bound address to write to resp = 2'b%0b",$time(), axi4If.BRESP);                
                end
                else begin
                    $error("Write response error: Expected SLVERR (2'b10) for out of bound address, Got %0b", axi4If.BRESP);
                    error_count ++;
                end          
            end
             else if(axi4If.BVALID === 1 && axi4If.BRESP === 2'b00) begin
                $display("Write response success:OKAY %0b", axi4If.BRESP);
                correct_count ++;
            end
            else begin
                $error("Write response error: Expected BVALID = 1 and BRESP = 2'b00, Got BVALID = %0b, BRESP = %0b", axi4If.BVALID, axi4If.BRESP);
                error_count ++;
            end
        end

     endtask
/////////////////////////////////////////////////////////////// Read /////////////////////////////////////////////////////////////
     task read_burst_of_data;
        assert(tb_item.randomize()) else $fatal("Failed to randomize transaction");
            @(negedge axi4If.ACLK);
            axi4If.ARESETn = tb_item.ARESETn;
            axi4If.ARADDR = collected_addr_for_read.pop_front();
            axi4If.ARLEN  = collected_len_for_read.pop_front();
            axi4If.ARSIZE = tb_item.ARSIZE;
            axi4If.ARVALID = 1'b1;
            axi4If.RREADY = tb_item.RREADY ;

            rlen = axi4If.ARLEN + 1;
            raddr = axi4If.ARADDR >> 2;

                out_of_bound_read = (raddr + rlen >= axi4If.MEMORY_DEPTH) ? 1 : 0;


            if(tb_item.ARESETn) begin
                $display("========================================================================");
                $display("burst read of rlength %0d from byte raddress %0d (word raddress %0d)", rlen, axi4If.ARADDR, raddr );
            end

            while (rlen > 0) begin
                if(!axi4If.ARESETn) begin
                    break;
                end
                @(negedge axi4If.ACLK);
                assert(tb_item.randomize()) else $fatal("Failed to randomize transaction");
                axi4If.RREADY = tb_item.RREADY ;

                
               
                if (axi4If.RVALID && axi4If.RREADY) begin
                    rlen--;
                    if (rlen === 0) begin
                    if (axi4If.RLAST !== 1'b1) begin
                        $display("Read error: RLAST not asserted on last beat");
                        error_count ++;
                    end
                    else begin
                        correct_count ++;
                    end
                end
                   read_check ();
                end
           
            end       
     endtask

     task read_check ;
        @(posedge axi4If.ACLK);
        @(posedge axi4If.ACLK);

       if (out_of_bound_read) begin
           if(axi4If.RRESP === 2'b10) begin
                $display ("time = %t  out of bound address to read from resp = 2'b%0b",$time(), axi4If.RRESP);                
            end
            else begin
                $error("Read response error: Expected SLVERR (2'b10) for out of bound address, Got %0b", axi4If.RRESP);
                error_count ++;
            end          
        end
        else if( axi4If.RDATA !== axi4_top.DUT.mem_inst.memory[raddr]  || axi4If.RRESP !== 2'b00 ) begin
                $display(" time = %t Read error: Expected %0h, Got %0h raddr %0d",$time(), axi4_top.DUT.mem_inst.memory[raddr],axi4If.RDATA, raddr);
                error_count ++;
            end
            else begin
                $display(" time = %t Read success: Expected %0h, Got %0h raddr %0d",$time(), axi4_top.DUT.mem_inst.memory[raddr],axi4If.RDATA, raddr);
                correct_count ++;
            end
            raddr += 1;

     endtask
  
endmodule