# !/bin/bash

# Install dependencies and verify the setup for mac os
./minikube-setup/install-dependencies.sh macos
./minikube-setup/verify-setup.sh

## Start minikube with the Docker driver and allocate resources
minikube start --cpus 4 --memory 6144 --driver docker
minikube addons enable metrics-server
minikube dashboard

## Verify the cluster is running
kubectl cluster-info

##
cd ../../sample-app/api-server
kubectl apply -f api-pod.yaml
kubectl get pods

##
kubectl port-forward pod/api-pod 9000:5000 &
# Test API
curl http://localhost:9000/health

#
kubectl apply -f api-deployment.yaml
kubectl scale deployment api-deployment --replicas=5

kubectl set image deployment/api-deployment api=nitinkc/myapp:2.0.0

kubectl apply -f api-hpa.yaml
kubectl apply -f api-service.yaml
kubectl apply -f api-nodeport.yaml





