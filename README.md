# Deploy scripts

This is a collection of scripts to deploy a production version of ChargeGrid, either locally, or on AWS. You can build 
production Docker images of all services and the portal with these scripts, and deploy those images.

## Use locally

**Prerequisites**

- Docker (and docker-compose)
- Leiningen

**Build the prerequisite Docker images**

```
$ ./build-services.sh service1 service2 ...
```

You can invoke it with a list of services that you want to build. If you do not specify any services, it will build 
**all services**. The build script expects 2 things:

1. The git repos of the services you want to build, available at the same level as the `deploy-scripts` repo
2. Leiningen

**Add the following to your `/etc/hosts`**

```
127.0.0.1 api.chargegrid.dev cb.chargegrid.dev
```

This is for Receptionist (api.chargegrid.io) and the Central System 
websocket entrypoint (cb.chargegrid.io)

**Run everything**

```
$ docker-compose up
```

## Deploy to AWS

Using Terraform, you can easily deploy a production version of ChargeGrid on Amazon Web Services.

**Prerequisites**

- Docker
- Leiningen
- Terraform
- AWS account
- AWS CLI

**One-time preparations**

- Create an _access key/secret key_ pair on AWS. This can be from an IAM user, as long as that user has at least priviliges for: ECR, EC2 and VPC
- In the prepare-install-scripts.sh, set the desired domain name
- Create an Elastic IP on AWS and take note of the Allocation ID
- In the DNS configuration of your domain, add the following records, pointing to your Elastic IP: `cb`, `api` and `platform`
- On AWS Elastic Container Registry create repositories with the following names: central-system, transaction-service, log-service, pricing-service, receptionist, charge-box-service, portal
- Make sure that in the portal source code `public/config-deployed.js` contains the proper domain name
- In the directory where the deploy-scripts reside, create a file `terraform.tfvars` with the following:

```
access_key = "<access-key>"
secret_key = "<secret-key>"
elastic_ip_id = "<allocation id of Elastic IP>"
```

This file will is in the `.gitignore`, so it will not be committed. Your secrets are safe!

**Automatically build and deploy everything**

```
$ ./deploy-and-build-all.sh
```

**Run each step manually**

```
$ ./build-services		# Compile all services and build Docker images
$ ./push-to-ecr.sh 		# Tag all Docker images and push to AWS ECR
$ terraform apply		# Provision a machine + all network stuff, install Docker and run ChargeGrid stack
```

When you're done demoing the coolest electrical chargeing platform in the world, don't forget to get rid of your 
demo environment again:

```
$ terraform destroy
```

