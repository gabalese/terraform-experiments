#!/bin/bash -v
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -y
sudo apt-get install -y nginx
sudo service nginx start