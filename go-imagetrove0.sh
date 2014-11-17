#!/bin/bash

sudo docker run -i -t --restart=on-failure                  \
        -p 0.0.0.0:3023:22                                  \
        -p 0.0.0.0:8001:8000                                \
        -p 0.0.0.0:8043:8042                                \
        -p 0.0.0.0:4243:4242                                \
        -v /data/Q0107/imagetrove0_dev_volumes/mytardis_staging:/mytardis_staging    \
        -v /data/Q0107/imagetrove0_dev_volumes/mytardis_store:/mytardis_store        \
        -v /data/Q0107/imagetrove0_dev_volumes/imagetrove:/imagetrove                \
        -v /data/Q0107/imagetrove0_dev_volumes/data:/data                            \
        -v /data/Q0107/imagetrove0_dev_volumes/var_log:/var/log                      \
        -v /data/Q0107/imagetrove0_dev_volumes/OrthancStorage:/OrthancStorage        \
        -v `pwd`/scratch:/scratch                                                    \
        -P user/imagetrove
