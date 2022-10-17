ci-test-deps:
	./scripts/arc.sh

flux-test-deps: start-flux
	./scripts/arc.sh

start-flux:
	curl -s https://fluxcd.io/install.sh | sudo bash
	flux bootstrap github --owner=nikimanoledaki --repository=gitops-energy-usage --path=clusters

grafana:
	scripts/configure-grafana.sh