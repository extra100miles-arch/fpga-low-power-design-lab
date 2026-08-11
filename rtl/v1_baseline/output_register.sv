//=============================================================================
// File        : output_register.sv
// Project     : FPGA Low Power Design Lab
// Version     : V1 - Baseline
//
// Purpose:
//   Register the final processed pixel before it leaves the pipeline.
//
// Description:
//   The output register provides a clean registered interface to downstream
//   logic.
//
// Inputs:
//   clk       - System clock
//   rst_n     - Active-low synchronous reset
//   in_valid  - Indicates valid processed pixel
//   in_pixel  - Processed pixel
//
// Outputs:
//   out_valid - Registered output-valid signal
//   out_pixel - Registered processed pixel
//
// Baseline Power Behavior:
//   The output register updates every clock cycle.
//=============================================================================

module output_register #(
    parameter int PIXEL_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic                   in_valid,
    input  logic [PIXEL_WIDTH-1:0] in_pixel,

    output logic                   out_valid,
    output logic [PIXEL_WIDTH-1:0] out_pixel
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_pixel <= '0;
        end
        else begin
            // Baseline: always update the output register.
            out_valid <= in_valid;
            out_pixel <= in_pixel;
        end
    end

endmodule
