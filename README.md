# k8s-repo

This repository contains files and scripts related to Kubernetes (K8s) setup, including Helm charts, metrics monitoring, and various configurations.

## Repository Structure

- **build-k8s/**: Scripts and configurations used for building Kubernetes environments.
- **helm-values/**: Values files for configuring Helm charts, particularly for ingress-nginx.
- **metrics-k8s/**: Configuration for setting up metrics server and monitoring in Kubernetes.
- **note/**: Contains notes and shell scripts such as ingress.sh for setting up ingress in Kubernetes.
- **README.md**: This document.

## Prerequisites

- **Kubernetes Cluster**: You need to have a running Kubernetes cluster.
- **Helm**: Make sure Helm is installed on your system to manage Kubernetes applications.
- **Metrics Server**: Required for resource monitoring.

## Usage

1. **Building the Kubernetes Environment**:  
   Navigate to the `build-k8s` directory and follow the scripts to build the environment.
   
2. **Deploying Ingress-NGINX**:  
   Check the `helm-values` directory for appropriate configuration values for ingress-nginx. Customize it if needed, then deploy using Helm.

3. **Setting up Metrics Server**:  
   Follow the steps in the `metrics-k8s` folder to set up the Kubernetes metrics server.

4. **Configuring Ingress**:  
   Use the script found in the `note/` directory to configure the ingress for your applications.

## Contributing

Feel free to fork this repository and submit pull requests. Contributions to improve or add new features are always welcome.

## License

This project is open-source and licensed under the MIT License.
