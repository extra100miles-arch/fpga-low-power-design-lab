//=============================================================================
// File        : reference_model.sv
// Project     : FPGA Low Power Design Lab
//
// Purpose:
//   Behavioral reference model for the baseline image-processing pipeline.
//
// Description:
//   The model calculates the expected output corresponding to each valid
//   input pixel. The testbench delays this expected result by the known
//   four-cycle pipeline latency before comparing it with the DUT.
//=============================================================================

function automatic logic [7:0] reference_gray(
    input logic [7:0] r,
    input logic [7:0] g,
    input logic [7:0] b
);

    logic [9:0] sum;

    begin
        sum = {2'b00, r}
            + ({2'b00, g} << 1)
            + {2'b00, b};

        reference_gray = sum >> 2;
    end

endfunction


function automatic logic [7:0] reference_edge(
    input logic [7:0] current_gray,
    input logic [7:0] previous_gray
);

    begin
        if (current_gray >= previous_gray)
            reference_edge = current_gray - previous_gray;
        else
            reference_edge = previous_gray - current_gray;
    end

endfunction


function automatic logic [7:0] reference_threshold(
    input logic [7:0] edge_value,
    input logic [7:0] threshold_value
);

    begin
        if (edge_value >= threshold_value)
            reference_threshold = 8'hFF;
        else
            reference_threshold = 8'h00;
    end

endfunction
