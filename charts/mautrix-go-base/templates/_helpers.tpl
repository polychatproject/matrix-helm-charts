{{- define "mautrix-go-base.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-go-base.fullname" -}}
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

{{- define "mautrix-go-base.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-go-base.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mautrix-go-base.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "mautrix-go-base.name" . }}
{{- end -}}

{{- define "mautrix-go-base.componentSelectorLabels" -}}
{{ include "mautrix-go-base.selectorLabels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "mautrix-go-base.labels" -}}
helm.sh/chart: {{ include "mautrix-go-base.chart" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "mautrix-go-base.selectorLabels" . }}
{{- end -}}

{{- define "mautrix-go-base.componentLabels" -}}
{{ include "mautrix-go-base.labels" .context }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "mautrix-go-base.image" -}}
{{- if .Values.image.tag -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- .Values.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.postgresImage" -}}
{{- if .Values.postgres.image.tag -}}
{{- printf "%s:%s" .Values.postgres.image.repository .Values.postgres.image.tag -}}
{{- else -}}
{{- .Values.postgres.image.repository -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.configSecretName" -}}
{{- printf "%s-config" (include "mautrix-go-base.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-go-base.registrationConfigMapName" -}}
{{- if .Values.registration.synapseConfigMapName -}}
{{- .Values.registration.synapseConfigMapName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-registration" (include "mautrix-go-base.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.runtimeSecretName" -}}
{{- if .Values.registration.existingSecret -}}
{{- .Values.registration.existingSecret -}}
{{- else if .Values.registration.managedSecret.name -}}
{{- .Values.registration.managedSecret.name -}}
{{- else -}}
{{- printf "%s-runtime-secrets" (include "mautrix-go-base.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.postgresFullname" -}}
{{- printf "%s-postgres" (include "mautrix-go-base.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mautrix-go-base.homeserverDomain" -}}
{{- required "values.homeserver.domain is required (example: matrix.example.com)" .Values.homeserver.domain -}}
{{- end -}}

{{- define "mautrix-go-base.databasePostgresDatabase" -}}
{{- $postgres := .Values.database.postgres | default dict -}}
{{- $database := (get $postgres "database") | default "" -}}
{{- required "values.database.postgres.database is required" $database -}}
{{- end -}}

{{- define "mautrix-go-base.databasePostgresUser" -}}
{{- $postgres := .Values.database.postgres | default dict -}}
{{- $user := (get $postgres "user") | default "" -}}
{{- required "values.database.postgres.user is required" $user -}}
{{- end -}}

{{- define "mautrix-go-base.databasePostgresPassword" -}}
{{- $postgres := .Values.database.postgres | default dict -}}
{{- $passwordCfg := (get $postgres "password") | default dict -}}
{{- $password := (get $passwordCfg "value") | default "" -}}
{{- required "values.database.postgres.password.value is required" $password -}}
{{- end -}}

{{- define "mautrix-go-base.databaseConnectionString" -}}
{{- $postgres := .Values.database.postgres | default dict -}}
{{- $host := (get $postgres "host") | default "" -}}
{{- $port := (get $postgres "port") | default 5432 -}}
{{- if and (eq $host "") .Values.postgres.enabled -}}
{{- $host = include "mautrix-go-base.postgresFullname" . -}}
{{- $port = .Values.postgres.service.port -}}
{{- end -}}
{{- if eq $host "" -}}
{{- fail "values.database.postgres.host is required when postgres.enabled=false" -}}
{{- end -}}
{{- $database := include "mautrix-go-base.databasePostgresDatabase" . -}}
{{- $user := include "mautrix-go-base.databasePostgresUser" . -}}
{{- $password := include "mautrix-go-base.databasePostgresPassword" . -}}
{{- $sslMode := (get $postgres "sslMode") | default "" -}}
{{- $connectionString := printf "postgres://%s:%s@%s:%v/%s" ($user | urlquery) ($password | urlquery) $host $port ($database | urlquery) -}}
{{- if ne $sslMode "" -}}
{{- printf "%s?sslmode=%s" $connectionString ($sslMode | urlquery) -}}
{{- else -}}
{{- $connectionString -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.appserviceAddress" -}}
{{- if .Values.appservice.address -}}
{{- .Values.appservice.address -}}
{{- else -}}
{{- printf "http://%s.%s.svc.cluster.local:%v" (include "mautrix-go-base.fullname" .) .Release.Namespace .Values.service.port -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.registrationServiceUrl" -}}
{{- if .Values.registration.serviceUrl -}}
{{- .Values.registration.serviceUrl -}}
{{- else -}}
{{- include "mautrix-go-base.appserviceAddress" . -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.registrationSenderLocalpart" -}}
{{- if .Values.registration.senderLocalpart -}}
{{- .Values.registration.senderLocalpart -}}
{{- else -}}
{{- $bot := .Values.appservice.bot | default dict -}}
{{- $username := (get $bot "username") | default "" -}}
{{- required "values.registration.senderLocalpart or values.appservice.bot.username is required" $username -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.registrationUserRegex" -}}
{{- if .Values.registration.userRegex -}}
{{- .Values.registration.userRegex -}}
{{- else -}}
{{- include (printf "%s.defaultRegistrationUserRegex" .Chart.Name) . -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.ensureRuntimeSecrets" -}}
{{- if not (hasKey .Values.registration "_computedRuntimeSecrets") -}}
{{- $keysRaw := include (printf "%s.runtimeSecretKeys" .Chart.Name) . | trim -}}
{{- if eq $keysRaw "" -}}
{{- fail (printf "%s.runtimeSecretKeys must render a comma-separated list of registration key names" .Chart.Name) -}}
{{- end -}}
{{- $keys := splitList "," $keysRaw -}}
{{- $useExistingSecret := ne (.Values.registration.existingSecret | default "") "" -}}
{{- $managedSecret := .Values.registration.managedSecret | default dict -}}
{{- $managedSecretEnabled := and (not $useExistingSecret) ((get $managedSecret "enabled") | default false) -}}
{{- $secretName := include "mautrix-go-base.runtimeSecretName" . -}}
{{- $existing := lookup "v1" "Secret" .Release.Namespace $secretName -}}
{{- $computed := dict -}}
{{- range $idx, $key := $keys -}}
{{- $secretKey := $key | trim -}}
{{- if eq $secretKey "" -}}
{{- fail (printf "%s.runtimeSecretKeys[%d] must not be empty" $.Chart.Name $idx) -}}
{{- end -}}
{{- $value := (get $.Values.registration $secretKey) | default "" -}}
{{- if eq $value "generate" -}}
{{- fail (printf "values.registration.%s must not be set to 'generate'; leave empty for auto-generation" $secretKey) -}}
{{- end -}}
{{- if and (eq $value "") $existing (hasKey $existing.data $secretKey) -}}
{{- $value = (index $existing.data $secretKey | b64dec) -}}
{{- end -}}
{{- if eq $value "" -}}
{{- if and $.Values.registration.autoGenerate $managedSecretEnabled -}}
{{- $value = (randAlphaNum 64 | sha256sum) -}}
{{- else -}}
{{- fail (printf "registration.%s is required when missing from secret %q (set registration.%s, set registration.existingSecret to a populated Secret, or enable registration.autoGenerate with registration.managedSecret.enabled=true)" $secretKey $secretName $secretKey) -}}
{{- end -}}
{{- end -}}
{{- $_ := set $computed $secretKey $value -}}
{{- end -}}
{{- $_ := set .Values.registration "_computedRuntimeSecrets" $computed -}}
{{- end -}}
{{- end -}}

{{- define "mautrix-go-base.runtimeSecretValue" -}}
{{- $root := .root -}}
{{- $key := .key -}}
{{- include "mautrix-go-base.ensureRuntimeSecrets" $root -}}
{{- $computed := index $root.Values.registration "_computedRuntimeSecrets" -}}
{{- if not (hasKey $computed $key) -}}
{{- fail (printf "computed runtime secrets missing key %q" $key) -}}
{{- end -}}
{{- index $computed $key -}}
{{- end -}}

{{- define "mautrix-go-base.registrationConfig" -}}
id: {{ .Values.appservice.id | quote }}
url: {{ include "mautrix-go-base.registrationServiceUrl" . | quote }}
as_token: {{ include "mautrix-go-base.runtimeSecretValue" (dict "root" . "key" "asToken") | quote }}
hs_token: {{ include "mautrix-go-base.runtimeSecretValue" (dict "root" . "key" "hsToken") | quote }}
sender_localpart: {{ include "mautrix-go-base.registrationSenderLocalpart" . | quote }}
rate_limited: {{ .Values.registration.rateLimited }}
namespaces:
  users:
    - exclusive: true
      regex: {{ include "mautrix-go-base.registrationUserRegex" . | squote }}
{{- end -}}
