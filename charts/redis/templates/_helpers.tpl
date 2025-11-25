{{- define "curso_redis.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "curso_redis.labels" -}}
app.kubernetes.io/name: {{ include "curso_redis.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}
