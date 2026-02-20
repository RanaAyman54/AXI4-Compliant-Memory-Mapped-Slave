interface axi4_if (
    input bit ACLK
);
 
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 16;
    parameter MEMORY_DEPTH = 1024;

    logic                     ARESETn;

    // Write address channel
    logic [ADDR_WIDTH-1:0]    AWADDR;
    logic [7:0]               AWLEN;
    logic [2:0]               AWSIZE;
    logic                     AWVALID;
    logic                     AWREADY;

    // Write data channel
    logic [DATA_WIDTH-1:0]    WDATA;
    logic                     WVALID;
    logic                     WLAST;
    logic                     WREADY;

    // Write response channel
    logic[1:0]                BRESP;
    logic                     BVALID;
    logic                     BREADY;

    // Read address channel
    logic [ADDR_WIDTH-1:0]    ARADDR;
    logic [7:0]               ARLEN;
    logic [2:0]               ARSIZE;
    logic                     ARVALID;
    logic                     ARREADY;

    // Read data channel
    logic[DATA_WIDTH-1:0]     RDATA;
    logic[1:0]                RRESP;
    logic                     RVALID;
    logic                     RLAST;
    logic                     RREADY;

    modport DUT (
    input ACLK,
    input ARESETn,
    input AWADDR,
    input AWLEN,
    input AWSIZE,
    input AWVALID,
    output AWREADY,
    input WDATA,
    input WVALID,
    input WLAST,
    output WREADY,
    output BRESP,
    output BVALID,
    input BREADY,
    input ARADDR,
    input ARLEN,
    input ARSIZE,
    input ARVALID,
    output ARREADY,
    output RDATA,
    output RRESP,
    output RVALID,
    output RLAST,
    input RREADY
    );

    modport TEST (
    input ACLK,
    output ARESETn,
    output AWADDR,
    output AWLEN,
    output AWSIZE,
    output AWVALID,
    input AWREADY,
    output WDATA,
    output WVALID,
    output WLAST,
    input WREADY,
    input BRESP,
    input BVALID,
    output BREADY,
    output ARADDR,
    output ARLEN,
    output ARSIZE,
    output ARVALID,
    input ARREADY,
    input RDATA,
    input RRESP,
    input RVALID,
    input RLAST,
    output RREADY
    );


    
endinterface