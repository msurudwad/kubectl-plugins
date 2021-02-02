#!/usr/bin/env bash

set -ex

helm repo add k8s-triliovault-stable http://charts.k8strilio.net/trilio-stable/k8s-triliovault
helm repo add k8s-operator-stable http://charts.k8strilio.net/trilio-stable/k8s-triliovault-operator

helm install -n ms k8s-tv-operator k8s-operator-stable/k8s-triliovault-operator --version v0.2.6
kubectl apply -n ms -f tvm.yaml

kubectl get -n ms -f tvm.yaml -oyaml

set +ex