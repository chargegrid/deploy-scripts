#!/usr/bin/env bash

set -e

. helpers/utils.sh

info "BEGIN DEPLOYMENT"

./build-services.sh
./push-to-ecr.sh
terraform apply

success "DEPLOYMENT SUCCESSFUL!"