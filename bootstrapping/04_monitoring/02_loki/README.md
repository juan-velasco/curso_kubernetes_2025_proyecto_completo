# Instalación de Loki, con persistencia

Se ha optado por la instalación con Minio, al menos en entorno de PRE, por ser más sencilla.

Alternativamente, se puede seguir esta guía para usar S3 o microservicios:

https://grafana.com/docs/loki/latest/setup/install/helm/deployment-guides/aws/

```
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update

# Hemos optado por desplegar Loki en modo "monolítico o singleBinary":

https://grafana.com/docs/loki/latest/setup/install/helm/install-scalable/

https://grafana.com/docs/loki/latest/get-started/deployment-modes/#simple-scalable

Comando de instalación:
helm install --values values-pre.yaml loki grafana/loki -n monitoring

```

Para enviar los logs a Loki, debemos instalar Alloy con Helm **(ver guía correspondiente)**.


### Tras la instalación, deberemos configurar el DataSource correspondiente en Grafana.

Debemos indicar:

Connection URL:
- http://loki-gateway.monitoring.svc.cluster.local/

HTTP Header:
- X-Scope-OrgId: 1

### Configurar el tiempo de retención de los logs

Por defecto los logs se guardan PARA SIEMPRE, debemos cofigurar algo así en el values.yaml

```
  tableManager:
    retention_deletes_enabled: true
    retention_period: 240h # 10 days
```

Y luego configurar Minio mediante este comando de kubectl, para que borre los chunks antiguos (daremos unos días más de margen sobre lo configurado en Loki):

```
kubectl run mc-runner \
--image=minio/mc \
--restart=Never \
--rm -i -t \
--namespace=monitoring \
--command -- /bin/sh -c "mc alias set local http://loki-minio:9000 root-user supersecretpassword && mc ilm add --expire-days 12 local/chunks"
```


---

**********************************************************************
Sending logs to Loki
***********************************************************************

Loki has been configured with a gateway (nginx) to support reads and writes from a single component.

You can send logs from inside the cluster using the cluster DNS:

http://loki-gateway.monitoring.svc.cluster.local/loki/api/v1/push

You can test to send data from outside the cluster by port-forwarding the gateway to your local machine:

  kubectl port-forward --namespace monitoring svc/loki-gateway 3100:80 &

And then using http://127.0.0.1:3100/loki/api/v1/push URL as shown below:

```
curl -H "Content-Type: application/json" -XPOST -s "http://127.0.0.1:3100/loki/api/v1/push"  \
--data-raw "{\"streams\": [{\"stream\": {\"job\": \"test\"}, \"values\": [[\"$(date +%s)000000000\", \"fizzbuzz\"]]}]}" \
-H X-Scope-OrgId:foo
```

Then verify that Loki did receive the data using the following command:

```
curl "http://127.0.0.1:3100/loki/api/v1/query_range" --data-urlencode 'query={job="test"}' -H X-Scope-OrgId:foo | jq .data.result
```

***********************************************************************
Connecting Grafana to Loki
***********************************************************************

If Grafana operates within the cluster, you'll set up a new Loki datasource by utilizing the following URL:

http://loki-gateway.monitoring.svc.cluster.local/

***********************************************************************
Multi-tenancy
***********************************************************************

Loki is configured with auth enabled (multi-tenancy) and expects tenant headers (`X-Scope-OrgID`) to be set for all API calls.

You must configure Grafana's Loki datasource using the `HTTP Headers` section with the `X-Scope-OrgID` to target a specific tenant.
For each tenant, you can create a different datasource.

The agent of your choice must also be configured to propagate this header.
For example, when using Promtail you can use the `tenant` stage. https://grafana.com/docs/loki/latest/send-data/promtail/stages/tenant/

When not provided with the `X-Scope-OrgID` while auth is enabled, Loki will reject reads and writes with a 404 status code `no org id`.

You can also use a reverse proxy, to automatically add the `X-Scope-OrgID` header as suggested by https://grafana.com/docs/loki/latest/operations/authentication/

For more information, read our documentation about multi-tenancy: https://grafana.com/docs/loki/latest/operations/multi-tenancy/

> When using curl you can pass `X-Scope-OrgId` header using `-H X-Scope-OrgId:foo` option, where foo can be replaced with the tenant of your choice.