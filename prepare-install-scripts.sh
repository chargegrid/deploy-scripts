#!/usr/bin/env bash

set -e

DOMAIN=chargegrid.io

cp templates/demo-install-template.sh temp-demo-install.sh
DOCKER_LOGIN=$(aws ecr get-login --region eu-west-1)
sed -i "" "s,<docker-login>,$DOCKER_LOGIN,g" temp-demo-install.sh
chmod +x temp-demo-install.sh

cp templates/docker-compose-demo-template.yml temp-docker-compose-demo.yml
AWS_ID=$(aws sts get-caller-identity --output text --query 'Account')
sed -i "" "s,<aws-id>,$AWS_ID,g" temp-docker-compose-demo.yml
sed -i "" "s,<domain>,$DOMAIN,g" temp-docker-compose-demo.yml