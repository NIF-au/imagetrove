import sys

sys.path.append('/opt/mytardis')
from append_django_paths import *

from tardis.tardis_portal.models import Experiment, Dataset, Dataset_File, Replica, Group, User

for thing in [Experiment.objects.all(), Dataset.objects.all(), Dataset_File.objects.all(), Replica.objects.all(), Group.objects.all()]:
    for x in thing:
        x.delete()

for u in User.objects.filter().exclude(username='admin'):
    u.delete()
