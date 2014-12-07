#!/bin/bash

docker run -i -t --rm                  \
        -p 0.0.0.0:8001:8000                                \
        -p 0.0.0.0:8444:8443                                \
        -p 0.0.0.0:8043:8042                                \
        -p 0.0.0.0:4243:4242                                \
        -v /export/nif02/imagetrove/zong-dev/imagetrove:/imagetrove                \
        -v /export/nif02/imagetrove/zong-dev/mytardis_staging:/mytardis_staging    \
        -v /export/nif02/imagetrove/zong-dev/mytardis_store:/mytardis_store        \
        -v /export/nif02/imagetrove/zong-dev/data:/data                            \
        -v /export/nif02/imagetrove/zong-dev/var_log:/var/log                      \
        -v /export/nif02/imagetrove/zong-dev/OrthancStorage:/OrthancStorage        \
        -v `pwd`/scratch:/scratch                                                    \
        -P user/imagetrove-store-dev
