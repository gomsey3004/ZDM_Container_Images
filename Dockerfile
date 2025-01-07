# ------------------------------------------------------------------------------
# Dockerfile to build Zero Downtime Migration Image
# Based on the following:
#   - Oracle Linux 7
#   - Oracle ZDM
# Example build and run.
#
# docker build -t zdm21.4:latest --build-arg INSTALLER= V1037236-01.zip .
# docker build --squash -t zdm21.4:latest --build-arg INSTALLER= V1037236-01.zip .
#
# Non-persistent storage.
# docker run -dit --name zdm21.4_con -p 1521:1521 -p 5500:5500 --shm-size="1G" zdm21.4:latest
#
# Persistent storage.
# docker run -dit --name zdm21.4_con -p 1521:1521 -p 5500:5500 --shm-size="1G" -v /u01/volumes/zdm21.4_con_u02/:/u02 zdm21.4:latest
#
# Persistent storage and part of Docker network called "my_network".
# docker run -dit --name zdm21.4_con -p 1521:1521 -p 5500:5500 --shm-size="1G" --network=my_network -v /u01/volumes/zdm21.4_con_u02/:/u02 zdm21.4:latest
#
# docker logs --follow zdm21.4_con
# docker exec -it zdm21.4_con bash
#
# docker stop --time=30 zdm21.4_con
# docker start zdm21.4_con
#
# docker rm -vf zdm21.4_con
#
# ------------------------------------------------------------------------------


# Set the base image to Oracle Linux 7
FROM oraclelinux:7

# File Author / Maintainer
# Use LABEL rather than deprecated MAINTAINER
LABEL maintainer="goutam.pal@oracle.com"

# ------------------------------------------------------------------------------
# Define fixed (build time) environment variables.
ENV ZDM_BASE=/u01/app/oracle/base                                               \
 ZDM_HOME=/u01/app/oracle/grid                          \
    SOFTWARE_DIR=/u01/software                                                 

# Separate ENV call to allow existing variables to be referenced.
ENV PATH=${ZDM_HOME}/bin:${PATH}


# ------------------------------------------------------------------------------
# Get all the files for the build.
ARG           INSTALLER
RUN           : ${INSTALLER:?}
COPY ${INSTALLER} ${SOFTWARE_DIR}/installer.zip


# ------------------------------------------------------------------------------
# Unpack all the software and remove the media.
# No config done in the build phase.
#
# Manually create user and group as preinstall package creates the with
# high IDs, which causes issues. Note 2 on link below.
# https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#user
#
        
RUN yum -y install oraclelinux-developer-release-el7 libnsl perl unzip glibc-devel expect libaio ncurses-compat-libs ncurses-devel numactl-libs openssl mlocate bind-utils && \
    groupadd zdm -g 1001                                                    && \
    useradd zdmuser -g 1001       && \
    yum -y update                                                           && \
    rm -Rf /var/cache/yum                                                   && \
        mkdir -p ${ZDM_HOME} ${ZDM_BASE}             && \
    chown -R zdmuser:zdm /u01

# Set "ZDM" as hostname for certificates to work
RUN echo "echo zdm" > /bin/hostname     &&\ 
chown -R zdmuser:zdm /bin/hostname  
# Perform the following actions as the zdmuser user
USER zdmuser

# Unzip software
RUN cd ${SOFTWARE_DIR}                                                      && \
    unzip -oq installer.zip                                               && \
    rm -f installer.zip       && \
#    cat /bin/hostname   && \
    chmod 777 /bin/hostname  && \
# Do ZDM installation
sh ${SOFTWARE_DIR}/zdm*/zdminstall.sh setup oraclehome=${ZDM_HOME} \
oraclebase=${ZDM_BASE} \
ziploc=${SOFTWARE_DIR}/zdm*/zdm_home.zip -zdm

# Remove source software
RUN rm -Rf ${SOFTWARE_DIR}/zdm*


# Start ZDM service
 WORKDIR /u01
CMD zdmservice start;tail -f /dev/null
HEALTHCHECK --start-period=90s --retries=1 --interval=30s \
CMD zdmservice status

#End

