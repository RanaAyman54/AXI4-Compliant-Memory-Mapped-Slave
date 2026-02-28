# AXI4-Compliant-Memory-Mapped-Slave
AXI4 Bus Verification Environment
📖 Overview

This repository provides a comprehensive SystemVerilog-based verification environment for the AXI4 bus protocol.

The environment verifies:

AXI4 protocol compliance

Functional correctness

Assertion-based protocol checking

Functional and protocol coverage metrics

It includes a modular testbench architecture composed of a top module, interface, assertions, coverage model, constrained-random transactions, and a memory model for read/write validation.

📁 Directory Structure
axi4_top.sv         — Top-level testbench module
axi4_tb.sv          — Testbench logic and stimulus generation
axi4_if.sv          — AXI4 interface definition
axi4_sva.sv         — SystemVerilog Assertions for protocol checking
axi4_coverage.sv    — Coverage model for functional and protocol coverage
axi4_transaction.sv — Transaction class with constrained stimulus
axi_memory.v        — Memory model for AXI4 read/write operations
axi4.sv             — DUT (Device Under Test) implementation
run.do              — Simulation script for ModelSim/Questa
src_files.list      — List of source files for compilation
wave.do             — Waveform configuration script
cov_report.txt      — Coverage report (generated after simulation)

Additional simulation artifacts and scripts may be generated after running the simulation.

🚀 Features

AXI4 protocol assertions (SVA-based protocol checking)

Constrained-random transaction generation

Functional and protocol coverage collection

AXI memory model for read/write verification

Boundary address testing

Burst transfer verification

Out-of-bound access validation

▶️ How to Run
1️⃣ Clone the Repository
git clone <repository-url>
cd <repository-folder>
2️⃣ Compile Using Source File List (ModelSim / Questa)
vlog -f src_files.list
3️⃣ Run Simulation
vsim -do run.do
4️⃣ Load Waveforms (Optional)
do wave.do
📊 Coverage and Assertions

After simulation:

Check assertion results in the simulator transcript

Open cov_report.txt to analyze coverage metrics

Use the Coverage Viewer (GUI mode) for detailed coverage inspection

🧰 Requirements

SystemVerilog simulator (ModelSim / Questa / VCS)


📌 Test Scenarios

Single read/write transactions

Burst transactions

Boundary address accesses

Out-of-range memory accesses

Protocol compliance validation using SVA

📄 License

This project is intended for educational and research purposes.
Please contact the repository owner for licensing details.
