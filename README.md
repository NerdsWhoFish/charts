# NerdsWhoFish Charts

Helm charts for [NerdsWhoFish](https://github.com/NerdsWhoFish) projects.

Charts are published as OCI artifacts to GHCR.
There is no chart repository index to add.

| Chart | Installs |
| --- | --- |
| [dusk](dusk/) | [Dusk](https://github.com/NerdsWhoFish/dusk), a service catalog that maintains itself |

## Install

```bash
helm install dusk oci://ghcr.io/nerdswhofish/charts/dusk \
  --set dusk.externalUrl=https://dusk.example.com
```

`dusk.externalUrl` must match how you actually reach the service.
It is baked into the GitHub App registration during onboarding, so a mismatch makes the setup callback fail.

## Versioning

**Chart versions track the application version.**
Releasing Dusk `v1.2.3` publishes chart `1.2.3` with `appVersion: 1.2.3`, pointing at image tag `v1.2.3`.

That coupling is deliberate and is why the release is driven from the Dusk repo rather than from here.
See [ADR-0019](https://github.com/NerdsWhoFish/dusk/blob/main/adr/0019-chart-repo.md).

A chart-only fix still gets a full version, because a chart version that does not correspond to an application version is a thing nobody can reason about later.

## Development

```bash
helm lint dusk
helm template dusk
helm template dusk --set ingress.enabled=true --set persistence.enabled=false
```

Charts here are expected to install cleanly with defaults on a single-node cluster.

## License

Apache 2.0.
