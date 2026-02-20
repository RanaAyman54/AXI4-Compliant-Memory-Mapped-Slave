package axi4_transaction_pkg;

    class axi4_transaction;
        parameter DATA_WIDTH = 32;
        parameter ADDR_WIDTH = 16;
        parameter MEMORY_DEPTH = 1024;

    bit ACLK;
    rand logic ARESETn;

    // Write address channel
    rand logic [ADDR_WIDTH-1:0]    AWADDR;
    rand logic [7:0]               AWLEN;
    rand logic [2:0]               AWSIZE;
    rand logic                    AWVALID;
    logic                      AWREADY;

    // Write data channel
    rand logic [DATA_WIDTH-1:0]    WDATA;
    rand logic                    WVALID;
    logic                   WLAST;
    logic                      WREADY;

    // Write response channel
    logic [1:0]                BRESP;
    logic                     BVALID;
    rand logic                     BREADY;

    // Read address channel
    rand logic [ADDR_WIDTH-1:0]    ARADDR;
    rand logic [7:0]               ARLEN;
    rand logic [2:0]               ARSIZE;
    rand logic                     ARVALID;
    logic                     ARREADY;

    // Read data channel
    logic [DATA_WIDTH-1:0]     RDATA;
    logic [1:0]                RRESP;
    logic                      RVALID;
    logic                     RLAST;
    rand logic                     RREADY;

    constraint rst {
        ARESETn dist {0:/2 , 1:/98};
    }

    constraint address {
        (AWADDR >> 2) + AWLEN + 1 < MEMORY_DEPTH;
        (ARADDR >> 2) + ARLEN + 1 < MEMORY_DEPTH;
        
    }

    constraint address_out_of_bound {
        AWADDR dist {[4050:4095]:/80 ,[0:4049]:/5, [4096:65535]:/15};
        ARADDR dist {[4050:4095]:/80 ,[0:4049]:/5, [4096:65535]:/15};

    }

    constraint sizeOfBeat {
        AWSIZE == 2;
        ARSIZE == 2;
    }

    constraint valid_signal {
        WVALID dist {0:/20 , 1:/80};
    }

    constraint ready_response {
        BREADY dist {1:/95 ,0:/5};
        RREADY dist {1:/95 ,0:/5};
    }

    constraint len_range {
        AWLEN inside {[0:15]};
        ARLEN inside {[0:15]};
    }

    constraint len_big_range {
        AWLEN dist {[100:200]:/10 , [201:255]:/90};
        ARLEN dist {[100:200]:/10 , [201:255]:/90};

    }

   
endclass
    
endpackage
