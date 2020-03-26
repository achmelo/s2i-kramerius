#!/bin/bash

kubectl create configmap solr-cluster-config --namespace=zk-solr-ha --from-env-file=solr-config.properties 
kubectl create configmap zookeeper-config --namespace=zk-solr-ha --from-env-file=zookeeper-config.properties 
kubectl apply -f statefulset-solr-cluster.yml

sleep 5

kubectl apply -f service-solr-cluster.yml

kubectl get pod
kubectl get deployment
kubectl get service

echo "created solr and zookeeper statefulsets"
echo "created solr and zookeeper services"
echo ""

