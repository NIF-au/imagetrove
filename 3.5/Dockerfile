FROM        carlohamalainen/imagetrove-base
MAINTAINER  Carlo Hamalainen <c.hamalainen@uq.edu.au>

# Sane vim environment.
RUN mkdir           /root/.vim
ADD vim/.vimrc      /root/.vimrc
ADD vim/autoload    /root/.vim/autoload
ADD vim/bundle      /root/.vim/bundle

WORKDIR /root/.vim/bundle/vimproc.vim
RUN     make

# Sane bash settings.
ADD bashrc-extra /root/.bashrc-extra
RUN echo 'source /root/.bashrc-extra' >> /root/.bashrc

# Set up the postgresql admin user with password admin.
RUN mkdir /data
RUN chown postgres.postgres /data
RUN chmod 0700 /data
ADD /postgresql.conf /etc/postgresql/9.4/main/postgresql.conf

RUN mkdir /scripts
ADD postgresql_first_run.sh     /scripts/
ADD postgresql_start.sh         /scripts/
RUN chmod +x /scripts/*

RUN touch /firstrun

# Supervisord
ADD supervisord.conf /etc/supervisord.conf

# Install MyTARDIS:
RUN         mkdir -p /opt
WORKDIR     /opt
ADD         mytardis /opt/mytardis
ADD         buildout-dev.cfg /opt/mytardis/
WORKDIR     /opt/mytardis
RUN         python bootstrap.py -v 1.7.0
RUN         ./bin/buildout -c buildout-dev.cfg

# Add our config to MyTARDIS:
WORKDIR     /opt
ADD         settings.py             /opt/mytardis/tardis/
ADD         run_mytardis.sh         /opt/mytardis/
ADD         run_celery.sh           /opt/mytardis/
ADD         create_admin.py         /opt/mytardis/
ADD         create_location.py      /opt/mytardis/
ADD         wipe_db.py              /opt/mytardis/
ADD         append_django_paths.py  /opt/mytardis/
ADD         create_role.sh          /opt/mytardis/

WORKDIR     /opt/mytardis
RUN         ln -s bin/django djangosettings.py

RUN         rmdir /opt/mytardis/var/store
RUN         ln -s /mytardis_store/ /opt/mytardis/var/store

RUN         rmdir /opt/mytardis/var/staging
RUN         ln -s /mytardis_staging/ /opt/mytardis/var/staging

RUN mkdir /mytardis_store /mytardis_staging

VOLUME ["/data", "/var/log", "/imagetrove", "/mytardis_store", "/mytardis_staging"]

EXPOSE 8000

EXPOSE 8042
EXPOSE 4242
EXPOSE 5242

RUN mkdir /scratch
VOLUME "/scratch"

CMD /usr/bin/supervisord -c /etc/supervisord.conf
