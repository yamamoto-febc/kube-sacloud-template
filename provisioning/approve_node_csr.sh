#!/usr/bin/env bash

kubectl certificate approve `kubectl get csr -o name`