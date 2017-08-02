#!/usr/bin/env bash

set -e

# install Docker
sudo yum update -y
sudo yum install -y docker
sudo service docker start

# add ec2-user to Docker group, so we don't have a sudo later on
# This only works after relogging, so for this script, we'll keep using sudo
sudo usermod -a -G docker ec2-user

# Install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.11.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Login to Docker with the temporary login command
sudo <docker-login>

sudo /usr/local/bin/docker-compose up -d

