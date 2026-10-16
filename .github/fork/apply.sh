#!/usr/bin/env bash
# Applies this fork's changes to an upstream FlClash checkout.
# Usage: apply.sh <fork checkout>, run from the upstream checkout root.

set -euo pipefail

fork="$(cd "$1" && pwd)"
utls_version="$(tr -d '[:space:]' < "$fork/.github/fork/utls-version")"
fingerprint_test=TestBrowserFingerprintsOfferPostQuantumKeyShare

(
  cd core
  package="$(go list -f '{{.Name}}' .)"
  sed "s/^package .*/package $package/" "$fork/.github/fork/fingerprint_test.go" > fingerprint_test.go
  if CGO_ENABLED=0 go test -count=1 -run "$fingerprint_test" . > /dev/null 2>&1; then
    echo 'Upstream core already sends post-quantum key shares; utls is left as is.'
  else
    go mod edit -replace "github.com/metacubex/utls=github.com/metacubex/utls@$utls_version"
    go mod tidy
  fi
  CGO_ENABLED=0 go test -count=1 -run "$fingerprint_test" -v .
)

for patch in "$fork"/.github/fork/core-patches/*.patch; do
  echo "Applying core $(basename "$patch")"
  git -C core/Clash.Meta apply --whitespace=nowarn "$patch"
done

for patch in "$fork"/.github/fork/patches/*.patch; do
  echo "Applying $(basename "$patch")"
  git apply --whitespace=nowarn "$patch"
done
