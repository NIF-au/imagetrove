import sys

sys.path.append('/opt/mytardis')
from append_django_paths import *

from tardis.tardis_portal.models import Location

name = 'imagetrove'
url  = 'file:///imagetrove'

if not Location.objects.filter(name=name).count():
    loc = Location(name=name, url=url, type='online', priority=5)
    loc.save()
