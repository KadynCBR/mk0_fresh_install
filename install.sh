REPO=$(pwd)
output () {
  echo ""
  echo "================================================="
  echo "$1"
  echo "================================================="
  echo ""
}
output "Getting extending sudo permissions"
sudo -v
# -------------- Apt update -------------- 
output "updating"
sudo apt update
# -------------- Install ros Humble -------------- 
output "Installing ROS Humble"
# check locale
sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo apt install curl gnupg lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update

# NOTE: Make sure systemd and udev are upgraded before intalling ros 2.
sudo apt upgrade -y

sudo apt install ros-humble-ros-base -y
source /opt/ros/humble/setup.bash
echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
sudo apt install -y python-rosdep
sudo rosdep init
rosdep update

# -------------- Install YD Lidar SDK -------------- 
output "Installing YDLidar SDK"
sudo apt install build-essentials -y
mkdir ~/tmp
cd ~/tmp
git clone https://github.com/YDLIDAR/YDLidar-SDK.git
cd YDLidar-SDK/
sudo apt install cmake pkg-config
mkdir build
cd build
cmake ..
make
sudo make install

# -------------- Pull in repos for mk0_ws -------------- 
output "Creating MK0 ROS 2 Workspace"
mkdir ~/mk0_ws
cd ~/mk0_ws
mkdir src
cd src
git clone https://github.com/KadynCBR/ydlidar_ros2_driver.git
git clone https://github.com/KadynCBR/mk0_ros.git
# git clone https://github.com/ros2/teleop_twist_joy # This might not be needed cuz humble.
git clone https://github.com/kobuki-base/velocity_smoother.git
git clone https://github.com/kobuki-base/kobuki_ros_interfaces.git
git clone https://github.com/kobuki-base/kobuki_ros.git
git clone https://github.com/kobuki-base/kobuki_core.git
git clone https://github.com/kobuki-base/cmd_vel_mux.git

# -------------- Install udev rules -------------- 
output "Installing UDEV rules"
sudo cp ${REPO}/UDEV/* /etc/udev/rules.d/
sudo udevadm control --reload
sudo service udev reload
sudo service udev restart

# -------------- Download maps -------------- 
output "Copying maps to maps folder"
mkdir ~/.maps/
cp ${REPO}/MAPS/* ~/.maps/

# -------------- Download sounds -------------- 
# output "Copying sounds to sounds folders"

# -------------- Extra Packages -------------- 
output "Installing extra ROS packages"
sudo apt install  ros-humble-teleop-twist-joy \
                  ros-humble-ros-testing \
                  ros-humble-joint-state-publisher \
                  python3-rosdep2 \
                  python3-colcon-common-extensions \
                  ros-humble-rviz2 \
                  ros-humble-robot-localization \
                  ros-humble-navigation2 \
                  ros-humble-nav2-bringup -y
sudo apt install ros-humble-turtlebot3* -y


# -------------- Grabbing extra packages for builds (These should eventually be released on apt for humble.) -----------------
output "Grabbing not-yet-released package dependencies"
cd ~/mk0_ws/src
git clone https://github.com/stonier/ecl_tools
git clone https://github.com/stonier/ecl_core
git clone https://github.com/stonier/ecl_lite
git clone https://github.com/stonier/sophus -b release/1.2.x

# -------------- ENV VARS ---------------------
output "Setting environment variables in bash file"
echo "export ROS_DOMAIN_ID=21" >> ~/.bashrc
echo "export ROS_DISTRO=humble" >> ~/.bashrc

# -------------- Workspace build --------------
output "Building workspace"
source ~/.bashrc
cd ~/mk0_ws/
rosdep install --from-paths src --ignore-src -y 
colcon build --symlink-install