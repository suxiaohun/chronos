{{/* Create a default fully qualified kafka app name. */}}
{{- define "kafka.fullname" -}}
{{- printf "%s-%s" .Chart.Name .Values.nameSuffix | trunc 63 }}
{{- end }}

{{/* Common labels */}}
{{- define "common.labels" -}}
{{- if .Chart.AppVersion -}}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ .Chart.Name }}
{{- end }}

{{/* Kafka selector labels */}}
{{- define "kafka.selectorLabels" -}}
app.kubernetes.io/component: {{ include "kafka.fullname" . }}
app.kubernetes.io/name: {{ include "kafka.fullname" . }}
{{- end }}

{{/* Return image */}}
{{- define "common.image" -}}
{{- $app := index . 1 }}
{{- with index . 0 }}
{{- printf "%s/%s:%s" .Values.global.dockerRegistry (get .Values.image.repository $app ) (get .Values.image.tag $app)}}
{{- end }}
{{- end }}

{{/* Return Kafka imagePullSecerts */}}
{{- define "kafka.imagePullSecrets" -}}
{{- if .Values.image.pullSecrets -}}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- else }}
imagePullSecrets: {}
{{- end }}
{{- end }}

{{/* Return Storage Class */}}
{{- define "kafka.storageClass" -}}
{{- if .Values.persistence.storageClass }}
{{- printf "storageClassName: %s" .Values.persistence.storageClass }}
{{- end }}
{{- end }}

{{/* Return Storage VolumeSize */}}
{{- define "kafka.volumeSize" -}}
{{- if .Values.persistence.volumeSize }}
{{- printf "storage: %s" .Values.persistence.volumeSize }}
{{- end }}
{{- end }}

{{/* kafka pods */}}
{{- define "kafka.pods" -}}
{{- $local := dict "first" true }}
{{- $fullname := include "kafka.fullname" . }}
{{- range $i, $e := until (int .Values.replicaCount) }}
{{- if not $local.first }}{{ " " }}{{ end }}{{ $fullname }}-{{ $i }}.{{ $fullname }}.{{$.Release.Namespace}}.svc.cluster.local
{{- $_ := set $local "first" false }}
{{- end }}
{{- end }}

{{/* Return kafka log dirs */}}
{{- define "kafka.logDirs" -}}
{{- $local := dict "first" true }}
{{- range $i, $m := until (int .Values.persistence.pvcPerPod) }}
{{- if not $local.first }},{{ end }}/var/lib/kafka{{ $i }}/disk00{{ $_ := set $local "first" false }}
{{- end }}
{{- end }}

{{/* Return feature version */}}
{{- define "feature.version" -}}
{{- $model_map_name := index . 1 }}
{{- $model_version := index . 2 }}
{{- with index . 0 }}
    {{- $configmap := (lookup "v1" "ConfigMap" .Values.global.model.configmap.namespace .Values.global.model.configmap.name).data }}
    {{- if $configmap }}
        {{- $models := get $configmap "models.yml" | fromYaml }}
        {{- $model_dict := get (get $models $model_map_name) $model_version }}
        {{- get $model_dict "FeatureVersion" }}
    {{- end }}
{{- end }}
{{- end }}

{{/* Return init topics */}}
{{- define "kafka.topics" -}}
{{- $face_replace_key := "FACE_FEATURE_VERSION" }}
{{- $ped_replace_key := "PED_FEATURE_VERSION" }}
{{- $automobile_replace_key := "AUTOMOBILE_FEATURE_VERSION" }}
{{- $carplate_replace_key := "CARPLATE_FEATURE_VERSION" }}
{{- $human_powered_vehicle_replace_key := "HUMAN_POWERED_VEHICLE_FEATURE_VERSION" }}
{{- range $topic := .Values.init.topics }}
    {{- if contains $face_replace_key $topic }}
        {{- $feature_version := include "feature.version" (list $ "engine_face_model_map" $.Values.global.model.version.face) }}
        {{- $topic | replace $face_replace_key ($feature_version|toString) }}
    {{- else if contains $ped_replace_key $topic }}
        {{- $feature_version := include "feature.version" (list $ "engine_pedestrian_model_map" $.Values.global.model.version.pedestrian) }}
        {{- $topic | replace $ped_replace_key ($feature_version|toString) }}
    {{- else if contains $automobile_replace_key $topic }}
        {{- $feature_version := include "feature.version" (list $ "engine_automobile_model_map" $.Values.global.model.version.automobile) }}
        {{- $topic | replace $automobile_replace_key ($feature_version|toString) }}
    {{- else if contains $carplate_replace_key $topic }}
        {{- $feature_version := include "feature.version" (list $ "engine_carplate_model_map" $.Values.global.model.version.carplate) }}
        {{- $topic | replace $carplate_replace_key ($feature_version|toString) }}
    {{- else if contains $human_powered_vehicle_replace_key $topic }}
        {{- $feature_version := include "feature.version" (list $ "engine_human_powered_vehicle_model_map" $.Values.global.model.version.humanPoweredVehicle) }}
        {{- $topic | replace $human_powered_vehicle_replace_key ($feature_version|toString) }}
    {{- else }}
        {{- $topic }}
    {{- end }}
    {{- print " " }}
{{- end }}
{{- end }}

{{/* Return topic retentions */}}
{{- define "kafka.topicRetentions" -}}
{{- $tr := list }}
{{- $face_replace_key := "FACE_FEATURE_VERSION" }}
{{- $ped_replace_key := "PED_FEATURE_VERSION" }}
{{- $automobile_replace_key := "AUTOMOBILE_FEATURE_VERSION" }}
{{- $carplate_replace_key := "CARPLATE_FEATURE_VERSION" }}
{{- $human_powered_vehicle_replace_key := "HUMAN_POWERED_VEHICLE_FEATURE_VERSION" }}
{{- range $item := .Values.init.topicRetentions }}
    {{- if contains $face_replace_key $item.topic_name }}
        {{- $feature_version := include "feature.version" (list $ "engine_face_model_map" $.Values.global.model.version.face) }}
        {{- $_ := set $item "topic_name" ($item.topic_name | replace $face_replace_key ($feature_version|toString)) }}
        {{- $tr = append $tr $item }}
    {{- else if contains $ped_replace_key $item.topic_name }}
        {{- $feature_version := include "feature.version" (list $ "engine_pedestrian_model_map" $.Values.global.model.version.pedestrian) }}
        {{- $_ := set $item "topic_name" ($item.topic_name | replace $ped_replace_key ($feature_version|toString)) }}
        {{- $tr = append $tr $item }}
    {{- else if contains $automobile_replace_key $item.topic_name }}
        {{- $feature_version := include "feature.version" (list $ "engine_automobile_model_map" $.Values.global.model.version.pedestrian) }}
        {{- $_ := set $item "topic_name" ($item.topic_name | replace $automobile_replace_key ($feature_version|toString)) }}
        {{- $tr = append $tr $item }}
    {{- else if contains $carplate_replace_key $item.topic_name }}
        {{- $feature_version := include "feature.version" (list $ "engine_carplate_model_map" $.Values.global.model.version.pedestrian) }}
        {{- $_ := set $item "topic_name" ($item.topic_name | replace $carplate_replace_key ($feature_version|toString)) }}
        {{- $tr = append $tr $item }}
    {{- else if contains $human_powered_vehicle_replace_key $item.topic_name }}
        {{- $feature_version := include "feature.version" (list $ "engine_human_powered_vehicle_model_map" $.Values.global.model.version.pedestrian) }}
        {{- $_ := set $item "topic_name" ($item.topic_name | replace $human_powered_vehicle_replace_key ($feature_version|toString)) }}
        {{- $tr = append $tr $item }}
    {{- else }}
        {{- $tr = append $tr $item }}
    {{- end }}
{{- end }}
{{- $tr|toJson }}
{{- end }}

{{/* Generate kafka admin secret */}}
{{- define "gen.admin-secret" -}}
{{- $fullname := include "kafka.fullname" . -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (printf "%s-secret" $fullname) -}}
{{- if $secret -}}
kafka_admin_username: {{ $secret.data.kafka_admin_username }}
kafka_admin_password: {{ $secret.data.kafka_admin_password }}
{{- else -}}
kafka_admin_username: {{ b64enc "admin" }}
kafka_admin_password: {{ randAlphaNum 8 | b64enc }}
{{- end -}}
{{- end -}}
