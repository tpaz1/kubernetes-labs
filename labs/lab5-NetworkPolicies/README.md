# Kubernetes Network Policy Lab

## Overview

In this lab, you will learn how to create and apply Kubernetes Network Policies to control the communication between different applications in your cluster. Network Policies allow you to define rules that control traffic flow between pods based on labels, namespaces, and ports.

This is an advanced lab, so you should be familiar with Kubernetes networking and basic resource management. 

## Prerequisites

- A Kubernetes cluster (Minikube, AWS EKS, or any cluster running Kubernetes)
- `kubectl` installed and configured to interact with your cluster
- `metrics-server` installed on the cluster

# Kubernetes Metrics Server Installation and Patching Guide

## **Step 1: Install the Metrics Server**

1. Apply the Metrics Server YAML:
   Use the official Metrics Server deployment file from GitHub:
   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

2. Verify that the Metrics Server is deployed:
   ```bash
   kubectl -n kube-system get pods -l k8s-app=metrics-server
   ```

   You should see the Metrics Server pod in the **Running** state.

---

## **Step 2: Patch the Metrics Server Deployment**

Patch the Metrics Server deployment to configure it properly:

1. Run the following command:
   ```bash
   kubectl -n kube-system patch deployment metrics-server --type='json' -p='[{
     "op": "add", 
     "path": "/spec/template/spec/containers/0/args", 
     "value": [
       "--kubelet-insecure-tls",
       "--cert-dir=/tmp",
       "--secure-port=10250",
       "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname",
       "--kubelet-use-node-status-port",
       "--metric-resolution=15s"
     ]
   }]'
   ```

---

## **Step 3: Restart the Metrics Server Deployment**

Restart the Metrics Server deployment to apply the patch:
```bash
kubectl -n kube-system rollout restart deployment metrics-server
```

---

## **Step 4: Verify the Metrics Server**

1. **Check Logs**:
   Ensure the Metrics Server pod is running without issues:
   ```bash
   kubectl -n kube-system logs -l k8s-app=metrics-server
   ```

2. **Test Metrics Availability**:
   Use the following commands to verify the Metrics API:
   ```bash
   kubectl top nodes
   kubectl top pods
   ```

   If these commands return metrics, the Metrics Server is working correctly.

---

## **Explanation of Patching Arguments**

- **`--kubelet-insecure-tls`**: Disables TLS verification for connections to the kubelet.
- **`--cert-dir=/tmp`**: Specifies a temporary directory for certificates.
- **`--secure-port=10250`**: Configures the Metrics Server to use the kubelet's secure port.
- **`--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname`**: Prioritizes the order of node address types for connections.
- **`--kubelet-use-node-status-port`**: Ensures the Metrics Server uses the correct port from the node status.
- **`--metric-resolution=15s`**: Sets the resolution interval for metrics scraping.

---

## **Summary**
- Installed the Metrics Server using the official YAML.
- Patched the deployment to fix connectivity issues in custom environments.
- Verified the Metrics Server by testing node and pod metrics.

This setup ensures the Metrics Server works seamlessly in various Kubernetes environments.

---

## Lab Steps

### Step 1: Setup a Simple Multi-Tier Application

1. **Create two namespaces**: One for frontend and one for backend.

    ```bash
    kubectl create namespace frontend
    kubectl create namespace backend
    ```

2. **Create a simple backend service** (e.g., an HTTP API).

    <details>
    <summary>Click to see Backend Deployment YAML</summary>

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: backend
      namespace: backend
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: backend
      template:
        metadata:
          labels:
            app: backend
        spec:
          containers:
            - name: backend
              image: nginx:latest
              ports:
                - containerPort: 80
    ```
    </details>

    Apply the deployment:

    ```bash
    kubectl apply -f backend-deployment.yaml
    ```

    <details>
    <summary>Click to see Backend Service YAML</summary>

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: backend
      namespace: backend
    spec:
      selector:
        app: backend
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80
    ```
    </details>

    Apply the service:

    ```bash
    kubectl apply -f backend-service.yaml
    ```

3. **Create a frontend service** (e.g., a simple web page that makes requests to the backend).

    <details>
    <summary>Click to see Frontend Deployment YAML</summary>

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: frontend
      namespace: frontend
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: frontend
      template:
        metadata:
          labels:
            app: frontend
        spec:
          containers:
            - name: frontend
              image: nginx:latest
              ports:
                - containerPort: 80
    ```
    </details>

    Apply the deployment:

    ```bash
    kubectl apply -f frontend-deployment.yaml
    ```

    <details>
    <summary>Click to see Frontend Service YAML</summary>

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: frontend
      namespace: frontend
    spec:
      selector:
        app: frontend
      ports:
        - protocol: TCP
          port: 80
          targetPort: 80
    ```
    </details>

    Apply the service:

    ```bash
    kubectl apply -f frontend-service.yaml
    ```

### Step 2: Apply Network Policies

1. **Create a basic network policy** that allows only the frontend to access the backend.

    <details>
    <summary>Click to see Network Policy YAML</summary>

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: NetworkPolicy
    metadata:
      name: backend-network-policy
      namespace: backend
    spec:
      podSelector:
        matchLabels:
          app: backend
      policyTypes:
      - Ingress
      - Egress
      ingress:
      - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: frontend
      egress:
      - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: frontend
    ```
    </details>

    Apply the network policy:

    ```bash
    kubectl apply -f network-policy.yaml
    ```

### Step 3: Verify Communication

1. **Test access** between frontend and backend pods:

    - First, enter a frontend pod:

      ```bash
      kubectl exec -it frontend-xxxxxx-xxxxx --namespace=frontend -- /bin/sh

      ```

    - Test access to the backend service from the frontend pod:

      ```bash
      wget backend.backend.svc.cluster.local
      ```

    This should succeed as per the network policy.

2. **Test blocked access** from an unrelated pod:

    - Create an unrelated pod (e.g., a pod in the `default` namespace):

      ```bash
      kubectl run -it --rm --namespace=default busybox --image=busybox --restart=Never -- /bin/sh
      ```

    - Try to access the backend service from this pod:

      ```bash
      wget backend.backend.svc.cluster.local
      ```

    This should fail because the network policy blocks access.
### Step 4: Clean Up

1. Delete the resources:

    ```bash
    kubectl delete -f frontend-deployment.yaml
    kubectl delete -f frontend-service.yaml
    kubectl delete -f backend-deployment.yaml
    kubectl delete -f backend-service.yaml
    kubectl delete -f network-policy.yaml
    ```

## Conclusion

In this lab, you've learned how to create a simple multi-tier application with frontend and backend services and applied a Kubernetes Network Policy to control traffic between the services. This practice gives you a fundamental understanding of network security and communication control in Kubernetes.

Feel free to extend this lab by experimenting with different network policies or adding more complex microservices to your application.
