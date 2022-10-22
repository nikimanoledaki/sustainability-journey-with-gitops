#!/bin/bash
# - Current (per 3 seconds) (`curr`)
# - Total (accumulative) (`total`)
# - By resource
# - Sum in namespace (`sum[...]`)
# - Compute (`pkg`)
# - Memory (`dram`)
# - Pod (`pod_name`)
# - Namespace (`pod_namespace`)

echo "1. Current"
echo "each separate resource"
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'}" | jq

echo "total in namespace"
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'

echo "2. Accumulative"
echo "each separate resource"
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_total_energy_in_pkg_millijoule{pod_namespace='flux-system'})"

echo "total in namespace"
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_total_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'

echo "3. Compute-only"

echo "each separate resource"
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'

echo "total in namespace"
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_total_energy_in_pkg_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'

echo "4. Memory-only"

echo "each separate resource"
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_dram_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'

echo "total in namespace"
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_dram_millijoule{pod_namespace='flux-system'})" | jq '.data.result[0].value[0]'


echo "get the actual energy consumption of all the pods in a namespace in the last min"
curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=rate(pod_curr_energy_millijoule{pod_namespace='flux-system'}[1m])/3" | jq '.data.result[0].value[0]'
