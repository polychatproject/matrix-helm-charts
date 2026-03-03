{{- define "mautrix-linkedin.runtimeSecretKeys" -}}
asToken,hsToken
{{- end -}}

{{- define "mautrix-linkedin.bridgeCommand" -}}
- mautrix-linkedin
{{- end -}}

{{- define "mautrix-linkedin.bridgeArgs" -}}
- -c
- /data/config.yaml
- --no-update
{{- end -}}

{{- define "mautrix-linkedin.registrationFileKey" -}}
appservice-registration-linkedin.yaml
{{- end -}}

{{- define "mautrix-linkedin.defaultRegistrationUserRegex" -}}
{{- printf "@%s_.*:%s" .Values.appservice.id (include "mautrix-go-base.homeserverDomain" .) -}}
{{- end -}}

{{- define "mautrix-linkedin.registrationConfig" -}}
{{ include "mautrix-go-base.registrationConfig" . }}
{{- end -}}

{{- define "mautrix-linkedin.doublePuppetRegistrationFileKey" -}}
appservice-registration-doublepuppet.yaml
{{- end -}}

{{- define "mautrix-linkedin.doublePuppetUserRegex" -}}
{{- $domain := include "mautrix-go-base.homeserverDomain" . -}}
{{- printf "@.*:%s" (replace "." "\\." $domain) -}}
{{- end -}}

{{- define "mautrix-linkedin.reservedBasePaths" -}}
homeserver.address,homeserver.domain,appservice.address,appservice.hostname,appservice.port,appservice.id,appservice.bot.username,appservice.as_token,appservice.hs_token,database.type,database.uri
{{- end -}}

{{- define "mautrix-linkedin.reservedNetworkPaths" -}}
{{- end -}}

{{- define "mautrix-linkedin.managedConfig" -}}
{{- $bot := .Values.appservice.bot | default dict -}}
{{- $managed := dict
  "homeserver" (dict
    "address" .Values.homeserver.address
    "domain" (include "mautrix-go-base.homeserverDomain" .)
  )
  "appservice" (dict
    "address" (include "mautrix-go-base.appserviceAddress" .)
    "hostname" .Values.appservice.hostname
    "port" .Values.appservice.port
    "id" .Values.appservice.id
    "as_token" (include "mautrix-go-base.runtimeSecretValue" (dict "root" . "key" "asToken"))
    "hs_token" (include "mautrix-go-base.runtimeSecretValue" (dict "root" . "key" "hsToken"))
    "bot" (dict
      "username" ((get $bot "username") | default "")
    )
  )
  "database" (dict
    "type" "postgres"
    "uri" (include "mautrix-go-base.databaseConnectionString" .)
  )
-}}
{{ toYaml $managed }}
{{- end -}}

{{- define "mautrix-linkedin.mergedConfig" -}}
{{ include "mautrix-go-base.bridgev2MergedConfig" . }}
{{- end -}}
