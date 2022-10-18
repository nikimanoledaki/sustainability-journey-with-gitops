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

Fork this repository, then clone the fork:
```
git clone git@github.com:<username>/sustainability-journey-with-gitops.git
```

#### Environment Setup

The following tests require a K8s cluster with [Kepler](https://github.com/sustainable-computing-io/kepler) running on it. This has some requirements that may not be present on all environments, such as kernel headers and certain kernel flags for eBPF support.

To make things easier, [here](create-cluster.md) is a step-by-step guide for how to create a baremetal cluster "the hard way" with `kubeadm` on RHEL 8.6. The tutorial creates and runs everything on a single Control Plane Node. Kepler, which is deployed as a Daemonset, can then be accessed as a Pod. It monitors and gathers energy metrics on Pods and the Node itself, which it exports to Prometheus. This environment can be used to gather energy consumption metrics about workloads running on the K8s cluster.

Support for doing this in a VM could be added in the future. Please open an issue to signal your interest for this!

Once the environment is setup, the following tests can be performed on the cluster.

### Methodology
#### Measure the energy consumption of a CI platform

In this test, the energy consumption of a CI platform will be measured by focusing on the runner itself.
GitHub Actions allows us to do this by deploying a [self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners).

1. Install Helm & ARC on the cluster to turn that node into a self-hosted GitHub runner. This will hook the K8s cluster to the GitHub Actions [workflow](.github/workflows/test.yaml). It contains a GH Actions job that deploys a mock API to a K8s cluster.
```bash
make ci-test-deps
```
2. Run the GH action manually to create the mock API Deployment.
3. Gather data about the energy consumption of the ARC Controllers and the Node (which is the self-hosted runner) that was used to perform this action. A step-by-step guide for this is coming soon.

#### Measure the energy consumption of Flux

This test aims to gather energy metrics of Flux Controllers when they are idle and when they are active.

1. Install & bootstrap Flux.
```bash
make flux-test-deps
make start-flux
```
This will bootstrap Flux and automatically add all the dependencies on the cluster e.g. Kepler, Prometheus & Grafana.
The manifests of these dependencies live in the `clusters/` dir ([here](clusters)).
One of these manifests contains the Mock API's manifest.
2. Gather data about the Flux Controllers by following [this tutorial](https://nikimanoledaki.com/measure-the-energy-consumption-of-flux-with-prometheus-kepler).
3. Uncomment the code for the mock API in `clusters/app.yaml` ([here](clusters/app.yaml)). Commit and push these changes to trigger a reconciliation.
4. Gather data about the energy consumption required by the Flux Controllers to perform this action. A step-by-step guide for this is coming soon.

#### Measure the energy consumption of Flux garbage collection
1. Complete the [steps](#test-2-measure-the-energy-consumption-of-flux) from the previous test.
2. Delete the manifest of the mock API that lives in ([clusters/app.yaml](clusters/app.yaml)). Commit and push these changes to trigger a reconciliation.
3. [Gather data](https://nikimanoledaki.com/measure-the-energy-consumption-of-flux-with-prometheus-kepler) on the energy consumption required by Flux Controllers to perform this action. Compare it with that of a Deployment that continues to exist in a snowflake cluster from a given checkpoint.

#### [Nice-to-have] Visualise energy metrics with Grafana

The energy consumption data can be visualised with Grafana. This can be used alongside any of the tests mentioned above. 

Spin up Grafana and load the Kepler dashboard:
```
make grafana
```

### Next Steps

The main restriction at the moment is the environment setup. It would be great to work on integrating Kepler with the following environments:
- Use it with a VM, or even better, a Liquid Metal microVM! Hopefully coming soon!
- Use it in an EC2 instance (which is technically a VM). This **does not work yet** but it might be possible, if the hypervisor supports it, and with a lot of integration work.
- Use it in a Kind cluster. This is currently in the works over at Kepler.
