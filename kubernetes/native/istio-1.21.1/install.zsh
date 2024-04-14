#!/usr/bin/env zsh
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm upgrade --install istio-base istio/base -n istio-system --create-namespace --set defaultRevision=default
helm upgrade --install istiod istio/istiod -n istio-system

helm ls -n istio-system
sleep 3

helm status istiod -n istio-system
sleep 3


echo "install istio-ingressgateway"
#kubectl create namespace istio-ingress
helm upgrade --install istio-ingress istio/gateway -n istio-ingress --create-namespace --set gateways.istio-ingressgateway.type=LoadBalancer
