# AXI4 Lite Ethernet Interface for UDP Payload Transmission

This repository contains Verilog code for an **AXI4-Lite Ethernet Interface** and **UDP Transmitter Module**. The design can be integrated into a processor system to enable the transmission of custom Ethernet packets with a UDP payload to a specified destination over Ethernet.


## Overview

The **AXI4-Lite Ethernet Interface** provides a flexible and efficient way to add Ethernet packet transmission capability to processors or custom designs. By integrating this interface, your system can send UDP packets with configurable IP addresses, ports, payload data, and payload length.

The **TX Ethernet UDP Transmission Module** complements this by formatting and sending the UDP payload as Ethernet frames. It is ideal for applications where transmitting custom data over UDP is required, such as IoT systems, embedded devices, or networked processors.

## Features

- **AXI4-Lite Protocol**: Provides an AXI4-Lite interface for seamless integration with processors to read and write control registers.
- **Configurable Destination**: Supports custom IP addresses and ports for transmitting UDP packets to specified destinations.
- **Custom Payload**: Allows for custom payload data and payload length configuration via AXI4-Lite registers.
- **UDP Packet Transmission**: Constructs and transmits UDP packets wrapped in Ethernet frames.
- **Efficient Design**: Suitable for implementation in FPGAs or ASICs with minimal resource overhead.

## Prerequisites

To work with this project, you will need the following tools:
- [Vivado](https://www.xilinx.com/products/design-tools/vivado.html) or other Verilog synthesis tools for building and deploying the design.
- [ModelSim](https://www.mentor.com/products/fv/modelsim/) or other simulation tools for functional testing.


### Module Descriptions

- **axi_4_lite_eth.v**: This module handles AXI4-Lite transactions, providing registers to configure the destination IP, source/destination ports, payload data, and payload length.
  - **Registers**:
    - `slv_reg1`: Set destination IP address
    - `slv_reg2`: Set source and destination ports
    - `slv_reg3`: Set UDP payload data
    - `slv_reg4`: Set UDP payload length

- **tx_ethernet.v**: This module constructs and sends the Ethernet frames containing the UDP payload, sourced from the configured registers in `axi_4_lite_eth`.

## Integration with Processor

The AXI4-Lite Ethernet interface can be directly added to a processor as an extension for transmitting custom UDP packets over Ethernet. Here’s a basic flow of how the module works when integrated into a processor system:

1. **AXI4-Lite Interface**: The processor writes configuration values (such as IP addresses, ports, and payload data) into the AXI4-Lite registers provided by the `axi_4_lite_eth` module.
2. **UDP Packet Construction**: Once configured, the `tx_ethernet` module constructs an Ethernet frame with a UDP header and the payload data.
3. **Packet Transmission**: The Ethernet frame is transmitted to the specified destination IP via the Ethernet interface.

This system allows a processor to send custom UDP packets efficiently and flexibly, ideal for embedded networking applications or systems requiring UDP-based communication.


## Cloning
To clone this repository, use the following command:

```bash
git clone https://github.com/MoulisvaranUdayakumar/AXI4-Lite-Interface-for-UDP-Packet-Transmission.git
