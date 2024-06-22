{{/*
Expand the name of the chart.
*/}}
{{- define "triton-inference-server.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "triton-inference-server.fullname" -}}
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
  Create inference server metrics service name and fullname derived from above and
  truncated appropriately.
*/}}
{{- define "triton-inference-server-metrics.name" -}}
{{- $basename := include "triton-inference-server.name" . -}}
{{- $basename_trimmed := $basename | trunc 55 | trimSuffix "-" -}}
{{- printf "%s-%s" $basename_trimmed "metrics" -}}
{{- end -}}

{{- define "triton-inference-server-metrics.fullname" -}}
{{- $basename := include "triton-inference-server.fullname" . -}}
{{- $basename_trimmed := $basename | trunc 55 | trimSuffix "-" -}}
{{- printf "%s-%s" $basename_trimmed "metrics" -}}
{{- end -}}

{{/*
  Create inference server metrics monitor name and fullname derived from
  above and truncated appropriately.
*/}}
{{- define "triton-inference-server-metrics-monitor.name" -}}
{{- $basename := include "triton-inference-server.name" . -}}
{{- $basename_trimmed := $basename | trunc 47 | trimSuffix "-" -}}
{{- printf "%s-%s" $basename_trimmed "metrics-monitor" -}}
{{- end -}}

{{- define "triton-inference-server-metrics-monitor.fullname" -}}
{{- $basename := include "triton-inference-server.fullname" . -}}
{{- $basename_trimmed := $basename | trunc 47 | trimSuffix "-" -}}
{{- printf "%s-%s" $basename_trimmed "metrics-monitor" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "triton-inference-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "triton-inference-server.labels" -}}
helm.sh/chart: {{ include "triton-inference-server.chart" . }}
{{ include "triton-inference-server.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "triton-inference-server.selectorLabels" -}}
app.kubernetes.io/name: {{ include "triton-inference-server.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "triton-inference-server.serviceAccountName" -}}
{{- if eq .Values.serviceAccount.create true }}
{{- default (include "triton-inference-server.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
