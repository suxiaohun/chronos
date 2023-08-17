{{/* Create a default fully qualified app name. */}}
{{- define "redis.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.nameSuffix | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels */}}
{{- define "redis.labels" -}}
{{ include "redis.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "redis.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Return image */}}
{{- define "common.image" -}}
{{- $arch := index . 1 }}
{{- $app := index . 2 }}
{{- with index . 0 }}
{{- printf "%s/%s:%s" .Values.global.imageRegistry (get (get .Values.image.repository $arch) $app ) (get (get .Values.image.tag $arch) $app)}}
{{- end }}
{{- end }}

{{- define "redis.maxMemory" -}}
{{- if contains "Mi" .Values.resources.redis.limits.memory -}}
{{- printf "%v" (int (mulf 1024 1024 (mulf 0.9 (trimSuffix "Mi" .Values.resources.redis.limits.memory)))) }}
{{- else if contains "M" .Values.resources.redis.limits.memory }}
{{- printf "%v" (int (mulf 1000 1000 (mulf 0.9 (trimSuffix "M" .Values.resources.redis.limits.memory)))) }}
{{- else if contains "Gi" .Values.resources.redis.limits.memory -}}
{{- printf "%v" (int (mulf 1024 1024 1024 (mulf 0.9 (trimSuffix "Gi" .Values.resources.redis.limits.memory)))) }}
{{- else if contains "G" .Values.resources.redis.limits.memory -}}
{{- printf "%v" (int (mulf 1000 1000 1000 (mulf 0.9 (trimSuffix "G" .Values.resources.redis.limits.memory)))) }}
{{- end }}
{{- end }}

