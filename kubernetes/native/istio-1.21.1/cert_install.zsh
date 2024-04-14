#!/usr/bin/env zsh
mkdir example_certs1

# Create a root certificate and private key
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=psawesome Inc./CN=psawesome.xyz' -keyout example_certs1/psawesome.xyz.key -out example_certs1/psawesome.xyz.crt

# Generate a certificate for httpbin.psawesome.xyz
openssl req -out example_certs1/httpbin.psawesome.xyz.csr -newkey rsa:2048 -nodes -keyout example_certs1/httpbin.psawesome.xyz.key -subj "/CN=httpbin.psawesome.xyz/O=httpbin organization"
openssl x509 -req -sha256 -days 365 -CA example_certs1/psawesome.xyz.crt -CAkey example_certs1/psawesome.xyz.key -set_serial 0 -in example_certs1/httpbin.psawesome.xyz.csr -out example_certs1/httpbin.psawesome.xyz.crt

# Create a second set of the same kind of certificates and keys
mkdir example_certs2
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj '/O=psawesome Inc./CN=psawesome.xyz' -keyout example_certs2/psawesome.xyz.key -out example_certs2/psawesome.xyz.crt
openssl req -out example_certs2/httpbin.psawesome.xyz.csr -newkey rsa:2048 -nodes -keyout example_certs2/httpbin.psawesome.xyz.key -subj "/CN=httpbin.psawesome.xyz/O=httpbin organization"
openssl x509 -req -sha256 -days 365 -CA example_certs2/psawesome.xyz.crt -CAkey example_certs2/psawesome.xyz.key -set_serial 0 -in example_certs2/httpbin.psawesome.xyz.csr -out example_certs2/httpbin.psawesome.xyz.crt

# Generate a certificate and a private key for helloworld.psawesome.xyz
openssl req -out example_certs1/helloworld.psawesome.xyz.csr -newkey rsa:2048 -nodes -keyout example_certs1/helloworld.psawesome.xyz.key -subj "/CN=helloworld.psawesome.xyz/O=helloworld organization"
openssl x509 -req -sha256 -days 365 -CA example_certs1/psawesome.xyz.crt -CAkey example_certs1/psawesome.xyz.key -set_serial 1 -in example_certs1/helloworld.psawesome.xyz.csr -out example_certs1/helloworld.psawesome.xyz.crt

# Generate a certificate and a private key for heloworld.psawesome.xyz
openssl req -out example_certs1/client.psawesome.xyz.csr -newkey rsa:2048 -nodes -keyout example_certs1/client.psawesome.xyz.key -subj "/CN=client.psawesome.xyz/O=client organization"
openssl x509 -req -sha256 -days 365 -CA example_certs1/psawesome.xyz.crt -CAkey example_certs1/psawesome.xyz.key -set_serial 1 -in example_certs1/client.psawesome.xyz.csr -out example_certs1/client.psawesome.xyz.crt
