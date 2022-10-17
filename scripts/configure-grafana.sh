#!/bin/bash

# while : ; do
    kubectl get pod -l app.kubernetes.io/name=grafana
#   kubectl get pod -l app.kubernetes.io/name=grafana && break
#   sleep 5
# done

# Configure Grafana
kubectl wait --for=condition=Ready=true pods -l app.kubernetes.io/name=grafana

curl -fsSL "https://raw.githubusercontent.com/nikimanoledaki/gitops-energy-usage/main/scripts/grafana-kepler-dashboard.json" -o grafana-kepler-dashboard.json

kubectl port-forward service/grafana 3000:3000 -n monitoring

grafana_host="http://localhost:3000"
grafana_cred="admin:admin"
grafana_datasource="kepler"
  echo -n "Processing: "
  j=$(cat grafana-kepler-dashboard.json)
  curl -s -k -u "$grafana_cred" -XPOST -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{\"dashboard\":$j,\"overwrite\":true, \
        \"inputs\":[{\"name\":\"KEPLER\",\"type\":\"datasource\", \
        \"pluginId\":\"kepler\",\"value\":\"$grafana_datasource\"}]}" \
    $grafana_host/api/dashboards/import; echo ""
