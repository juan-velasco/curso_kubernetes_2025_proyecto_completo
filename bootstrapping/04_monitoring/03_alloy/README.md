# Instalación de Grafana Alloy para el envío de logs a Loki

Alloy instala un DaemonSet en cada nodo del clúster para recoger logs y enviarlos a Loki

https://grafana.com/docs/alloy/latest/set-up/install/kubernetes/

```
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

# Comando de instalación:
helm install --namespace monitoring alloy grafana/alloy --values values-pre.yaml

```