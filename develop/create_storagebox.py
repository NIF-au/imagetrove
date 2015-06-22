import sys

sys.path.append('/opt/mytardis')
from append_django_paths import *

from tardis.tardis_portal.models.storage import StorageBox, StorageBoxOption

try:
    s = StorageBox(
            status='online',
            max_size=0,
            name='ImageTrove at /imagetrove',             
            description='ImageTrove StorageBox',
            )
    s.save()

    location_opt = StorageBoxOption(
                    storage_box=s,
                    key='location',
                    value='/imagetrove')
    location_opt.save()

    s.options.add(location_opt)
    s.save()

    print s
except:
    pass
