module soc_top (
    input  wire         clk,
    input  wire         rst_n,

    // AXI-Lite Slave (CPU control)
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

    // Simulated AXI memory interface
    output wire [31:0]  axi_araddr,
    output wire         axi_arvalid,
    input  wire         axi_arready,
    input  wire [31:0]  axi_rdata,
    input  wire         axi_rvalid,
    output wire         axi_rready,
    output wire [31:0]  axi_awaddr,
    output wire         axi_awvalid,
    input  wire         axi_awready,
    output wire [31:0]  axi_wdata,
    output wire         axi_wvalid,
    input  wire         axi_wready,
    input  wire         axi_bvalid,
    output wire         axi_bready
);

wire [31:0] src_addr, dest_addr, transfer_len;
wire start_dma, dma_done;

// Clock and power gating signals
wire clk_en, power_on;
wire gated_clk;

// Clock Gating
clock_gate u_clk_gate (
    .clk(clk),
    .clk_en(clk_en),
    .gated_clk(gated_clk)
);

// DMA Configuration Register Interface
dma_axi_slave u_axi_slave (
    .clk(clk),
    .rst_n(rst_n),
    .s_axi_awaddr(s_axi_awaddr),
    .s_axi_awvalid(s_axi_awvalid),
    .s_axi_wvalid(s_axi_wvalid),
    .s_axi_wdata(s_axi_wdata),
    .s_axi_araddr(s_axi_araddr),
    .s_axi_arvalid(s_axi_arvalid),
    .s_axi_awready(s_axi_awready),
    .s_axi_wready(s_axi_wready),
    .s_axi_bvalid(s_axi_bvalid),
    .s_axi_rdata(s_axi_rdata),
    .s_axi_arready(s_axi_arready),
    .s_axi_rvalid(s_axi_rvalid),
    .src_addr(src_addr),
    .dest_addr(dest_addr),
    .transfer_len(transfer_len),
    .start_dma(start_dma)
);

// Idle detection logic (simplified)
reg [15:0] idle_counter;
assign clk_en = (idle_counter < 16'd50);
assign power_on = (idle_counter < 16'd200);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        idle_counter <= 0;
    else if (start_dma)
        idle_counter <= 0;
    else if (!dma_done)
        idle_counter <= idle_counter;
    else
        idle_counter <= idle_counter + 1;
end

// DMA Core with power/clock gating
dma_core u_dma (
    .clk(gated_clk),
    .rst_n(rst_n),
    .clk_en(clk_en),
    .power_on(power_on),
    .start_dma(start_dma),
    .src_addr(src_addr),
    .dest_addr(dest_addr),
    .transfer_len(transfer_len),
    .dma_done(dma_done),
    .axi_araddr(axi_araddr),
    .axi_arvalid(axi_arvalid),
    .axi_arready(axi_arready),
    .axi_rdata(axi_rdata),
    .axi_rvalid(axi_rvalid),
    .axi_rready(axi_rready),
    .axi_awaddr(axi_awaddr),
    .axi_awvalid(axi_awvalid),
    .axi_awready(axi_awready),
    .axi_wdata(axi_wdata),
    .axi_wvalid(axi_wvalid),
    .axi_wready(axi_wready),
    .axi_bvalid(axi_bvalid),
    .axi_bready(axi_bready)
);

endmodule
