## Overview
This repository contains a Helm Chart with images for running Moonray's Arras Distributed Rendering service. Currently the provided images only support CPU rendering. In the near future these will be updated to support Moonray's XPU rendering capability.



## Getting Started

There are two paths

- Using a prebuilt Docker image with all requirements installed
- DIY which requires building Moonray yourself and preparing a machine to run arras_render which will involve building OpenImageIO 2.3~ from source.

This documentation will only cover the first path.

### Running the Docker Container

First you'll want to clone a copy of this repository to your host machine. We will map this folder to the container in a moment so you have persistent storage for your Kubectl config and Terraform state.

Assuming you've cloned your repository to ~/Dev/moonray-k8s and have the assets your wish to render in ~/assets . . .

```
docker run -v ~/Dev/moonray-k8s:/moonray-k8s:Z -v ~/assets:/assets:Z --security-opt seccomp=unconfined --rm -it whyspur/arrasrender:latest
```

Once inside the container shell there's some further setup to do.

### Logging into Azure CLI

Terraform requires you authenticate to your Azure account and create an RBAC role to deploy infrastructure with. 

Perform these steps inside the container

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

### Deploy the Kubernetes Cluster with Terraform

```
cd /moonray-k8s/terraform
```

```
terraform init
```

```
terraform apply
```

**Export your kubeconfig**

```
echo "$(terraform output kube_config)" > /moonray-k8s/azurek8s
```

Open the azurek8s file and remove << EOT from the start and EOT from the end

```
export KUBECONFIG=/moonray-k8s/azurek8s
```

**Check you can auth to the cluster**

```
kubectl get nodes
```

You should see a list of agentpool nodes. If not, double check you've exported the KUBECONFIG path correctly and that you've removed the start << EOT and trailing EOT from the azurek8s file.

**Port-Forward to the Coordinator**

```
kubectl port-forward deployment/arras-coordinator 8888:8888 -n moonray
```

### Setup Render Requirements

```
cd /installs/moonray-renderer
```

```
source /installs/moonray-renderer/scripts/setup.sh
```

Export required ENV

```
export PATH=${PWD}/bin:${PATH}
export RDL2_DSO_PATH=${PWD}/rdl2dso.proxy
export ARRAS_SESSION_PATH=${PWD}/sessions
```

### Start a Render Job

```
arras_render --host localhost --port 8888 --rdl /assets/example.rdl -exr /assets/renders/example.exr -s mcrt_progressive --num-mcrt 3 --current-env --no-gui
```

## Modying the Deploying and Arras Session Definitions

You have effectively two choices in scaling up the deploying. At this moment I cannot conclusively say one is superior to the other.

**Option 1:**
Scale the number of Azure VM's the Kubernetes Cluster has

- Modify terraform/variables node_count.default or override with a custom .tfvars

**Option 2:**
Scale the size of the Azure VM's and increase the Kubernetes Arras Node Deployment Replica Count

- Modify terraform/variables vm_size.default or override with a custom .tfvars
- [Optional] Update helm/values.yaml node.replicas to scale the number of deployed pods to match or exceed the number of deployed nodes.

It's entirely possible to use this repo as a way to deploy infrastruce running one arras node (pod) per Azure VM. Alternatively one may choose to get very larger Azure VM's and run multiple arras node pods per VM. The latter is the way Kubernetes is generally intended to be used, but without testing it's hard to say if one is better than the other for this use case.

### Arras .sessiondef

Arras uses sessiondef configs to specify various options including memory and cpu values. If a target node does not have available memory in the amount defined, it will not receive new jobs until such time as that much memory is available. This can lead to a case where your deployed arras node containers are sized too small relative to the amount of memory/cpu defined in the .sessiondef.

In order to fix this go to /installs/moonray_renderer/mcrt_progressive and update the memoryMB to a sane value based on the chosen allocated memory for the arrasnode containers.

Docs: https://docs.openmoonray.org/developer-reference/arras/arras-session-definitions/

## DIY 

If you wish to run all of this directly from your host machine and build Moonray yourself you'll need to do the following from a Linux or OSX machine (no Win build target):

- Build Moonray (https://docs.openmoonray.org/getting-started/installation/building-moonray/rocky9_build/)  

- Install Azure CLI (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)  

- Install Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)  

- Install Kubectl (https://kubernetes.io/docs/tasks/tools/)  

- Install Helm (https://helm.sh/docs/intro/install/)  

At the time of writing even RockyLinux9 has a number of missing requirements to build Moonray. You'll need to work through installing the additional requirements, the most onerous of which is building OpenImageIO 2.3~ from source. 

It's on my list to get a guide together for building Moonray from source on Ubuntu to support a Github Actions CI-friendly option for builds. If someone else cares to write this please send it my way so I can link it here!
