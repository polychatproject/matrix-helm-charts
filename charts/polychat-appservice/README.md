# polychat-appservice

Helm chart for the Polychat Matrix appservice + linker frontend
([polychatproject/polychat-appservice](https://github.com/polychatproject/polychat-appservice)).

## Overview

- Singleton `StatefulSet` (the unclaimed-sub-room pool is in-memory and
  doesn't tolerate scaling).
- Two HTTP ports:
  - `appservice` (default 9999) — Synapse → appservice transactions.
  - `api` (default 9998) — public provisioning API and the React
    "linker" UI served at e.g. `https://join.polychat.de/`.
- A chart-managed `ConfigMap` containing the Synapse appservice
  `registration.yaml` (with auto-generated `as_token` / `hs_token`
  stored in a Secret named `<release>-tokens`). The ESS chart then
  references it via `synapse.appservices`.
- Persistent volume mounted at `/data` for `appservice.json` plus the
  matrix-bot-sdk SimpleFsStorageProvider state.
- An `Ingress` for the linker frontend, annotated for cert-manager.

## Quick start (against an ESS Community deployment)

```bash
helm upgrade --install \
  --namespace dtn10-customer-polychat polychat-appservice \
  oci://ghcr.io/polychatproject/matrix-helm-charts/polychat-appservice \
  -f values.matrix.example.yaml
```

Then add the registration to ESS:

```yaml
# polychat-ess/values.yaml
synapse:
  appservices:
    - configMap: polychat-appservice-registration
      configMapKey: registration.yaml
    # ...other bridge configMaps
```

…and re-apply ESS.

## Values

| Key | Description |
|-----|-------------|
| `serverName` | Matrix server name, e.g. `polychat.de`. **Required.** |
| `homeserverUrl` | In-cluster Synapse client+AS API URL. **Required.** |
| `image.{registry,repository,tag}` | Container image. Default: `ghcr.io/polychatproject/polychat-appservice:main`. |
| `api.ingress.host` | Public hostname for the linker UI (e.g. `join.polychat.de`). |
| `subRoomsPoolTarget` | Pre-created sub rooms per network. Default `2`. |
| `loadExistingRooms` | Reload pool state from existing Matrix rooms on boot (experimental). Default `false`. |
| `debugMxid` | If set, this MXID is invited to every sub room. |
| `networks.<irc/matrix/signal/telegram/whatsapp>.bridgeMxid` | Bridge bot MXID. Empty disables the network. |
| `networks.<...>.accountMxids` | Comma-joined list of MXIDs the appservice puppets via the bridge. |
| `appservice.registration.autoGenerate` | Generate the registration ConfigMap and tokens. Default `true`. |
| `persistence.enabled` | PVC for `/data`. Default `true`. |

See `values.yaml` for the full schema.

## Notes

- The chart leaves `podSecurityContext: {}` so OpenShift's SCC mutator
  can auto-assign UIDs from the namespace range. Stock Kubernetes can
  set `runAsNonRoot: true` and a fixed UID explicitly if needed.
- The matrix-bot-sdk crypto module sometimes fails to install via Bun;
  the upstream Dockerfile builds with `npm` and runs with `bun`, and
  this chart inherits that image so no special handling is needed here.
