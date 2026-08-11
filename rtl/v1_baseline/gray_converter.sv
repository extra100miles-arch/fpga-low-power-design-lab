//=============================================================================
// File        : gray_converter.sv
// Project     : FPGA Low Power Design Lab
// Version     : V1 - Baseline
//
// Purpose:
//   Convert an 8-bit RGB pixel into an 8-bit grayscale pixel.
//
// Description:
//   A hardware-friendly grayscale approximation is used:
//
//       Gray = (R + 2*G + B) / 4
//
//   The division by four is implemented as a right shift.
//
//   The arithmetic is intentionally performed every clock cycle in the
//   baseline implementation, regardless of pixel_valid.
//
// Inputs:
//   clk       - System clock
//   rst_n     - Active-low synchronous reset
//   in_valid  - Indicates valid RGB data
//   in_r      - Red component
//   in_g      - Green component
//   in_b      - Blue component
//
// Outputs:
//   out_valid - Delayed valid signal
//   out_gray  - 8-bit grayscale pixel
//
// Architecture:
//   Combinational arithmetic calculates the grayscale value.
//   A register stores the result and valid signal.
//
// Baseline Power Behavior:
//   The arithmetic remains active every cycle.
//   Later versions will introduce clock enable and operand isolation.
//=============================================================================

module gray_converter #(
    parameter int PIXEL_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic                   in_valid,
    input  logic [PIXEL_WIDTH-1:0] in_r,
    input  logic [PIXEL_WIDTH-1:0] in_g,
    input  logic [PIXEL_WIDTH-1:0] in_b,

    output logic                   out_valid,
    output logic [PIXEL_WIDTH-1:0] out_gray
);

    // Maximum value:
    //
    // 255 + (2 * 255) + 255 = 1020
    //
    // Therefore 10 bits are required before the divide-by-four operation.
    logic [9:0] gray_sum;

    logic [PIXEL_WIDTH-1:0] gray_comb;

    always_comb begin
        gray_sum  = {2'b00, in_r}
                  + ({2'b00, in_g} << 1)
                  + {2'b00, in_b};

        gray_comb = gray_sum >> 2;
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid <= 1'b0;
            out_gray  <= '0;
        end
        else begin
            // Baseline: register updates every clock.
            out_valid <= in_valid;
            out_gray  <= gray_comb;
        end
    end

endmodule
