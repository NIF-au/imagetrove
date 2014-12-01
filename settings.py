from os import path
from settings_changeme import *

# Add site specific changes here.

# Turn on django debug mode.
DEBUG = True

# Lots of output...
import logging
SYSTEM_LOG_LEVEL = logging.DEBUG
MODULE_LOG_LEVEL = logging.DEBUG

SYSTEM_LOG_FILENAME = '/var/log/request-test.log'
MODULE_LOG_FILENAME = '/var/log/tardis-test.log'

DATABASES['default']['ENGINE'] = 'django.db.backends.postgresql_psycopg2'
DATABASES['default']['NAME'] = 'tardis'
DATABASES['default']['USER'] = 'admin'
DATABASES['default']['PASSWORD'] = 'admin_CHANGEME'
DATABASES['default']['HOST'] = '127.0.0.1'
DATABASES['default']['PORT'] = ''

FILE_STORE_PATH = '/mytardis_store'
STAGING_PATH    = '/mytardis_staging'
SYNC_TEMP_PATH = '/opt/mytardis/var/staging/'

# Disable user registration as we use AAF.
INSTALLED_APPS = tuple([x for x in INSTALLED_APPS if x != 'registration'])

# Disable user account management.
MANAGE_ACCOUNT_ENABLED = False

# Django places a temporary uploaded file here and then does a save_move
# to the final name in FILE_STORE_PATH. So ideally the directories
# FILE_UPLOAD_TEMP_DIR and FILE_STORE_PATH will be on the same file system.
FILE_UPLOAD_TEMP_DIR = '/tmp'

# Show the Rapid Connect login button.
RAPID_CONNECT_ENABLED = True

RAPID_CONNECT_CONFIG = {}

RAPID_CONNECT_CONFIG['secret']           = 'SECRET_CHANGEME'
RAPID_CONNECT_CONFIG['authnrequest_url'] = 'https://rapid.test.aaf.edu.au/jwt/authnrequest/research/CHANGE_ME'

RAPID_CONNECT_CONFIG['iss'] = 'https://rapid.test.aaf.edu.au_CHANGEME'
RAPID_CONNECT_CONFIG['aud'] = 'http://example.com/rc/_CHANGEME'
