# MySQL Operator Helm Deployment Guide

## Introduction
This guide provides step-by-step instructions for deploying MySQL Operator and MySQL InnoDB Cluster using Helm in a Kubernetes environment.

## Prerequisites
- Kubernetes cluster
- Helm installed
- Access to the MySQL Operator Helm repository

## Add the MySQL Operator Helm Repository
```sh
helm repo add mysql-operator https://mysql.github.io/mysql-operator/
helm repo update
```

## Install MySQL Operator
```sh
helm install my-mysql-operator mysql-operator/mysql-operator \
   --namespace mysql-operator --create-namespace
```

## Deploy MySQL InnoDB Cluster

### Option 1: With Self-Signed Certificates
```sh
export NAMESPACE="mysql-operator"
helm install my-mysql-innodbcluster mysql-operator/mysql-innodbcluster -n $NAMESPACE \
    --version 2.2.0 \
    --set credentials.root.password=">-0URS4F3P4SS" \
    --set tls.useSelfSigned=true
```

### Option 2: Using Custom CA and TLS Certificates
```sh
export NAMESPACE="mysql-operator"
export CLUSTER_NAME="my-mysql-innodbcluster"
export CA_SECRET="$CLUSTER_NAME-ca-secret"
export TLS_SECRET="$CLUSTER_NAME-tls-secret"
export ROUTER_TLS_SECRET="$CLUSTER_NAME-router-tls-secret"
export CERT_PATH="/path/to/your/ca_and_tls_certificates"

kubectl create namespace $NAMESPACE

kubectl create secret generic $CA_SECRET \
    --namespace=$NAMESPACE --dry-run=client --save-config -o yaml \
    --from-file=ca.pem=$CERT_PATH/ca.pem | kubectl apply -f -

kubectl create secret tls $TLS_SECRET \
    --namespace=$NAMESPACE --dry-run=client --save-config -o yaml \
    --cert=$CERT_PATH/server-cert.pem --key=$CERT_PATH/server-key.pem | kubectl apply -f -

kubectl create secret tls $ROUTER_TLS_SECRET \
    --namespace=$NAMESPACE --dry-run=client --save-config -o yaml \
    --cert=$CERT_PATH/router-cert.pem --key=$CERT_PATH/router-key.pem | kubectl apply -f -

helm install my-mysql-innodbcluster mysql-operator/mysql-innodbcluster -n $NAMESPACE \
    --version 2.2.0 \
    --set credentials.root.password=">-0URS4F3P4SS" \
    --set tls.useSelfSigned=false \
    --set tls.caSecretName=$CA_SECRET \
    --set tls.serverCertAndPKsecretName=$TLS_SECRET \
    --set tls.routerCertAndPKsecretName=$ROUTER_TLS_SECRET
```

## Verify Deployment
Check the status of MySQL Operator:
```sh
kubectl get pods -n mysql-operator
```

Check the status of MySQL InnoDB Cluster:
```sh
kubectl get pods -n your-namespace
```

## Cleanup
To uninstall MySQL Operator and InnoDB Cluster:
```sh
helm uninstall my-mysql-operator -n mysql-operator
helm uninstall my-mysql-innodbcluster -n your-namespace
```

