echo "this will remove all ros2 items for foxy."
sudo apt remove ~nros-foxy-* && sudo apt autoremove

echo "also removing the repository."
sudo rm /etc/apt/sources.list.d/ros2.list
sudo apt update
sudo apt autoremove
sudo apt upgrade