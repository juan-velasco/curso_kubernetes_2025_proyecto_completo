# Instalación de Prometheus, Grafana y AlertManager

El repo utilizado es el siguiente:
https://github.com/prometheus-community/helm-charts

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Lanzamos el comando utilizando el fichero values.yaml, que básicamente tiene la configuración necesaria para que los datos persistan entre despliegues

Previamente, debemos haber configurado los DNS para el dominio elegido apunte a nuestro clúster

helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace -f values-pre.yaml
```

Ver el estado de los pods generados por la instalación:

```
kubectl --namespace monitoring get pods -l "release=kube-prometheus-stack"
```

Obtener las credenciales del usuario admin de Grafana:

```
kubectl --namespace monitoring get secrets kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
```

Montar port forward:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=kube-prometheus-stack" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.

## Reglas adicionales para alertas

Podemos aplicar el richero rules.yaml, para aplicar algunas reglas de alerta a medida

```
kubectl apply -f rules.yaml
```

## Monitorizacion de cert-manager

Para poder monitorizar el estado de los certificados generados por cert-manager, debemos configurar el correspondiente service monitor:

```
kubectl apply -f service-monitor.yaml
```

## Aplicar cambios en el fichero values-pro.yaml

helm upgrade kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring -f values-pro.yaml