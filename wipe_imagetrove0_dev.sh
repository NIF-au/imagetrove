sudo chown -R carlo.carlo /data/Q0107/imagetrove0_dev_volumes/*
find /data/Q0107/imagetrove0_dev_volumes/var_log/ -type f -exec rm {} \;
rm -fr /data/Q0107/imagetrove0_dev_volumes/data/*
rm -fr /data/Q0107/imagetrove0_dev_volumes/mytardis_staging/*
rm -fr /data/Q0107/imagetrove0_dev_volumes/mytardis_store/*
rm -fr /data/Q0107/imagetrove0_dev_volumes/OrthancStorage/*
