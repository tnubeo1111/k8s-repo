#!/bin/bash

# Update Package Index:

sudo apt update

# Install Dependencies:

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker's Official GPG Key:

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker Repository:

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update

# Install Docker Engine:

sudo apt install docker-ce -y

# Download Docker Compose:

sudo curl -L "https://github.com/docker/compose/releases/download/v2.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Apply Executable Permissions:

sudo chmod +x /usr/local/bin/docker-compose

# Verify Installation:

docker-compose --version

# Install K8S

# Check the architecture of the machine
ARCH=$(uname -m)

# Get the latest version of kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

# Check the architecture and download the corresponding kubectl

if [ "$ARCH" == "x86_64" ]; then
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
    echo "Downloaded kubectl for x86-64."
elif [ "$ARCH" == "aarch64" ]; then
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/arm64/kubectl"
    echo "Downloaded kubectl for ARM64."
else
    echo "The machine architecture is not supported. Unable to install kubectl."
    exit 1
fi

#  Validate the binary (optional)

if [ "$ARCH" == "x86_64" ]; then
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256"
elif [ "$ARCH" == "aarch64" ]; then
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/arm64/kubectl.sha256"
else
    echo "The machine architecture is not supported. Unable to install kubectl."
    exit 1
fi

# Validate the kubectl binary against the checksum file:

echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

chmod +x kubectl

mkdir -p ~/.local/bin

mv ./kubectl ~/.local/bin/kubectl

#  Test to ensure the version you installed is up-to-date:

kubectl version --client

# Minikube

if [ "$ARCH" == "x86_64" ]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube && rm minikube-linux-amd64

elif [ "$ARCH" == "aarch64" ]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-arm64
    sudo install minikube-linux-arm64 /usr/local/bin/minikube && rm minikube-linux-arm64
else
    echo "https://minikube.sigs.k8s.io/docs/start/"
    exit 1
fi

# Provide instructions to the user on how to get started with minikube
echo "To get started with minikube, please visit the following page:"
echo "https://minikube.sigs.k8s.io/docs/start/"


# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
