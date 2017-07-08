#!/usr/bin/env bash

KUBERNETES_ADDRESS="${fqdn}"
kubectl config set-cluster kube-sacloud-devel \
  --certificate-authority=generated/ca.pem \
  --embed-certs=true \
  --server=https://$KUBERNETES_ADDRESS:6443 \
  --kubeconfig=generated/sacloud.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=generated/admin.pem \
  --client-key=generated/admin-key.pem \
  --kubeconfig=generated/sacloud.kubeconfig

kubectl config set-context kube-sacloud-devel \
  --cluster=kube-sacloud-devel \
  --user=admin \
  --kubeconfig=generated/sacloud.kubeconfig

kubectl config use-context kube-sacloud-devel \
  --kubeconfig=generated/sacloud.kubeconfig
