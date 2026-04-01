#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <keystore-path> <alias>"
  exit 1
fi

KEYSTORE_PATH="$1"
ALIAS="$2"

keytool -genkey -v \
  -keystore "$KEYSTORE_PATH" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

echo "\nCreated keystore: $KEYSTORE_PATH"
echo "Now copy android/key.properties.example to android/key.properties and fill values."
