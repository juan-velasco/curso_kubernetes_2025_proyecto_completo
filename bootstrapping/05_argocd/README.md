# Instalación de ArgoCD

1. Hacemos uso de la documentación oficial, básicamente son dos pasos:

https://argo-cd.readthedocs.io/en/stable/getting_started/#1-install-argo-cd

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

2. (Opcional) Creamos las reglas de ingress:

```bash
kubectl apply -f 01_ingress_http.yaml
kubectl apply -n 02_ingress_grpc.yaml
```

3. (Opcional) Debemos modificar el ConfigMap **argocd-cmd-params-cm** para que internamente ArgoCD se ejecute de forma insegura. Agregamos estas líneas al final del mismo:

```bash
data:
  server.insecure: 'true'
```

Para aplicar los cambios del ConfigMap debemos reiniciar los pods.
