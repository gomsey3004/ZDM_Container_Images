# Oracle Zero Downtime Migration Container Images 

Sample container image build files to provide an installation of Oracle Zero Downtime Migration tool for DevOps users. These instructions apply to building container images for Oracle ZDM 21.4


## Before You Start

This project was tested with:

- Oracle ZDM 21.4 for Oracle on Linux x86-64

**IMPORTANT:** You must download the installation binaries of Oracle ZDM. You only need to provide the binaries for the version you plan to install. The binaries can be downloaded from the <https://www.oracle.com/database/technologies/rac/zdm-downloads.html> . Do not decompress the Oracle ZDM ZIP file. The container build process will handle that for you. You also must have Internet connectivity when building the container image for the package manager to perform additional software installations.

All shell commands in this document assume the usage of Bash shell.

For more information about Oracle ZDM please see the <https://docs.oracle.com/en/database/oracle/zero-downtime-migration/21.4>

## Build an Oracle ZDM Container Image

Once you have downloaded the Oracle ZDM software, a container image can be created using container management command-line applications. A single --build-arg is needed to indicate the ZDM installer which was downloaded.

To create a container image for ZDM for Oracle Database, use the following script:
```
$ docker build --tag=ZDMIMAGE:21.4 \
--build-arg INSTALLER= V1037236-01.zip .
```
> Sending build context to Docker daemon
> ...
> Successfully tagged ZDMIMAGE:21.4


## Running Oracle ZDM in a Container

Use the docker run command to create and start a container from the Oracle ZDM container image.
```
$ docker run \
-h zdm \
-dit \
--restart always \
--name <container name> \
ZDMIMAGE:21.4
```
Parameters:

- &lt;container name&gt; - A name for the new container (default: auto generated)
- \-h zdm - Specifies a hostname for the container. **DO NOT CHANGE/OMMIT.**
- \-dit - Is used to run a container interactively, but it can also be used to run a container "detached" (-d) (in the background) for situations where the container's process expects a TTY (-t) to be attached to keep running.
- \--restart always - Always restart the container regardless of the exit status.

## Verify ZDM service status:

The status of ZDM can be monitored with this command:
```
$ docker exec -it <container_name> /bin/sh -c "zdmservice status"
```
## Running the ZDM Client:

Login to the ZDM container and use the zdmcli tool to perform database migration
```
$ docker exec -it <container_name> bash
```
Refer to the migration document:

[Start a Migration Job](https://www.oracle.com/pls/topic/lookup?ctx=en/database/oracle/zero-downtime-migration/21.5&id=ZDMUG-GUID-C20DB7D4-E0CE-4B50-99D0-B16C18DDD34B)


