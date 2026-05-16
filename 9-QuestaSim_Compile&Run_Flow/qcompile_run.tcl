# ==============================================================================
# Script Name: questa_simulation_flow.tcl
# Author: Alican Yengec
# Description: This is a robust QuestaSim/ModelSim simulation flow script. 
#              It demonstrates how to map libraries, compile SystemVerilog RTL,
#              enable functional coverage, load the simulator with vopt arguments,
#              and dump waveforms. This proves that while base TCL handles the
#              logic, the simulation commands (vlib, vlog, vsim) are proprietary.
# ==============================================================================

puts "--------------------------------------------------------"
puts " Starting QuestaSim Regression Flow"
puts "--------------------------------------------------------"

# 1. Workspace Cleanup
# If the 'work' library exists, delete it to ensure a clean build
if {[file exists work]} {
    puts "[INFO] Removing old work library..."
    vdel -lib work -all
}

# 2. Library Creation
# 'vlib' creates the directory, 'vmap' links the logical name to the physical path
puts "[INFO] Creating and mapping new work library..."
vlib work
vmap work work

# 3. Compilation (vlog)
# Compile the design files. We use -sv for SystemVerilog support and 
# -cover bces for branch, condition, expression, and statement coverage.
puts "[INFO] Compiling RTL and Testbench..."
set compile_status [catch {
    vlog -work work -sv -cover bces ../src/*.sv
    vlog -work work -sv -cover bces ../tb/tb_top.sv
} compile_err]

if {$compile_status != 0} {
    puts "[ERROR] Compilation failed! Check syntax errors."
    puts "Error details: $compile_err"
    quit -code 1
}

# 4. Elaboration & Simulation Loading (vsim)
# +acc ensures variables are accessible for waveforms (prevents optimization stripping)
# -coverage enables the coverage engine during simulation
puts "[INFO] Starting vsim..."
vsim -voptargs="+acc" -coverage work.tb_top

# 5. Waveform Configuration
# Log all signals recursively
log -r /*
# If GUI is running, add signals to the waveform window
if {[batch_mode] == 0} {
    add wave -position insertpoint sim:/tb_top/*
}

# 6. Run the simulation
puts "[INFO] Running simulation..."
run -all

# 7. Coverage Reporting
# Generate a textual coverage report
coverage report -file questa_cov_report.txt -byfile -detail
puts "[INFO] Coverage report saved to questa_cov_report.txt"

puts "--------------------------------------------------------"
puts " QuestaSim Flow Completed Successfully!"
puts "--------------------------------------------------------"

# 8. Quit (if in batch mode)
if {[batch_mode] == 1} {
    quit -sim
}
