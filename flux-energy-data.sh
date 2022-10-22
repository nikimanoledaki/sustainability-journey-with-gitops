#!/bin/bash
# - Current (per 3 seconds) (`curr`)
# - Total (accumulative) (`total`)
# - By resource
# - Sum in namespace (`sum[...]`)
# - Compute (`pkg`)
# - Memory (`dram`)
# - Pod (`pod_name`)
# - Namespace (`pod_namespace`)

# 1. Current
# each separate resource
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


# total in namespace
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'
1666394273.906

# actual in namespace in last minute
# TODO: is this total?
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=rate(pod_curr_energy_millijoule{pod_namespace='flux-system'}[1m])/3" | jq '.data.result[0].value[0]'
1666394505.589

# 2. Accumulative
# each separate resource
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

# total in namespace
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_total_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'
1666394385.315


# 3. Compute-only
# each separate resource
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'}" | jq
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
          1666394470.098,
          "39"
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
          1666394470.098,
          "466"
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
          1666394470.098,
          "34"
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
          1666394470.098,
          "85"
        ]
      }
    ]
  }
}

# total in namespace
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_total_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'
1666394479.49

# 4. Memory-only

# each separate resource
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

# total in namespace
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_dram_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'
1666394498.732