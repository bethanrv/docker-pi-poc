# Setup & Development

This project uses uv for Python package management and Task for automation. It is optimized for the Raspberry Pi 5 architecture.

## 1. System Prerequisites

Before installing Python dependencies, the host Raspberry Pi must have the necessary C-libraries and build tools to interface with the RP1 chip.
```Bash

# Update system packages
sudo apt update

# Install build tools and hardware headers
sudo apt install -y swig liblgpio-dev libgpiod-dev gcc
```

## 2. Python Environment

We use uv to manage an isolated virtual environment. This ensures we don't pollute the system Python.
```Bash

# Install dependencies
uv sync

# Add hardware libraries (if starting fresh)
uv add gpiozero lgpio
```

## 3. Hardware Access & Environment

The Raspberry Pi 5 requires the lgpio factory to communicate with the GPIO pins correctly.
  - Pin Factory: You must set GPIOZERO_PIN_FACTORY=lgpio.
  - Device Mapping: The hardware is typically exposed via /dev/gpiochip4 (or gpiochip0 depending on your kernel).

## 4. Running the Project

## Install requirements

```Bash
uv sync

# or via task...
task env
```

## Run the script

```Bash
uv run main.py

# or via task...
task run
```

# Docker Deployment

To run this in a container, we map the hardware character device directly into the isolated environment.
Docker Compose

The simplest way to maintain the correct hardware permissions is via docker-compose.yml:
```YAML

services:
  app:
    build: .
    devices:
      - "/dev/gpiochip4:/dev/gpiochip4" # Map the RP1 GPIO chip
    environment:
      - GPIOZERO_PIN_FACTORY=lgpio
```
Build & Start

If you have Task installed:
```Bash

task build  # Build the optimized Docker image
task up     # Start the container with hardware access
```

# Automation with Task
Using the provided Taskfile.yml, you can manage the container lifecycle easily:

---
| Command | Description
--- | ---
| task build | "Builds the optimized, multi-stage Docker image using uv." |
| task up | Starts the container in the background with hardware access. |
| task logs | Follows the real-time output (e.g., "LED ON/OFF"). |
| task down | Stops the container and releases the GPIO pins. |

# Troubleshooting
Note: If you get a "Device not found" error, run gpiodetect on the host. If the rp1-gpio is listed as gpiochip0 instead of gpiochip4, update the mapping in the docker-compose.yml and the chip variable in your Python code.

Docker:
If docker is missing sudo access, run the following to add your user to the docker group:
```Bash
sudo usermod -aG docker $USER
# either log out and back in, or run the following to update the group membership:
newgrp docker
```
