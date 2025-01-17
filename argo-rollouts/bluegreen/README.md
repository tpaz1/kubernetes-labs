# Argo Rollouts Lab: Blue-Green Deployment with Rollback

## Objective
This lab demonstrates how to:
- Install Argo Rollouts in a Kubernetes cluster.
- Deploy a sample application using a Rollout resource with a Blue-Green deployment strategy.
- Upgrade the application version from `v3` to `v6`.
- Verify changes in the application UI.
- Explore how Argo Rollouts manages the Blue-Green deployment.
- Rollback the deployment if needed.

---

## Prerequisites
1. A running Kubernetes cluster.
2. `kubectl` CLI installed and configured to interact with your cluster.
3. `kubectl-argo-rollouts` plugin installed. [Installation guide](https://argo-rollouts.readthedocs.io/en/stable/installation/#kubectl-plugin-installation).
4. Basic knowledge of Kubernetes concepts.

---

## Step 1: Install Argo Rollouts
Install the Argo Rollouts controller in your cluster:

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

Verify the installation:

```bash
kubectl get pods -n argo-rollouts
```
You should see the Argo Rollouts controller pod running.

---

## Step 2: Create the Kubernetes Service
Create a service to expose the application:

```yaml
# service.yaml
kind: Service
apiVersion: v1
metadata:
  name: solar-service
spec:
  selector:
    app: solar-system
  ports:
  - name: solar-port
    port: 80
    targetPort: 80
```

Apply the service configuration:

```bash
kubectl apply -f service.yaml
```

---

## Step 3: Deploy the Initial Rollout
Create the initial `Rollout` resource using the Blue-Green strategy:

```yaml
# rollout.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: bluegreen-demo
  namespace: default
spec:
  replicas: 3
  revisionHistoryLimit: 2
  strategy:
    blueGreen:
      activeService: solar-service
      previewService: preview-service
      autoPromotionEnabled: false
  selector:
    matchLabels:
      app: bluegreen-demo
  template:
    metadata:
      labels:
        app: bluegreen-demo
    spec:
      containers:
      - name: bluegreen-demo
        image: siddharth67/solar-system:v3
        ports:
        - containerPort: 80
```

Apply the rollout configuration:

```bash
kubectl apply -f rollout.yaml
```

Verify the rollout:

```bash
kubectl get rollouts
kubectl argo rollouts get rollout bluegreen-demo
```

---

## Step 4: Upgrade the Application
Update the Rollout to use version `v6` of the application:

```bash
kubectl argo rollouts set image bluegreen-demo bluegreen-demo=siddharth67/solar-system:v6

```

Verify that the rollout has started:

```bash
kubectl argo rollouts get rollout bluegreen-demo --watch
```

---

## Step 5: Verify the Change in UI
Access the **preview service** to verify the changes before promoting the new version.

1. Create a temporary port-forward to the `preview-service`:
   ```bash
   kubectl port-forward svc/preview-service 8080:80
   ```

2. Open your browser and navigate to `http://localhost:8080` to verify the UI reflects version `v6`.

---

## Step 6: Promote the New Version
Once satisfied with the preview, promote the new version to production:

```bash
kubectl argo rollouts promote bluegreen-demo
```

Verify that the active service is updated:

```bash
kubectl argo rollouts get rollout bluegreen-demo
```
Access the application via the `solar-service` service:

```bash
kubectl port-forward svc/solar-service 8080:80
```

Navigate to `http://localhost:8080` and confirm the UI reflects version `v6`.

---

## Step 7: Rollback the Deployment
If issues are detected after promotion, rollback to the previous version (`v3`):

```bash
kubectl argo rollouts rollback bluegreen-demo
```

Verify the rollback:

```bash
kubectl argo rollouts get rollout bluegreen-demo
```
Access the application again via the `solar-service` service and confirm it is back to version `v3`.

---

## Additional Steps (Optional)
1. **View Rollout History:**
   ```bash
   kubectl argo rollouts history bluegreen-demo
   ```
2. **Add Metric Analysis:**
   Integrate Prometheus to automatically halt or rollback based on performance metrics.

---

## Cleanup
To clean up resources created during this lab:

```bash
kubectl delete rollout bluegreen-demo
kubectl delete service solar-service
kubectl delete service preview-service
kubectl delete namespace argo-rollouts
```
