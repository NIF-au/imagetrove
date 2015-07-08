FROM        nifau/imagetrove-base
MAINTAINER  Carlo Hamalainen <c.hamalainen@uq.edu.au>

ADD sources.list /etc/apt/sources.list

RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get -y install python-pip git libxml2-dev libxslt1-dev python-dev zlib1g-dev python-wand python-virtualenv virtualenvwrapper python-psycopg2 python-yaml ipython python-anyjson python-bs4 python-billiard python-feedparser python-html5lib python-httplib2 python-pystache python-crypto python-flexmock python-dateutil
RUN pip install -U pip

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
ADD         mytardis-develop /opt/mytardis
WORKDIR     /opt/mytardis
RUN         pip install -r requirements.txt
RUN         pip install django-longerusernameandemail
RUN         chmod +x mytardis.py

# Install the ImageTrove plugin:
ADD         mytardis-plugin-imagetrove /opt/mytardis/tardis/apps/imagetrove
WORKDIR     /opt/mytardis/tardis/apps/imagetrove
RUN         pip install -r requirements.txt

# Add our config to MyTARDIS:
WORKDIR     /opt
ADD         settings.py             /opt/mytardis/tardis/
ADD         run_mytardis.sh         /opt/mytardis/
ADD         run_celery.sh           /opt/mytardis/
ADD         create_admin.py         /opt/mytardis/
ADD         create_storagebox.py      /opt/mytardis/
ADD         wipe_db.py              /opt/mytardis/
ADD         append_django_paths.py  /opt/mytardis/
ADD         create_role.sh          /opt/mytardis/

WORKDIR     /opt/mytardis
ADD         djangosettings.py       /opt/mytardis/

RUN          pip install --upgrade pwgen simplejson

WORKDIR     /opt/mytardis

VOLUME ["/data", "/var/log", "/imagetrove"]

VOLUME ["/opt/mytardis/tardis/apps/imagetrove"]

EXPOSE 8000

RUN mkdir /scratch
VOLUME "/scratch"

CMD /usr/bin/supervisord -c /etc/supervisord.conf
