# Despliegue de Keda con Helm

```
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
helm install keda kedacore/keda --namespace keda --create-namespace
```

# Guía de uso

Get started by deploying Scaled Objects to your cluster:
    - Information about Scaled Objects : https://keda.sh/docs/latest/concepts/
    - Samples: https://github.com/kedacore/samples

Get information about the deployed ScaledObjects:
  kubectl get scaledobject [--namespace <namespace>]

Get details about a deployed ScaledObject:
  kubectl describe scaledobject <scaled-object-name> [--namespace <namespace>]

Get information about the deployed ScaledObjects:
  kubectl get triggerauthentication [--namespace <namespace>]

Get details about a deployed ScaledObject:
  kubectl describe triggerauthentication <trigger-authentication-name> [--namespace <namespace>]

Get an overview of the Horizontal Pod Autoscalers (HPA) that KEDA is using behind the scenes:
  kubectl get hpa [--all-namespaces] [--namespace <namespace>]

Learn more about KEDA:
- Documentation: https://keda.sh/
- Support: https://keda.sh/support/
- File an issue: https://github.com/kedacore/keda/issues/new/choose

# Ejemplo de scaledObject con RabbitMQ
```
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: consumer
spec:
  scaleTargetRef:
    apiVersion: apps/v1         # Optional. Default: apps/v1
    kind: Deployment                # Optional. Default: Deployment
    name: consumer                # Mandatory. Must be in the same namespace as the ScaledObject
  pollingInterval:  10                                      # Optional. Default: 30 seconds
  cooldownPeriod:   30                                     # Optional. Default: 300 seconds
  idleReplicaCount: 5                                       # Optional. Default: ignored, must be less than minReplicaCount
  minReplicaCount:  6                                       # Optional. Default: 0
  maxReplicaCount:  20                                     # Optional. Default: 100
  triggers:
  - type: rabbitmq
    metadata:
      host: amqp://admin:admin@rabbitmq.default.svc.cluster.local:5672 # Optional. If not specified, it must be done by using TriggerAuthentication.
      protocol: auto # Optional. Specifies protocol to use, either amqp or http, or auto to autodetect based on the `host` value. Default value is auto.
      mode: QueueLength # QueueLength or MessageRate
      value: "50" # message backlog or publish/sec. target per instance
      activationValue: "10" # Optional. Activation threshold
      queueName: poc_keda
      vhostName: / # Optional. If not specified, use the vhost in the `host` connection string. Required for Azure AD Workload Identity authorization (see bellow)
```