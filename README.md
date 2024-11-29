# kubernetes-labs

minikube start --driver=docker --cni=cilium --insecure-registry="registry.k8s.io" --extra-config=apiserver.oidc-ca-file="" --extra-config=apiserver.authorization-mode=AlwaysAllow 
--extra-config=kubelet.authentication-token-webhook=false 


minikube start --driver=docker --cni=cilium --kubernetes-version=stable --extra-config=kubelet.authentication-token-webhook=true --extra-config=kubelet.authorization-mode=AlwaysAllow --extra-config=kubelet.cgroup-driver=systemd --extra-config=kubelet.read-only-port=10255 --insecure-registry="registry.k8s.io"


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


"--cert-dir=/tmp"
"--secure-port=10250"
"--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname"
"--kubelet-use-node-status-port"
"--metric-resolution=15s"