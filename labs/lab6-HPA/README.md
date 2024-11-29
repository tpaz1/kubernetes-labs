
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

4. **Stress Testing Tool**: We'll use a `busybox` pod to stress the application.

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
