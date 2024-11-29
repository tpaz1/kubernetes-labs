
# Kubernetes Lab: Readiness and Liveness Probes

This lab demonstrates how to use readiness and liveness probes in Kubernetes to ensure proper health checks for containers in your cluster. You'll configure these probes for a deployment and observe how Kubernetes handles failing probes.

---

## **Lab Objectives**
1. Understand the purpose of readiness and liveness probes.
2. Configure HTTP, TCP, and command-based probes.
3. Simulate failures to observe Kubernetes behavior.

---

## **Prerequisites**
1. A running Kubernetes cluster (e.g., Minikube or any other).
2. `kubectl` installed and configured to manage your cluster.

---

## **Scenario Overview**
1. Deploy an HTTP-based application (e.g., `nginx` or a custom Flask app).
2. Configure:
   - A **readiness probe** to ensure the app is ready to serve traffic.
   - A **liveness probe** to check if the app is healthy.
3. Simulate failures:
   - Delay app readiness.
   - Cause app health failures.
4. Observe Kubernetes responses:
   - Pods marked as **not ready**.
   - Pods restarted due to liveness probe failures.

---

## **Step 1: Create a Deployment**
This deployment uses `nginx` with custom readiness and liveness probes.

<details>
<summary>View Deployment YAML</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: probe-demo
  labels:
    app: probe-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: probe-demo
  template:
    metadata:
      labels:
        app: probe-demo
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 5
```

</details>

Apply the deployment:
```bash
kubectl apply -f probe-demo.yaml
```

---

## **Step 2: Monitor Deployment**
1. Check the pod status:
   ```bash
   kubectl get pods
   ```

2. Observe readiness and liveness probes:
   ```bash
   kubectl describe pod <pod-name>
   ```

---

## **Step 3: Simulate Failures**

### **A. Simulate Readiness Probe Failure**
1. Edit the readiness probe to check a non-existing path:
   ```bash
   kubectl edit deployment probe-demo
   ```

   <details>
   <summary>View Updated Readiness Probe YAML</summary>

   ```yaml
   readinessProbe:
     httpGet:
       path: /nonexistent
       port: 80
     initialDelaySeconds: 5
     periodSeconds: 10
   ```

   </details>

2. Observe the pod's readiness:
   ```bash
   kubectl get pods
   ```

   The pod will enter the `NotReady` state because the readiness probe fails.

3. Restore the readiness probe path to `/` to make the pod ready again:
   ```bash
   kubectl edit deployment probe-demo
   ```

---

### **B. Simulate Liveness Probe Failure**
1. Edit the liveness probe to check a non-existing path:
   ```bash
   kubectl edit deployment probe-demo
   ```

   <details>
   <summary>View Updated Liveness Probe YAML</summary>

   ```yaml
   livenessProbe:
     httpGet:
       path: /nonexistent
       port: 80
     initialDelaySeconds: 15
     periodSeconds: 5
   ```

   </details>

2. Observe the pod restarts:
   ```bash
   kubectl get pods
   kubectl describe pod <pod-name>
   ```

   Kubernetes will restart the container because the liveness probe fails.

---

## **Step 4: Use Command-Based Probes**
Replace HTTP-based probes with a command-based probe to check file availability.

1. Update the deployment:
   ```bash
   kubectl edit deployment probe-demo
   ```

   <details>
   <summary>View Command-Based Probes YAML</summary>

   ```yaml
   readinessProbe:
     exec:
       command:
       - cat
       - /etc/alpine-release
     initialDelaySeconds: 5
     periodSeconds: 10
   livenessProbe:
     exec:
       command:
       - cat
       - /etc/alpine-release
     initialDelaySeconds: 15
     periodSeconds: 5
   ```

   </details>

2. Simulate readiness and liveness failures by removing the required files:
   - Inside the pod, remove `/etc/alpine-release` to fail the readiness probe:
     ```bash
     kubectl exec -it <pod-name> -- sh -c "rm /etc/alpine-release"
     ```
   - Remove `/etc/alpine-release` to fail the liveness probe and trigger a pod restart:
     ```bash
     kubectl exec -it <pod-name> -- sh -c "rm /etc/alpine-release"
     ```

---

## **Step 5: Monitor Kubernetes Behavior**
1. Observe pod readiness and restarts:
   ```bash
   kubectl get pods
   kubectl describe pod <pod-name>
   ```

2. Check event logs for probe failures:
   ```bash
   kubectl logs <pod-name>
   ```

---

## **Step 6: Cleanup**
Remove all resources:
```bash
kubectl delete deployment probe-demo
```

---

## **Lab Summary**
In this lab, you:
1. Configured readiness and liveness probes for a deployment.
2. Simulated readiness and liveness failures to observe Kubernetes behavior.
3. Used HTTP and command-based probes for advanced health checks.

This lab demonstrates how Kubernetes uses probes to manage pod health and ensure reliability in your cluster.
