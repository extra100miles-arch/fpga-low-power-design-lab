//=============================================================================
// File        : pixel_source.sv
// Project     : FPGA Low Power Design Lab
// Version     : V1 - Baseline
//
// Purpose:
//   Provides the input staging register for the streaming image-processing
//   pipeline.
//
// Description:
//   The module represents the interface between an external pixel source
//   (for example, a camera interface or testbench) and the internal FPGA
//   processing pipeline.
//
//   RGB data and its valid indication are registered on every clock cycle.
//   This is the BASELINE implementation, so there is intentionally no
//   clock-enable optimization.
//
//   Even when in_valid is LOW, the input registers continue to update.
//   The valid signal determines whether the corresponding pixel is meaningful.
//
// Inputs:
//   clk       - System clock
//   rst_n     - Active-low synchronous reset
//   in_valid  - Indicates that RGB input contains a valid pixel
//   in_r      - 8-bit red component
//   in_g      - 8-bit green component
//   in_b      - 8-bit blue component
//
// Outputs:
//   out_valid - Registered valid signal
//   out_r     - Registered red component
//   out_g     - Registered green component
//   out_b     - Registered blue component
//
// Architecture:
//   Input RGB channels are registered before entering the processing pipeline.
//
// Baseline Power Behavior:
//   Registers update on every clock cycle regardless of in_valid.
//   This intentional behavior provides the reference implementation against
//   which clock-enable optimization will later be compared.
//=============================================================================

module pixel_source #(
    parameter int PIXEL_WIDTH = 8
) (
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  in_valid,
    input  logic [PIXEL_WIDTH-1:0] in_r,
    input  logic [PIXEL_WIDTH-1:0] in_g,
    input  logic [PIXEL_WIDTH-1:0] in_b,

    output logic                  out_valid,
    output logic [PIXEL_WIDTH-1:0] out_r,
    output logic [PIXEL_WIDTH-1:0] out_g,
    output logic [PIXEL_WIDTH-1:0] out_b
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_r     <= '0;
            out_g     <= '0;
            out_b     <= '0;
        end
        else begin
            // Baseline: registers update every clock.
            out_valid <= in_valid;
            out_r     <= in_r;
            out_g     <= in_g;
            out_b     <= in_b;
        end
    end

endmodule
