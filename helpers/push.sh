#!/usr/bin/env bash

set -e

. helpers/utils.sh

if [[ $# -lt 2 ]]; then
	echo "Usage: helpers/push.sh [service] [amazon-id]"
	echo "You can get the amazon-id with: aws sts get-caller-identity --output text --query 'Account'"
fi

SERVICE=$1
AWS_ID=$2

function delete_image {
	image_ids=$(aws ecr describe-images --repository-name $1 --query "imageDetails[*].imageDigest" --output=text)
	for image in $image_ids
	do
		aws ecr batch-delete-image --repository-name $1 --image-ids imageDigest=$image
	done
}

function push_image {
	local_tag="$1:latest"
	tag="$AWS_ID.dkr.ecr.eu-west-1.amazonaws.com/$local_tag"
	docker tag $local_tag $tag
	docker push $tag
}

info "Deleting old images for $SERVICE"
delete_image $SERVICE
info "Pushing $SERVICE to ECR..."
push_image $SERVICE
success "$SERVICE has been pushed to ECR"