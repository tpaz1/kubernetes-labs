
# Kubernetes Lab: Horizontal Pod Autoscaler (HPA)

This lab demonstrates how to set up a Kubernetes Horizontal Pod Autoscaler (HPA) for a deployment, stress the CPU, and observe scaling behavior.

---

## Prerequisites

1. **Kubernetes Cluster**: A running cluster (e.g., Minikube, Docker Desktop, GKE, EKS, or AKS).
2. **Kubectl Installed**: Ensure you have `kubectl` configured to interact with your cluster.
3. **Metrics Server**: Required for HPA to work. Install it if not already present:
   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

 cluster
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

## Steps

### 1. Create a Deployment

Create a deployment running a CPU-intensive application.

<details>
<summary>View Deployment YAML</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cpu-stress-deployment
  labels:
    app: cpu-stress
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cpu-stress
  template:
    metadata:
      labels:
        app: cpu-stress
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        volumeMounts:
        - name: html-volume
          mountPath: /usr/share/nginx/html
        resources:
          requests:
            cpu: "20m"
          limits:
            cpu: "60m"
        ports:
        - containerPort: 80
      volumes:
      - name: html-volume
        configMap:
          name: html-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: html-config
data:
  index.html: |
    <html>
      <head><title>CPU Stress Test</title></head>
      <body><h1>Welcome to the CPU Stress Test!</h1></body>
    </html>
```

</details>

Apply the deployment:
```bash
kubectl apply -f cpu-app.yaml
```

---

### 2. Expose the Deployment

Expose the deployment as a ClusterIP service:

<details>
<summary>View Service YAML</summary>

```yaml
apiVersion: v1
kind: Service
metadata:
  name: cpu-stress-service
  labels:
    app: cpu-stress
spec:
  selector:
    app: cpu-stress
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 80
```
</details>

Apply the service:
```bash
kubectl apply -f cpu-app-svc.yaml
```

### 3. Set Up Horizontal Pod Autoscaler

Create an HPA for the deployment, targeting 50% CPU utilization and scaling between 1 and 5 replicas:
<details>
<summary>View HPA YAML</summary>

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: cpu-stress-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: cpu-stress-deployment
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

</details>

Apply the HPA:
```bash
kubectl apply -f cpu-app-HPA.yaml
```


Verify the HPA:
```bash
kubectl get hpa
```

---

### 4. Stress the Application

Use a `busybox` pod to generate continuous load on the application.

<details>
<summary>View Stress Pod YAML</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: stress-pod
spec:
  containers:
  - name: stress
    image: busybox
    command:
    - /bin/sh
    - -c
    - while true; do wget -q -O- http://cpu-stress-service.default.svc.cluster.local:8080; done;
```

</details>

Apply the stress pod:
```bash
kubectl apply -f stress-pod.yaml
```

---

### 5. Monitor Scaling Behavior

Watch the HPA in action:
```bash
kubectl get hpa -w
```

Observe the scaling of replicas:
```bash
kubectl get pods -l app=cpu-stress -w
```

---

### Optional Enhancements

1. **Visualize Metrics**: Use monitoring tools like Prometheus and Grafana.
2. **Custom Metrics**: Experiment with Kubernetes Metrics Adapter.
3. **Scale Down**: Stop the stress pod to observe scaling down.

---

### Cleanup

Remove all resources after the lab:
```bash
kubectl delete deployment cpu-stress-deployment
kubectl delete hpa cpu-stress-deployment
kubectl delete pod stress-pod
kubectl delete svc cpu-stress-deployment
```

---

Enjoy exploring the Kubernetes Horizontal Pod Autoscaler!
