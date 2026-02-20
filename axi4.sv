module axi4 (
    axi4_if.DUT axi4If
);


    // Internal memory signals
    reg mem_en, mem_we;
    reg [$clog2(axi4If.MEMORY_DEPTH)-1:0] mem_addr;
    reg [axi4If.DATA_WIDTH-1:0] mem_wdata;
    wire [axi4If.DATA_WIDTH-1:0] mem_rdata;

    // Address and burst management
    reg [axi4If.ADDR_WIDTH-1:0] write_addr, read_addr;
    reg [7:0] write_burst_len, read_burst_len;
    reg [7:0] write_burst_cnt, read_burst_cnt;
    reg [2:0] write_size, read_size;
    
    wire [axi4If.ADDR_WIDTH-1:0] write_addr_incr,read_addr_incr;
    
    
    
    // Address increment calculation
    assign  write_addr_incr = (1 << write_size);
    assign  read_addr_incr  = (1 << read_size);
    
    // Address boundary check (4KB boundary = 12 bits)
    //assign write_boundary_cross = ( + (write_burst_len << write_size)) > 12'hFFF;
    assign write_boundary_cross = ((write_addr & 12'hFFF) + ((write_burst_cnt + 1) << write_size)) > 12'hFFF;
    //assign read_boundary_cross = ( + (read_burst_len << read_size)) > 12'hFFF;
    assign read_boundary_cross = ((read_addr & 12'hFFF) + ((read_burst_cnt + 1) << read_size)) > 12'hFFF;
    
    // Address range check
    assign write_addr_valid = (write_addr >> 2) < axi4If.MEMORY_DEPTH;
    assign read_addr_valid = (read_addr >> 2) < axi4If.MEMORY_DEPTH;

    // Memory instance
    axi4_memory #(
        .DATA_WIDTH(axi4If.DATA_WIDTH),
        .ADDR_WIDTH($clog2(axi4If.MEMORY_DEPTH)),
        .DEPTH(axi4If.MEMORY_DEPTH)
    ) mem_inst (
        .clk(axi4If.ACLK),
        .rst_n(axi4If.ARESETn),
        .mem_en(mem_en),
        .mem_we(mem_we),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_rdata(mem_rdata)
    );

    // FSM states
    reg [2:0] write_state;
    localparam W_IDLE = 3'd0,
               W_ADDR = 3'd1,
               W_DATA = 3'd2,
               W_RESP = 3'd3;

    reg [2:0] read_state;
    localparam R_IDLE = 3'd0,
               R_ADDR = 3'd1,
               R_DATA = 3'd2;

    // Registered memory read data for timing
    reg [axi4If.DATA_WIDTH-1:0] mem_rdata_reg;

    always @(posedge axi4If.ACLK or negedge axi4If.ARESETn) begin
        if (!axi4If.ARESETn) begin
            // Reset all outputs
            axi4If.AWREADY <= 1'b1;  // Ready to accept address
            axi4If.WREADY <= 1'b0;
            axi4If.BVALID <= 1'b0;
            axi4If.BRESP <= 2'b00;
            
            axi4If.ARREADY <= 1'b1;  // Ready to accept address
            axi4If.RVALID <= 1'b0;
            axi4If.RRESP <= 2'b00;
            axi4If.RDATA <= {axi4If.DATA_WIDTH{1'b0}};
            axi4If.RLAST <= 1'b0;
            
            // Reset internal state
            write_state <= W_IDLE;
            read_state <= R_IDLE;
            mem_en <= 1'b0;
            mem_we <= 1'b0;
            mem_addr <= {$clog2(axi4If.MEMORY_DEPTH){1'b0}};
            mem_wdata <= {axi4If.DATA_WIDTH{1'b0}};
            
            // Reset address tracking
            write_addr <= {axi4If.ADDR_WIDTH{1'b0}};
            read_addr <= {axi4If.ADDR_WIDTH{1'b0}};
            write_burst_len <= 8'b0;
            read_burst_len <= 8'b0;
            write_burst_cnt <= 8'b0;
            read_burst_cnt <= 8'b0;
            write_size <= 3'b0;
            read_size <= 3'b0;
            
            mem_rdata_reg <= {axi4If.DATA_WIDTH{1'b0}};
            
        end else begin
            // Default memory disable
            mem_en <= 1'b0;
            mem_we <= 1'b0;

            // --------------------------
            // Write Channel FSM
            // --------------------------
            case (write_state)
                W_IDLE: begin
                    axi4If.AWREADY <= 1'b1;
                    axi4If.WREADY <= 1'b0;
                    axi4If.BVALID <= 1'b0;
                    
                    if (axi4If.AWVALID && axi4If.AWREADY) begin
                        // Capture address phase information
                        write_addr <= axi4If.AWADDR;
                        write_burst_len <= axi4If.AWLEN;
                        write_burst_cnt <= axi4If.AWLEN;
                        write_size <= axi4If.AWSIZE;
                        
                        axi4If.AWREADY <= 1'b0;
                        write_state <= W_ADDR;
                    end
                end
                
                W_ADDR: begin
                    // Transition to data phase
                    axi4If.WREADY <= 1'b1;
                    write_state <= W_DATA;
                end
                
                W_DATA: begin
                    if (axi4If.WVALID && axi4If.WREADY) begin
                        // Check if address is valid
                        if (write_addr_valid && !write_boundary_cross) begin
                            // Perform write operation
                            mem_en <= 1'b1;
                            mem_we <= 1'b1;
                            mem_addr <= write_addr >> 2;  // Convert to word address
                            mem_wdata <= axi4If.WDATA;
                        end
                        
                        // Check for last transfer
                        if (axi4If.WLAST || write_burst_cnt == 0) begin
                            axi4If.WREADY <= 1'b0;
                            write_state <= W_RESP;
                            
                            // Set response - delayed until write completion
                            if (!write_addr_valid || write_boundary_cross) begin
                                axi4If.BRESP <= 2'b10;  // SLVERR
                            end else begin
                                axi4If.BRESP <= 2'b00;  // OKAY
                            end
                            axi4If.BVALID <= 1'b1;
                        end else begin
                            // Continue burst - increment address
                            write_addr <= write_addr + write_addr_incr;
                            write_burst_cnt <= write_burst_cnt - 1'b1;
                        end
                    end
                end
                
                W_RESP: begin
                    if (axi4If.BREADY && axi4If.BVALID) begin
                        axi4If.BVALID <= 1'b0;
                        axi4If.BRESP <= 2'b00;
                        write_state <= W_IDLE;
                    end
                end
                
                default: write_state <= W_IDLE;
            endcase

            // --------------------------
            // Read Channel FSM
            // --------------------------
            
            case (read_state)
                R_IDLE: begin
                    axi4If.ARREADY <= 1'b1;
                    axi4If.RVALID <= 1'b0;
                    axi4If.RLAST <= 1'b0;
                    
                    if (axi4If.ARVALID && axi4If.ARREADY) begin
                        // Capture address phase information
                        read_addr <= axi4If.ARADDR;
                        read_burst_len <= axi4If.ARLEN;
                        read_burst_cnt <= axi4If.ARLEN;
                        read_size <= axi4If.ARSIZE;
                        
                        axi4If.ARREADY <= 1'b0;
                        read_state <= R_ADDR;
                    end
                end
                
                R_ADDR: begin
                    // Start first read
                    if (read_addr_valid && !read_boundary_cross) begin
                        mem_en <= 1'b1;
                        mem_addr <= read_addr >> 2;  // Convert to word address
                        
                    end
                    read_state <= R_DATA;
                end
                
                R_DATA: begin
                    // Present read data
                    if (read_addr_valid && !read_boundary_cross) begin
                        axi4If.RDATA <= mem_rdata;
                        axi4If.RRESP <= 2'b00;  // OKAY
                    end else begin
                        axi4If.RDATA <= {axi4If.DATA_WIDTH{1'b0}};
                        axi4If.RRESP <= 2'b10;  // SLVERR
                    end
                    
                    axi4If.RVALID <= 1'b1;
                    axi4If.RLAST <= (read_burst_cnt == 0);
                    
                    if (axi4If.RREADY && axi4If.RVALID) begin
                        axi4If.RVALID <= 1'b0;
                        
                        if (read_burst_cnt > 0) begin
                            // Continue burst
                            read_addr <= read_addr + read_addr_incr;
                            read_burst_cnt <= read_burst_cnt - 1'b1;
                            
                            // Start next read
                            if (read_addr_valid && !read_boundary_cross) begin
                                mem_en <= 1'b1;
                                mem_addr <= (read_addr + read_addr_incr) >> 2;
                            end
                            
                            // Stay in R_DATA for next transfer
                        end else begin
                            // End of burst
                            axi4If.RLAST <= 1'b0;
                            read_state <= R_IDLE;
                        end
                    end
                end
                
                default: read_state <= R_IDLE;
            endcase
        end
    end

endmodule