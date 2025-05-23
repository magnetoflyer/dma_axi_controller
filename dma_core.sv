module dma_core (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         clk_en,        // Clock gating control
    input  wire         power_on,      // Power gating control
    input  wire         start_dma,
    input  wire [31:0]  src_addr,
    input  wire [31:0]  dest_addr,
    input  wire [31:0]  transfer_len,
    output reg          dma_done,

    // AXI Master (simplified)
    output reg [31:0]   axi_araddr,
    output reg          axi_arvalid,
    input  wire         axi_arready,
    input  wire [31:0]  axi_rdata,
    input  wire         axi_rvalid,
    output reg          axi_rready,

    output reg [31:0]   axi_awaddr,
    output reg          axi_awvalid,
    input  wire         axi_awready,

    output reg [31:0]   axi_wdata,
    output reg          axi_wvalid,
    input  wire         axi_wready,

    input  wire         axi_bvalid,
    output reg          axi_bready
);

typedef enum logic [2:0] {
    IDLE, CONFIG, READ, WRITE, CHECK, DONE
} dma_state_t;

dma_state_t state, next_state;

reg [31:0] read_data;
reg [31:0] bytes_left;
reg [31:0] read_ptr, write_ptr;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n || !power_on)
        state <= IDLE;
    else if (clk_en)
        state <= next_state;
end

// DMA FSM
always @(*) begin
    next_state = state;
    case (state)
        IDLE: begin
            if (start_dma)
                next_state = CONFIG;
        end

        CONFIG: begin
            next_state = READ;
        end

        READ: begin
            if (axi_arready && axi_rvalid)
                next_state = WRITE;
        end

        WRITE: begin
            if (axi_awready && axi_wready)
                next_state = CHECK;
        end

        CHECK: begin
            if (bytes_left == 0)
                next_state = DONE;
            else
                next_state = READ;
        end

        DONE: begin
            next_state = IDLE;
        end
    endcase
end

// Control signals
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dma_done <= 0;
        bytes_left <= 0;
        read_ptr <= 0;
        write_ptr <= 0;
        axi_arvalid <= 0;
        axi_rready  <= 0;
        axi_awvalid <= 0;
        axi_wvalid  <= 0;
        axi_bready  <= 0;
    end else if (clk_en && power_on) begin
        case (state)
            IDLE: begin
                dma_done <= 0;
            end

            CONFIG: begin
                read_ptr <= src_addr;
                write_ptr <= dest_addr;
                bytes_left <= transfer_len;
            end

            READ: begin
                axi_araddr <= read_ptr;
                axi_arvalid <= 1;
                axi_rready <= 1;
                if (axi_rvalid) begin
                    read_data <= axi_rdata;
                    read_ptr <= read_ptr + 4;
                    axi_arvalid <= 0;
                    axi_rready <= 0;
                end
            end

            WRITE: begin
                axi_awaddr <= write_ptr;
                axi_wdata <= read_data;
                axi_awvalid <= 1;
                axi_wvalid <= 1;
                axi_bready <= 1;

                if (axi_wready && axi_awready) begin
                    write_ptr <= write_ptr + 4;
                    bytes_left <= bytes_left - 4;
                    axi_awvalid <= 0;
                    axi_wvalid <= 0;
                end
            end

            CHECK: begin
                axi_bready <= 0;
            end

            DONE: begin
                dma_done <= 1;
            end
        endcase
    end
end

endmodule
