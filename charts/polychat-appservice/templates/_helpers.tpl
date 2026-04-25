{{/* Common helpers for polychat-appservice */}}

{{- define "polychat-appservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "polychat-appservice.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "polychat-appservice.labels" -}}
app.kubernetes.io/name: {{ include "polychat-appservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: matrix-stack
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "polychat-appservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "polychat-appservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "polychat-appservice.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "polychat-appservice.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "polychat-appservice.image" -}}
{{- printf "%s/%s:%s" .Values.image.registry .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{- define "polychat-appservice.appserviceAddress" -}}
{{- printf "http://%s.%s.svc.cluster.local:%d" (include "polychat-appservice.fullname" .) .Release.Namespace (int .Values.appservice.port) -}}
{{- end -}}
