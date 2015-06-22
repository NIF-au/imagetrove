import sys

sys.path.append('/opt/mytardis')
from append_django_paths import *

from django.contrib.auth.models import User
from tardis.tardis_portal.models import UserProfile

if not User.objects.filter(username='admin').count():
    u = User.objects.create_superuser('admin', 'admin@example.com', 'admin_CHANGEME')
    UserProfile(user=u).save()
