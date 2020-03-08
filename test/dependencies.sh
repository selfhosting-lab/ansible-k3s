#!/usr/bin/env bash
#
# Install Ansible dependencies

set -e
DIR=$(cd "$(dirname "${0}")" && pwd)
ROLES_DIR="${DIR}/roles"

if [[ -f "${DIR}/dependencies.yml" ]]; then
  [[ -d "${ROLES_DIR}" ]] && mkdir -p "${ROLES_DIR}"
  ansible-galaxy install -r "${DIR}/dependencies.yml" --force -p "${ROLES_DIR}"
fi
