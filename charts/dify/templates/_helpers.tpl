{{/*
Expand the name of the chart.
*/}}
{{- define "dify.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dify.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dify.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dify.labels" -}}
helm.sh/chart: {{ include "dify.chart" . }}
{{ include "dify.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dify.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dify.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Global labels
*/}}
{{- define "dify.global.labels" -}}
{{- if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dify.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dify.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "dify.baseUrl" -}}
{{ if .Values.global.enableTLS }}https://{{ else }}http://{{ end }}{{.Values.global.host}}{{ if .Values.global.port }}:{{.Values.global.port}}{{ end }}
{{- end }}

{{/*
dify environments
commonEnvs are for all containers
commonBackendEnvs are for api and worker containers
*/}}
{{- define "dify.commonEnvs" -}}
- name: EDITION
  value: {{ .Values.global.edition }}
{{- range tuple "CONSOLE_API_URL" "CONSOLE_WEB_URL" "SERVICE_API_URL" "APP_API_URL" "APP_WEB_URL" }}
- name: {{ . }}
  value: {{ include "dify.baseUrl" $ }}
{{- end }}
- name: MARKETPLACE_API_URL
  value: https://marketplace.dify.ai
- name: MARKETPLACE_URL
  value: https://marketplace.dify.ai
{{- end }}


{{- define "dify.commonBackendEnvs" -}}
- name: STORAGE_TYPE
  value: {{ .Values.global.storageType }}
- name: DB_PLUGIN_DATABASE
  value: dify_plugin
- name: EXPOSE_PLUGIN_DAEMON_PORT
  value: "5002"
- name: PLUGIN_DAEMON_PORT
  value: "5002"
- name: PLUGIN_DAEMON_KEY
  value: lYkiYYT6owG+71oLerGzA7GXCgOT++6ovaezWAjpCjf+Sjc3ZtU+qUEi
- name: PLUGIN_DAEMON_URL
  value: http://{{ include "dify.fullname" . }}-plugin-daemon:5002
- name: PLUGIN_MAX_PACKAGE_SIZE
  value: "52428800"
- name: PLUGIN_PPROF_ENABLED
  value: "false"
- name: PLUGIN_DEBUGGING_HOST
  value: 0.0.0.0
- name: PLUGIN_DEBUGGING_PORT
  value: "5003"
- name: EXPOSE_PLUGIN_DEBUGGING_HOST
  value: localhost
- name: EXPOSE_PLUGIN_DEBUGGING_PORT
  value: "5003"
- name: PLUGIN_DIFY_INNER_API_KEY
  value: QaHbTe77CtuXmsfyhR7+vRjI/+XbV1AaFy691iy+kGDv2Jvy0/eAh8Y1
- name: PLUGIN_DIFY_INNER_API_URL
  value: http://dify-api-svc:5001
- name: ENDPOINT_URL_TEMPLATE
  value: http://localhost/e/{hook_id}
- name: MARKETPLACE_ENABLED
  value: "true"
- name: MARKETPLACE_API_URL
  value: https://marketplace.dify.ai
{{- if eq .Values.global.storageType "volcengine-tos" }}
- name: VOLCENGINE_TOS_ACCESS_KEY
  value: {{ .Values.globalEnv.VOLCENGINE_TOS_ACCESS_KEY }}
- name: VOLCENGINE_TOS_BUCKET_NAME
  value: {{ .Values.globalEnv.VOLCENGINE_TOS_BUCKET_NAME }}
- name: VOLCENGINE_TOS_ENDPOINT
  value: {{ .Values.globalEnv.VOLCENGINE_TOS_ENDPOINT }}
- name: VOLCENGINE_TOS_REGION
  value: {{ .Values.globalEnv.VOLCENGINE_TOS_REGION }}
- name: VOLCENGINE_TOS_SECRET_KEY
  value: {{ .Values.globalEnv.VOLCENGINE_TOS_SECRET_KEY }}
{{- end }}
- name: INNER_API_KEY_FOR_PLUGIN
  value: QaHbTe77CtuXmsfyhR7+vRjI/+XbV1AaFy691iy+kGDv2Jvy0/eAh8Y1
{{- if .Values.redis.embedded }}
- name: CELERY_BROKER_URL
  value: redis://:{{ .Values.redis.auth.password }}@{{ include "dify.fullname" . }}-redis-master:6379/1
- name: REDIS_HOST
  value: {{ include "dify.fullname" . }}-redis-master
- name: REDIS_DB
  value: "1"
- name: REDIS_PASSWORD
  value: {{ .Values.redis.auth.password }}
- name: REDIS_PORT
  value: "6379"
{{- end }}
{{- if .Values.postgresql.embedded }}
- name: DB_USERNAME
  value: postgres
- name: DB_PASSWORD
  value: "{{ .Values.postgresql.auth.postgresPassword }}"
- name: DB_HOST
  value: {{ include "dify.fullname" . }}-postgresql
- name: DB_PORT
  value: "5432"
- name: DB_DATABASE
  value: {{ .Values.postgresql.auth.database }}
{{- end }}

{{- if .Values.minio.embedded }}
- name: S3_ENDPOINT
  value: http://{{ include "dify.fullname" . }}-minio:{{ .Values.minio.service.ports.api }}
- name: S3_BUCKET_NAME
  value: {{ .Values.minio.defaultBuckets }}
- name: S3_ACCESS_KEY
  value: {{ .Values.minio.auth.rootUser }}
- name: S3_SECRET_KEY
  value: {{ .Values.minio.auth.rootPassword }}
{{- else if eq .Values.global.storageType "s3" }}
- name: S3_BUCKET_NAME
  value: {{ .Values.globalEnv.S3_BUCKET_NAME }}
- name: S3_ACCESS_KEY
  value: {{ .Values.globalEnv.S3_ACCESS_KEY }}
- name: S3_SECRET_KEY
  value: {{ .Values.globalEnv.S3_SECRET_KEY }}
- name: S3_ENDPOINT
  value: {{ .Values.globalEnv.S3_ENDPOINT }}
- name: S3_REGION
  value: {{ .Values.globalEnv.S3_REGION }}
{{- end }}
{{- end }}
