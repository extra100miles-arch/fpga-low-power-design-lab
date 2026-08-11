//=============================================================================
// File        : tb_pipeline_top.sv
// Project     : FPGA Low Power Design Lab
// Version     : V1 - Baseline
//
// Purpose:
//   Self-checking simulation environment for the baseline image-processing
//   pipeline.
//
// Testbench Features:
//   - Clock generation
//   - Synchronous reset
//   - Directed test cases
//   - Random RGB pixels
//   - Random valid/idle cycles
//   - Expected-output reference model
//   - Four-cycle latency checking
//   - PASS/FAIL reporting
//   - VCD waveform generation
//
// Simulation:
//   Recommended with Icarus Verilog:
//
//   iverilog -g2012 \
//       -o sim.out \
//       rtl/v1_baseline/*.sv \
//       tb/v1/reference_model.sv \
//       tb/v1/tb_pipeline_top.sv
//
//   vvp sim.out
//
// Waveform:
//
//   gtkwave baseline.vcd
//=============================================================================

`timescale 1ns/1ps

module tb_pipeline_top;

    localparam int PIXEL_WIDTH     = 8;
    localparam int THRESHOLD_VALUE = 8'd32;
    localparam int PIPELINE_LATENCY = 4;

    //-------------------------------------------------------------------------
    // Clock / Reset
    //-------------------------------------------------------------------------

    logic clk;
    logic rst_n;

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    //-------------------------------------------------------------------------
    // DUT Inputs
    //-------------------------------------------------------------------------

    logic                   pixel_valid;
    logic [PIXEL_WIDTH-1:0] pixel_r;
    logic [PIXEL_WIDTH-1:0] pixel_g;
    logic [PIXEL_WIDTH-1:0] pixel_b;

    //-------------------------------------------------------------------------
    // DUT Outputs
    //-------------------------------------------------------------------------

    logic                   output_valid;
    logic [PIXEL_WIDTH-1:0] output_pixel;

    //-------------------------------------------------------------------------
    // Expected Output Pipeline
    //-------------------------------------------------------------------------

    logic [PIXEL_WIDTH-1:0] expected_pixel_pipe [0:PIPELINE_LATENCY-1];
    logic                   expected_valid_pipe [0:PIPELINE_LATENCY-1];

    //-------------------------------------------------------------------------
    // Reference-model state
    //-------------------------------------------------------------------------

    logic [7:0] previous_gray;

    integer cycle_count;
    integer error_count;

    //-------------------------------------------------------------------------
    // DUT
    //-------------------------------------------------------------------------

    pipeline_top #(
        .PIXEL_WIDTH     (PIXEL_WIDTH),
        .THRESHOLD_VALUE (THRESHOLD_VALUE)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),

        .pixel_valid  (pixel_valid),
        .pixel_r      (pixel_r),
        .pixel_g      (pixel_g),
        .pixel_b      (pixel_b),

        .output_valid (output_valid),
        .output_pixel (output_pixel)
    );

    //-------------------------------------------------------------------------
    // VCD
    //-------------------------------------------------------------------------

    initial begin
        $dumpfile("baseline.vcd");
        $dumpvars(0, tb_pipeline_top);
    end

    //-------------------------------------------------------------------------
    // Reset
    //-------------------------------------------------------------------------

    initial begin
        rst_n        = 1'b0;
        pixel_valid  = 1'b0;
        pixel_r      = 8'h00;
        pixel_g      = 8'h00;
        pixel_b      = 8'h00;

        cycle_count  = 0;
        error_count  = 0;
        previous_gray = 8'h00;

        for (int i = 0; i < PIPELINE_LATENCY; i++) begin
            expected_pixel_pipe[i] = 8'h00;
            expected_valid_pipe[i] = 1'b0;
        end

        repeat (3) @(posedge clk);

        rst_n = 1'b1;
    end

    //-------------------------------------------------------------------------
    // Drive inputs
    //-------------------------------------------------------------------------
    //
    // Inputs are changed on the falling edge so that they are stable before
    // the next rising edge.
    //-------------------------------------------------------------------------

    task automatic drive_pixel(
        input logic       valid,
        input logic [7:0] r,
        input logic [7:0] g,
        input logic [7:0] b
    );

        begin
            @(negedge clk);

            pixel_valid = valid;
            pixel_r     = r;
            pixel_g     = g;
            pixel_b     = b;
        end

    endtask

    //-------------------------------------------------------------------------
    // Main stimulus
    //-------------------------------------------------------------------------

    initial begin

        wait (rst_n == 1'b1);

        //=====================================================================
        // Directed tests
        //=====================================================================

        // Black pixel
        drive_pixel(1'b1, 8'd0,   8'd0,   8'd0);

        // White pixel
        drive_pixel(1'b1, 8'd255, 8'd255, 8'd255);

        // Mid-gray pixel
        drive_pixel(1'b1, 8'd128, 8'd128, 8'd128);

        // Strong color transition
        drive_pixel(1'b1, 8'd255, 8'd0,   8'd0);

        // Idle cycle
        drive_pixel(1'b0, 8'd0,   8'd0,   8'd0);

        // Another valid pixel after idle
        drive_pixel(1'b1, 8'd0,   8'd255, 8'd0);

        //=====================================================================
        // Threshold boundary tests
        //=====================================================================

        // Several values around the threshold
        drive_pixel(1'b1, 8'd32,  8'd32,  8'd32);
        drive_pixel(1'b1, 8'd64,  8'd64,  8'd64);
        drive_pixel(1'b1, 8'd16,  8'd16,  8'd16);

        //=====================================================================
        // Randomized testing
        //=====================================================================

        for (int i = 0; i < 500; i++) begin

            drive_pixel(
                ($urandom_range(0, 9) < 7),
                $urandom_range(0, 255),
                $urandom_range(0, 255),
                $urandom_range(0, 255)
            );

        end

        // Flush the pipeline
        repeat (PIPELINE_LATENCY + 2)
            drive_pixel(1'b0, 8'h00, 8'h00, 8'h00);

        repeat (2)
            @(posedge clk);

        if (error_count == 0) begin
            $display("");
            $display("==================================================");
            $display("              BASELINE TEST PASSED");
            $display("==================================================");
            $display("Cycles checked : %0d", cycle_count);
            $display("Errors         : %0d", error_count);
            $display("==================================================");
        end
        else begin
            $display("");
            $display("==================================================");
            $display("              BASELINE TEST FAILED");
            $display("==================================================");
            $display("Cycles checked : %0d", cycle_count);
            $display("Errors         : %0d", error_count);
            $display("==================================================");
        end

        $finish;
    end

    //-------------------------------------------------------------------------
    // Expected-value generation
    //-------------------------------------------------------------------------
    //
    // This block runs on the same clock as the DUT.
    //
    // The expected result is generated from the current input transaction,
    // then delayed through a four-cycle software pipeline.
    //-------------------------------------------------------------------------

    always @(posedge clk) begin

        logic [7:0] current_gray;
        logic [7:0] current_edge;
        logic [7:0] current_output;

        cycle_count = cycle_count + 1;

        // Wait a small delta cycle so DUT outputs have updated.
        #1;

        //=====================================================================
        // Compare the result that should emerge from the DUT this cycle.
        //=====================================================================

        if (expected_valid_pipe[PIPELINE_LATENCY-1]) begin

            if (!output_valid) begin

                $display(
                    "[ERROR] Cycle %0d: Expected valid output, got valid=0",
                    cycle_count
                );

                error_count = error_count + 1;
            end
            else if (output_pixel !==
                     expected_pixel_pipe[PIPELINE_LATENCY-1]) begin

                $display(
                    "[ERROR] Cycle %0d: Expected pixel=%0d, got pixel=%0d",
                    cycle_count,
                    expected_pixel_pipe[PIPELINE_LATENCY-1],
                    output_pixel
                );

                error_count = error_count + 1;
            end

        end
        else begin

            if (output_valid) begin

                $display(
                    "[ERROR] Cycle %0d: Unexpected valid output, pixel=%0d",
                    cycle_count,
                    output_pixel
                );

                error_count = error_count + 1;
            end

        end

        //=====================================================================
        // Shift expected-output pipeline.
        //=====================================================================

        for (int i = PIPELINE_LATENCY-1; i > 0; i--) begin
            expected_pixel_pipe[i] = expected_pixel_pipe[i-1];
            expected_valid_pipe[i] = expected_valid_pipe[i-1];
        end

        //=====================================================================
        // Generate expected result for current input.
        //=====================================================================

        expected_valid_pipe[0] = pixel_valid;
        expected_pixel_pipe[0] = 8'h00;

        if (pixel_valid) begin

            current_gray =
                  reference_gray(
                      pixel_r,
                      pixel_g,
                      pixel_b
                  );

            current_edge =
                  reference_edge(
                      current_gray,
                      previous_gray
                  );

            current_output =
                  reference_threshold(
                      current_edge,
                      THRESHOLD_VALUE
                  );

            expected_pixel_pipe[0] = current_output;

            // Only VALID pixels participate in edge history.
            previous_gray = current_gray;

        end

    end

endmodule
