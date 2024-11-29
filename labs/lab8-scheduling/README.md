
# Kubernetes Lab: Scheduling with Taints, Tolerations, Node Affinity, and Pod Anti-Affinity

This lab demonstrates how Kubernetes uses taints, tolerations, node affinity, and pod anti-affinity to control pod scheduling.

---

## **Prerequisites**
1. A running Kubernetes cluster (e.g., Minikube with two nodes: master and worker).
2. `kubectl` installed and configured.

---

## **Cluster Setup**

### Step 1: Start Minikube with Two Nodes
1. Start Minikube:
   ```bash
   minikube start --driver=docker --cni=cilium --kubernetes-version=stable --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=AlwaysAllow --extra-config=kubelet.cgroup-driver=systemd --extra-config=kubelet.read-only-port=10255 --insecure-registry="registry.k8s.io"
   ```

2. Add a worker node:
   ```bash
   minikube node add
   ```

3. Verify nodes:
   ```bash
   kubectl get nodes
   ```

You should see:
```
NAME           STATUS   ROLES                  AGE   VERSION
minikube       Ready    control-plane,master   Xs    v1.XX.X
minikube-m02   Ready    <none>                 Xs    v1.XX.X
```

---

## **Taint the Master Node**
To prevent non-system pods from being scheduled on the master node:

1. Add a taint to the master node:
   ```bash
   kubectl taint nodes minikube node-role.kubernetes.io/master:NoSchedule
   ```

2. Verify the taint:
   ```bash
   kubectl describe node minikube | grep Taint
   ```

---

## **Lab Objectives**
1. Understand and configure **taints and tolerations**.
2. Learn how to use **node affinity** to schedule pods on specific nodes.
3. Use **pod anti-affinity** to distribute pods across nodes.

---

## **1. Taints and Tolerations**

### Step 1: Taint the Worker Node
Taint the worker node to prevent pods from being scheduled unless they tolerate the taint:
```bash
kubectl taint nodes minikube-m02 key1=value1:NoSchedule
```

Verify the taint:
```bash
kubectl describe node minikube-m02 | grep Taint
```

### Step 2: Deploy a Pod Without Tolerations
<details>
<summary>View Pod YAML</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: no-toleration-pod
spec:
  containers:
  - name: nginx
    image: nginx
```

</details>

Apply the pod:
```bash
kubectl apply -f no-toleration-pod.yaml
```

The pod will be **Pending** because it cannot be scheduled on the tainted worker node or the master node (master is also tainted).

### Step 3: Deploy a Pod with Tolerations
<details>
<summary>View Pod YAML</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toleration-pod
spec:
  tolerations:
  - key: "key1"
    operator: "Equal"
    value: "value1"
    effect: "NoSchedule"
  containers:
  - name: nginx
    image: nginx
```

</details>

Apply the pod:
```bash
kubectl apply -f toleration-pod.yaml
```

The pod should now run on the tainted worker node.

---

## **2. Node Affinity**

### Step 1: Label the Worker Node
Label the worker node:
```bash
kubectl label nodes minikube-m02 disktype=ssd
```

Verify the label:
```bash
kubectl get nodes --show-labels
```

### Step 2: Deploy a Pod with Node Affinity
<details>
<summary>View Pod YAML</summary>

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: nginx
    image: nginx
```

</details>

Apply the pod:
```bash
kubectl apply -f node-affinity-pod.yaml
```

The pod should be scheduled on the worker node.

---

## **3. Pod Anti-Affinity**

### Step 1: Deploy a Pod with Anti-Affinity
<details>
<summary>View Deployment YAML</summary>

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: anti-affinity-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: anti-affinity
  template:
    metadata:
      labels:
        app: anti-affinity
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app: anti-affinity
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: nginx
        image: nginx
```

</details>

Apply the deployment:
```bash
kubectl apply -f anti-affinity-deployment.yaml
```

### Step 2: Verify Pod Distribution
Check where the pods are scheduled:
```bash
kubectl get pods -o wide
```

The pods should be distributed across the nodes.

---

## **Cleanup**
Remove all resources created during the lab:
```bash
kubectl delete pod no-toleration-pod toleration-pod node-affinity-pod
kubectl delete deployment anti-affinity-app
kubectl taint nodes minikube-m02 key1=value1:NoSchedule-
kubectl label nodes minikube-m02 disktype-
kubectl taint nodes minikube node-role.kubernetes.io/master:NoSchedule-
```

---

## **Lab Summary**
1. **Taints and Tolerations**: Prevent pods from being scheduled on nodes unless they tolerate the taints.
2. **Node Affinity**: Schedule pods on specific nodes based on labels.
3. **Pod Anti-Affinity**: Distribute pods across nodes to avoid co-locating them.

This lab demonstrates how Kubernetes uses scheduling controls to manage workload placement.
