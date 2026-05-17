# ==============================================================================
# Script Name: cadence_xcelium_simulation_flow.tcl
# Author: Alican Yengec
# Description: This is a Cadence Xcelium simulation control script. 
#              While Xcelium compilation is usually triggered via 'xrun' from 
#              bash, this script is passed into the simulator (-input run_xcelium.tcl)
#              to control runtime behavior. It highlights Cadence's proprietary
#              TCL commands like 'database', 'probe', and 'coverage'.
# ==============================================================================

puts "--------------------------------------------------------"
puts " Starting Cadence Xcelium Simulation Flow"
puts "--------------------------------------------------------"

# 1. Open SHM Database
# Cadence uses SHM (Simulation History Manager) format for waveforms.
# This opens a database named 'waves.shm' and sets it as the default target.
puts "[INFO] Initializing SHM waveform database..."
database -open waves -into waves.shm -default

# 2. Probe Signals
# The 'probe' command tells Xcelium what to record into the database.
# -create: create a new probe
# -shm: use the default SHM database
# -all -depth all: dump all signals in tb_top and everything below it
puts "[INFO] Probing all signals in 'tb_top'..."
probe -create -shm tb_top -all -depth all

# 3. Configure Coverage Reporting (Optional)
# If the simulation was compiled with coverage enabled (xrun -coverage all),
# you can use TCL to control when and how it is dumped.
puts "[INFO] Setting up coverage dump..."
coverage -dump -name xcelium_cov_run

# 4. Run Simulation
# We can use TCL variables to control how long we run, or just run until $finish
set MAX_SIM_TIME "10ms"
puts "[INFO] Running simulation until $MAX_SIM_TIME or \$finish..."
run $MAX_SIM_TIME

# 5. Clean up and Exit
# It is critical to close the database in Cadence to prevent file corruption
puts "[INFO] Closing waveform database..."
database -close waves

puts "--------------------------------------------------------"
puts " Cadence Xcelium Flow Completed Successfully!"
puts "--------------------------------------------------------"

# Exit the simulator and return to shell
exit
