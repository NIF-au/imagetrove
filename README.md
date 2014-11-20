# ImageTrove

ImageTrove is a tool for ingesting and archiving NIF datasets. It is made up of a number of components:

* PostgreSQL database.
* Web front end: [MyTARDIS](http://mytardis.org/), a [Django](https://www.djangoproject.com/) application.
* DICOM server: [Orthanc](http://orthanc-server.com/).
* Dataset uploader: [imagetrove-uploader](https://github.com/carlohamalainen/imagetrove).
* Federated authentication: end users log in to MyTARDIS using their institutional identity, which is verified by
  the Australian Access Federation's [Rapid Connect](https://rapid.aaf.edu.au) service.

For ease of deployment, all of the components are packaged into a [Docker](https://www.docker.com/) container.

The flow of data through the system is as follows:

1. Instrument user chooses a dataset to archive.
2. At the instrument console, the user sends the dataset to the ImageTrove modality (this is the Orthanc server).
3. Periodically, imagetrove-uploader scans the Orthanc DICOM server for new datasets which are converted to [MINC](http://www.bic.mni.mcgill.ca/ServicesSoftware/MINC) and imported into MyTARDIS, along with metadata.

Alternatively, DICOM and other files can be imported via a file system, e.g. SAMBA share.

# System requirements

* A 64bit Linux system with sufficient storage for the
datasets. For example a [Nectar VM](http://nectar.org.au/) with an
[RDSI](https://www.rdsi.edu.au/) storage allocation mounted as NFS. Any
distribution of Linux is acceptable as long as there is a [Docker package](https://docs.docker.com/installation/#installation).
* Each instrument's DICOM server must be able to connect to the ImageTrove instance on port 4242.
* Alternatively, each file system mount (containing DICOM and other instrument files) must be mountable over the network on the ImageTrove instance.
* The ImageTrove web server must be able to accept a HTTPS POST request from an AAF system.

# Installation

## Docker

Follow the instructions at https://docs.docker.com/installation/#installation

By default Docker stores its images in ```/var/lib/docker``` so ensure that this
directory is on a partition with sufficient free space. Check these settings in ```/etc/default/docker```:

    DOCKER_OPTS="--graph=/mnt/bigdrive/docker"
    export TMPDIR="/mnt/bigdrive/docker-tmp"

While not necessary, running Docker with AUFS makes building containers much faster. You can
check if AUFS is enabled by looking at the ```Storage Driver``` field:

    $ sudo docker info
    Containers: 22
    Images: 652
    Storage Driver: aufs
     Root Dir: /var/lib/docker/aufs
     Dirs: 696
    Execution Driver: native-0.2
    Kernel Version: 3.14.0-2-amd64
    Operating System: Debian GNU/Linux jessie/sid (containerized)
    WARNING: No memory limit support
    WARNING: No swap limit support

You might need to install the kernel package ```linux-image-extra-`uname -r` ``` for AUFS to work.
## ImageTrove

Clone the imagetrove and MyTARDIS repositories:

    git clone https://github.com/carlohamalainen/imagetrove
    cd imagetrove
    git clone git://github.com/carlohamalainen/mytardis.git # current dev fork; later will be git://github.com/mytardis/mytardis.git

## Configuration

### Local settings

Look for ```CHANGEME``` in ```create_admin.py```, ```postgresql_first_run.sh```, ```settings.py```, and ```imagetrove_uploader.conf```.

### AAF authentication

To use AAF authentication you must register your service at https://rapid.aaf.edu.au
For the purposes of testing you can use a plain ```http``` callback URL, but for production
you need a ```https``` callback.

TODO Configuration of SSL certificates in the container.

The callback URL is at ```/rc```, so in the test federation use

    RAPID_CONNECT_CONFIG['aud'] = 'http://imagetrove.example.com/rc/'

and in production,

    RAPID_CONNECT_CONFIG['aud'] = 'https://imagetrove.example.com/rc/'

### Shell access

To get a shell in a running container, use ```docker exec```:

    sudo docker exec -it <hash> bash

where ```<hash>``` is the value in the first column of output given by ```docker ps```.

Alternatively, do it in one line with:

    sudo docker exec -it `sudo docker ps | grep 'user/imagetrove:latest' | awk '{print $1}'` bash

### DICOM modalities

Each instrument must be specified in [imagetrove_uploader.conf](imagetrove_uploader.conf).

The fields in each instrument block are:

* ```instrument```: list of name/value pairs used to identify a DICOM dataset as belonging to this instrument.
* ```experiment_title```: list of DICOM fields that will be used to construct the experiment title for the corresponding MyTARDIS experiment.
* ```dataset_title```: list of DICOM fields that will be used to construct the dataset name for the corresponding MyTARDIS dataset.
* ```default_institution_name```: institution name to be used if the DICOM field ```InstitutionName``` is missing.
* ```default_institutional_department_name```:  department name to be uesd if the DICOM field ```InstitutionalDepartmentName``` is missing.
* ```default_institutional_address```: institutional address to be used if the DICOM field ```InstitutionAddress``` is missing.
* ```schema_experiment```: URL-style identifier for the MyTARDIS experiment schema, e.g. ```http://cai.edu.au/schema/1```
* ```schema_dataset```:    URL-style identifier for the MyTARDIS dataset schema, e.g. ```http://cai.edu.au/schema/2```
* ```schema_file```:       URL-style identifier for the MyTARDIS file schema, e.g. ```http://cai.edu.au/schema/3```

Correspondingly, each instrument needs to know the address of the
ImageTrove DICOM server, which is a ```STORESCP``` server. By
default this will be ```imagetrove.example.com:4242``` where ```imagetrove.example.com```
is the main ImageTrove instance.

### Network access

Each instrument's DICOM server needs to be able to connect to the
ImageTrove STORESCP server on port 4242.

### Securing Orthanc

To secure DICOM transmission from an instrument to Orthanc,
use [stunnel](https://www.stunnel.org/index.html). The Docker container
has stunnel configured to pass SSL traffic from port 5242 to the unencrypted
local port 4242. If you use this option, you should not expose port
4242 when running Docker (i.e. drop the port specification
```-p 0.0.0.0:4242:4242``` from the ```docker run``` command).

On the instrument's DICOM server, install stunnel in client mode by editing
```/etc/stunnel/stunnel.conf``` as follows:

    client = yes

    [dicom]
    accept = localhost:4242
    connect = {ip}:5242

where ```{ip}``` is the IP address of the ImageTrove
instance. Configure the instrument's DICOM server to connect to port
4242 on the machine running stunnel.

TODO Add password access to web UI.

## Build the ImageTrove container

    sudo docker build -t='user/imagetrove' .

## Configure volumes

The container uses external volumes for persistent storage.

* ```imagetrove```: our shared storage location with MyTARDIS.
* ```mytardis_staging```: the MyTARDIS staging directory.
* ```mytardis_store```: the final place that MyTARDIS stores data.
* ```data```: postgresql database files.
* ```var_log```: logfiles for supervisord, postgresql, mytardis, etc.
* ```OrthancStorage```: storage for the Orthanc DICOM server.

Ideally ```imagetrove``` and ```OrthancStorage``` would be on the
same file system.

# Running ImageTrove

Create directories for the persistent storage:

    mkdir -p /somewhere/imagetrove          \
             /somewhere/mytardis_staging    \
             /somewhere/mytardis_store      \
             /somewhere/data                \
             /somewhere/var_log/supervisor  \
             /somewhere/OrthancStorage

Run the container:

    sudo docker run -i -t --rm                              \
        -p 0.0.0.0:3022:22                                  \
        -p 0.0.0.0:8000:8000                                \
        -p 0.0.0.0:8042:8042                                \
        -p 0.0.0.0:4242:4242                                \
        -p 0.0.0.0:5242:5242                                \
        -v /somewhere/imagetrove:/imagetrove                \
        -v /somewhere/mytardis_staging:/mytardis_staging    \
        -v /somewhere/mytardis_store:/mytardis_store        \
        -v /somewhere/data:/data                            \
        -v /somewhere/var_log:/var/log                      \
        -v /somewhere/OrthancStorage:/OrthancStorage        \
        -P user/imagetrove

Now go to http://localhost:8000 and you should see the default MyTARDIS front page.

# Testing

## Log in: admin

    TODO

## Log in: AAF

    TODO

## Push dataset to ImageTrove

For testing, manually push some DICOM files to the local Orthanc server:

    sudo apt-get install python-httplib2
    ./import_into_orthanc.py localhost 8042 /path/to/dicom/files

Check the files in Orthanc's web interface, which runs at http://localhost:8042

    TODO

## Check ingested dataset

    TODO

## Log files

    TODO

# Data flow

* Define interaction of user-ACL utility and pre-existing projects:
experiment imported before project has been defined?

# TODO

* Required DICOM fields - list from Orthanc docs.
* File mount ingestion
* Configure ingestion application
* Apache or Nginx instead of django-runserver.
* How to use command line interface.
