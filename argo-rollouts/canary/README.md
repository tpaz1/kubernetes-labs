# Argo Rollouts Lab: Canary Deployment with Rollback

## Objective
This lab demonstrates how to:
- Install Argo Rollouts in a Kubernetes cluster.
- Deploy a sample application using a Rollout resource.
- Upgrade the application version from `v3` to `v6` with a canary deployment strategy.
- Verify changes in the application UI.
- Observe Argo Rollouts managing the upgrade.
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
Create the initial `Rollout` resource:

```yaml
# rollout.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: canary-demo
  namespace: default
spec:
  replicas: 3
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: { duration: 30s }
      - setWeight: 50
      - pause: { duration: 60s }
      - setWeight: 100
  selector:
    matchLabels:
      app: canary-demo
  template:
    metadata:
      labels:
        app: canary-demo
    spec:
      containers:
      - name: canary-demo
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
kubectl argo rollouts get rollout canary-demo
```

---

## Step 4: Upgrade the Application
Update the Rollout to use version `v6` of the application:
kubectl argo rollouts set image canary-demo canary-demo=siddharth67/solar-system:v3
```bash
kubectl argo rollouts set image canary-demo canary-demo=siddharth67/solar-system:v3
```

Verify that the rollout has started:

```bash
kubectl argo rollouts get rollout canary-demo --watch
```

---

## Step 5: Verify the Change in UI
Access the application via the `solar-service` service.

```bash
kubectl port-forward svc/solar-service 8080:80
```

Open your browser and navigate to `http://localhost:8080` to verify the UI reflects version `v6`.

---

## Step 6: Observe Argo Rollouts Managing the Upgrade
1. Watch how Argo Rollouts shifts traffic gradually based on the defined `canary` steps:
   ```bash
   kubectl argo rollouts get rollout canary-demo --watch
   ```
   You will see traffic weights updating over time.

2. Pause and resume the rollout manually:
   ```bash
   kubectl argo rollouts pause canary-demo
   kubectl argo rollouts resume canary-demo
   ```

---

## Step 7: Rollback the Deployment
If issues are detected, rollback to the previous version (`v3`):

```bash
kubectl argo rollouts rollback canary-demo
```

Verify the rollback:

```bash
kubectl argo rollouts get rollout canary-demo
```
Access the application again and confirm it is back to version `v3`.

---

## Additional Steps (Optional)
1. **View Rollout History:**
   ```bash
   kubectl argo rollouts history canary-demo
   ```
2. **Add Metric Analysis:**
   Integrate Prometheus to automatically halt or rollback based on performance metrics.

---

## Cleanup
To clean up resources created during this lab:

```bash
kubectl delete rollout canary-demo
kubectl delete service solar-service
kubectl delete namespace argo-rollouts
```
