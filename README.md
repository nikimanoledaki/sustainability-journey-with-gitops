### ⚡Lightning Talk: Green(Ing) CI/CD: A Sustainability Journey with GitOps
#### by Niki Manoledaki, Software Engineer, Weaveworks
[[GitOpsCon NA 2022](https://gitopsconna22.sched.com/event/1AR8Y)]

</br>

### Talk Abstract
Our infrastructure needs are increasingly energy and carbon intensive. CI/CD is one area where we can take steps to measure and reduce our footprint. In this talk, we present our investigation into instrumenting CI/CD systems and GitOps tools to achieve this. We share the outcomes and lessons learned from these experiments so far. Our journey begins with traditional CI/CD where the two are tightly coupled. Transitioning to GitOps often starts with decoupling the two. This is an opportunity to measure the energy consumption of each step and think about environmental impact from the very beginning. Energy use can be measured before and after this decoupling, and we can show you how. On the next stop in our sustainability journey, we evaluate how GitOps tools and patterns can be used to reduce energy consumption and wasted resources. Expressing a system declaratively offers full visibility of the tools running in your clusters. Another promise of GitOps is that it can be used to turn IT off when not needed. GitOps can also support tools and policies to measure and optimize energy and carbon usage. Our journey ends with some reflections on methodology, outcomes, and next steps.

</br>

----

</br>

### Introduction

The aim of this project is to measure and compare the energy consumption of operations that run on a traditional / snowflake K8s cluster versus on a Flux-operated GitOps-based K8s cluster.

### Getting started

#### 1. Fork this repository
Then, clone the fork:
```
git clone git@github.com:<username>/sustainability-journey-with-gitops.git
```

#### 2. Spin up a K8s cluster that can run Kepler
The following tests require a K8s cluster with [Kepler](https://github.com/sustainable-computing-io/kepler) running on it. Kepler, which stands for "Kubernetes-based Efficient Power Level Exporter", uses eBPF to probe energy related system stats and exports as Prometheus metrics. It has some requirements that may not be present on all environments, such as kernel headers and certain kernel flags for eBPF support.

To make things easier, [here](create-cluster.md) is a step-by-step guide for how to create a baremetal cluster "the hard way" with `kubeadm` on RHEL 8.6. The tutorial creates and runs everything on a single Control Plane Node. Kepler, which is deployed as a Daemonset, can then be accessed as a Pod. It monitors and gathers energy metrics on Pods and the Node itself, which it exports to Prometheus. This environment can be used to gather energy consumption metrics about workloads running on the K8s cluster.

Once the environment is setup, the following tests can be performed on the cluster.


#### 3. Install & bootstrap Flux
Install Flux if you have not done so already. Then, bootstrap Flux on your cluster.
```bash
curl -s https://fluxcd.io/install.sh | sudo bash
flux bootstrap github --owner=$GITHUB_USER --repository=gitops-energy-usage --path=clusters
```
This will automatically add all the dependencies - Kepler, Prometheus & Grafana - on the cluster. Their manifests live in the `clusters/` dir ([here](clusters)).

#### 4. Gather energy consumption metrics about the Flux Source Controller

First, let's check what lives in the Flux namespace:
```bash
kubectl get all -n flux-system
NAME                                          READY   STATUS    RESTARTS   AGE
pod/helm-controller-68b799b589-5zh7z          1/1     Running   0          3m34s
pod/kustomize-controller-7ddb8d8f7-6p4lb      1/1     Running   0          3m34s
pod/notification-controller-56bd788f9-96djn   1/1     Running   0          3m34s
pod/source-controller-7d98d6688c-d6mmd        1/1     Running   0          3m34s

NAME                              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/notification-controller   ClusterIP   10.99.61.198   <none>        80/TCP    3m35s
service/source-controller         ClusterIP   10.99.132.41   <none>        80/TCP    3m35s
service/webhook-receiver          ClusterIP   10.104.46.54   <none>        80/TCP    3m35s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/helm-controller           1/1     1            1           3m35s
deployment.apps/kustomize-controller      1/1     1            1           3m35s
deployment.apps/notification-controller   1/1     1            1           3m35s
deployment.apps/source-controller         1/1     1            1           3m35s

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/helm-controller-68b799b589          1         1         1       3m35s
replicaset.apps/kustomize-controller-7ddb8d8f7      1         1         1       3m35s
replicaset.apps/notification-controller-56bd788f9   1         1         1       3m35s
replicaset.apps/source-controller-7d98d6688c        1         1         1       3m35s
```

To get the energy metrics, first, port-forward Prometheus to `9090`:
```bash
kubectl port-forward pod/prometheus-k8s-0 9090 -n monitoring
```

Queries can be written for the Prometheus Pod `prometheus-k8s-0` with a curl request that targets the `api/v1/query` endpoint. For example, here is a query that gathers the current (`curr`) energy of compute (the CPU, denoted by `pkg`) in milliJoule for the Flux Source Controller:

```bash
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=pod_curr_energy_in_pkg_millijoule{pod_name='source-controller-7d98d6688c-d6mmd'}" | jq
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "pod_curr_energy_in_pkg_millijoule",
          "command": "source-con",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "source-controller-7d98d6688c-d6mmd",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666559968.74,
          "394"
        ]
      }
    ]
  }
}
```

In the command above, the flag `--data-urlencode` is used to pass a Prometheus query in PromQL syntax. The result is piped to `jq` to transform it into json format. 

A list of example queries and data can be found in [flux-energy-data.md](flux-energy-data.md).
<!-- 
#### Energy consumption metrics about all Flux Controllers

There are currently four default Flux controllers: the Source, Helm, Kustomize, and Notification Controllers.

The query below measures the energy consumption of all of the Pods in the `flux-system` namespace, where the Flux controllers are deployed.

The command below returns the **sum** of the energy consumed by the CPU to compute the Flux controllers:
```bash
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {},
        "value": [
          1664037856.556,
          "4"
        ]
      }
    ]
  }
}
```

The json results can be narrowed down with the following filters for `jq` to isolate and return the value alone:
```bash
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'
1664037900.094
```

The value here is 1664037900.094 mJ (millijoules). The section below, ["Joule for Beginners"](#joule-for-beginners), goes over the basics (or a refresher) of joules.

Ideally it would be great to narrow this further to a range that calculates the past hour by using a [range vector](https://prometheus.io/docs/prometheus/latest/querying/basics/#range-vector-selectors). -->
<!-- 
#### 4. Gather Node-level energy data

The `node_enegy_stat` vector will return information about the Kubernetes Node:
```bash
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=node_energy_stat" | jq
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "node_energy_stat",
          "container": "kepler-exporter",
          "cpu_architecture": "Sandy Bridge",
          "endpoint": "http",
          "instance": "kind-control-plane",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "node_block_devices_used": "20",
          "node_curr_bytes_read": "0",
          "node_curr_bytes_writes": "135168",
          "node_curr_cache_miss": "0",
          "node_curr_container_cpu_usage_seconds_total": "3",
          "node_curr_container_memory_working_set_bytes": "630784",
          "node_curr_cpu_cycles": "0",
          "node_curr_cpu_instr": "0",
          "node_curr_cpu_time": "0",
          "node_curr_energy_in_core_joule": "0.013000",
          "node_curr_energy_in_dram_joule": "0.095000",
          "node_curr_energy_in_gpu_joule": "0.000000",
          "node_curr_energy_in_other_joule": "0.000000",
          "node_curr_energy_in_pkg_joule": "0.013000",
          "node_curr_energy_in_uncore_joule": "0.000000",
          "node_name": "kind-control-plane",
          "pod": "kepler-exporter-7nbzs",
          "service": "kepler-exporter"
        },
        "value": [
          1664036361.77,
          "0"
        ]
      }
    ]
  }
}
```

Lastly, the json result for `node_energy_stat` narrowed down by adding filters to `jq`:
```bash
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=node_energy_stat" | jq '.data.result[0].value[0]'
1664037946.617
``` -->

<!-- #### 5. Deploy a mock application with Flux
Uncomment the code for the mock API in `clusters/app.yaml` ([here](clusters/app.yaml)).
Commit and push these changes to your repository. This will trigger a reconciliation.

#### 6. Gather energy data with Prometheus
Query Prometheus to gather data about the Flux Controllers:
```bash
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'}" | jq
``` -->

#### 7. Visualise the energy data with Grafana
The energy consumption data can be visualised with Grafana. This can be used alongside any of the tests mentioned above. 
The script provided can be used to spin up Grafana and load the Kepler dashboard:
```
./scripts/configure-grafana.sh
```

### Coming Soon (Hopefully)!

The main restriction at the moment is the environment setup for Kepler. The reason for this, as written in [this](https://blog.px.dev/ebpf-portability/) post by the Pixie team on "The Challenge with Deploying eBPF Into the Wild": 
> One problem that hinders the wide-scale deployment of eBPF is the fact that it is challenging to build applications that are compatible across a wide range of Linux distributions.

It would be great to work on integrating Kepler with the following environments:
- Use it with a VM, or even better, a Liquid Metal microVM! Hopefully coming soon!
- Use it in an EC2 instance (which is technically a VM). This **does not work yet** but it might be possible, if the hypervisor supports it, and with a lot of integration work.
- Use it in a Kind cluster. This is currently in the works over at Kepler.

#### Joule for beginners

What is a joule (J)? Very simply put, it is a unit of energy. 

1 joule equals 1000 millijoules (mJ), where `1 J = 1000 mJ`.

1 joule _per second_ equals to 1 Watt, so `1W = 1 J/s`.

Therefore, `1 W/h = 3600 J = 3600000 mJ`, which is the same as `(60 sec x 60 min) x 1000`, where the multiplication by 1000 converts joules to millijoules.