### ⚡Lightning Talk: Green(Ing) CI/CD: A Sustainability Journey with GitOps
#### by Niki Manoledaki, Software Engineer, Weaveworks
[[GitOpsCon NA 2022](https://gitopsconna22.sched.com/event/1AR8Y)]

</br>

### Talk Abstract
Our infrastructure needs are increasingly energy and carbon intensive. CI/CD is one area where we can take steps to measure and reduce our footprint. In this talk, we present our investigation into instrumenting CI/CD systems and GitOps tools to achieve this. We share the outcomes and lessons learned from these experiments so far. Our journey begins with traditional CI/CD where the two are tightly coupled. Transitioning to GitOps often starts with decoupling the two. This is an opportunity to measure the energy consumption of each step and think about environmental impact from the very beginning. Energy use can be measured before and after this decoupling, and we can show you how. On the next stop in our sustainability journey, we evaluate how GitOps tools and patterns can be used to reduce energy consumption and wasted resources. Expressing a system declaratively offers full visibility of the tools running in your clusters. Another promise of GitOps is that it can be used to turn IT off when not needed. GitOps can also support tools and policies to measure and optimize energy and carbon usage. Our journey ends with some reflections on methodology, outcomes, and next steps.

</br>

----

### Aim

This project aims to measure and compare the energy consumption of snowflake clusters versus that of Flux-based GitOps clusters.

### Getting started

Fork this repository, then clone the fork:
```
git clone git@github.com:<username>/sustainability-journey-with-gitops.git
```

### Environment Setup
This is a step-by-step guide for how to create a Kubernetes baremetal cluster "the hard way" with `kubeadm`, on RHEL 8. It is recommended to use either baremetal (preferred for this test).

- [[GUIDE](create-cluster.md)] **Follow these steps to create a cluster with kubeadm & install Kepler on it.** 
    - Kepler is deployed on one single node, the Control Plane Node, as a Daemonset's Pod.
    - Kepler can then be used to gather energy consumption metrics about resource.

[ALL WIP] Next steps for Kepler:
- Use it with a VM, or even better, a Liquid Metal microVM! Hopefully coming soon!
- Use it in an EC2 instance (which is technically a VM). This **does not work yet** but it might be possible, if the hypervisor supports it, and with a lot of integration work.
- Use it in a Kind cluster. This is currently in the works over at Kepler.

### Test 1: Measure the energy consumption of a CI platform

Here, the energy consumption of a CI platform will be measured by focusing on job runner itself.
GitHub Actions allows us to do this by deploying a self-hosted runner.

1. Setup a K8s cluster with Kepler [(see above for instructions)](#env-setup).
2. Manually install Prometheus & Grafana.
3. Install Helm & ARC on the cluster to turn that node into a self-hosted GitHub runner.
```bash
make ci-test-deps
```
1. Using a simple GitHub Actions [workflow](.github/workflows/test.yaml), create a GH Actions job that deploys a mock API to a K8s cluster.
2. [WIP] Gather data in milliJoules on energy consumption used by Node (self-hosted runner) to perform this action.

### Test 2: Measure the energy consumption of Flux
1. Setup a K8s cluster with Kepler [(see above for instructions)](#env-setup) & Flux.
```bash
make flux-test-deps
make start-flux
```
This will bootstrap Flux and automatically add all the dependencies on the cluster e.g. Kepler, Prometheus & Grafana.
The manifests of these dependencies live in the `clusters/` dir ([here](clusters)).
1. Add Mock API's manifests as a Source to git repo. Uncomment the code in `clusters/app.yaml` ([here](clusters/app.yaml)).
2. [WIP] Gather data in milliJoules on energy consumption used by Flux Controllers to perform this action.
   1. [WIP] Timecheck is probably going to be a Git change + use Flux to force of Kustomization.

### Test 3: Measure the energy consumption of Flux garbage collection [WIP]
1. Complete [previous test's](#test-2-measure-the-energy-consumption-of-flux) steps.
4. Delete mock API's manifest from the git repo watched by Flux.
5. [WIP] Gather data on energy consumption used by Flux Controllers to perform this action & compare with that of Deployment that continues to exist in other cluster from a given checkpoint.

### [Nice-to-have] Visualise energy metrics with Grafana
```
make grafana
```