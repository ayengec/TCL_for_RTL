# Cadence Xcelium Compile & Run Flow

This directory demonstrates the complete flow for compiling and simulating SystemVerilog designs using **Cadence Xcelium**, specifically highlighting how bash scripts (`.sh`) and TCL scripts work together.

Unlike Siemens QuestaSim, which often uses TCL for both compilation and execution (`vlog` / `vsim`), Cadence Xcelium uses a unified single-step command (`xrun`) from the bash shell for compilation and elaboration. TCL is then passed into the simulator to control the execution phase (e.g., waveform dumping, coverage management, and simulation length).

## 1. The Compile Flow (`xrun_compile.sh`)

Compilation in Xcelium is heavily command-line driven. To automate this, we use the bash script `xrun_compile.sh`.

Inside the script, the standard compilation command looks like this:
```bash
xrun -clean \
     -sv \
     -access +rwc \
     -coverage all \
     tb_top.sv \
     -input cadence_xcelium_simulation_flow.tcl
```
* **`-clean`**: Removes previous compilation databases (INCA_libs).
* **`-sv`**: Enables SystemVerilog compilation.
* **`-access +rwc`**: Grants Read/Write/Connectivity access to the simulation database. **(Crucial: If you don't include this, you won't be able to dump waveforms!)**
* **`-coverage all`**: Instruments the code for coverage collection.
* **`-input ...`**: Passes our TCL script to Xcelium to run automatically after compilation finishes.

## 2. The Run Flow (TCL Dialect)

Once compiled, Xcelium needs instructions on how to run the simulation. This is handled by the `cadence_xcelium_simulation_flow.tcl` script. It highlights Cadence's proprietary TCL dialects:

*   **`database`**: Manages the Cadence SHM (Simulation History Manager) waveform database. The script creates and opens a database named `waves.shm`.
*   **`probe`**: Instructs the simulator on what signals to record. In this example, we probe all signals within `tb_top` and all its sub-hierarchies recursively (`-depth all`).
*   **`coverage`**: Controls the dumping of coverage data dynamically during simulation.
*   **`run`**: Executes the simulation for a specific duration or until a `$finish` statement is encountered in the SystemVerilog code.
*   **`exit`**: Safely closes the database (preventing corruption) and exits the Xcelium environment.

## How to Run the Complete Flow

We have combined the compile and run steps. Simply execute the bash script from your terminal:

```bash
./xrun_compile.sh
```

*Wait for the compilation and simulation to finish. The waveforms will be automatically saved in the `waves.shm` directory.*

### Viewing Waveforms (SimVision)
After the simulation finishes, you can open the generated database using Cadence SimVision:
```bash
simvision waves.shm
```

## Summary
This repository proves that a verification engineer must understand where bash scripting ends and TCL scripting begins. In the Cadence ecosystem, **Bash handles the Compile (`xrun_compile.sh`)**, while **TCL handles the Run (`cadence_xcelium_simulation_flow.tcl`)**.
