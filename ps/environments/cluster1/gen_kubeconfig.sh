#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="tenant-system"
OUTPUT_DIR="./kubeconfigs"
SERVER="https://cluster1.projectsprint.id"

# Get the base64 CA data from capsule-proxy-root-secret
CA_DATA=$(kubectl get secret capsule-proxy-root-secret \
  -n capsule-system \
  -o jsonpath='{.data.tls\.crt}')

mkdir -p "$OUTPUT_DIR"

# Get all tenant names from the cluster
TENANTS=$(kubectl get tenants.capsule.clastix.io -o jsonpath='{.items[*].metadata.name}')

if [[ -z "$TENANTS" ]]; then
  echo "[!] No tenants found in the cluster."
  exit 0
fi

for TEAM in $TENANTS; do
  echo "[*] Processing tenant: $TEAM"
  SA_NAME="${TEAM}-sa"

  # Skip if ServiceAccount does not exist
  if ! kubectl get sa "$SA_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "[!] Skipping '$TEAM' (ServiceAccount '$SA_NAME' not found)"
    continue
  fi

  # Create long-lived token (30 days = 720h)
  TOKEN=$(kubectl create token "$SA_NAME" \
    -n "$NAMESPACE" \
    --duration=720h)

  # Generate kubeconfig
  cat > "$OUTPUT_DIR/${TEAM}.kubeconfig" <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CA_DATA}
    server: ${SERVER}
  name: default
contexts:
- context:
    cluster: default
    user: ${TEAM}
  name: ${TEAM}-context
current-context: ${TEAM}-context
preferences: {}
users:
- name: ${TEAM}
  user:
    token: ${TOKEN}
EOF

  echo "[+] Kubeconfig written: $OUTPUT_DIR/${TEAM}.kubeconfig"
done

