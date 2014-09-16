FROM        debian:jessie
MAINTAINER  Carlo Hamalainen <c.hamalainen@uq.edu.au>

# Update and install packages.
ADD sources.list /etc/apt/sources.list
RUN apt-get -qq update
RUN apt-get -qqy dist-upgrade
RUN apt-get -qqy install python python-dev libpq-dev libssl-dev libsasl2-dev   \
                         libldap2-dev libxslt1.1 libxslt1-dev python-libxslt1  \
                         libexiv2-dev git libgraphviz-dev git ipython screen   \
                         htop imagemagick vim dcmtk openssh-server supervisor  \
                         pwgen libpq-dev python-dev python-software-properties \
                         software-properties-common python-psycopg2 pyflakes   \
                         tcsh make vim-gtk minc-tools python-pip               \
                         redis-server python-redis python-requests             \
                         inotify-tools daemontools

RUN DEBIAN_FRONTEND=noninteractive apt-get -qqy install postgresql postgresql-contrib

# Python packages.
RUN pip install pydicom
RUN pip install pynetdicom
RUN pip install PyJWT
RUN pip install PyCrypto
RUN pip install pwgen

# Locale needs to be right for various Haskell packages.
RUN sed -i 's/# en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/g' /etc/locale.gen
RUN locale-gen

# GHC and friends
RUN apt-get -qqy install ghc ghc-prof ghc-haddock cabal-install happy alex
WORKDIR /root
ENV HOME /root
RUN cabal update
RUN cabal install cabal-install
RUN echo 'export PATH=/root/.cabal/bin:$PATH' >> /root/.bashrc
RUN cabal update
RUN /root/.cabal/bin/cabal install ghc-mod-4.1.6

# Cabal defaults.
RUN sed -i 's/-- documentation: False/documentation: True/g'         /root/.cabal/config
RUN sed -i 's/-- library-profiling: False/library-profiling: True/g' /root/.cabal/config
RUN sed -i 's/-- jobs:/jobs: $ncpus/g'                               /root/.cabal/config

# Clean up.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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

# SSH access using the authorized_keys file (not in the git repo).
RUN mkdir /root/.ssh
ADD authorized_keys /root/.ssh/
RUN chmod 700 /root/.ssh
RUN chmod 600 /root/.ssh/authorized_keys

# SSH daemon needs host keys to be generated.
RUN mkdir -p  /var/run/sshd
RUN chmod -rx /var/run/sshd
RUN rm -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key

# Disable PAM otherwise we get logged out immediately.
# http://stackoverflow.com/questions/18173889/cannot-access-centos-sshd-on-docker
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g'   /etc/ssh/sshd_config

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

# Pynetdicom
ADD run_pynetdicom.sh      /opt/mytardis/
ADD mytardisdicomserver.py /opt/mytardis/
RUN chmod +x /opt/mytardis/run_pynetdicom.sh

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
ADD         append_django_paths.py  /opt/mytardis/

WORKDIR     /opt/mytardis
RUN         ln -s bin/django djangosettings.py

RUN mkdir /mytardis_store /mytardis_staging

VOLUME ["/data", "/var/log", "/mytardis_store", "/mytardis_staging", "/dicom_tmp"]

EXPOSE 22
EXPOSE 5000
EXPOSE 8000

RUN mkdir /scratch
VOLUME "/scratch"

CMD /usr/bin/supervisord -c /etc/supervisord.conf

# For testing, just load ssh.
#CMD         /usr/sbin/sshd -D
