sudo chown -R carlo.carlo /data/Q0107/imagetrove0_dev_volumes/*
find /data/Q0107/imagetrove0_dev_volumes/var_log/ -type f -exec rm {} \;

find /data/Q0107/imagetrove0_dev_volumes/imagetrove         -type f -exec rm {} \;
find /data/Q0107/imagetrove0_dev_volumes/data               -type f -exec rm {} \;
find /data/Q0107/imagetrove0_dev_volumes/mytardis_staging   -type f -exec rm {} \;
find /data/Q0107/imagetrove0_dev_volumes/mytardis_store     -type f -exec rm {} \;
find /data/Q0107/imagetrove0_dev_volumes/OrthancStorage     -type f -exec rm {} \;

rm -fr /data/Q0107/imagetrove0_dev_volumes/imagetrove/*
rm -fr /data/Q0107/imagetrove0_dev_volumes/data/*
rm -fr /data/Q0107/imagetrove0_dev_volumes/mytardis_staging/*
rm -fr /data/Q0107/imagetrove0_dev_volumes/mytardis_store/*
rm -fr /data/Q0107/imagetrove0_dev_volumes/OrthancStorage/*


echo
echo
echo
echo 'Remaining files:'
echo

find /data/Q0107/imagetrove0_dev_volumes/ -type f
