module clock_gate (
    input  wire clk,
    input  wire clk_en,
    output wire gated_clk
);

assign gated_clk = clk & clk_en;

endmodule