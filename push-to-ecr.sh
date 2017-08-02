#!/usr/bin/env bash

set -e

. helpers/utils.sh

SERVICES="central-system transaction-service log-service pricing-service receptionist charge-box-service"

if [[ $# -gt 0 ]]; then
	SERVICES="$@"
fi

# Get AWS account ID
AWS_ID=$(aws sts get-caller-identity --output text --query 'Account')

# Login to Docker
$(aws ecr get-login --region eu-west-1)

info "Pushing to AWS ECR: $SERVICES"

for service in $SERVICES
do
	helpers/push.sh $service $AWS_ID
done
wait
success "*** ALL DONE ***"