module soc_tb;

reg clk = 0;
reg rst_n = 0;

// AXI-Lite inputs
reg [31:0] awaddr, wdata, araddr;
reg        awvalid, wvalid, arvalid;
wire       awready, wready, bvalid, arready, rvalid;
wire [31:0] rdata;

// AXI Master outputs (memory)
wire [31:0] araddr_dma, awaddr_dma, wdata_dma;
wire        arvalid_dma, arready_dma, rvalid_dma;
wire        rready_dma, awvalid_dma, awready_dma;
wire        wvalid_dma, wready_dma, bvalid_dma, bready_dma;

// Simulated memory
reg [31:0] mem [0:255];
assign arready_dma = 1;
assign awready_dma = 1;
assign wready_dma  = 1;
assign bvalid_dma  = 1;
assign rvalid_dma  = 1;
assign rdata       = mem[araddr_dma[7:2]];

assign rready_dma  = 1;
assign bready_dma  = 1;

// DUT
soc_top dut (
    .clk(clk),
    .rst_n(rst_n),
    .s_axi_awaddr(awaddr),
    .s_axi_awvalid(awvalid),
    .s_axi_wvalid(wvalid),
    .s_axi_wdata(wdata),
    .s_axi_araddr(araddr),
    .s_axi_arvalid(arvalid),
    .s_axi_awready(awready),
    .s_axi_wready(wready),
    .s_axi_bvalid(bvalid),
    .s_axi_rdata(rdata),
    .s_axi_arready(arready),
    .s_axi_rvalid(rvalid),
    .axi_araddr(araddr_dma),
    .axi_arvalid(arvalid_dma),
    .axi_arready(arready_dma),
    .axi_rdata(mem[araddr_dma[7:2]]),
    .axi_rvalid(rvalid_dma),
    .axi_rready(rready_dma),
    .axi_awaddr(awaddr_dma),
    .axi_awvalid(awvalid_dma),
    .axi_awready(awready_dma),
    .axi_wdata(wdata_dma),
    .axi_wvalid(wvalid_dma),
    .axi_wready(wready_dma),
    .axi_bvalid(bvalid_dma),
    .axi_bready(bready_dma)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    $dumpfile("soc_tb.vcd");
    $dumpvars(0, soc_tb);

    rst_n = 0;
    #20 rst_n = 1;

    // Preload memory
    mem[0] = 32'hDEADBEEF;
    mem[1] = 32'hBAADF00D;

    // CPU writes SRC, DEST, LEN, START
    #10 awaddr = 32'h00; wdata = 0; awvalid = 1; wvalid = 1; #10 awvalid = 0; wvalid = 0;
    #10 awaddr = 32'h04; wdata = 4; awvalid = 1; wvalid = 1; #10 awvalid = 0; wvalid = 0;
    #10 awaddr = 32'h08; wdata = 8; awvalid = 1; wvalid = 1; #10 awvalid = 0; wvalid = 0;
    #10 awaddr = 32'h0C; wdata = 1; awvalid = 1; wvalid = 1; #10 awvalid = 0; wvalid = 0;

    #200 $finish;
end

endmodule
