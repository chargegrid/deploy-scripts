#!/usr/bin/env bash

set -e

if [[ $# -eq 0 ]]; then
	echo "No domain specified! Usage: ./deploy-and-build-all.sh [domain]"
fi

DOMAIN=$1

cp templates/prod-install-template.sh temp-prod-install.sh
DOCKER_LOGIN=$(aws ecr get-login --region eu-west-1)
sed -i "" "s,<docker-login>,$DOCKER_LOGIN,g" temp-prod-install.sh
chmod +x temp-prod-install.sh

cp templates/docker-compose-prod-template.yml temp-docker-compose-prod.yml
AWS_ID=$(aws sts get-caller-identity --output text --query 'Account')
sed -i "" "s,<aws-id>,$AWS_ID,g" temp-docker-compose-prod.yml
sed -i "" "s,<domain>,$DOMAIN,g" temp-docker-compose-prod.yml