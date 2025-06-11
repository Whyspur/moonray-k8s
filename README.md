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

Make sure you're in the Terraform directory.

```
terraform init
```

```
terraform apply
```

### Set your Kubeconfig

Export your Kubeconfig somewhere from Terraform

```
echo "$(terraform output kube_config)" > ~/azurek8s
```

Open the azurek8s file and remove << EOT from the start and EOT from the end

Export your kubeconfig

```
export KUBECONFIG=~/azurek8s
```

## Port-Forward to access Coordinator from Localhost

```
kubectl port-forward deployment/arras-coordinator 8888:8888 -n moonray
```

## Start a Render Job

Change to the root directory of your Moonray release

Export required ENV

export PATH=${PWD}/bin:${PATH}  
export RDL2_DSO_PATH=${PWD}/rdl2dso.proxy  
export ARRAS_SESSION_PATH=${PWD}/sessions

If you're using the example sessiondef (mcrt_progressive) make sure you update resources.memoryMB to 8000.0 if you're using all default values in this repo.

```
arras_render --host localhost --port 8888 --rdl rectangle.rdla -s mcrt_progressive --num-mcrt 3 --current-env
```
