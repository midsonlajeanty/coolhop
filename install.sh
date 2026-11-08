#!/usr/bin/env bash
set -euo pipefail

REPO="midsonlajeanty/coolhop"
HOST_HOME="/data/coolify/backups/coolhop"
CONTAINER_HOME="/var/www/html/storage/app/backups/coolhop"
APP_CONTAINER="coolify"
DB_CONTAINER="coolify-db"

say() { printf '\033[1;36mcoolhop\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31mcoolhop\033[0m %s\n' "$*" >&2; exit 1; }

require_running() {
  [ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null)" = "true" ] \
    || fail "container $1 is not running. Run this on the Coolify host."
}

needs_backup() {
  case "${1:-}" in
    teams | plan | check | help | list | --help | -h | --version | -V) return 1 ;;
    *) return 0 ;;
  esac
}

download() {
  local base
  if [ -n "${COOLHOP_VERSION:-}" ]; then
    base="https://github.com/${REPO}/releases/download/${COOLHOP_VERSION}"
  else
    base="https://github.com/${REPO}/releases/latest/download"
  fi

  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "${base}/coolhop.phar" -o "${tmp}/coolhop.phar" || fail "cannot download ${base}/coolhop.phar"
  curl -fsSL "${base}/coolhop.phar.sha256" -o "${tmp}/coolhop.phar.sha256" || fail "cannot download the checksum"
  (cd "${tmp}" && sha256sum -c coolhop.phar.sha256 > /dev/null) || fail "checksum mismatch, refusing to run"
  install -m 0644 "${tmp}/coolhop.phar" "${HOST_HOME}/coolhop.phar"
  rm -rf "${tmp}"
}

backup() {
  local stamp dir user database
  stamp="$(date -u +%Y%m%d-%H%M%S)"
  dir="${HOST_HOME}/backups/${stamp}"
  user="$(docker exec "${APP_CONTAINER}" printenv DB_USERNAME 2> /dev/null || echo coolify)"
  database="$(docker exec "${APP_CONTAINER}" printenv DB_DATABASE 2> /dev/null || echo coolify)"

  mkdir -p "${dir}"
  chmod 0711 "${HOST_HOME}/backups" "${dir}"
  say "backing up the Coolify database to ${dir}/coolify.dump"
  docker exec "${DB_CONTAINER}" pg_dump -U "${user}" -Fc "${database}" > "${dir}/coolify.dump"
  chmod 0600 "${dir}/coolify.dump"
  [ -s "${dir}/coolify.dump" ] || fail "the backup is empty, refusing to continue"

  BACKUP_IN_CONTAINER="${CONTAINER_HOME}/backups/${stamp}/coolify.dump"
}

main() {
  command -v docker > /dev/null || fail "docker is required"
  command -v curl > /dev/null || fail "curl is required"
  require_running "${APP_CONTAINER}"
  require_running "${DB_CONTAINER}"

  mkdir -p "${HOST_HOME}"
  local owner
  owner="$(docker exec "${APP_CONTAINER}" sh -c 'echo "$(id -u):$(id -g)"')"
  chown "${owner}" "${HOST_HOME}"

  if [ -n "${COOLHOP_PHAR:-}" ]; then
    install -m 0644 "${COOLHOP_PHAR}" "${HOST_HOME}/coolhop.phar"
  else
    download
  fi

  BACKUP_IN_CONTAINER=""
  if needs_backup "${1:-}"; then
    backup
  fi

  local args=(exec -e "COOLHOP_HOME=${CONTAINER_HOME}" -e "COOLHOP_BACKUP=${BACKUP_IN_CONTAINER}")
  if [ -t 1 ] && [ -r /dev/tty ]; then
    docker "${args[@]}" -it "${APP_CONTAINER}" php "${CONTAINER_HOME}/coolhop.phar" "$@" < /dev/tty
  else
    docker "${args[@]}" -i "${APP_CONTAINER}" php "${CONTAINER_HOME}/coolhop.phar" "$@" --no-interaction
  fi
}

main "$@"
