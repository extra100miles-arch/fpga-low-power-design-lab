//=============================================================================
// File        : edge_detector.sv
// Project     : FPGA Low Power Design Lab
// Version     : V1 - Baseline
//
// Purpose:
//   Detect horizontal intensity changes between consecutive valid pixels.
//
// Description:
//   The edge magnitude is calculated as:
//
//       Edge = |Gray(current) - Gray(previous_valid_pixel)|
//
//   This is a deliberately simple streaming edge detector.
//
//   Only one previous grayscale pixel is stored, so no frame buffer or line
//   buffer is required.
//
// Inputs:
//   clk       - System clock
//   rst_n     - Active-low synchronous reset
//   in_valid  - Indicates valid grayscale data
//   in_gray   - Current grayscale pixel
//
// Outputs:
//   out_valid - Delayed valid signal
//   out_edge  - 8-bit edge magnitude
//
// Architecture:
//   - previous_gray stores the previous VALID grayscale pixel.
//   - Absolute difference is calculated combinationally.
//   - Edge result is registered.
//
// Baseline Power Behavior:
//   The edge arithmetic and output register operate every clock.
//   The previous-pixel state is updated only when a valid pixel arrives,
//   because this state is part of the algorithm rather than an optimization.
//=============================================================================

module edge_detector #(
    parameter int PIXEL_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic                   in_valid,
    input  logic [PIXEL_WIDTH-1:0] in_gray,

    output logic                   out_valid,
    output logic [PIXEL_WIDTH-1:0] out_edge
);

    logic [PIXEL_WIDTH-1:0] previous_gray;
    logic [PIXEL_WIDTH-1:0] edge_comb;

    always_comb begin
        if (in_gray >= previous_gray)
            edge_comb = in_gray - previous_gray;
        else
            edge_comb = previous_gray - in_gray;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid    <= 1'b0;
            out_edge     <= '0;
            previous_gray <= '0;
        end
        else begin
            // Baseline: edge result register updates every clock.
            out_valid <= in_valid;
            out_edge  <= edge_comb;

            // Algorithmic state:
            // retain the previous VALID pixel.
            if (in_valid)
                previous_gray <= in_gray;
        end
    end

endmodule
