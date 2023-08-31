{{/* Create a default fully qualified app name. */}}
{{- define "clickhouse.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.nameSuffix | trunc 63 }}
{{- end }}

{{/* Common labels */}}
{{- define "clickhouse.labels" -}}
{{ include "clickhouse.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "clickhouse.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Return clickhouse image */}}
{{- define "clickhouse.image" -}}
{{- if eq "amd64" .Values.global.hostArch }}
{{- printf "%s/%s:%s" .Values.global.dockerRegistry .Values.image.repository.amd64.clickhouse .Values.image.tag.amd64.clickhouse }}
{{- end }}
{{- if eq "arm64" .Values.global.hostArch }}
{{- printf "%s/%s:%s" .Values.global.dockerRegistry .Values.image.repository.arm64.clickhouse .Values.image.tag.arm64.clickhouse }}
{{- end }}
{{- end }}

{{/* Return exporter image */}}
{{- define "exporter.image" -}}
{{- if eq "amd64" .Values.global.hostArch }}
{{- printf "%s/%s:%s" .Values.global.dockerRegistry .Values.image.repository.amd64.exporter .Values.image.tag.amd64.exporter }}
{{- end }}
{{- if eq "arm64" .Values.global.hostArch }}
{{- printf "%s/%s:%s" .Values.global.dockerRegistry .Values.image.repository.arm64.exporter .Values.image.tag.arm64.exporter }}
{{- end }}
{{- end }}

{{/* Return busybox image */}}
{{- define "busybox.image" -}}
{{- if eq "amd64" .Values.global.hostArch }}
{{- printf "%s/%s:%s" .Values.global.dockerRegistry .Values.image.repository.amd64.busybox .Values.image.tag.amd64.busybox }}
{{- end }}
{{- if eq "arm64" .Values.global.hostArch }}
{{- printf "%s/%s:%s" .Values.global.dockerRegistry .Values.image.repository.arm64.busybox .Values.image.tag.arm64.busybox }}
{{- end }}
{{- end }}

{{/* Return kafka auth username */}}
{{- define "kafka.username" }}
{{- $secret := (lookup "v1" "Secret" .Values.dep.kafka.namespace .Values.dep.kafka.auth.secretName) }}
{{- if $secret }}
{{- get $secret.data .Values.dep.kafka.auth.usernameRef | b64dec }}
{{- end }}
{{- end }}

{{/* Return kafka auth password */}}
{{- define "kafka.password" }}
{{- $secret := (lookup "v1" "Secret" .Values.dep.kafka.namespace .Values.dep.kafka.auth.secretName) }}
{{- if $secret }}
{{- get $secret.data .Values.dep.kafka.auth.passwordRef | b64dec }}
{{- end }}
{{- end }}

{{/* Return redis endpoint */}}
{{- define "redis.endpoint" -}}
    {{- printf "redis-%s.%s.svc.cluster.local" .Values.dep.redis.nameSuffix .Values.dep.redis.namespace }}
{{- end }}
