# AES-128 Decryption Module in VHDL

This repository contains the **VHDL implementation of an AES-128 decryption module** designed for the **Basys3 FPGA**. The project is structured using a modular and hierarchical design approach to ensure clarity, efficiency, and ease of debugging. Key components of the system include an FSM-controlled AES decryption process, memory units (ROM and RAM), and a real-time display of the decrypted output on a seven-segment display.

## Features
- **AES-128 Decryption**: Implements the AES-128 decryption algorithm, including:
  - **Inverse SubBytes**: Reverses the SubBytes operation using the inverse S-Box.
  - **Inverse ShiftRows**: Reverses the ShiftRows operation by shifting rows in the opposite direction.
  - **Inverse MixColumns**: Reverses the MixColumns operation to restore the original data state.
  - **AddRoundKey**: XORs the data with the round key to complete the decryption process.
- **Finite State Machine (FSM)**: Controls the entire decryption sequence, ensuring that the AES transformations are performed in the correct order.
- **Memory Management**: Uses multiple memory components:
  - **ROM Units**: Store the key, ciphertext, and inverse S-box for the decryption process.
  - **RAM Units**: Store intermediate and final decrypted results.
- **Real-Time Display**: Displays the decrypted data on a **seven-segment display**, allowing the user to visually verify the decryption.
- **Optimized FPGA Implementation**: The design is optimized for use with the **Basys3 FPGA**, ensuring efficient resource utilization.

## Design Overview
The design follows a **hierarchical structure**, where each component serves a specific role in the AES decryption process:

1. **TopModule**: The top-level controller that manages the overall decryption process, including memory operations, sequencing of decryption steps, and controlling the display.
2. **AES Decryptor**: A core compute unit that implements the AES decryption algorithm, processing transformations like Inverse SubBytes, Inverse ShiftRows, Inverse MixColumns, and AddRoundKey.
3. **Output RAM**: Stores the decrypted output and intermediate data during the decryption process.
4. **Digital Display**: A submodule responsible for displaying the decrypted data on a seven-segment display, using multiplexing to show the data in hexadecimal form.

## Finite State Machine (FSM)
The FSM in the **AES Decryptor** manages the sequence of decryption transformations. Key states in the FSM include:
- `IDLE`: Waits for the decryption process to start.
- `LOAD CIPHERTEXT`: Loads the ciphertext into memory.
- `ADD ROUND KEY`: Applies the round key to the ciphertext.
- `INVERSE SUB BYTES`: Applies the inverse S-Box substitution.
- `INVERSE SHIFT ROWS`: Reverses the row shifts.
- `INVERSE MIX COLUMNS`: Reverses the column mixing.
- `DONE`: Marks the completion of the decryption process.

## Simulation and Testing
The design has been tested through **FPGA simulations** on a Basys3 board to ensure correct functionality across all stages of decryption. Waveform simulations are available to demonstrate signal transitions between the different states of the FSM and the decrypted output.

## Prerequisites
- **FPGA**: Basys3 FPGA board.
- **Software Tools**:
  - Xilinx Vivado for VHDL synthesis, simulation, and FPGA deployment.
- **Languages**: VHDL for the design and simulation.

## Authors
- **Tejaswa Singh Mehra**  
- **Ishan Rehal**

## License
This project is licensed under the MIT License.
