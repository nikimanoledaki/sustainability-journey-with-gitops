```
curl -G http://localhost:9090/api/v1/query --data-urlencode "query=pod_curr_energy_in_pkg_millijoule{pod_namespace='default'}" | jq

curl -sG http://localhost:9090/api/v1/query --data-urlencode "query=sum(pod_curr_energy_in_core_millijoule{pod_name='manual-destruct-j6sv6-tmbrm'})" | jq

```