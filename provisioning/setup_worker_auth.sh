#!/usr/bin/env bash
# @sacloud-once

sudo apt-get update || exit 1
sudo apt-get install -y curl || exit 1

export DEBIAN_FRONTEND=noninteractive
# install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin

# create bootstrap.kubeconfig
kubectl config set-cluster kube-sacloud-devel \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${kubernetes_address}:6443 \
  --kubeconfig=bootstrap.kubeconfig

kubectl config set-credentials kubelet-bootstrap \
  --token=${bootstrap_token} \
  --kubeconfig=bootstrap.kubeconfig

kubectl config set-context default \
  --cluster=kube-sacloud-devel \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig

kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

# create kube-proxy.kubeconfig
kubectl config set-cluster kube-sacloud-devel \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${kubernetes_address}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=kube-proxy.pem \
  --client-key=kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kube-sacloud-devel \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

