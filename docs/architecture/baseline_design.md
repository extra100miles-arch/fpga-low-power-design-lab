FPGA Low Power Design Lab
Baseline Design Specification

Version: 1.0

Author: Your Name

1. Objective
Purpose

The baseline implementation serves as the reference design for the entire project.

No power optimization techniques are applied in this version.

Every pipeline stage operates on every clock cycle regardless of whether the incoming pixel is valid.

Future versions will introduce RTL optimizations and compare their impact on power consumption, timing, and resource utilization against this baseline.

2. Design Philosophy

The objective of this project is not image processing accuracy.

The image-processing algorithms are intentionally simple so that changes in FPGA implementation metrics can be attributed to RTL design techniques rather than algorithmic complexity.

The design emphasizes:

Modular RTL
Streaming architecture
One pixel per clock throughput
Parameterized modules
Easy-to-understand hardware
Measurable power optimizations
3. System Overview

The processing pipeline consists of five stages.

                +-------------------+
Pixel Source -->| Gray Converter    |
                +-------------------+
                          |
                          ▼
                +-------------------+
                | Edge Detector     |
                +-------------------+
                          |
                          ▼
                +-------------------+
                | Threshold         |
                +-------------------+
                          |
                          ▼
                +-------------------+
                | Output Register   |
                +-------------------+

Each stage performs a single operation.

Each stage is separated by pipeline registers.

4. Why this Pipeline?

The pipeline was selected because it contains a representative mix of FPGA hardware resources.

Stage	Hardware Used
Gray Conversion	Adders
Edge Detection	Registers + Subtractor + Comparator
Threshold	Comparator + Multiplexer
Output Register	Flip-Flops

This allows the project to study both sequential and combinational switching activity.

5. Pipeline Architecture

The design processes one pixel every clock cycle.

Pipeline latency:

4 clock cycles

Pipeline throughput:

1 pixel / clock

Example

Clock

1

Pixel1 → Gray

-------------------------

2

Pixel1 → Edge

Pixel2 → Gray

-------------------------

3

Pixel1 → Threshold

Pixel2 → Edge

Pixel3 → Gray

-------------------------

4

Pixel1 → Output

Pixel2 → Threshold

Pixel3 → Edge

Pixel4 → Gray
6. Streaming Interface

Every module uses the same interface.

clk

rst_n

in_valid

in_pixel[7:0]

out_valid

out_pixel[7:0]

Keeping a common interface allows future optimizations to be introduced without redesigning the pipeline.

7. Module Responsibilities
Pixel Source

Purpose

Generates an input pixel stream.

Responsibilities

Receive pixels from the testbench
Generate valid signal
Forward pixels into the pipeline

No image processing occurs here.

Gray Converter

Purpose

Convert RGB intensity to grayscale.

Simplified equation

Gray = (R + G + B)/3

For this project, the implementation will use an efficient hardware-friendly approximation.

Main hardware

Adders
Shift
Register
Edge Detector

Purpose

Detect intensity changes.

Algorithm

Edge = |Current - Previous|

If neighbouring pixels differ significantly,

an edge exists.

Hardware

Register
Subtractor
Absolute value
Threshold

Purpose

Convert grayscale edge magnitude into binary output.

if Edge > Threshold

255

else

0

Hardware

Comparator
Multiplexer
Output Register

Purpose

Register the final output.

Benefits

Better timing
Cleaner interfaces
Allows future clock-enable optimization
8. Pipeline Timing

Each stage requires one clock.

Input

↓

Gray

↓

Edge

↓

Threshold

↓

Output

Latency

4 cycles

Throughput

1 pixel every clock
9. Data Width
Signal	Width
Pixel	8 bits
Valid	1 bit
Gray	8 bits
Edge	8 bits
Threshold	8 bits
10. Reset Strategy

Synchronous active-low reset.

rst_n

All pipeline registers are reset to zero.

11. Baseline Behaviour

The baseline implementation intentionally performs computation on every clock cycle.

Even if

in_valid = 0

the arithmetic logic still evaluates.

This increases unnecessary switching activity and therefore provides a suitable reference for later optimization.

12. Expected RTL Hierarchy
pipeline_top

│

├── pixel_source

├── gray_converter

├── edge_detector

├── threshold

└── output_register
13. Expected RTL Schematic

We expect Vivado RTL Viewer to show

Pipeline Top

↓

Pixel Source

↓

Gray Converter

↓

Edge Detector

↓

Threshold

↓

Output Register

Each module should appear as a distinct hierarchical block.

14. Expected Technology Schematic

After synthesis,

Vivado should infer

LUTs
Flip-Flops
Adders
Comparators

No DSP blocks are expected.

No BRAM is expected.

No Clock Enables.

15. Experimental Goal

The baseline design establishes the reference values for

Dynamic Power
Static Power
Clock Power
Logic Power
Signal Power
LUT Utilization
Register Utilization
Timing
Maximum Frequency

All subsequent optimization techniques will be compared against these measurements.

16. Assumptions
Single clock domain
100 MHz target clock
8-bit pixel stream
One pixel per clock
No external memory
No AXI
No DMA
Pure RTL implementation
17. Future Optimizations

The following versions will modify this baseline.

Version	Optimization
V2	Clock Enable
V3	Operand Isolation
V4	Pipeline Control
V5	Resource Sharing
V6	FSM Optimization
18. Design Decisions

This section documents why key architectural choices were made.

Why streaming?

To avoid frame buffers and enable one-pixel-per-clock processing.

Why simple algorithms?

To isolate the effects of RTL optimizations from algorithmic complexity.

Why modular stages?

To make it easy to attribute changes in power, timing, and utilization to a specific processing stage.

Why registered outputs?

To improve timing closure and provide a natural point for future clock-enable and pipeline-control optimizations.
