#!/bin/bash

cd /opt/mytardis
C_FORCE_ROOT=YES bin/django celeryd --beat --loglevel DEBUG
