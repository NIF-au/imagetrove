#!/bin/bash

cd /opt/mytardis
C_FORCE_ROOT=YES ./mytardis.py celeryd --beat # --loglevel DEBUG
