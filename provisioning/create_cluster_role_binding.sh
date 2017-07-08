#!/usr/bin/env bash

kubectl get clusterrolebinding kubelet-bootstrap
if [ $? -ne 0 ] ; then
  kubectl create clusterrolebinding kubelet-bootstrap \
    --clusterrole=system:node-bootstrapper \
    --user=kubelet-bootstrap
fi