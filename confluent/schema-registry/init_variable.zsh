#!/bin/zsh
CLUSTER_NAME=dev-vircle
NAMESPACE=kafka
SERVICE_ACCOUNT_NAME=schema-registry-sa
POLICY_ARN=arn:aws:iam::677062093523:policy/SchemaRegistryMSKPolicy
OIDC_PROVIDER=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")

