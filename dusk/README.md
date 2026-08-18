# Dusk chart

This chart runs one Dusk process against one persistent volume.
It deliberately does not scale horizontally because SQLite and the local action journal have one writer.

## Install

Create the namespace and a Secret containing the encryption key and one agent access mode.

```zsh
kubectl create namespace dusk
kubectl --namespace dusk create secret generic dusk-secrets \
  --from-literal=DUSK_ENCRYPTION_KEY="$DUSK_ENCRYPTION_KEY" \
  --from-literal=DUSK_MCP_TOKEN="$DUSK_MCP_TOKEN"
```

Install from GHCR with the private URL and Secret named explicitly.

```zsh
helm install dusk oci://ghcr.io/nerdswhofish/charts/dusk \
  --namespace dusk \
  --set dusk.privateHost=https://dusk.example.com \
  --set dusk.existingSecret=dusk-secrets
```

Enable and configure the Ingress for the cluster, or leave it off and supply a Service route another way.
Set `dusk.publicHost` when GitHub reaches `/webhooks` through a different public hostname.

## Persistent data

The generated PVC is retained when the Helm release is uninstalled because it contains credentials, action receipts, and installed plugins that Git cannot rebuild.
Delete the PVC explicitly only when resetting Dusk is intentional.

Set `persistence.existingClaim` to restore or adopt a PVC.
The Deployment uses `Recreate`, so two versions never mount the single-writer volume at once.

## Backup and restore

Scale the Deployment to zero and take a consistent PVC snapshot with the cluster's storage system.
Back up the Secret separately because the PVC is useless without the encryption key and the key should not live in the archive it unlocks.

Restore the snapshot as a PVC, recreate the Secret with the same values, set `persistence.existingClaim`, and install the same chart and image versions that made the backup.
Verify health, readiness, and a known catalog entity before upgrading.

## Upgrade and rollback

Inspect `helm show chart oci://ghcr.io/nerdswhofish/charts/dusk` to see which exact image tag `appVersion` targets.
Take a PVC snapshot, then use `helm upgrade` with the same required values.

Rollback requires both the previous Helm revision and the matching pre-upgrade PVC snapshot.
Do not point an older Dusk image at a volume already opened by a newer one because Dusk provides no backward-migration contract.
