{{/*
Expand the name of the chart.
*/}}
{{- define "dusk.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name, capped at 63 chars for the label limit.
*/}}
{{- define "dusk.fullname" -}}
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

{{- define "dusk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dusk.labels" -}}
helm.sh/chart: {{ include "dusk.chart" . }}
{{ include "dusk.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "dusk.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dusk.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "dusk.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dusk.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The claim the pod mounts: an existing one if given, otherwise the chart's.
*/}}
{{- define "dusk.claimName" -}}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- include "dusk.fullname" . }}-data
{{- end }}
{{- end }}

{{/*
Container port, parsed from dusk.addr so the port is configured in one place.
*/}}
{{- define "dusk.containerPort" -}}
{{- $addr := default ":8080" .Values.dusk.addr -}}
{{- $port := last (splitList ":" $addr) -}}
{{- if not (regexMatch "^[0-9]+$" $port) -}}
{{- fail (printf "dusk.addr must end in a numeric port, got %q" $addr) -}}
{{- end -}}
{{- $port -}}
{{- end }}

{{/*
The scheme-and-host users actually reach, for NOTES.txt only.
*/}}
{{- define "dusk.notesURL" -}}
{{- if .Values.dusk.externalUrl -}}
{{- .Values.dusk.externalUrl | trimSuffix "/" -}}
{{- else if .Values.ingress.enabled -}}
{{- $host := (first .Values.ingress.hosts).host -}}
{{- $scheme := ternary "https" "http" (gt (len .Values.ingress.tls) 0) -}}
{{- printf "%s://%s" $scheme $host -}}
{{- else -}}
{{- printf "http://localhost:8080" -}}
{{- end -}}
{{- end }}
