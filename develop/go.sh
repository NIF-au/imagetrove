#!/bin/bash

docker run -i -t --rm                  \
        -p 8000:8000                                \
        -v /export/nif02/uqchamal/mytardis_develop/data:/data                           \
        -v /export/nif02/uqchamal/mytardis_develop/var_log:/var/log                     \
        -v /export/nif02/uqchamal/mytardis_develop/imagetrove:/imagetrove               \
        -P user/mytardis-develop
