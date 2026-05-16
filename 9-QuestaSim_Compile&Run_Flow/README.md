# QuestaSim / ModelSim Simulation Flow

This folder contains a robust, production-ready TCL script tailored specifically for the **Mentor QuestaSim / ModelSim** ecosystem. 

While the core TCL syntax remains standard across EDA tools, the compilation and simulation commands (`vlib`, `vlog`, `vsim`) are proprietary to Siemens. This example demonstrates how to efficiently automate a complete simulation flow using these specific commands.

## Key Features

- **Workspace Cleanup:** Automatically detects and deletes old `work` libraries to prevent ghost errors from previous runs.
- **Robust Compilation (`vlog`):** Compiles SystemVerilog RTL and Testbench files with advanced coverage flags (`-cover bces`). It also includes a `catch` mechanism to stop the flow immediately if syntax errors occur.
- **Elaboration & Optimization (`vsim`):** Loads the testbench using `+acc` to prevent the simulator from optimizing away internal signals, ensuring they are visible in waveforms.
- **Automated Coverage Reporting:** Runs the simulation to completion and generates a detailed textual code coverage report (`questa_cov_report.txt`).

## How to Run

You need to have QuestaSim or ModelSim installed and accessible in your system `PATH`. 

### 1. Batch Mode (Terminal/Console)
The fastest way to run regressions. This will execute the entire flow in the terminal without opening the graphical interface, generate the coverage report, and exit automatically:
```sh
vsim -c -do qcompile_run.tcl.tcl
```

### 2. GUI Mode
If you want to debug the design and view the waveforms, open the simulator GUI and run the script from the internal TCL console:
```tcl
do qcompile_run.tcl.tcl
```
