#!/usr/bin/env bash

set -e

. helpers/utils.sh

if [[ $# -eq 0 ]]; then
	echo "No service specified! Usage: helpers/build.sh [service]"
fi

SERVICE=$1

function build {
	info "Building Docker image for $1"
	docker build -t $1:latest .
}

function compile {
	info "Compiling $1..."
	lein uberjar
}

cd ../$SERVICE
rm -rf target
compile $SERVICE
build $SERVICE
success "$SERVICE has been compiled and built!"