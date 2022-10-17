#!/bin/bash

# install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# install ARC
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install \
        cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.9.1 \
        --set installCRDs=true

kubectl create namespace actions-runner-system
kubectl create secret generic controller-manager -n actions-runner-system --from-literal=github_token="$GITHUB_TOKEN"

helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm upgrade --install --namespace actions-runner-system \
             --wait actions-runner-controller actions-runner-controller/actions-runner-controller
