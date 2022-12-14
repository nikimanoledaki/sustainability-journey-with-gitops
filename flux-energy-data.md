## How To Gather Energy Consumption Metrics about Flux with Kepler
- Sum (`sum[...]`)
- [Current](#current) (per 3 seconds) (`curr`)
  - [Compute](#compute) (`pkg`)
    - Pod (`pod_name`)
    - Namespace (`pod_namespace`)
  - [Memory](#memory) (`dram`)
    - Pod (`pod_name`)
    - Namespace (`pod_namespace`)
- [Total](#total) (accumulative) (`total`)

### Current

#### Compute

The following data represents the energy consumed by the CPU processes to compute the given resources.

**Each separate resource for namespace `flux-system`:**
```bash
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'}" | jq

{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "pod_curr_energy_in_pkg_millijoule",
          "command": "helm-contr",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "helm-controller-68b799b589-5zh7z",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394247.901,
          "73"
        ]
      },
      {
        "metric": {
          "__name__": "pod_curr_energy_in_pkg_millijoule",
          "command": "kustomize-",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "kustomize-controller-7ddb8d8f7-6p4lb",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394247.901,
          "68"
        ]
      },
      {
        "metric": {
          "__name__": "pod_curr_energy_in_pkg_millijoule",
          "command": "notificati",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "notification-controller-56bd788f9-96djn",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394247.901,
          "118"
        ]
      },
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
          1666394247.901,
          "108"
        ]
      }
    ]
  }
}
```

**Total current energy use for namespace `flux-system`**
```bash
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[1]'
"387"
```

**Current for namespace `flux-system` in the last minute**
```bash
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=rate(pod_curr_energy_millijoule{pod_namespace='flux-system'}[24h])" | jq '.data.result[0].value[1]'
"7.292397660818714"
```

### Memory

**Each separate resource**
```bash
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=pod_curr_energy_in_dram_millijoule{pod_namespace='flux-system'}" | jq

{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "pod_curr_energy_in_dram_millijoule",
          "command": "helm-contr",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "helm-controller-68b799b589-5zh7z",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394491.954,
          "23"
        ]
      },
      {
        "metric": {
          "__name__": "pod_curr_energy_in_dram_millijoule",
          "command": "kustomize-",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "kustomize-controller-7ddb8d8f7-6p4lb",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394491.954,
          "28"
        ]
      },
      {
        "metric": {
          "__name__": "pod_curr_energy_in_dram_millijoule",
          "command": "notificati",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "notification-controller-56bd788f9-96djn",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394491.954,
          "31"
        ]
      },
      {
        "metric": {
          "__name__": "pod_curr_energy_in_dram_millijoule",
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
          1666394491.954,
          "23"
        ]
      }
    ]
  }
}
```

**Total for namespace `flux-system`**
```bash
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_dram_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[1]'
"122"
```

### Accumulative

The following queries are missing the total duration of the metrics gathering process, which renders them less useful than the `curr` data above. This will require some improvements.

**Each separate resource**
```bash
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=pod_total_energy_in_pkg_millijoule{pod_namespace='flux-system'}" | jq
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "pod_total_energy_in_pkg_millijoule",
          "command": "helm-contr",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "helm-controller-68b799b589-5zh7z",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394356.395,
          "18424628186400976"
        ]
      },
      {
        "metric": {
          "__name__": "pod_total_energy_in_pkg_millijoule",
          "command": "kustomize-",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "kustomize-controller-7ddb8d8f7-6p4lb",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394356.395,
          "4600183380505419000"
        ]
      },
      {
        "metric": {
          "__name__": "pod_total_energy_in_pkg_millijoule",
          "command": "notificati",
          "container": "kepler-exporter",
          "endpoint": "http",
          "instance": "c3.small.x86-01",
          "job": "kepler-exporter",
          "namespace": "kepler",
          "pod": "kepler-exporter-6q26p",
          "pod_name": "notification-controller-56bd788f9-96djn",
          "pod_namespace": "flux-system",
          "service": "kepler-exporter"
        },
        "value": [
          1666394356.395,
          "26654541578090530"
        ]
      },
      {
        "metric": {
          "__name__": "pod_total_energy_in_pkg_millijoule",
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
          1666394356.395,
          "43242015130644740"
        ]
      }
    ]
  }
}
```

**Total for namespace `flux-system`**
```bash
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_total_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[1]'
"5115348420039602000"
```
