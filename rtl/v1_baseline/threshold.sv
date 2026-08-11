//=============================================================================
// File        : threshold.sv
// Project     : FPGA Low Power Design Lab
// Version     : V1 - Baseline
//
// Purpose:
//   Convert an 8-bit edge magnitude into a binary image.
//
// Description:
//   If the edge magnitude is greater than or equal to THRESHOLD_VALUE,
//   the output pixel is 255. Otherwise the output is 0.
//
// Inputs:
//   clk       - System clock
//   rst_n     - Active-low synchronous reset
//   in_valid  - Indicates valid edge data
//   in_edge   - Edge magnitude
//
// Outputs:
//   out_valid - Delayed valid signal
//   out_pixel - Thresholded output pixel
//
// Baseline Power Behavior:
//   Comparator and output register operate every clock cycle.
//=============================================================================

module threshold #(
    parameter int PIXEL_WIDTH     = 8,
    parameter int THRESHOLD_VALUE = 8'd32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic                   in_valid,
    input  logic [PIXEL_WIDTH-1:0] in_edge,

    output logic                   out_valid,
    output logic [PIXEL_WIDTH-1:0] out_pixel
);

    logic [PIXEL_WIDTH-1:0] threshold_comb;

    always_comb begin
        if (in_edge >= THRESHOLD_VALUE)
            threshold_comb = {PIXEL_WIDTH{1'b1}};
        else
            threshold_comb = '0;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_pixel <= '0;
        end
        else begin
            // Baseline: register updates every clock.
            out_valid <= in_valid;
            out_pixel <= threshold_comb;
        end
    end

endmodule
