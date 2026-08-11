//=============================================================================
// File        : pipeline_top.sv
// Project     : FPGA Low Power Design Lab
// Version     : V1 - Baseline
//
// Purpose:
//   Top-level integration of the baseline streaming image-processing
//   pipeline.
//
// Pipeline:
//
//   RGB Input
//       |
//       v
//   Pixel Source
//       |
//       v
//   Grayscale Conversion
//       |
//       v
//   Edge Detection
//       |
//       v
//   Threshold
//       |
//       v
//   Output Register
//
// Throughput:
//   One pixel per clock after pipeline fill.
//
// Latency:
//   Four clock cycles from input acceptance to output.
//
// Baseline Characteristics:
//   - No clock gating
//   - No clock enable optimization
//   - No operand isolation
//   - No resource sharing beyond natural synthesis optimization
//   - No back-pressure
//   - No AXI
//   - No external IP
//=============================================================================

module pipeline_top #(
    parameter int PIXEL_WIDTH     = 8,
    parameter int THRESHOLD_VALUE = 8'd32
) (
    input  logic                   clk,
    input  logic                   rst_n,

    input  logic                   pixel_valid,
    input  logic [PIXEL_WIDTH-1:0] pixel_r,
    input  logic [PIXEL_WIDTH-1:0] pixel_g,
    input  logic [PIXEL_WIDTH-1:0] pixel_b,

    output logic                   output_valid,
    output logic [PIXEL_WIDTH-1:0] output_pixel
);

    //-------------------------------------------------------------------------
    // Pixel Source
    //-------------------------------------------------------------------------

    logic                   source_valid;
    logic [PIXEL_WIDTH-1:0] source_r;
    logic [PIXEL_WIDTH-1:0] source_g;
    logic [PIXEL_WIDTH-1:0] source_b;

    //-------------------------------------------------------------------------
    // Grayscale Converter
    //-------------------------------------------------------------------------

    logic                   gray_valid;
    logic [PIXEL_WIDTH-1:0] gray_pixel;

    //-------------------------------------------------------------------------
    // Edge Detector
    //-------------------------------------------------------------------------

    logic                   edge_valid;
    logic [PIXEL_WIDTH-1:0] edge_pixel;

    //-------------------------------------------------------------------------
    // Threshold
    //-------------------------------------------------------------------------

    logic                   threshold_valid;
    logic [PIXEL_WIDTH-1:0] threshold_pixel;

    //-------------------------------------------------------------------------
    // Pixel Source
    //-------------------------------------------------------------------------

    pixel_source #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_pixel_source (
        .clk       (clk),
        .rst_n     (rst_n),

        .in_valid  (pixel_valid),
        .in_r      (pixel_r),
        .in_g      (pixel_g),
        .in_b      (pixel_b),

        .out_valid (source_valid),
        .out_r     (source_r),
        .out_g     (source_g),
        .out_b     (source_b)
    );

    //-------------------------------------------------------------------------
    // Grayscale Conversion
    //-------------------------------------------------------------------------

    gray_converter #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_gray_converter (
        .clk       (clk),
        .rst_n     (rst_n),

        .in_valid  (source_valid),
        .in_r      (source_r),
        .in_g      (source_g),
        .in_b      (source_b),

        .out_valid (gray_valid),
        .out_gray  (gray_pixel)
    );

    //-------------------------------------------------------------------------
    // Edge Detection
    //-------------------------------------------------------------------------

    edge_detector #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_edge_detector (
        .clk       (clk),
        .rst_n     (rst_n),

        .in_valid  (gray_valid),
        .in_gray   (gray_pixel),

        .out_valid (edge_valid),
        .out_edge  (edge_pixel)
    );

    //-------------------------------------------------------------------------
    // Threshold
    //-------------------------------------------------------------------------

    threshold #(
        .PIXEL_WIDTH    (PIXEL_WIDTH),
        .THRESHOLD_VALUE(THRESHOLD_VALUE)
    ) u_threshold (
        .clk       (clk),
        .rst_n     (rst_n),

        .in_valid  (edge_valid),
        .in_edge   (edge_pixel),

        .out_valid (threshold_valid),
        .out_pixel (threshold_pixel)
    );

    //-------------------------------------------------------------------------
    // Output Register
    //-------------------------------------------------------------------------

    output_register #(
        .PIXEL_WIDTH(PIXEL_WIDTH)
    ) u_output_register (
        .clk       (clk),
        .rst_n     (rst_n),

        .in_valid  (threshold_valid),
        .in_pixel  (threshold_pixel),

        .out_valid (output_valid),
        .out_pixel (output_pixel)
    );

endmodule
