<!-- PROJECT LOGO -->
<br />
<p align="center">
  <h3 align="center">TCL SCRIPTING for EDA RTL</h3>
  <p align="center">
    TCL Script Examples for RTL, FPGA & ASIC Design Flows
  </p>
</p>

---

## About This Repository

This repo is a growing collection of TCL script examples, starting from the very basics and gradually moving toward real-world EDA tool usage — synthesis, simulation, testbench automation, and more.

The examples are kept intentionally simple and readable. Each folder is self-contained, so you can jump to whatever topic you need without going through everything in order. Whether you're just getting started with TCL syntax or trying to automate a Vivado project, there should be something useful here.

---

## Why TCL for RTL / FPGA / ASIC?

If you've ever opened Vivado, Quartus, Design Compiler, or Cadence Innovus, you've already been using TCL — you just might not have noticed. Pretty much every major EDA tool in the industry is scripted in TCL, and that's not an accident. TCL was designed to be embedded inside other applications, which makes it a perfect fit for tools that need a lightweight, flexible scripting layer on top of a heavy C/C++ core.

Here's why it actually matters in practice:

**Automation and reproducibility.** Running synthesis or simulation by clicking through a GUI every time is fine when you're experimenting, but it doesn't scale. With a TCL script, you can define your entire flow — reading source files, setting constraints, running synthesis, writing reports — and rerun it with a single command. This is essential when you're working on a team, running nightly regressions, or trying to reproduce a result someone else got three months ago.

**Portability across tools.** The same TCL knowledge that lets you script Vivado also transfers to Synopsys and Cadence tools. The syntax is the same; it's just the built-in commands that change. Once you're comfortable with the language itself, picking up a new tool's TCL API is mostly about reading documentation, not learning a whole new language.

**Testbench and simulation control.** In simulation environments like Vivado's xsim or ModelSim/QuestaSim, TCL is how you control the simulation programmatically — applying stimulus, checking outputs, logging results to files, looping through multiple test cases automatically. This is much more maintainable than writing everything in the HDL testbench itself.

**Constraint management.** XDC files (used in Xilinx/AMD tools) are actually TCL scripts. Every `set_property`, `create_clock`, and `set_false_path` command is just TCL. Understanding TCL properly means you can write smarter, conditional, parametric constraints instead of static files that break every time you rename a port.

**CI/CD for hardware.** As hardware teams start adopting software-style development practices — version control, pull requests, automated testing — having your entire FPGA/ASIC flow scripted in TCL is what makes that possible. You can't easily plug a GUI into a Jenkins pipeline. You can plug a TCL script in without much trouble.

In short: TCL is not the most glamorous language, and it has its quirks, but fluency in it is one of those practical skills that quietly makes a digital design engineer significantly more effective.

---
## Why Every RTL Engineer Should Master TCL?

In the world of FPGA and ASIC design, GUI is for exploration, but TCL is for production. While clicking buttons in Vivado or Quartus works for small projects, professional hardware design requires automation, repeatability, and precision.

Here is why TCL is my go-to scripting language in this repo:

Eliminating Human Error: Automating the build flow (Synthesis, Implementation, Bitstream generation) ensures that the exact same process is followed every time, avoiding "magic clicks" in the GUI.

EDA Tool Mastery: Almost every major EDA tool (Vivado, Quartus, ModelSim, Genus, Innovus) uses TCL as its native command language. If you know TCL, you own the tool.

Version Control Friendly: Instead of tracking huge binary project files (like .xpr or .qpf), I track a single TCL script that recreates the entire project from scratch. This keeps my repositories clean and Git-friendly.

Custom Reporting & Constraints: TCL allows me to parse timing reports and generate custom power/area analyses that the standard GUI doesn't provide.

"If you are doing the same task twice in an EDA tool, you should have scripted it in TCL already."
---

## Contents

| # | Topic | Description |
|---|-------|-------------|
| 1 | [Basic Scripts](https://github.com/ayengec/TCL-scripts/tree/main/1-Basics) | Variables, puts, expressions, string operations |
| 2 | [Conditions and Loops](https://github.com/ayengec/TCL-scripts/tree/main/2-If-else-Loops) | if/else, while, for, foreach |
| 3 | [Functions (Procedures)](https://github.com/ayengec/TCL-scripts/tree/main/3-Functions(Procedures)) | proc definitions, arguments, return values |
| 4 | [Data Types](https://github.com/ayengec/TCL-scripts/tree/main/4-Data-Types) | Lists, dicts, arrays — with practical examples |
| 5 | [File I/O](https://github.com/ayengec/TCL-scripts/tree/main/5-File-IO) | Reading and writing files, log generation |
| 6 | [Regular Expressions](https://github.com/ayengec/TCL-scripts/tree/main/6-Regex) | Pattern matching, text parsing |
| 7 | [Vivado Testbench Example](https://github.com/ayengec/TCL-scripts/tree/main/7-Vivado-Testbench-Example) | Full simulation automation with xvlog/xelab/xsim |

> More examples will be added over time.

---

## Getting Started

### Clone the repo

```sh
git clone https://github.com/ayengec/TCL-scripts.git
```

No dependencies needed for the basic examples. For the Vivado-specific scripts (folder 7+), you'll need Vivado installed and added to your system PATH so that `xvlog`, `xelab`, and `xsim` are accessible from the terminal.

---

## Running the Examples

### Option 1 — Online (no install required)

Paste any `.tcl` file contents into the online interpreter and hit **F8** to run:

👉 [rextester.com TCL compiler](https://rextester.com/l/tcl_online_compiler)

Works well for everything in folders 1–6.

### Option 2 — Install TCL locally

Download and install from ActiveState (Windows / Linux / macOS):

👉 [activestate.com/products/tcl](https://www.activestate.com/products/tcl/downloads/)

Then run any script with:

```sh
tclsh your_script.tcl
```

### Option 3 — Vivado TCL Console

For the EDA-specific examples, open Vivado and use the TCL console at the bottom of the IDE, or run in batch mode:

```sh
vivado -mode batch -source run_sim_fifo.tcl
```
---

## Contributing

If you spot a mistake, want to add an example, or have a cleaner way to do something — feel free to open an issue or a pull request. The goal is for this to be useful to people learning TCL in an FPGA/ASIC context, so any improvement in that direction is welcome.

---
