# Clunky module to append all the paths from the
# Django install so that a stand-alone script can run
# things. Causes side-effects when imported.

import os
import os.path
import sys

old_cwd = os.getcwd()

sys.path.append('/opt/mytardis')

import djangosettings
sys.path += djangosettings.sys.path

os.chdir('/opt/mytardis')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')

sys.path.append(os.path.join(os.getcwd(), 'tardis'))

os.chdir(old_cwd)
