# Instalación de Nginx Ingress Controller
  
Instalar Nginx Ingress con Helm, agregamos la configuración para Prometheus:  
```  
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.metrics.enabled=true \
  --set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" \
  --set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true"  
```

Comprobamos que los pods están en ejecución:
```
kubectl get pods -n ingress-nginx
```

Confirmamos que se ha creado un LoadBalancer para el Ingress (nos guardamos la IP externa):
```
kubectl get svc -n ingress-nginx
```

Aplicar cambios tras la instalación:
```
helm upgrade ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx -f values.yaml
```