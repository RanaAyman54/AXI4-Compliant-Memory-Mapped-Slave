`timescale 1ns/1ps
module axi4_sva (axi4_if.DUT axi4If);

    //reset checker
    always_comb begin 
            if(!axi4If.ARESETn)
                  assert_rst: assert final(axi4If.AWREADY === 1 && axi4If.WREADY === 0 && axi4If.BRESP === 0 && axi4If.BVALID === 0 && axi4If.ARREADY === 1 && axi4If.RDATA === 0 && axi4If.RRESP === 0 && axi4If.RLAST === 0 && axi4If.RVALID ===0);
      end

      //clk checker
      bit clk_temp;
      parameter CLK_PERIOD = 10;
      initial begin
            #CLK_PERIOD;
            forever begin
                  clk_temp = axi4If.ACLK;
                  #(CLK_PERIOD/2);
                 clk_check: assert(axi4If.ACLK == ~clk_temp);
                  
            end
      end

      property address_write;
            @(posedge axi4If.ACLK) disable iff (!axi4If.ARESETn) axi4If.AWVALID |=> ##[0:$] axi4If.AWREADY ;
      endproperty

      property address_read;
            @(posedge axi4If.ACLK) disable iff (!axi4If.ARESETn) axi4If.ARVALID |=> ##[0:$] axi4If.ARREADY ;
      endproperty

      property writeData;
            @(posedge axi4If.ACLK) disable iff (!axi4If.ARESETn) axi4If.WVALID |=> ##[0:$] axi4If.WREADY ;
      endproperty


      property writeBoundaryCheck;
            @(posedge axi4If.ACLK) disable iff (!axi4If.ARESETn) axi4If.AWVALID |->  (axi4If.AWADDR >> 2) + (axi4If.AWLEN + 1) < axi4If.MEMORY_DEPTH ;
      endproperty

      property write_response;
            @(posedge axi4If.ACLK) disable iff (!axi4If.ARESETn) axi4If.WLAST |=> !axi4If.WREADY && axi4If.BVALID && (axi4If.BRESP === 2'b00 ||axi4If.BRESP === 2'b10);
      endproperty

      property readBoundaryCheck;
            @(posedge axi4If.ACLK) disable iff (!axi4If.ARESETn) axi4If.ARVALID |->  (axi4If.ARADDR >> 2) + (axi4If.ARLEN + 1) < axi4If.MEMORY_DEPTH ;
      endproperty

      ap_address_write : assert property(address_write);
      cp_address_write : cover property(address_write);

      ap_address_read : assert property(address_read);
      cp_address_read : cover property(address_read);

      ap_writeData : assert property(writeData);
      cp_writeData : cover property(writeData);

      /*ap_writeBoundaryCheck : assert property(writeBoundaryCheck);
      cp_writeBoundaryCheck : cover property(writeBoundaryCheck);

      ap_readBoundaryCheck : assert property(readBoundaryCheck);
      cp_readBoundaryCheck : cover property(readBoundaryCheck);*/

      ap_writeResponse : assert property(write_response);
      cp_writeResponse : cover property(write_response);
      
    
endmodule