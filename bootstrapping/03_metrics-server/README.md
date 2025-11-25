# Instalar metrics server

El uso de metrics-server permite el autoescalado de pods mediante HPA y estadísticas de uso de recursos como `kubectl top nodes` o `kubectl top pods`.

También podemos ver el uso de CPU y memoria en Freelens / Lens.

- Instalar con el siguiente comando:

`helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system`