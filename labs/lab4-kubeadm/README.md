
# Kubernetes Lab: Creating a Cluster Using KUBEADM

## Overview

This lab will guide you through the process of setting up a Kubernetes cluster using **Kubeadm**. By the end of this lab, you will have a functional Kubernetes cluster deployed across multiple EC2 instances.

### What You'll Learn

- How to install and configure **Kubeadm**, **Kubelet**, and **Kubectl** on EC2 instances.
- How to configure and initialize the control plane node.
- How to join worker nodes to the Kubernetes cluster.
- How to deploy a basic application (NGINX) on your cluster to verify the setup.

---

## Prerequisites

Before starting this lab, ensure you have the following:

- 3 EC2 instances running Ubuntu or any supported Linux distribution.
- Security groups configured to allow traffic into the API server (usually port 6443).
- Sudo or root access to the instances.

---

## Lab Structure

This lab is divided into the following steps:

1. **Install Kubeadm, Kubelet, and Kubectl**
2. **Set up the Control Plane**
3. **Join Worker Nodes to the Cluster**
4. **Install a Pod Network**
5. **Verify the Cluster with a Simple Application**

---

## Step 1: Install Kubeadm, Kubelet, and Kubectl

Follow the official Kubernetes installation guide for your environment: [Install Kubeadm, Kubelet, and Kubectl](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-kubeadm-kubelet-and-kubectl)

Start by updating your package list:

```bash
sudo apt-get update
```

Install necessary dependencies:

```bash
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
```

Download and add the Kubernetes repository key:

```bash
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
```

Add the Kubernetes repository to your system:

```bash
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Update package list again:

```bash
sudo apt-get update
```

Install **Kubelet**, **Kubeadm**, and **Kubectl**:

```bash
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

Enable **Kubelet** to start on boot:

```bash
sudo systemctl enable --now kubelet
```

---

## Step 2: Configure Sysctl and Install Containerd
[See](https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd)

Load the `br_netfilter` kernel module to allow bridge network packets to be passed to iptables.

```bash
sudo modprobe br_netfilter
```

Ensure the `br_netfilter` module is loaded automatically after a reboot.

```bash
echo 'br_netfilter' | sudo tee -a /etc/modules-load.d/k8s.conf
```

Check if the `br_netfilter` module is loaded in the kernel.

```bash
lsmod | grep br_netfilter
```

Write sysctl settings to enable iptables for bridge network traffic.

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
```

Kubernetes requires IP forwarding to be enabled on the nodes. Apply the sysctl parameters:

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
```

Apply the sysctl settings without reboot:

```bash
sudo sysctl --system
```

Now, install **Containerd**, the container runtime:

```bash
sudo apt install -y containerd
sudo apt install -y cri-tools
```

Configure **Containerd**:

```bash
sudo mkdir /etc/containerd
containerd config default
```

Update the **Containerd** config file to enable Systemd as the Cgroup driver:

```bash
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' | sudo tee /etc/containerd/config.toml
```

Restart **Containerd**:

```bash
sudo systemctl restart containerd
```

---

## Step 3: Initialize the Control Plane Node

[See](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node)

Now, initialize the control plane node with the following command:

```bash
sudo kubeadm init --apiserver-advertise-address <control-plane-ip> --pod-network-cidr "10.244.0.0/16" --upload-certs
```

This will output a **kubeadm join** command, which you'll use to join worker nodes to the cluster.

---

## Step 4: Join Worker Nodes to the Cluster

On each worker node, run the join command provided by the control plane node:

```bash
sudo kubeadm join <control-plane-ip>:6443 --token <token> --discovery-token-ca-cert-hash <hash>
```

---

## Step 5: Install a Pod Network

[Install a pod network](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network) to enable communication between nodes. For this lab, we'll use [**Flannel**](https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy):

```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

Verify that the pods are running correctly:

```bash
kubectl get pods -n kube-system
```

---

## Step 6: Set up Kubeconfig for Local Access

On the control plane node, copy the kubeconfig file to your local machine:

```bash
cat ~/.kube/config
```

Copy all the content of the file into your local `~/.kube/config` file. This will allow you to access the cluster from your local machine.

---

## Step 7: Verify the Cluster

Run a simple application to verify your cluster setup. For example, deploy **NGINX**:

```bash
kubectl run nginx --image=nginx
```

Check the status of your pod:

```bash
kubectl get pods
```

---

## Conclusion

Congratulations! You've successfully created a Kubernetes cluster using **Kubeadm**. You've also verified the setup by running an NGINX pod. From here, you can start deploying more complex applications and explore other Kubernetes features like services, deployments, and namespaces.
