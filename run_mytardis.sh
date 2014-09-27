#!/bin/bash

set -e

cd /opt/mytardis

# Wait for postgres.
while [[ ! -e /run/postgresql/9.4-main.pid ]] ; do
    inotifywait -q -e create /run/postgresql/ >> /dev/null
done

echo "[run] create role"
./create_role.sh

echo "[run] createdb tardis"
setuidgid postgres createdb tardis || echo 'tardis database already exists'

echo "[run] syncdb"
./bin/django syncdb --noinput --migrate

./bin/django migrate || echo 'migrate failed, ignoring'
./bin/django schemamigration tardis_portal --auto || echo 'schemamigration failed, ignoring'
./bin/django migrate tardis_portal || echo 'migrate tardis_portal failed, ignoring'

echo "[run] create_admin.py"
python create_admin.py

echo "[run] runserver"
./bin/django runserver 0.0.0.0:8000
