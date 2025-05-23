module dma_axi_slave (
    input  wire         clk,
    input  wire         rst_n,

    // AXI-Lite Slave Interface
    input  wire [31:0]  s_axi_awaddr,
    input  wire         s_axi_awvalid,
    input  wire         s_axi_wvalid,
    input  wire [31:0]  s_axi_wdata,
    input  wire [31:0]  s_axi_araddr,
    input  wire         s_axi_arvalid,
    output wire         s_axi_awready,
    output wire         s_axi_wready,
    output wire         s_axi_bvalid,
    output wire [31:0]  s_axi_rdata,
    output wire         s_axi_arready,
    output wire         s_axi_rvalid,

    // Control outputs to DMA core
    output reg [31:0]   src_addr,
    output reg [31:0]   dest_addr,
    output reg [31:0]   transfer_len,
    output reg          start_dma
);

reg [31:0] regfile [0:3]; // 0: SRC, 1: DEST, 2: LEN, 3: START
assign s_axi_awready = 1'b1;
assign s_axi_wready  = 1'b1;
assign s_axi_bvalid  = 1'b1;
assign s_axi_arready = 1'b1;
assign s_axi_rvalid  = 1'b1;

// Register write logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        src_addr     <= 32'b0;
        dest_addr    <= 32'b0;
        transfer_len <= 32'b0;
        start_dma    <= 1'b0;
    end else begin
        if (s_axi_awvalid && s_axi_wvalid) begin
            case (s_axi_awaddr[5:2]) // aligned to word boundary
                4'h0: src_addr     <= s_axi_wdata;
                4'h1: dest_addr    <= s_axi_wdata;
                4'h2: transfer_len <= s_axi_wdata;
                4'h3: start_dma    <= s_axi_wdata[0]; // 1 to start
            endcase
        end

        // Clear start_dma after one cycle (pulse)
        if (start_dma)
            start_dma <= 1'b0;
    end
end

// AXI Read-back for debug (not used in this version)
assign s_axi_rdata = 32'b0;

endmodule
