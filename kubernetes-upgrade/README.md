# Подходы к развёртыванию

Проведём установку Kubernetes v1.27 с последующим обновлением до Kubernetes v1.28

## Установка kubeadm
Документация: [Installing kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

### Installing a container runtime
Документация: [container-runtimes](https://kubernetes.io/docs/setup/production-environment/container-runtimes/)

#### Install and configure prerequisites

Forwarding IPv4 and letting iptables see bridged traffic 

```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

Verify that the br_netfilter, overlay modules are loaded by running the following commands:
```
lsmod | grep "br_netfilter\|overlay"

br_netfilter           28672  0
bridge                176128  1 br_netfilter
overlay               118784  0
```

Verify that the net.bridge.bridge-nf-call-iptables, net.bridge.bridge-nf-call-ip6tables, and net.ipv4.ip_forward system variables are set to 1 in your sysctl config by running the following command:

```
sysctl net.bridge.bridge-nf-call-iptables net.bridge.bridge-nf-call-ip6tables net.ipv4.ip_forward

net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
```

Если не выключить apparmor, не запустится cni:
```
systemctl stop apparmor
systemctl disable apparmor 
systemctl reboot
```

#### cgroup drivers

There are two cgroup drivers available:

- cgroupfs
- systemd

The cgroupfs driver is not recommended when systemd is the init system because systemd expects a single cgroup manager on the system. Additionally, if you use cgroup v2, use the systemd cgroup driver instead of cgroupfs

To set systemd as the cgroup driver, edit the KubeletConfiguration option of cgroupDriver and set it to systemd. For example:

```
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
...
cgroupDriver: systemd
```

Note: Starting with v1.22 and later, when creating a cluster with kubeadm, if the user does not set the cgroupDriver field under KubeletConfiguration, kubeadm defaults it to systemd.

#### containerd
Документация: [containerd getting-started](https://github.com/containerd/containerd/blob/main/docs/getting-started.md)
Так же можно установить средствами [пакетного менеджера](https://docs.docker.com/engine/install/ubuntu/)

##### Step 1: Installing containerd

Download the containerd-<VERSION>-<OS>-<ARCH>.tar.gz archive and unpack:

```
wget https://github.com/containerd/containerd/releases/download/v1.7.13/containerd-1.7.13-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.13-linux-amd64.tar.gz
```

If you intend to start containerd via systemd, you should also download the containerd.service unit file:

```
sudo wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service -P /usr/local/lib/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable --now containerd
```

##### Step 2: Installing runc

Download the runc.<ARCH> binary from https://github.com/opencontainers/runc/releases and install it as /usr/local/sbin/runc

```
wget https://github.com/opencontainers/runc/releases/download/v1.1.12/runc.amd64 
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
```

##### Step 3: Installing CNI plugins

Download the cni-plugins archive from https://github.com/containernetworking/plugins/releases , and extract it under /opt/cni/bin:

```
sudo mkdir -p /opt/cni/bin
wget https://github.com/containernetworking/plugins/releases/download/v1.4.0/cni-plugins-linux-amd64-v1.4.0.tgz
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.4.0.tgz
```

##### Step 4: generate config.toml

The default configuration can be generated via:

```
sudo mkdir /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
```

#### Configuring the systemd cgroup driver

Set up SystemdCgroup:

```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true

sudo systemctl restart containerd
```

#### Installing kubeadm, kubelet and kubectl

These instructions are for Kubernetes 1.27.

```
sudo apt-get update
# apt-transport-https may be a dummy package; if so, you can skip that package
sudo apt-get install -y apt-transport-https ca-certificates curl

wget --no-check-certificate -qO - https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | apt-key add -

# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

## Creating a cluster with kubeadm
Документация: [create-cluster-kubeadm](https://v1-27.docs.kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

master-node:
```
kubeadm init --control-plane-endpoint cluster-endpoint.internal --pod-network-cidr=10.244.0.0/16 --upload-certs --kubernetes-version=v1.27.0 --cri-socket /run/containerd/containerd.sock
```

```
Your Kubernetes control-plane has initialized successfully!
```

To start using your cluster, you need to run the following as a regular user:
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

```
$ kubectl get nodes
NAME         STATUS     ROLES           AGE     VERSION
k8s-master   NotReady   control-plane   2m22s   v1.27.11
```

You should now deploy a pod network to the cluster. Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
 https://kubernetes.io/docs/concepts/cluster-administration/addons/

You must deploy a Container Network Interface (CNI) based Pod network add-on so that your Pods can communicate with each other. Cluster DNS (CoreDNS) will not start up before a network is installed.

```
$ kubectl -n kube-system get po
NAME                                 READY   STATUS    RESTARTS   AGE
coredns-5d78c9869d-9dthr             0/1     Pending   0          6m32s
coredns-5d78c9869d-gsvx5             0/1     Pending   0          6m32s
```

Install calico with [quickstart](https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart)

В одном из манифестов, необходимо сменить сеть на ту, что указывали в --pod-network-cidr;

```
$ kubectl -n kube-system get pod
NAME                                 READY   STATUS    RESTARTS   AGE
coredns-5d78c9869d-9dthr             1/1     Running   0          34m
coredns-5d78c9869d-gsvx5             1/1     Running   0          34m

$ kubectl get nodes
NAME         STATUS   ROLES           AGE   VERSION
k8s-master   Ready    control-plane   35m   v1.27.11
```

You can now join any number of the control-plane node running the following command on each as root:
```
kubeadm join cluster-endpoint.internal:6443 --token iepuca.055f21ns3cf212n9 \
      --discovery-token-ca-cert-hash sha256:0a41c312b992a104f5ea7bae96aeaa1bab3c610ec2b3fede8fe48ff6b0cdd809 \
      --control-plane --certificate-key cce481bf4dd626bda3daef066bc79e3922939a285240d5eb15b2d693dc591e75
```

You can now join any number of machines by running the following on each node as root:

```
kubeadm join cluster-endpoint.internal:6443 --token iepuca.055f21ns3cf212n9 \
      --discovery-token-ca-cert-hash sha256:0a41c312b992a104f5ea7bae96aeaa1bab3c610ec2b3fede8fe48ff6b0cdd809
```

```
$ kubectl get nodes 
NAME          STATUS   ROLES           AGE    VERSION
k8s-master    Ready    control-plane   38m    v1.27.11
k8s-worker1   Ready    <none>          101s   v1.27.11
k8s-worker2   Ready    <none>          61s    v1.27.11
k8s-worker3   Ready    <none>          61s    v1.27.11
```

## Обновление кластера
Документация: [kubeadm-upgrade](https://v1-28.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

### master node

Switching to another Kubernetes package repository

```
nano /etc/apt/sources.list.d/kubernetes.list
deb https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /
```

```
# Find the latest 1.28 version in the list.
# It should look like 1.28.x-*, where x is the latest patch.
apt update
apt-cache madison kubeadm

# apt-cache madison kubeadm
   kubeadm | 1.28.7-1.1 | https://pkgs.k8s.io/core:/stable:/v1.28/deb  Packages
   kubeadm | 1.28.6-1.1 | https://pkgs.k8s.io/core:/stable:/v1.28/deb  Packages
   kubeadm | 1.28.5-1.1 | https://pkgs.k8s.io/core:/stable:/v1.28/deb  Packages
   kubeadm | 1.28.4-1.1 | https://pkgs.k8s.io/core:/stable:/v1.28/deb  Packages
   kubeadm | 1.28.3-1.1 | https://pkgs.k8s.io/core:/stable:/v1.28/deb  Packages
   kubeadm | 1.28.2-1.1 | https://pkgs.k8s.io/core:/stable:/v1.28/deb  Packages
   kubeadm | 1.28.1-1.1 | https://pkgs.k8s.io/core:/stable:/v1.28/deb  Packages
   kubeadm | 1.28.0-1.1 | https://pkgs.k8s.io/core:/stable:/v1.28/deb  Packages
```

Call "kubeadm upgrade" for the first control plane node

```
# replace x in 1.28.x-* with the latest patch version
apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm='1.28.7-1.1' && \
apt-mark hold kubeadm
```

Verify that the download works and has the expected version:

```
kubeadm version
kubeadm upgrade plan
```

```
Upgrade to the latest stable version:

COMPONENT                 CURRENT    TARGET
kube-apiserver            v1.27.0    v1.28.7
kube-controller-manager   v1.27.0    v1.28.7
kube-scheduler            v1.27.0    v1.28.7
kube-proxy                v1.27.0    v1.28.7
CoreDNS                   v1.10.1    v1.10.1
etcd                      3.5.10-0   3.5.10-0

You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.28.7
```

```
kubeadm upgrade apply v1.28.7

[upgrade/successful] SUCCESS! Your cluster was upgraded to "v1.28.7". Enjoy!

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.
```

#### Upgrade kubelet and kubectl

Drain the node

```
kubectl drain k8s-master --ignore-daemonsets

$ kubectl get nodes
NAME          STATUS                     ROLES           AGE    VERSION
k8s-master    Ready,SchedulingDisabled   control-plane   112m   v1.27.11
```

Upgrade kubelet and kubect

```
apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet='1.28.7-1.1' kubectl='1.28.7-1.1' && \
apt-mark hold kubelet kubectl
```

Restart the kubelet:

```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

```
$ kubectl get nodes
NAME          STATUS                        ROLES           AGE    VERSION
k8s-master    NotReady,SchedulingDisabled   control-plane   114m   v1.28.7
k8s-worker1   Ready                         <none>          77m    v1.27.11
k8s-worker2   Ready                         <none>          77m    v1.27.11
k8s-worker3   Ready                         <none>          77m    v1.27.11
```

Uncordon the node

```
kubectl uncordon k8s-master
```

### worker nodes

Обновляем одну ноду за раз. Drain the node

```
kubectl drain k8s-worker1 --ignore-daemonsets
```

Upgrade kubelet and kubect

```
apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet='1.28.7-1.1' kubectl='1.28.7-1.1' && \
apt-mark hold kubelet kubectl
```

Restart the kubelet:

```
systemctl daemon-reload
systemctl restart kubelet
```

Uncordon the node

```
kubectl uncordon k8s-worker1
```

### Итог

Проведено обновление кластера с версии v1.27.11 до версии v1.28.7

```
~$ kubectl get nodes
NAME          STATUS   ROLES           AGE    VERSION
k8s-master    Ready    control-plane   130m   v1.28.7
k8s-worker1   Ready    <none>          93m    v1.28.7
k8s-worker2   Ready    <none>          93m    v1.28.7
k8s-worker3   Ready    <none>          93m    v1.28.7
```
