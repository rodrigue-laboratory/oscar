# OSCAR Platform

This repository provides the open-source implementation of the **OSCAR System**, a versatile, modular, and affordable collaborative robot platform for biological laboratory automation.

![OSCAR System](./doc/gamma-protocol-initial-setup.jpg)

It contains instructions for setting up all required ROS packages and configuration files to reproduce the protocols described in our manuscript.

The platform automates multi-step molecular biology workflows:
- PCR Amplification and Validation (*Protocol #1 - Alpha*)
- Gibson Assembly and Bacterial Transformation (*Protocol #2 - Beta*)
- Colony Picking and Construct Validation (*Protocol #3 - Gamma*)


## Hardware

The Biology Cobot platform is built from accessible, commercially available, and custom-fabricated components.  


| Component               | Model                        | Approx. Cost (USD)  |
| ----------------------- | ---------------------------- | ------------------- |
| **Robot**               | Universal Robots UR3         | \$20,000 (academic) |
| **Force–Torque Sensor** | Robotiq FT-300               | \$4,500             |
| **Gripper**             | Robotiq 2F-140               | \$2,800             |
| **Camera**              | Intel RealSense D415         | \$300               |
| **Custom Pipette**      | In-house built               | \$1,000             |
| **Optical Table**       | Newport VH3660 (48 × 48 in)  | \$670               |
| **3D Printer**          | Bambu Lab X1 Series          | \$1,200             |
| **Total**               | —                            | **\$30,470**        |


*Note: Costs are approximate and may vary depending on suppliers and configurations.*  

## Software

The platform relies on the **Robot Operating System (ROS)** and associated motion planning frameworks.

The reference implementation has been developed and tested on:
- Ubuntu 20.04 LTS
- ROS Noetic (ROS 1)

### Required Packages

| Package / Link                                                                                                                                 | Description                                           |
|------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------|
| [cartesian\_controllers](https://github.com/captain-yoshi/cartesian_controllers/tree/c1526e5d7abed7066e93afded14b0eb7c1e49a3e)                 | Cartesian motion/impedance controllers.               |
| [control\_msgs](https://github.com/captain-yoshi/control_msgs/tree/c776cc61bcfa32ac3b1cbf107050abbcb66e8f59)                                   | ROS control message/action definitions.               |
| [deterministic\_trac\_ik](https://github.com/captain-yoshi/deterministic_trac_ik/tree/f80c3d472f5b7dd98c12a9aa33b2d7804efe23c2)                | Deterministic TRAC-IK MoveIt kinematics plugin.       |
| [oscar\_description](https://github.com/rodrigue-laboratory/oscar_description)                                                                 | URDF/Xacro and meshes for the OSCAR platform.         |
| [oscar\_robot\_setup](https://github.com/rodrigue-laboratory/oscar_robot_setup)                                                                | Bringup/launch/config for lab setups (UR3/FT/vision). |
| [oscar\_task](https://github.com/rodrigue-laboratory/oscar_task)                                                                               | Build and execute the three biology protocols.        |
| [oscar\_ur\_launch](https://github.com/rodrigue-laboratory/oscar_ur_launch)                                                                    | UR-specific launch files and configs.                 |
| [oscar\_vision](https://github.com/rodrigue-laboratory/oscar_vision)                                                                           | Vision nodes/pipeline utilities.                      |
| [moveit](https://github.com/captain-yoshi/moveit/tree/ba67fc38b78363caa4f4c5068833276b5e5c8b1c)                                                | MoveIt (motion planning framework).                   |
| [moveit\_task\_constructor](https://github.com/captain-yoshi/moveit_task_constructor/tree/0b00477808c216853594dc5cd27bf0df1761b93d)            | MoveIt Task Constructor (task planning).              |
| [pipette-tool-cad](https://github.com/UdeS-Biology-Cobot/pipette-tool-cad)                                                                     | Pipette tool CAD drawings.                            |
| [pipette-tool-pcb](https://github.com/UdeS-Biology-Cobot/pipette-tool-pcb)                                                                     | Pipette tool PCB drawings.                            |
| [pipette-tool-sw](https://github.com/UdeS-Biology-Cobot/pipette-tool-sw)                                                                       | Pipette tool firmware/driver.                         |
| [realsense\_ros](https://github.com/IntelRealSense/realsense-ros/tree/b14ce433d1cccd2dfb1ab316c0ff1715e16ab961)                                | Intel RealSense ROS wrapper.                          |
| [robotiq](https://github.com/captain-yoshi/robotiq/tree/0b2f924ab39d2ac8d9268279e3fcdbd8ed909954)                                              | Robotiq gripper/FT drivers and msgs.                  |
| [ros\_colony\_morphology](https://github.com/UdeS-Biology-Cobot/ros_colony_morphology/tree/7cf4f3c496ca7262dc2793607b4baa73cd7a13da)           | Colony detection & morphology analysis.               |
| [ros\_pipette\_tool](https://github.com/UdeS-Biology-Cobot/ros_pipette_tool/tree/0ef0586e6e1256a87e860412ef895128a7e83170)                     | Pipette tool ROS wrapper.                             |
| [sodf](https://github.com/captain-yoshi/sodf/tree/e90e050dca6deafc2feb13fe001e253251d6f92f)                                                    | Semantic Object Description Format.                   |
| [task\_space\_feedback](https://github.com/captain-yoshi/task_space_feedback/tree/d2f86c0a989731bcf25aa1b01836b698d21bb9cd)                    | Task-space feedback utilities.                        |
| [universal\_robots\_ros\_driver](https://github.com/UniversalRobots/Universal_Robots_ROS_Driver/tree/d73f7f7b4d1c978780cb19648d505678317b3009) | Official UR ROS driver.                               |
| [vision\_opencv](https://github.com/ros-perception/vision_opencv/tree/cfabf72fb02970a661b5e68fbee503c5d9f94729)                                | OpenCV ROS wrapper.                                   |


## Installation

To simplify installation, this repository includes a setup script for Ubuntu 20.04:

```bash
# Run the setup script (may take several minutes)
$ ./ubuntu-20.04-setup.bash

# Reload your shell so the new environment settings take effect
$ source ~/.bashrc
```

## Run

Follow this [Guide](https://github.com/rodrigue-laboratory/oscar_task).
