import sys

sys.path.append('/opt/mytardis')
from append_django_paths import *

from tardis.tardis_portal.models import Experiment, Dataset, DataFile, DataFileObject, Group, User

for thing in [Experiment.objects.all(), Dataset.objects.all(), DataFile.objects.all(), DataFileObject.objects.all(), Group.objects.all()]:
    for x in thing:
        x.delete()

for u in User.objects.filter().exclude(username='admin'):
    u.delete()
