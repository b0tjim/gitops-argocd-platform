#!/usr/bin/env bash
# Seal the PostgreSQL credentials for one environment with kubeseal.
#
# Reads POSTGRES_USER / POSTGRES_PASSWORD / POSTGRES_DB from .env, builds the
# same Secret the chart would (bakery-orders-api-postgresql), encrypts it with
# the cluster's Sealed Secrets public key and writes only the SealedSecret to
# workloads/bakery-orders-api/overlays/<env>/postgresql-sealedsecret.yaml.
# The plain Secret never touches disk.
#
# Usage: scripts/seal-db-secret.sh <dev|prod>
# Set SEALED_SECRETS_CERT=path/to/cert.pem to seal offline instead of asking the
# controller (get one with: kubeseal --fetch-cert > cert.pem).
set -euo pipefail

env_name="${1:-}"
case "$env_name" in
  dev | prod) ;;
  *) echo "usage: $0 <dev|prod>" >&2; exit 1 ;;
esac

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
env_file="${ENV_FILE:-$repo_root/.env}"
[[ -f "$env_file" ]] || { echo "missing $env_file (copy .env.example)" >&2; exit 1; }
command -v kubeseal >/dev/null || { echo "kubeseal not found on PATH" >&2; exit 1; }

set -a
# shellcheck source=/dev/null
source "$env_file"
set +a
: "${POSTGRES_USER:?set in .env}" "${POSTGRES_PASSWORD:?set in .env}" "${POSTGRES_DB:?set in .env}"

namespace="bakery-$env_name"
name="bakery-orders-api-postgresql"
out="$repo_root/workloads/bakery-orders-api/overlays/$env_name/postgresql-sealedsecret.yaml"
# Same format the chart builds; the host is the in-cluster PostgreSQL Service.
database_url="postgresql+psycopg://$POSTGRES_USER:$POSTGRES_PASSWORD@$name:5432/$POSTGRES_DB"

cert_args=()
[[ -n "${SEALED_SECRETS_CERT:-}" ]] && cert_args=(--cert "$SEALED_SECRETS_CERT")

# Values are JSON-quoted (valid YAML) so passwords with special characters survive.
q() { printf '"%s"' "$(printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"; }

# kubeseal emits `creationTimestamp: null`, which the SealedSecret schema rejects.
kubeseal --format yaml --namespace "$namespace" "${cert_args[@]}" <<YAML \
  | sed "/creationTimestamp: null/d" > "$out"
apiVersion: v1
kind: Secret
metadata:
  name: $name
  namespace: $namespace
type: Opaque
stringData:
  POSTGRES_USER: $(q "$POSTGRES_USER")
  POSTGRES_PASSWORD: $(q "$POSTGRES_PASSWORD")
  POSTGRES_DB: $(q "$POSTGRES_DB")
  DATABASE_URL: $(q "$database_url")
YAML

echo "wrote $out"
