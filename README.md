# NerdsWhoFish Charts

Helm charts for [NerdsWhoFish](https://github.com/NerdsWhoFish) projects.

Charts are published as OCI artifacts to GHCR.
There is no chart repository index to add.

| Chart | Installs |
| --- | --- |
| [dusk](dusk/) | [Dusk](https://github.com/NerdsWhoFish/dusk), a service catalog that maintains itself |

## Install

Create the namespace and the Secret Dusk needs before installing the chart.

```zsh
kubectl create namespace dusk
kubectl --namespace dusk create secret generic dusk-secrets \
  --from-literal=DUSK_ENCRYPTION_KEY="$DUSK_ENCRYPTION_KEY" \
  --from-literal=DUSK_MCP_TOKEN="$DUSK_MCP_TOKEN"

helm install dusk oci://ghcr.io/nerdswhofish/charts/dusk \
  --namespace dusk \
  --set dusk.privateHost=https://dusk.example.com \
  --set dusk.existingSecret=dusk-secrets
```

`dusk.privateHost` must match how you actually reach the service.
It is baked into the GitHub App registration during onboarding, so a mismatch makes the setup callback fail.
Configure the chart's Ingress values or another route before opening that URL.
See the [chart guide](dusk/README.md) for ingress, persistence, backup, upgrade, and rollback.

## Versioning

Chart versions and Dusk versions are independent.
The chart's `appVersion` is the exact Dusk image tag it targets.
Git release tags have a leading `v`; container tags and `appVersion` do not.
See [ADR-0024](https://github.com/NerdsWhoFish/dusk/blob/main/adr/0024-charts-publishes-charts.md).

## Development

```bash
helm lint dusk
helm template dusk
helm template dusk --set ingress.enabled=true --set persistence.enabled=false
```

Charts here are expected to install cleanly with defaults on a single-node cluster.

## License

Apache 2.0.
