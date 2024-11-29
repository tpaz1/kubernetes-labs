
# Kubernetes Labs Collection

Welcome to the `Kubernetes` Labs folder! This collection contains 8 different hands-on labs designed to enhance your understanding of `Kubernetes`. Each lab focuses on a specific concept or feature of `Kubernetes`, offering practical scenarios for learning and experimentation.

---

## **Prerequisites**
To get started with these labs, ensure the following prerequisites are met:

- A running Kubernetes cluster (e.g., Minikube, Kind, or a managed cluster).
- `kubectl` installed and configured.
- Basic understanding of Kubernetes concepts.

### **Setting Up Minikube**
For those using Minikube, you can start your cluster with the following command:

```bash
minikube start --driver=docker --cni=cilium --kubernetes-version=stable --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=AlwaysAllow --extra-config=kubelet.cgroup-driver=systemd --extra-config=kubelet.read-only-port=10255 --insecure-registry="registry.k8s.io"
```

---

## **Labs Overview**

### 1. **Using ConfigMap to Change Application**
   - **Objective**: Learn how to use a **ConfigMap** in `Kubernetes` to manage configuration data for your application.
   - **Key Topics**: `ConfigMap`, `Deployment`
   - **Folder**: `lab1-ConfigMap`
   - [Detailed Instructions](./lab1-ConfigMap/README.md)

---

### 2. **Using ConfigMap, Multiple Deployments, and Ingress**
   - **Objective**: In this lab, you will extend the previous exercise by creating two separate deployments of the same application.
   - **Key Topics**: `ConfigMap`, `Deployment`, `Ingress`.
   - **Folder**: `lab2-Ingress`
   - [Detailed Instructions](./lab2-Ingress/README.md)

---

### 3. **Understanding Persistence with StatefulSets, and Persistent Volumes**
   - **Objective**: Learn about `Kubernetes` persistence by deploying a PostgreSQL database using both **Deployments** and **StatefulSets**.
   - **Key Topics**: `PVC`, `PV`, `StorageClass`, `Statefulset`.
   - **Folder**: `lab3-persistence`
   - [Detailed Instructions](./lab3-persistence/README.md)

---

### 4. **Creating a Cluster Using KUBEADM**
   - **Objective**: This lab will guide you through the process of setting up a Kubernetes cluster using **Kubeadm**.
   - **Key Topics**: `Kubernetes` components.
   - **Folder**: `lab4-kubeadm`
   - [Detailed Instructions](./lab4-kubeadm/README.md)

---

### 5. **`Kubernetes` Network Policy Lab**
   - **Objective**: Learn how to create and apply Kubernetes Network Policies to control the communication between different applications in your cluster.
   - **Key Topics**: NetworkPolicy.
   - **Folder**: `lab5-NetworkPolicies`
   - [Detailed Instructions](./lab5-NetworkPolicies/README.md)

---

### 6. **`Kubernetes` Horizontal Pod Autoscaler (HPA)**
   - **Objective**: This lab demonstrates how to set up a `Kubernetes` `Horizontal Pod Autoscaler` (HPA) for a `deployment`, stress the CPU, and observe scaling behavior.
   - **Key Topics**: `HPA`.
   - **Folder**: `lab6-HPA`
   - [Detailed Instructions](./lab6-HPA/README.md)

---

### 7. **Readiness and Liveness Probes**
   - **Objective**: This lab demonstrates how to use `readiness` and `liveness probes` in `Kubernetes` to ensure proper health checks for containers in your cluster. 
   - **Key Topics**: `Liveness probes`, `Readiness Probes`.
   - **Folder**: `lab7-probes`
   - [Detailed Instructions](./lab7-probes/README.md)

---

### 8. **Scheduling**
   - **Objective**: This lab demonstrates how Kubernetes uses `taints`, `tolerations`, `node affinity`, and `pod anti-affinity` to control pod scheduling.
   - **Key Topics**: `Taints`, `Tolerations`, `Node Affinity`, `Pod Anti-affinity`.
   - **Folder**: `lab8-scheduling`
   - [Detailed Instructions](./lab8-scheduling/README.md)

---

## **How to Use These Labs**
1. Navigate to the folder of the lab you wish to explore.
2. Follow the instructions in the `README.md` file of the respective lab.
3. Experiment with the concepts and extend the labs as needed!

---

## **Feedback and Contributions**
If you encounter issues or have suggestions for improvement, feel free to contribute by submitting a pull request or opening an issue in the repository.

Enjoy your Kubernetes learning journey!
