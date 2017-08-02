#!/usr/bin/env bash

set -e

. helpers/utils.sh

SERVICES="central-system transaction-service log-service pricing-service receptionist charge-box-service"

if [[ $# -gt 0 ]]; then
	SERVICES="$@"
fi

info "Building: $SERVICES"

for service in $SERVICES
do
	helpers/build.sh $service &
done
wait
success "*** ALL DONE ***"