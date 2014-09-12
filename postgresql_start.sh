#!/bin/bash
# Starts up postgresql within the container.
# Based on https://raw.githubusercontent.com/Painted-Fox/docker-postgresql/master/scripts/start.sh

# Stop on error
set -e

DATA_DIR=/data

if [[ -e /firstrun ]]; then
  source /scripts/postgresql_first_run.sh
else
  source /scripts/postgresql_normal_run.sh
fi

wait_for_postgres_and_run_post_start_action() {
  # Wait for postgres to finish starting up first.
  while [[ ! -e /run/postgresql/9.4-main.pid ]] ; do
      inotifywait -q -e create /run/postgresql/ >> /dev/null
  done

  post_start_action
}

pre_start_action

wait_for_postgres_and_run_post_start_action &

# Start PostgreSQL
echo "Starting PostgreSQL..."
setuidgid postgres /usr/lib/postgresql/9.4/bin/postgres -D /etc/postgresql/9.4/main
