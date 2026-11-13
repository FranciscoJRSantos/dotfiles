#!/usr/bin/env bash
# Unattended backup + prune, started by backup.service (systemd user timer).
# The credentials arrive decrypted in $CREDENTIALS_DIRECTORY (LoadCredentialEncrypted=
# in the unit); store them there once with `make creds`. No 1Password prompt involved.
set -euo pipefail

dir=${CREDENTIALS_DIRECTORY:?run this through backup.service}
RESTIC_REPOSITORY=$(<"$dir/restic-repository")
AWS_ACCESS_KEY_ID=$(<"$dir/aws-access-key-id")
AWS_SECRET_ACCESS_KEY=$(<"$dir/aws-secret-access-key")
RESTIC_PASSWORD=$(<"$dir/restic-password")
export RESTIC_REPOSITORY AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY RESTIC_PASSWORD

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# make stops at the first failure, so a failed backup never reaches prune.
exec make -C "$here" backup prune RESTIC=restic
