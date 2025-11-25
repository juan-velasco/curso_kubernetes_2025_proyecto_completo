# Instalación de Cert-manager

Usamos cert-manager como "wrapper" de Certbot, que nos permitirá crear certificados con Let's Encrypt de forma automática en el clúster y asociarlos a una regla de ingress.

Usamos el método de instalación con Helm:

https://cert-manager.io/docs/installation/helm/


```
helm repo add jetstack https://charts.jetstack.io --force-update

helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.19.1 \
  --set crds.enabled=true
```

## Creamos los issuers de staging y producción

Para ello debemos aplicar en el clúster los manifiestos de este directorio:

```
kubectl apply -f issuer-staging.yaml
kubectl apply -f issuer-prod.yaml
```

La diferencia entre un issuer y otro, es que el de staging genera certificados no válidos (autofirmados), pero el issuer de producción tiene un "rate limit" bastante estricto, así que usaremos primero el de staging hasta comprobar que la generación de certificados funciona correctamente.

## Ya podemos crear un ingress que haga uso de cert-manager

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: pre-bipeek-com
  annotations: 
    cert-manager.io/cluster-issuer: letsencrypt-staging
spec:
  ingressClassName: nginx # webapprouting.kubernetes.azure.com para el addon de Azure
  tls:
  - hosts:
    - pre.bipeek.com
    secretName: pre-bipeek-com-tls
  rules:
  - host: pre.bipeek.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: bipeek-backend-bipeek-backend
            port:
              number: 80
```