
# Kubernetes Lab: Using ConfigMap, Multiple Deployments, and Ingress

## Overview

In this lab, you will extend the previous exercise by creating two separate deployments of the same application, each with a different UI color. You will then set up an **Ingress** resource to route traffic based on the URL path.

### What You'll Learn
- How to deploy multiple Kubernetes **Deployments** with different configurations.
- How to set up an **Ingress** to route traffic to different services based on the URL path.
- How to manage application configurations using **ConfigMap**.

---

## Prerequisites

Before starting this lab, ensure you have the following:
- Access to a Kubernetes cluster (e.g., Minikube, Docker Desktop, or a cloud provider).
- **kubectl** command-line tool installed and configured.
- **Ingress Controller** installed in your Kubernetes cluster.
- Basic knowledge of Kubernetes objects (ConfigMap, Deployment, Service, Ingress).

---

## Step 1: Create a ConfigMap

The **ConfigMap** will store the configuration value for the application's UI color.

### ConfigMap Manifest

Create a file named `color-config.yaml` with the following content:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: color-config
data:
  UI_COLOR_BLUE: "blue"
  UI_COLOR_GREEN: "green"
```

### Apply the ConfigMap

Run the following command to create the ConfigMap:

```bash
kubectl apply -f color-config.yaml
```

---

## Step 2: Deploy the Blue and Green Applications

### Blue Deployment

Create a file named `color-app-blue-deployment.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: color-app-blue
spec:
  replicas: 1
  selector:
    matchLabels:
      app: color-app-blue
  template:
    metadata:
      labels:
        app: color-app-blue
    spec:
      containers:
        - name: color-app
          image: tpaz1/devopscourse:latest
          ports:
            - containerPort: 8080
          env:
            - name: UI_COLOR
              valueFrom:
                configMapKeyRef:
                  name: color-config
                  key: UI_COLOR_BLUE
```

### Green Deployment

Create a file named `color-app-green-deployment.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: color-app-green
spec:
  replicas: 1
  selector:
    matchLabels:
      app: color-app-green
  template:
    metadata:
      labels:
        app: color-app-green
    spec:
      containers:
        - name: color-app
          image: tpaz1/devopscourse:latest
          ports:
            - containerPort: 8080
          env:
            - name: UI_COLOR
              valueFrom:
                configMapKeyRef:
                  name: color-config
                  key: UI_COLOR_GREEN
```

### Apply the Deployments

Run the following commands:

```bash
kubectl apply -f color-app-blue-deployment.yaml
kubectl apply -f color-app-green-deployment.yaml
```

---

## Step 3: Create Services for Both Deployments

### Blue Service

Create a file named `color-app-blue-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: color-app-blue
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: color-app-blue
```

### Green Service

Create a file named `color-app-green-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: color-app-green
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: color-app-green
```

### Apply the Services

Run the following commands:

```bash
kubectl apply -f color-app-blue-service.yaml
kubectl apply -f color-app-green-service.yaml
```

---

## Step 4: Set Up Ingress for Path-Based Routing

Create a file named `color-app-ingress.yaml` with the following content:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: color-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - http:
        paths:
          - path: /blue
            pathType: Prefix
            backend:
              service:
                name: color-app-blue
                port:
                  number: 80
          - path: /green
            pathType: Prefix
            backend:
              service:
                name: color-app-green
                port:
                  number: 80
```

### Apply the Ingress

Run the following command:

```bash
kubectl apply -f color-app-ingress.yaml
```

---

## Step 5: Access the Application

- Get the Ingress Controller's external IP:

  ```bash
  kubectl get ingress color-app-ingress
  ```

- Open a web browser and go to the following URLs:
  - `http://<EXTERNAL-IP>/blue` to access the blue deployment.
  - `http://<EXTERNAL-IP>/green` to access the green deployment.

---

## Step 6: Cleanup (Optional)

To delete all the resources created in this lab:

```bash
kubectl delete deployment color-app-blue
kubectl delete deployment color-app-green
kubectl delete service color-app-blue
kubectl delete service color-app-green
kubectl delete configmap color-config
kubectl delete ingress color-app-ingress
```

---

## Conclusion

In this lab, you learned how to deploy multiple applications with different configurations and route traffic to them using an **Ingress** resource. This is useful for managing different versions of an application or serving multiple environments from the same Kubernetes cluster.

Feel free to experiment with different configurations and explore the capabilities of Kubernetes Ingress!

---
