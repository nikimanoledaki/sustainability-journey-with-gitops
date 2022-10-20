# Create a cluster with kubeadm & install Kepler on it

This is a step-by-step guide for how to create a Kubernetes cluster "the hard way" with kubeadm. It is then used to run Kepler on it to gather energy consumption metrics.

## RHEL 8
```bash install-rhel-kepler.sh
# cri
yum install -y vim curl wget git jq

cat <<EOF > /etc/yum.repos.d/cri.repo
[devel_kubic_libcontainers_stable]
name=Stable Releases of Upstream github.com/containers packages (CentOS_8)
type=rpm-md
baseurl=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/
gpgcheck=1
gpgkey=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/repodata/repomd.xml.key
enabled=1
[devel_kubic_libcontainers_stable_cri-o_1.24_1.24.1]
name=devel:kubic:libcontainers:stable:cri-o:1.24:1.24.1 (CentOS_8)
type=rpm-md
baseurl=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24:/1.24.1/CentOS_8/
gpgcheck=1
gpgkey=https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/1.24:/1.24.1/CentOS_8/repodata/repomd.xml.key
enabled=1
EOF

yum install cri-o and cri-tools

# if ipv6 is not supported, remove ipv6 networks from /etc/cni/net.d/100-crio-bridge.conf, it will be like this:

{
    "cniVersion": "0.3.1",
    "name": "crio",
    "type": "bridge",
    "bridge": "cni0",
    "isGateway": true,
    "ipMasq": true,
    "hairpinMode": true,
    "ipam": {
        "type": "host-local",
        "routes": [
            { "dst": "0.0.0.0/0" }
        ],
        "ranges": [
            [{ "subnet": "10.85.0.0/16" }]
        ]
    }
}

systemctl enable crio --now

modprobe br_netfilter # need this for bridge-nf-call-iptables

cat <<EOF >> /etc/sysctl.conf
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 2
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOD

comment out swap from /etc/fstab and turn off swap (for kubelet)

swapoff -a


# install kubeadm, this is from https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

setenforce 0

sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

kubeadm init --pod-network-cidr 172.16.0.0/16
export KUBECONFIG=/etc/kubernetes/admin.conf

# recall pod network used in kubeadm:
# - added a pod network dir option `kubeadm init --pod-network-cidr 172.16.0.0/16`, this has to match with flannel https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
# -  download flannel manifest and modify it

# if default pod network and flannel net-conf are the same, just apply it
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml 

# if pod network dir and flannel net-conf are different (e.g. used pod network dir option in kubeadm), download it and update net-conf.json
wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
  net-conf.json: |
    {
      "Network": "172.16.0.0/24",
      "Backend": {
        "Type": "vxlan"
      }
    }


# remove ipv6 net from `/etc/cni/net.d/100-crio-bridge.conf`

# install kepler

kubectl apply -f https://raw.githubusercontent.com/sustainable-computing-io/kepler/release-0.3/manifests/kubernet
es/deployment.yaml

# Check if node name is resolved by coredns: 
# - exec to kepler pod `kubectl exec -ti -n kepler kepler-exporter-<podhash>  bash`
# - curl the node name e.g. http://node_name:9102/metrics

# If not resolved, download kepler manifest and  use this env to replace the node name in kepler manifest
        env:
        - name: NODE_NAME
          value: localhost
wget https://raw.githubusercontent.com/sustainable-computing-io/kepler/release-0.3/manifests/kubernetes/deploymen
t.yaml

# install prometheus, service monitor
follow steps here: https://github.com/sustainable-computing-io/kepler/tree/release-0.3#deploy-the-prometheus-operator-and-the-whole-monitoring-stack

git clone https://github.com/prometheus-operator/kube-prometheus
cd kube-prometheus/
kubectl apply --server-side -f manifests/setup
kubectl apply -f manifests/
kubectl apply -f https://raw.githubusercontent.com/sustainable-computing-io/kepler/main/manifests/kubernetes/kepl
erExporter-serviceMonitor.yaml

# curl metrics
export IP=$(kubectl get svc -n monitoring prometheus-k8s -ojsonpath='{.spec.clusterIP}')
curl "http://${IP}:9090/api/v1/query?query=node_energy_stat"
curl "http://${IP}:9090/api/v1/query?query=pod_energy_stat" |jq .data.result[].metric
```

