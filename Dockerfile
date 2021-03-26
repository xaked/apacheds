FROM ubuntu:18.04
LABEL MAINTAINER="u@xaked.com"\
      APACHEDS_VERSION="2.0.0.AM26"\
      ARCH="amd64"\
      OS="ubuntu"\
      OS_VERSION="18.04"

#############################################
# ApacheDS installation
#############################################

ENV APACHEDS_VERSION=2.0.0.AM26\
 APACHEDS_ARCH=amd64

ENV APACHEDS_ARCHIVE=apacheds-${APACHEDS_VERSION}-${APACHEDS_ARCH}.deb\
 APACHEDS_DATA=/var/lib/apacheds\
 APACHEDS_USER=apacheds\
 APACHEDS_GROUP=apacheds

RUN ln -s ${APACHEDS_DATA}-${APACHEDS_VERSION} ${APACHEDS_DATA}
VOLUME ${APACHEDS_DATA}

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get update \
    && apt-get install -y \
       apt-utils

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get install -y \
       ldap-utils \
       procps \
       openjdk-11-jre-headless \
       curl \
       jq \
    && curl https://downloads.apache.org/directory/apacheds/dist/${APACHEDS_VERSION}/${APACHEDS_ARCHIVE} > ${APACHEDS_ARCHIVE} \
    && dpkg -i ${APACHEDS_ARCHIVE} \
    && rm ${APACHEDS_ARCHIVE}

# Ports defined by the default instance configuration:
# 10389: ldap
# 10636: ldaps
# 60088: kerberos
# 60464: changePasswordServer
# 8080: http
# 8443: https
EXPOSE 10389 10636

#############################################
# ApacheDS bootstrap configuration
#############################################

ENV APACHEDS_INSTANCE=default\
 APACHEDS_BOOTSTRAP=/bootstrap

ADD scripts/run.sh /run.sh
RUN chown ${APACHEDS_USER}:${APACHEDS_GROUP} /run.sh \
    && chmod u+rx /run.sh

ADD instance/* ${APACHEDS_BOOTSTRAP}/conf/
RUN sed -i "s/ads-contextentry:: [A-Za-z0-9\+\=\/]*/ads-contextentry:: $(base64 -w 0 $APACHEDS_BOOTSTRAP/conf/ads-contextentry.decoded)/g" /$APACHEDS_BOOTSTRAP/conf/config.ldif
ADD base.ldif ${APACHEDS_BOOTSTRAP}/
COPY bin/* /usr/bin/
RUN mkdir ${APACHEDS_BOOTSTRAP}/cache \
    && mkdir ${APACHEDS_BOOTSTRAP}/run \
    && mkdir ${APACHEDS_BOOTSTRAP}/log \
    && mkdir ${APACHEDS_BOOTSTRAP}/partitions \
    && touch /var/log/journal.log\
    && chown -R ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_BOOTSTRAP}\
    && chown -R ${APACHEDS_USER}:${APACHEDS_GROUP} /var/log/journal.log\
    && chmod u+rw /usr/bin/*

RUN apt-get install -y python-ldap

#############################################
# ApacheDS wrapper command
#############################################

# Correct for hard-coded INSTANCES_DIRECTORY variable
RUN sed -i "s#/var/lib/apacheds-${APACHEDS_VERSION}#/var/lib/apacheds#" /opt/apacheds-${APACHEDS_VERSION}/bin/apacheds


RUN curl -L -o /usr/local/bin/dumb-init \
    https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod +x /usr/local/bin/dumb-init

ENTRYPOINT ["/run.sh"]
