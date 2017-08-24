#!/usr/bin/env bash

chmod +x /home/ubuntu/wait-for-it.sh

echo "Wait for api-server..."
/home/ubuntu/wait-for-it.sh -t 60 localhost:8080 -- echo "api-server is up"

kubectl get clusterrolebinding kubelet-bootstrap
if [ $? -ne 0 ] ; then
  kubectl create clusterrolebinding kubelet-bootstrap \
    --clusterrole=system:node-bootstrapper \
    --user=kubelet-bootstrap
fi