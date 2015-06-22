
import os.path
import sys

# This is copied from mytardis.py in the project's root directory.

custom_settings = 'tardis.settings'
custom_settings_file = custom_settings.replace('.', '/') + '.py'
demo_settings = 'tardis.settings_changeme'
if os.path.isfile(custom_settings_file):
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", custom_settings)
else:
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", demo_settings)
    print('Using demo settings in "tardis/settings_changeme.py",'
          ' please add your own settings file, '
          '"tardis/settings.py".')
