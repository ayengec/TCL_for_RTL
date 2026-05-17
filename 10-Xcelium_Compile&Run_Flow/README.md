# Cadence Xcelium Compile & Run Flow

This directory demonstrates the complete flow for compiling and simulating SystemVerilog designs using **Cadence Xcelium**, specifically highlighting how bash commands (`xrun`) and TCL scripts work together.

Unlike Siemens QuestaSim, which often uses TCL for both compilation and execution (`vlog` / `vsim`), Cadence Xcelium uses a unified single-step command (`xrun`) from the bash shell for compilation and elaboration. TCL is then passed into the simulator to control the execution phase (e.g., waveform dumping, coverage management, and simulation length).

## 1. The Compile Flow (`xrun`)

Compilation in Xcelium is heavily command-line driven. Instead of a TCL script, you typically use `xrun` with a file list (`.f` file) or direct file inputs. 

A standard compilation command looks like this:
```bash
xrun -clean \
     -sv \
     -access +rwc \
     -coverage all \
     -f rtl_files.f \
     tb_top.sv
```
* **`-clean`**: Removes previous compilation databases (INCA_libs).
* **`-sv`**: Enables SystemVerilog compilation.
* **`-access +rwc`**: Grants Read/Write/Connectivity access to the simulation database. **(Crucial: If you don't include this, you won't be able to dump waveforms!)**
* **`-coverage all`**: Instruments the code for coverage collection.
* **`-f rtl_files.f`**: Points to a text file containing the list of your RTL files and include directories.

## 2. The Run Flow (TCL Dialect)

Once compiled, Xcelium needs instructions on how to run the simulation. This is where the `cadence_xcelium_simulation_flow.tcl` script comes in. It highlights Cadence's proprietary TCL dialects:

*   **`database`**: Manages the Cadence SHM (Simulation History Manager) waveform database. The script creates and opens a database named `waves.shm`.
*   **`probe`**: Instructs the simulator on what signals to record. In this example, we probe all signals within `tb_top` and all its sub-hierarchies recursively (`-depth all`).
*   **`coverage`**: Controls the dumping of coverage data dynamically during simulation.
*   **`run`**: Executes the simulation for a specific duration or until a `$finish` statement is encountered in the SystemVerilog code.
*   **`exit`**: Safely closes the database (preventing corruption) and exits the Xcelium environment.

## How to Combine Compile & Run

To compile the design and immediately run it using the TCL script, you combine the two steps into a single `xrun` command by using the `-input` flag.

### Batch Mode (No GUI)
```bash
xrun -clean -access +rwc tb_top.sv -input cadence_xcelium_simulation_flow.tcl
```
*Wait for the compilation and simulation to finish. The waveforms will be saved in the `waves.shm` directory.*

### Viewing Waveforms (SimVision)
After the batch simulation finishes, you can open the generated database using Cadence SimVision:
```bash
simvision waves.shm
```

### GUI Mode (Interactive)
If you prefer to compile, load the GUI immediately, and let the script execute its initialization steps (like probing signals) before you manually hit "Run", use the `-gui` flag:
```bash
xrun -clean -access +rwc tb_top.sv -gui -input cadence_xcelium_simulation_flow.tcl
```

## Summary
This repository proves that a verification engineer must understand where bash scripting ends and TCL scripting begins. In the Cadence ecosystem, **Bash/Makefiles handle the Compile**, while **TCL handles the Run**.
