#!/usr/bin/env bash
# =============================================================
#  TBG Postgres — spin up a container and import tbg_data.sql
#
#  Usage:
#    chmod +x docker_postgres.sh
#    ./docker_postgres.sh          # first run  (create + import)
#    ./docker_postgres.sh connect  # open psql shell
#    ./docker_postgres.sh stop     # stop container
#    ./docker_postgres.sh reset    # destroy volume + recreate
# =============================================================

set -e

CONTAINER="tbg-postgres"
DB_NAME="tbg"
DB_USER="tbg"
DB_PASS="tbg_secret"
DB_PORT="5432"          # host port — change if 5432 is already in use
VOLUME="tbg-pgdata"
SQL_FILE="$(dirname "$0")/tbg_data.sql"

# ---------------------------------------------------------------
start_or_create() {
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "→ Container '${CONTAINER}' already exists — starting it."
    docker start "${CONTAINER}"
  else
    echo "→ Creating volume '${VOLUME}'."
    docker volume create "${VOLUME}" >/dev/null

    echo "→ Running Postgres container '${CONTAINER}'."
    docker run -d \
      --name  "${CONTAINER}" \
      -e      POSTGRES_DB="${DB_NAME}" \
      -e      POSTGRES_USER="${DB_USER}" \
      -e      POSTGRES_PASSWORD="${DB_PASS}" \
      -p      "${DB_PORT}:5432" \
      -v      "${VOLUME}:/var/lib/postgresql/data" \
      postgres:16-alpine
  fi

  echo "→ Waiting for Postgres to be ready..."
  until docker exec "${CONTAINER}" pg_isready -U "${DB_USER}" -d "${DB_NAME}" -q; do
    sleep 1
  done
  echo "   Postgres is ready."
}

import_sql() {
  if [ ! -f "${SQL_FILE}" ]; then
    echo "ERROR: ${SQL_FILE} not found. Run this script from the repo root." >&2
    exit 1
  fi

  echo "→ Importing ${SQL_FILE} ..."
  docker exec -i "${CONTAINER}" \
    psql -U "${DB_USER}" -d "${DB_NAME}" < "${SQL_FILE}"
  echo "   Import complete."
}

verify() {
  echo ""
  echo "→ Quick verification:"
  docker exec "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}" -c \
    "SET search_path = tbg, public;
     SELECT sheet, COUNT(*) AS rows, MIN(period) AS first_period, MAX(period) AS last_period
     FROM   tbg_data
     GROUP  BY sheet
     ORDER  BY sheet;"
}

# ---------------------------------------------------------------
CMD="${1:-up}"

case "${CMD}" in

  up)
    start_or_create
    import_sql
    verify
    echo ""
    echo "✅  TBG database is up."
    echo ""
    echo "   Connection string:"
    echo "   postgresql://${DB_USER}:${DB_PASS}@localhost:${DB_PORT}/${DB_NAME}"
    echo ""
    echo "   To open a psql shell:  ./docker_postgres.sh connect"
    ;;

  connect)
    docker exec -it "${CONTAINER}" \
      psql -U "${DB_USER}" -d "${DB_NAME}" -c "SET search_path = tbg, public;" \
      || docker exec -it "${CONTAINER}" psql -U "${DB_USER}" -d "${DB_NAME}"
    ;;

  stop)
    docker stop "${CONTAINER}"
    echo "Container stopped (data preserved in volume '${VOLUME}')."
    ;;

  reset)
    echo "→ Removing container and volume (ALL DATA WILL BE LOST)."
    docker rm -f "${CONTAINER}" 2>/dev/null || true
    docker volume rm "${VOLUME}"  2>/dev/null || true
    echo "   Done. Run './docker_postgres.sh up' to recreate."
    ;;

  *)
    echo "Usage: $0 [up|connect|stop|reset]"
    exit 1
    ;;

esac
