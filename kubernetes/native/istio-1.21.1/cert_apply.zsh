#!/usr/bin/env zsh
kubectl create -n istio-system secret tls httpbin-credential --key=example_certs1/httpbin.psawesome.xyz.key --cert=example_certs1/httpbin.psawesome.xyz.crt

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: mygateway
spec:
  selector:
    istio: ingress # use istio default ingress gateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - httpbin.psawesome.xyz
  - port:
      number: 443
      name: https
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: httpbin-credential # must be the same as secret
    hosts:
    - httpbin.psawesome.xyz
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: httpbin
spec:
  hosts:
  - "httpbin.psawesome.xyz"
  gateways:
  - mygateway
  http:
  - match:
    - uri:
        prefix: /status
    - uri:
        prefix: /delay
    route:
    - destination:
        port:
          number: 8000
        host: httpbin
EOF


curl -v -HHost:httpbin.psawesome.xyz --resolve "httpbin.psawesome.xyz" \
  --cacert example_certs1/psawesome.xyz.crt "https://httpbin.psawesome.xyz/status/418"
