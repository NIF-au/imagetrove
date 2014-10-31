import sys

sys.path.append('/opt/mytardis')
from append_django_paths import *

from tardis.tardis_portal.models import Experiment, Dataset, Dataset_File, Replica

for thing in [Experiment.objects.all(), Dataset.objects.all(), Dataset_File.objects.all(), Replica.objects.all()]:
    for x in thing:
        x.delete()
