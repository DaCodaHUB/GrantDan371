# GrantDan371

## Demo
Watch the demo: [https://youtu.be/phgyvtayKy0](https://youtu.be/phgyvtayKy0)

## Project Overview
This project contains comprehensive coursework for digital logic design and embedded systems. It includes implementations of various counter designs, multiplexers, and an interactive RLC game system. The project demonstrates progression from basic combinational logic to complex sequential circuits, with both hardware description language (HDL) implementations and C-based control software.

## Technologies Used
- **Verilog & SystemVerilog**: Hardware description language for digital logic design
- **C**: Software implementation for game control and system interaction
- **Quartus**: FPGA design and synthesis tool (Intel/Altera DE1-SoC)
- **ModelSim**: HDL simulation and waveform analysis
- **iVerilog & GTKWave**: Open-source Verilog simulation tools

## Project Structure

### Example Verilog
- Introductory Verilog demonstrations
- Clock divider reference implementations

### Lab 1: Counter Designs
- **RDown_Counter**: Ripple down counter implementation
- **SyncUpCount**: Synchronous up counter design
- **JohnsonCount**: Johnson counter (shift register counter variant)
- Includes both Verilog and behavioral C implementations

### Lab 1 New: Advanced Counter Designs (SystemVerilog)
- Modernized implementations using SystemVerilog
- Improved counter designs with D flip-flops
- Integration with DE1-SoC development board
- Clock divider module for frequency scaling
- Quartus project files and compilation reports included

### Lab 2: Multiplexers & Complex Circuits
- **Pound Circuit**: Custom digital logic implementation
- **Mux2_1**: 2-to-1 multiplexer design
- SystemVerilog implementations with simulation waveforms
- ModelSim simulation workflows and test benches

### Lab 3: Advanced Circuits
- Higher-level circuit designs
- Integration of multiple components

### Lab 4: Specialized Circuits
- Extended digital logic implementations

### Lab 5: RLC Game System
- **RLC Game**: Interactive multiplayer game system
- Menu system and game logic in C
- 5-bit multiplexer implementation for I/O handling
- Land and world management systems
- Real-time game control via FPGA

## File Organization
- **Verilog/SystemVerilog (.v, .sv)**: Hardware design files
- **C (.c)**: Software implementation and control logic
- **Waveforms (.vcd, .do)**: Simulation results and wave definitions
- **Quartus (.qpf, .qsf, .sdc)**: FPGA project and constraint files
- **Reports (.rpt)**: Compilation, timing, and placement reports

## Lab Summaries

### Lab 1: Counter Designs
Introduces fundamental sequential logic by implementing 4-bit counters using D flip-flops:
- **Ripple Down Counter**: Asynchronous down counter using cascaded stages
- **Synchronous Up Counter**: Parallel clock counter with carry propagation logic
- **Johnson Counter**: State machine-based counter generating 8 unique output patterns
- **Objective**: Understand clock propagation, synchronous vs. asynchronous design, and state transitions
- **Tools**: Verilog simulation with ModelSim and iVerilog/GTKWave

### Lab 1 New: Advanced Counter Designs (SystemVerilog)
Modernized implementation of Lab 1 circuits for FPGA deployment:
- Refactored counters using SystemVerilog `always_ff` blocks
- D flip-flop building blocks with asynchronous reset
- Clock divider for frequency scaling on DE1-SoC
- Integrated Quartus compilation flow with timing reports
- **Objective**: Transition from simulation to hardware implementation, FPGA constraints, timing analysis

### Lab 2: Multiplexers & Complex Circuits
Combines combinational and sequential logic:
- **Mux2_1**: 2-to-1 multiplexer for 7-bit signal selection
- **Pound Circuit**: Water lock system simulation using multiple D flip-flops for input synchronization and 6 hex displays for state visualization
- **Objective**: Metastability handling, clock domain crossing, display interfacing, complex state management

### Lab 3: Advanced Circuits
Higher-level circuit designs building on previous labs:
- Integration of multiple counter and multiplexer modules
- Complex behavioral modeling in SystemVerilog

### Lab 4: Specialized Circuits
Extended digital logic implementations for specific applications

---

## Lab 5: RLC Game System - Comprehensive Overview

### Project Scope
Lab 5 is the capstone project combining all previous coursework into a fully interactive game system. The RLC Game demonstrates integration of FPGA hardware, embedded C software, and real-time I/O on the Intel/Altera DE1-SoC development board.

### System Architecture

#### Hardware-Software Integration
- **FPGA Layer**: SystemVerilog logic running on DE1-SoC (Cyclone V FPGA)
- **Software Layer**: C program running on ARM HPS (Hard Processor System)
- **Communication**: Memory-mapped I/O registers via Avalon bus
- **Real-time I/O**: VGA display, button inputs, switch inputs, LED outputs

#### Core I/O Subsystems

**Display System**
- **VGA Output**: Coordinate-based graphics rendering (x, y positioning)
- **Hex Displays (6x)**: Alphanumeric display for game state, water levels, scores
- **LED Array (10-bit)**: Visual indicators for game status and water flow

**Input System**
- **Push Buttons (4x)**: KEY[0]=Reset, KEY[1]=Water Up, KEY[2]=Water Down, KEY[3]=Direction/Mode
- **Slide Switches (10x)**: Environmental conditions (arriving/departing players, lock states, flow direction)
- **Serial Input**: 2-player game support via serial emulation

**Control Registers** (Altera HAL Memory-Mapped I/O)
- `VGA_x_cord` (0x00081020): Horizontal pixel coordinate
- `VGA_y_cord` (0x00081010): Vertical pixel coordinate
- `VGA_clock_out` (0x00081000): Video timing synchronization
- `VGA_reset` (0x00081040): VGA display reset control
- `outputData` (0x00081070): Parallel data for serial transmission
- `outputClockEn` (0x00081050): Clock enable for data transfer
- `HEX0-HEX5` (0x00081060, etc.): 7-segment display control (each 7-bit: g,f,e,d,c,b,a)
- `KEY_321_in` (0x00081080): 3-bit button input interface
- `switches_in` (0x000810a0): 10-bit switch input from board
- `inputData` (0x00081090): Serial data received from player
- `states` (0x000810b0): Game state register

### Game Mechanics

#### RLC Lock System Concept
The game simulates a water lock system (RLC) where:
- **Water Level**: Dynamic height managed by software (0-100+ units)
- **Lock Chambers**: Upper and lower compartments with gates
- **Player Actions**:
  - **Water Up** (KEY[1]): Increase water level in active chamber
  - **Water Down** (KEY[2]): Decrease water level
  - **Direction Switch** (SW[4] / KEY[3]): Switch between chambers or change flow direction
- **Environmental Factors**:
  - Arriving passengers (SW[0]): Incoming water flow
  - Departing passengers (SW[1]): Outgoing water flow
  - Outside lock state (SW[2]): External water conditions
  - Inside lock state (SW[3]): Internal chamber conditions

#### Multi-Player Support
- **Player 1**: Direct control via DE1-SoC board buttons and switches
- **Player 2**: Serial emulation allowing networked/simulated second player
- **Game Coordination**: Both players view synchronized game state on VGA and hex displays

#### Game States & Transitions
- **Menu State**: Initial player selection and game mode setup
- **Active Game State**: Real-time water level management with visual feedback
- **Status Indicators**: Game flags track current game mode, player control, and environmental conditions

### Software Implementation

#### Main Program Structure

**RLC_grant_mainMenu_template.c**
- Entry point for game initialization
- Menu system for player selection and mode selection
- Initialization of game flags: `menuFlag`, `gameFlag`, `player1Select`
- Display initialization for hex displays and VGA system

**RLC_land.c**
- Land-based game logic and mechanics
- Water level calculations and state updates
- Collision detection and boundary conditions
- Player interaction response handling

**RLC_world.c**
- World/environment management
- Global game state tracking
- Environmental factor integration (arriving/departing flows)
- Game progression and win/lose conditions

#### Hardware Interaction Pattern
```
C Program (HPS) → Memory-Mapped I/O → FPGA Hardware
     ↓
IOWR_ALTERA_AVALON_PIO_DATA(register_address, value)  // Write to FPGA
     ↓
IORD_ALTERA_AVALON_PIO_DATA(register_address)         // Read from FPGA
     ↓
FPGA Updates VGA, LEDs, Hex Displays
```

#### Altera HAL Communication Functions
- `alt_printf(format, ...)`: Console output for debugging (supports %s, %x, %c)
- `alt_putstr(string)`: String output without newline
- `alt_putchar(char)`: Single character output
- `alt_getchar()`: Single character input from console

#### Data Flow Architecture
- **Parallel Data Path**: 8-bit or wider data from software to FPGA logic
- **Serial Conversion**: Parallel-to-serial (P2S) conversion for efficient transmission
- **Clock Synchronization**: `outputClockEn` controls when new data is latched in FPGA
- **Two-Phase Protocol**:
  1. Write data to `outputData` register
  2. Pulse `outputClockEn` to 1 then back to 0 to transfer

### Graphics & Display

#### VGA Graphics System
- **Resolution**: Configurable coordinate-based rendering
- **Color Support**: Determined by FPGA graphics module (typically 8-16 bit color)
- **Synchronization**: `VGA_clock_out` provides pixel clock for timing

#### Display Elements
- **Background**: Game world/environment visualization
- **Game Objects**: Water chambers, gates, player indicators
- **Animations**: Water level bar graphs, state transitions
- **Text Overlays**: Score, player names, status messages on hex displays

#### 7-Segment Display Encoding
Each hex display uses 7-bit control (one bit per segment):
```
 aaa
f   b
 ggg
e   c
 ddd
```
Example: Display "0" = 0x3F (segments a,b,c,d,e,f enabled)

### FPGA Hardware Design Elements

#### Synchronization Logic
- Input debouncing for buttons and switches
- Clock domain crossing for serial data
- Metastability protection using flip-flops

#### VGA Timing Controller
- Horizontal and vertical sync signal generation
- Pixel counter and coordinate tracking
- Display refresh rate management

#### Serial Interface (P2S)
- Shift register implementation for parallel-to-serial conversion
- Clock enable sequencing for reliable data transfer
- Receiver path for player 2 input

#### Display Multiplexing
- Hex display time-division multiplexing (6 displays, single controller)
- LED array direct control via GPIO

### Testing & Validation

#### Simulation Environment
- ModelSim for RTL simulation and waveform analysis
- Test benches for individual modules (counters, muxes, synchronizers)
- VCD waveform files for timing verification

#### Hardware Verification
- Quartus compilation and place-and-route (timing reports: DE1_SoC.sta.rpt)
- Fit summary showing resource utilization
- ProgramTheDE1_SoC.cdf for FPGA configuration and programming

#### Integration Testing
- Verify each FPGA peripheral independently
- Test HPS-to-FPGA communication through memory-mapped I/O
- Validate game logic state transitions with manual player input
- Check VGA graphics rendering and timing
- Verify 2-player serial communication

### Project Deliverables

**Hardware Artifacts**
- DE1_SoC.sv: Top-level FPGA design
- DE1_SoC.sof: FPGA configuration bitstream (programmed to board)
- Clock_divider.sv: Frequency scaling for game timing

**Software Artifacts**
- RLC_grant_mainMenu_template.c: Main game executable
- RLC_land.c, RLC_world.c: Game logic modules
- Launch_ModelSim.bat: Automated simulation script
- Makefile/Project build configuration

**Documentation**
- Timing reports and placement analysis
- Design constraints (DE1_SoC.sdc)
- Simulation waveforms (RippleUp_wave.do, SynchUpCounter_wave.do)

### Development Flow

1. **Design Phase**: SystemVerilog hardware architecture
2. **Simulation Phase**: Individual component testing with ModelSim
3. **Synthesis Phase**: Quartus compilation and optimization
4. **Integration Phase**: FPGA + HPS software development
5. **Verification Phase**: Hardware testing on DE1-SoC board
6. **Demonstration Phase**: Live gameplay and interaction testing