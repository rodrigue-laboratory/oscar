#!/usr/bin/env bash
# install_noetic_catkin.sh
# Install ROS Noetic + catkin_tools on Ubuntu 20.04, create ~/ros_ws, clone packages (branches/submodules), and build.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== 1) System update ==="
sudo apt update && sudo apt -y upgrade

echo "=== 2) Force CPU governor to performance mode ==="
sudo apt install -y linux-tools-common linux-tools-generic "linux-tools-$(uname -r)"

sudo tee /etc/systemd/system/cpufreq-performance.service >/dev/null <<'EOF'
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/cpupower frequency-set -g performance

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now cpufreq-performance

echo "=== 3) Add ROS repository and keys (Ubuntu 20.04 'focal') ==="
sudo apt install -y curl gnupg ca-certificates
if [ ! -f /etc/apt/sources.list.d/ros-latest.list ]; then
  echo "deb http://packages.ros.org/ros/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/ros-latest.list >/dev/null
fi
curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | sudo apt-key add -

echo "=== 4) Install ROS Noetic Desktop-Full ==="
sudo apt update
sudo apt install -y ros-noetic-desktop-full

echo "=== 5) Base ROS tools & catkin_tools ==="
sudo apt install -y \
  git \
  python3-rosdep \
  python3-rosinstall \
  python3-rosinstall-generator \
  python3-wstool \
  build-essential \
  python3-catkin-tools

echo "=== 6) Initialize rosdep ==="
if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init
fi
rosdep update

echo "=== 7) Create catkin workspace at ~/ros_ws ==="
WS="$HOME/ros_ws"
SRC="$WS/src"
mkdir -p "$SRC"
# Ensure environment for catkin to find ROS
export ROS_DISTRO=noetic
export ROS_MASTER_URI="${ROS_MASTER_URI:-http://localhost:11311}"
export ROS_HOSTNAME="${ROS_HOSTNAME:-$(hostname -f 2>/dev/null || hostname)}"

source /opt/ros/noetic/setup.bash
cd "$WS"

if [ ! -d "$WS/.catkin_tools" ]; then
  catkin init
  catkin config --extend /opt/ros/noetic
  catkin config --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5
fi

# ------------------------------
# 8) REPOSITORY CLONING SECTION
# ------------------------------
# Edit the table below to add/remove packages. Format:
# name,url,ref,submodules
#   - name: folder under ~/ros_ws/src
#   - url : git URL (HTTPS or SSH)
#   - ref : branch, tag, or commit SHA (use "-" for default)
#   - submodules: [Optional] "yes" to init/update submodules, otherwise "no", defaults to "auto"
#
mapfile -t REPOS <<'EOF'
cartesian_controllers,https://github.com/captain-yoshi/cartesian_controllers.git,c1526e5d7abed7066e93afded14b0eb7c1e49a3e
control_msgs,https://github.com/captain-yoshi/control_msgs.git,c776cc61bcfa32ac3b1cbf107050abbcb66e8f59
deterministic_trac_ik,https://github.com/captain-yoshi/deterministic_trac_ik.git,f80c3d472f5b7dd98c12a9aa33b2d7804efe23c2
oscar_description,https://github.com/rodrigue-laboratory/oscar_description.git,5dd12f763df3649ab6e67ee6bf20d27248ba886a
oscar_robot_setup,https://github.com/rodrigue-laboratory/oscar_robot_setup.git,002e4989fda6f1a3f9e895f4f41092cff767fe27
oscar_task,https://github.com/rodrigue-laboratory/oscar_task.git,ca4d7151bd63eb4faa6fa2ca988b488082e3be42
oscar_ur_launch,https://github.com/rodrigue-laboratory/oscar_ur_launch.git,1bb7438f01a05081d9f3c61261d127eac1b8d3aa
oscar_vision,https://github.com/rodrigue-laboratory/oscar_vision.git,13138e5797beed3572e62d208c5fa26db00c8afc
moveit,https://github.com/captain-yoshi/moveit.git,ba67fc38b78363caa4f4c5068833276b5e5c8b1c
moveit_task_constructor,https://github.com/captain-yoshi/moveit_task_constructor.git,0b00477808c216853594dc5cd27bf0df1761b93d
realsense_ros,https://github.com/IntelRealSense/realsense-ros.git,b14ce433d1cccd2dfb1ab316c0ff1715e16ab961
robotiq,https://github.com/captain-yoshi/robotiq.git,0b2f924ab39d2ac8d9268279e3fcdbd8ed909954
ros_colony_morphology,https://github.com/UdeS-Biology-Cobot/ros_colony_morphology.git,7cf4f3c496ca7262dc2793607b4baa73cd7a13da
ros_pipette_tool,https://github.com/UdeS-Biology-Cobot/ros_pipette_tool.git,0ef0586e6e1256a87e860412ef895128a7e83170
sodf,https://github.com/captain-yoshi/sodf.git,e90e050dca6deafc2feb13fe001e253251d6f92f
task_space_feedback,https://github.com/captain-yoshi/task_space_feedback.git,d2f86c0a989731bcf25aa1b01836b698d21bb9cd
universal_robots_ros_driver,https://github.com/UniversalRobots/Universal_Robots_ROS_Driver.git,d73f7f7b4d1c978780cb19648d505678317b3009
vision_opencv,https://github.com/ros-perception/vision_opencv.git,cfabf72fb02970a661b5e68fbee503c5d9f94729
EOF

clone_or_update () {
  local name="$1" url="$2" ref="$3" submods="${4:-auto}"
  local dest="$SRC/$name"

  if [ -d "$dest/.git" ]; then
    echo "=== Updating $name ==="
    git -C "$dest" fetch --all --tags

    if [ "$ref" != "-" ]; then
      if git -C "$dest" rev-parse --verify --quiet "origin/$ref" >/dev/null; then
        git -C "$dest" checkout "$ref"
        git -C "$dest" reset --hard "origin/$ref"
      else
        git -C "$dest" checkout "$ref" 2>/dev/null || true
        git -C "$dest" reset --hard "$ref" || true
      fi
    else
      git -C "$dest" checkout -q
      git -C "$dest" pull --rebase --autostash
    fi

    # Auto-detect submodules on update
    if [ "$submods" = "yes" ] || { [ "$submods" = "auto" ] && [ -f "$dest/.gitmodules" ] || git -C "$dest" config --file .gitmodules --name-only --get-regexp path >/dev/null 2>&1; }; then
      echo "=== Syncing & updating submodules for $name ==="
      git -C "$dest" submodule sync --recursive
      git -C "$dest" submodule update --init --recursive --depth 1 --jobs 4
    fi

  else
    echo "=== Cloning $name ==="
    # Prefer shallow clone when ref is a branch/tag we can resolve
    if [ "$ref" != "-" ] && git ls-remote --heads --tags "$url" "$ref" | grep -q "$ref"; then
      git clone --branch "$ref" --depth 1 --recurse-submodules --shallow-submodules "$url" "$dest"
    else
      git clone --recurse-submodules --shallow-submodules "$url" "$dest"
      [ "$ref" != "-" ] && git -C "$dest" checkout "$ref" || true
    fi

    # Auto-detect submodules after clone (re-check in case checkout changed .gitmodules)
    if [ "$submods" = "yes" ] || { [ "$submods" = "auto" ] && [ -f "$dest/.gitmodules" ] || git -C "$dest" config --file .gitmodules --name-only --get-regexp path >/dev/null 2>&1; }; then
      echo "=== Initializing submodules for $name ==="
      git -C "$dest" submodule sync --recursive
      git -C "$dest" submodule update --init --recursive --depth 1 --jobs 4
    fi
  fi
}

echo "=== 8) Cloning/updating packages into $SRC ==="
# supress git warnings
git config --global advice.detachedHead false

for line in "${REPOS[@]}"; do
  IFS=',' read -r NAME URL REF SUBS <<< "$line"
  [[ -z "${NAME// }" ]] && continue
  [[ "$NAME" =~ ^# ]] && continue
  clone_or_update "$NAME" "$URL" "$REF" "${SUBS:-auto}"
done <<< "$REPOS"



echo "=== 9) Resolve dependencies (system pkg + rosdep) ==="

# eigen
sudo apt install -y libeigen3-dev

# deterministic_trac_ik_lib
sudo apt install -y libnlopt-cxx-dev

# realsense2
# https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md#installing-the-packages
sudo mkdir -p /etc/apt/keyrings
curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | sudo tee /etc/apt/keyrings/librealsense.pgp > /dev/null
sudo apt install -y apt-transport-https

echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | \
sudo tee /etc/apt/sources.list.d/librealsense.list
sudo apt update

RS2_VERSION=2.55.1-0~realsense.12473
sudo apt install -y \
  librealsense2="$RS2_VERSION" \
  librealsense2-dev="$RS2_VERSION" \
  librealsense2-utils="$RS2_VERSION" \
  librealsense2-udev-rules="$RS2_VERSION" \
  librealsense2-gl="$RS2_VERSION"
sudo apt-mark hold librealsense2 librealsense2-dev librealsense2-utils librealsense2-udev-rules librealsense2-gl

# oscar_robot_setup_description
sudo apt install -y ros-noetic-ur-description
sudo apt install ros-noetic-moveit-resources-panda-description

# robotiq_2f_gripper_control
sudo apt install -y libmodbus-dev libusb-1.0-0-dev

# realsense2 camera
sudo apt install -y ros-noetic-ddynamic-reconfigure

# google cloud c++
echo "=== Running Google Cloud C++ installer ==="
"$SCRIPT_DIR/scripts/install_google_cloud_cpp.sh"

# moveit
sudo apt install -y \
  ros-noetic-moveit-msgs \
  ros-noetic-ruckig \
  ros-noetic-pybind11-catkin \
  ros-noetic-geometric-shapes \
  ros-noetic-srdfdom \
  ros-noetic-ompl \
  ros-noetic-warehouse-ros \
  ros-noetic-eigenpy \
  ros-noetic-rosparam-shortcuts

# mtc
sudo apt install -y \
  ros-noetic-py-binding-tools

#ur_robot_driver
sudo apt install -y \
  ros-noetic-industrial-robot-status-interface \
  ros-noetic-scaled-joint-trajectory-controller \
  ros-noetic-speed-scaling-state-controller \
  ros-noetic-speed-scaling-interface \
  ros-noetic-ur-msgs \
  ros-noetic-pass-through-controllers \
  ros-noetic-ur-client-library

# install dependencies from rosdep
source /opt/ros/noetic/setup.bash
export ROS_DISTRO=noetic
export ROS_PYTHON_VERSION=3
echo "ROS_DISTRO=$ROS_DISTRO  ROS_PYTHON_VERSION=$ROS_PYTHON_VERSION"

rosdep install --from-paths "$SRC" --ignore-src -r -y || true

echo "=== 10) Build workspace with catkin build ==="
cd "$WS"
catkin build

echo "=== 11) Add sourcing lines to ~/.bashrc (idempotent) ==="
BASHRC="$HOME/.bashrc"
if ! grep -Fxq 'source /opt/ros/noetic/setup.bash' "$BASHRC"; then
  echo 'source /opt/ros/noetic/setup.bash' >> "$BASHRC"
fi
if ! grep -Fxq 'source ~/ros_ws/devel/setup.bash' "$BASHRC"; then
  echo 'source ~/ros_ws/devel/setup.bash' >> "$BASHRC"
fi
if ! grep -Fxq 'export DISABLE_ROS1_EOL_WARNINGS=1' "$BASHRC"; then
  echo 'export DISABLE_ROS1_EOL_WARNINGS=1' >> "$BASHRC"
fi

echo "=== Done! Open a new terminal or run: source ~/.bashrc ==="
