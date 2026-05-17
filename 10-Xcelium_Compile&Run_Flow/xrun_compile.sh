#!/bin/bash
# ==============================================================================
# Script Name: xrun_compile.sh
# Author: Alican Yengec
# Description: Cadence Xcelium Compilation and Execution Bash Script.
#              In the Cadence flow, compilation happens in the shell via 'xrun',
#              which then calls a TCL script (-input) to handle waveform dumping.
# ==============================================================================

echo "--------------------------------------------------------"
echo " Starting Cadence Xcelium Compile & Run Flow"
echo "--------------------------------------------------------"

# Remove old compilation databases and logs to ensure a clean build
echo "[INFO] Cleaning old databases (INCA_libs)..."
rm -rf INCA_libs waves.shm xcelium.d xrun.log xrun.history

# Run the single-step compilation and simulation using xrun
echo "[INFO] Compiling and Launching Xcelium..."
xrun -clean \
     -sv \
     -access +rwc \
     -coverage all \
     -timescale 1ns/1ps \
     tb_top.sv \
     -input cadence_xcelium_simulation_flow.tcl

echo "--------------------------------------------------------"
echo " Simulation Finished. To view waveforms, run:"
echo " simvision waves.shm"
echo "--------------------------------------------------------"
