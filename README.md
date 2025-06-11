## Overview
This repository contains a Helm Chart with images for running Moonray's Arras Distributed Rendering service. Currently the provided images only support CPU rendering. In the near future these will be updated to support Moonray's XPU rendering capability.

## Requirements
- Linux or OSX Machine to deploy and send the render job from

- Azure Account, and Azure CLI Installed (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

- Terraform installed (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

- Kubectl installed (https://kubernetes.io/docs/tasks/tools/)

- Helm installed (https://helm.sh/docs/intro/install/)

- Built copy of Moonray (https://docs.openmoonray.org/getting-started/installation/building-moonray/)

## Configuring Azure CLI for Terraform

Once installed first login to your account

```
az login
```

Get your account, copying the 'id' field.

```
az account list
```

Create the Service Principal for Terraform

```
az ad sp create-for-rbac --role="Contributor" -scopes="/subscriptions/id-copied-from-earlier"
```

## Deploy Cluster with Terraform

### Set your Kubeconfig


## Port-Forward to access Coordinator from Localhost


## Start a Render Job