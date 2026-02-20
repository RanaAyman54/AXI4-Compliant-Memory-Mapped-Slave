package axi4_coverage_pkg;

    import axi4_transaction_pkg::*;

    class axi4_coverage;

      axi4_transaction cov_item = new();
      
      covergroup cg ;

        /*w_addr: coverpoint cov_item.AWADDR {
            bins legal = {[0:4095]};
            illegal_bins illegal = default;
        }*/

        w_len: coverpoint cov_item.AWLEN {
            bins max = {255};
            bins min = {0};
            bins remaining = default;
        }

        w_size: coverpoint cov_item.AWSIZE {
            bins size = {2};
            illegal_bins illegal = default;
        }

        w_addr_valid : coverpoint cov_item.AWVALID {option.weight = 0;}

        w_addr_ready: coverpoint cov_item.AWREADY{option.weight = 0;}

        w_data : coverpoint cov_item.WDATA ;

        w_valid: coverpoint cov_item.WVALID{option.weight = 0;}

        w_ready: coverpoint cov_item.WREADY{option.weight = 0;}

        w_last: coverpoint cov_item.WLAST ;

        w_response : coverpoint cov_item.BRESP {
            bins legal = {2'b00,2'b10};
        }

        w_response_valid: coverpoint cov_item.BVALID{option.weight = 0;}

        w_response_ready: coverpoint cov_item.BREADY{option.weight = 0;}

        /*r_addr: coverpoint cov_item.ARADDR {
            bins legal = {[0:4095]};
            illegal_bins illegal = default;
        }*/

        r_len: coverpoint cov_item.ARLEN {
            bins max = {255};
            bins min = {0};
            bins remaining = default;
        }

        r_size: coverpoint cov_item.ARSIZE {
            bins size = {2};
            illegal_bins illegal = default;
        }

        r_addr_valid : coverpoint cov_item.ARVALID {option.weight = 0;}

        r_addr_ready: coverpoint cov_item.ARREADY{option.weight = 0;}

        r_last: coverpoint cov_item.RLAST ;

        r_response : coverpoint cov_item.RRESP {
            bins legal = {2'b00,2'b10};
        }

        r_valid: coverpoint cov_item.RVALID{option.weight = 0;}

        r_ready: coverpoint cov_item.RREADY{option.weight = 0;}

        r_data : coverpoint cov_item.RDATA ;

        c_w_addr_valid_ready:cross w_addr_valid ,w_addr_ready;

        c_w_valid_ready: cross w_valid ,w_ready;

        c_w_response : cross w_response_valid , w_response_ready;

        c_r_addr_valid_ready:cross r_addr_valid ,r_addr_ready;

        c_r_valid_ready:cross r_valid ,r_ready;

      endgroup

      function void sample(axi4_transaction item);
        cov_item = item;
        cg.sample();
      endfunction

      function new;
        cg = new();       
      endfunction


    
    endclass
    
endpackage
