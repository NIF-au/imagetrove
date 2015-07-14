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
python mytardis.py syncdb --all --noinput || echo 'syncdb failed, ignoring'
python mytardis.py migrate --fake --delete-ghost-migrations || echo 'migrate fake failed, ignoring'

echo "[run] migrate for longer email and usernames"
./mytardis.py migrate longerusernameandemail

echo "[run] create_admin.py"
python create_admin.py

echo "[run] collectstatic"
echo 'yes' | ./mytardis.py collectstatic --noinput

echo "[run] create_storagebox.py"
python create_storagebox.py

echo "[run] runserver"
./mytardis.py runserver 0.0.0.0:8000 # --noreload
