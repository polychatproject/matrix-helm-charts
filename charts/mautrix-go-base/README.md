# mautrix-go-base

Shared Helm library chart for mautrix Go bridge wrappers.

## Purpose

This chart centralizes Kubernetes resource templates and shared helper logic so bridge-specific charts only define:

- bridge-specific config merge and reserved key checks
- bridge command and startup args
- registration file key and regex defaults
- chart metadata, schema, and examples

## Wrapper Contract

A wrapper chart that depends on this library must define these helpers:

- `<chart>.runtimeSecretKeys`: YAML list of runtime secret keys in `values.registration`.
- `<chart>.bridgeCommand`: YAML list for container `command`.
- `<chart>.bridgeArgs`: YAML list for container `args`.
- `<chart>.mergedConfig`: final merged bridge config as YAML mapping.
- `<chart>.registrationFileKey`: appservice registration configmap key name.
- `<chart>.registrationConfig`: registration YAML document.
- `<chart>.defaultRegistrationUserRegex`: default user namespace regex when `registration.userRegex` is empty.

## Kubernetes Behavior

Templates in this library follow mautrix Kubernetes guidance:

- direct bridge command (no startup script)
- `--no-update` support via wrapper args
- read-only config mount at `/data`
- singleton bridge StatefulSet (`replicas: 1`)
- `publishNotReadyAddresses: true`
- optional probes only (disabled by default)

## New Go Bridge Checklist

Use `mautrix-whatsapp` as the scaffold:

1. Copy `charts/mautrix-whatsapp` to a new chart name.
2. Update `Chart.yaml` metadata and image defaults.
3. Update wrapper helpers in `templates/_helpers.tpl`:
- `registrationFileKey`
- `defaultRegistrationUserRegex`
- `mergedConfig` reserved path checks
- any bridge-specific config defaults
4. Keep Kubernetes runtime shape unchanged unless bridge behavior requires it.
5. Update `values.yaml`, `values.schema.json`, and examples.
6. Update chart README and root docs tables.
7. Validate with `helm lint` and `helm template` across all example values.
