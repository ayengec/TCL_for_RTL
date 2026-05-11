# 8 — Vivado Report Parsing with TCL

Vivado generates `.rpt` files after every synthesis and implementation run. This project shows how to parse those reports automatically using TCL — extracting timing violations, resource usage, and clock analysis, then writing clean summary logs.

---

## Project Structure

```
8-Report-Parsing/
├── parse_reports.tcl           # Main parser script
├── sample_reports/
│   ├── timing_summary.rpt      # Sample Vivado timing report  (Zynq-7020)
│   └── utilization.rpt         # Sample Vivado utilization report (Zynq-7020)
├── logs/                       # Auto-created on run
│   ├── report_summary.txt
│   ├── timing_details.txt
│   └── utilization_details.txt
└── README.md
```

---

## What This Project Covers

| TCL Concept | Where Used |
|---|---|
| File I/O (`open`, `gets`, `close`) | Reading `.rpt` files line by line |
| Regular expressions (`regexp`) | Extracting values from unstructured text |
| Procedures with return values | `parse_timing`, `parse_utilization` |
| Arrays | Storing resource data by name |
| `string is double` | Safe numeric comparisons |
| `format` | Aligned log tables |
| Threshold logic | Warning / critical flags on utilization |

---

## Sample Design

The `.rpt` files represent an **AXI4 Image Processing Pipeline** on a **Zynq-7020 (xc7z020clg400-1)**:

- Sobel edge detection core (DSP-heavy)
- Line buffer (BRAM-based)
- Histogram equalization block
- AXI4-Stream video input/output
- AXI4 DMA master interface
- 4 clock domains: `clk_100MHz`, `clk_200MHz`, `clk_pixel`, `axi_aclk`

The design has intentional timing violations in the 100 MHz domain — the parser catches and reports them.

---

## How to Run

### Standalone (no Vivado needed)

```bash
tclsh parse_reports.tcl
```

### Inside Vivado TCL Console

```tcl
source parse_reports.tcl
```

---

## Sample Output

```
============================================================
 Vivado Report Parser
============================================================

=== Overall Timing ===
  WNS : -1.247 ns
  TNS : -89.412 ns
  Failing Endpoints : 37
  STATUS : *** TIMING FAILED ***

=== Per-Clock Violations ===
  [FAIL] clk_100MHz    WNS= -1.247 ns  TNS= -89.412 ns  Failing=37
  [ OK ] clk_200MHz    WNS=  0.312 ns  TNS=   0.000 ns  Failing=0
  [ OK ] clk_pixel     WNS=  0.893 ns  TNS=   0.000 ns  Failing=0
  [ OK ] axi_aclk      WNS=  0.215 ns  TNS=   0.000 ns  Failing=0

=== Utilization ===
  [    OK     ] Slice LUTs       21847 / 53200   41.07%
  [    OK     ] Slice Registers  28941 / 106400  27.20%
  [    OK     ] Block RAM Tile      58 / 140      41.43%
  [    OK     ] DSPs                94 / 220      42.73%

--------------------------------------------------------------
  TIMING   : *** FAILED ***  WNS=-1.247 ns | Failing Endpoints=37
  Logs written to: ./logs/
--------------------------------------------------------------
```

---

## Using with Your Own Reports

After running implementation in Vivado:

```tcl
report_timing_summary -file ./reports/timing_summary.rpt
report_utilization    -file ./reports/utilization.rpt
```

Then update the paths in `parse_reports.tcl`:

```tcl
set timing_rpt  "./reports/timing_summary.rpt"
set util_rpt    "./reports/utilization.rpt"
```

Works with Vivado 2019.x – 2023.x without modification.

---

## Configurable Thresholds

```tcl
set warn_pct  70.0    # !   WARNING
set crit_pct  90.0    # !!! CRITICAL
```
