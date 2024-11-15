
# Kubernetes Lab: Using ConfigMap to Change Application Behavior

## Overview

In this lab, you will learn how to use a **ConfigMap** in Kubernetes to manage configuration data for your application. You will deploy a sample application, observe its default behavior, and then update the configuration to see how it affects the running application.

### What You'll Learn
- How to deploy a Kubernetes **ConfigMap**.
- How to use **ConfigMap** values in a deployment.
- How to change configuration data without modifying the application code.
- How to apply changes using `kubectl rollout restart`.

---

## Prerequisites

Before starting this lab, ensure you have the following:
- Access to a Kubernetes cluster (e.g., Minikube, Docker Desktop, or a cloud provider).
- **kubectl** command-line tool installed and configured.
- Basic knowledge of Kubernetes objects (ConfigMap, Deployment, Service).

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
  UI_COLOR: "green" # Default color
```

### Apply the ConfigMap

Run the following command to create the ConfigMap:

```bash
kubectl apply -f color-config.yaml
```

---

## Step 2: Deploy the Application

Now, you'll deploy a sample application that uses the **ConfigMap** for its UI color.

### Deployment Manifest

Create a file named `color-app-deployment.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: color-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: color-app
  template:
    metadata:
      labels:
        app: color-app
    spec:
      containers:
        - name: color-app
          image: tpaz1/devopscourse:latest
          ports:
            - containerPort: 8080 # Default port for this app
          env:
            - name: UI_COLOR
              valueFrom:
                configMapKeyRef:
                  name: color-config
                  key: UI_COLOR
```

### Service Manifest

Create a file named `color-app-service.yaml` with the following content:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: color-app
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: color-app
```

### Apply the Deployment and Service

Run the following commands:

```bash
kubectl apply -f color-app-deployment.yaml
kubectl apply -f color-app-service.yaml
```

---

## Step 3: Access the Application

- Once the **Service** is created, get the external IP to access the application:

  ```bash
  kubectl get svc color-app
  ```

- Open a web browser and go to the external IP address to see the application.

---

## Step 4: Update the ConfigMap

Let's change the UI color of the application.

### Edit the ConfigMap

Run the following command to edit the ConfigMap:

```bash
kubectl edit configmap color-config
```

- Change the `UI_COLOR` value from `"green"` to any other color (e.g., `"blue"`):

  ```yaml
  data:
    UI_COLOR: "blue"
  ```

- Save and exit the editor.

---

## Step 5: Apply Changes to the Deployment

After updating the ConfigMap, you need to restart the deployment to apply the changes:

```bash
kubectl rollout restart deployment/color-app
```

- Wait a few moments for the application to restart.
- Refresh the browser to see the updated UI color.

---

## Step 6: Cleanup (Optional)

To delete all the resources created in this lab:

```bash
kubectl delete deployment color-app
kubectl delete service color-app
kubectl delete configmap color-config
```

---

## Conclusion

In this lab, you learned how to use a **ConfigMap** to dynamically change application configuration without modifying its code. You also practiced using `kubectl rollout restart` to apply configuration changes.

Feel free to experiment with different configuration values and observe how they affect the application!

---
