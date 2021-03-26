#!/usr/local/bin/dumb-init /bin/bash

# Environment variables:
# APACHEDS_VERSION
# APACHEDS_INSTANCE
# APACHEDS_BOOTSTRAP
# APACHEDS_DATA
# APACHEDS_USER
# APACHEDS_GROUP

APACHEDS_INSTANCE_DIRECTORY=${APACHEDS_DATA}/${APACHEDS_INSTANCE}
PIDFILE="${APACHEDS_INSTANCE_DIRECTORY}/run/apacheds-${APACHEDS_INSTANCE}.pid"

wait_for_ldap() {
    CURL_RESULT=7;
    while [[ "$CURL_RESULT" != "0" ]]; do
      echo 'Waiting for Apache DS server to boot up';
      curl http://localhost:10389 &>/dev/null;
      CURL_RESULT=$?;
      sleep 1;
    done;
}

# When a fresh data folder is detected then bootstrap the instance configuration.
if [ ! -d ${APACHEDS_INSTANCE_DIRECTORY} ]; then
    mkdir ${APACHEDS_INSTANCE_DIRECTORY};
    cp -rv ${APACHEDS_BOOTSTRAP}/* ${APACHEDS_INSTANCE_DIRECTORY};
    chown -v -R ${APACHEDS_USER}:${APACHEDS_GROUP} ${APACHEDS_INSTANCE_DIRECTORY};
    /opt/apacheds-${APACHEDS_VERSION}/bin/apacheds start ${APACHEDS_INSTANCE};
    wait_for_ldap;
    /usr/bin/initialize || exit 1;
    /opt/apacheds-${APACHEDS_VERSION}/bin/apacheds stop ${APACHEDS_INSTANCE};
fi

cleanup(){
    if [ -e "${PIDFILE}" ];
    then
        echo "Cleaning up ${PIDFILE}"
        rm "${PIDFILE}"
    fi
}

trap cleanup EXIT
cleanup

/opt/apacheds-${APACHEDS_VERSION}/bin/apacheds start ${APACHEDS_INSTANCE}
wait_for_ldap;

shutdown(){
    echo "Shutting down..."
    /opt/apacheds-${APACHEDS_VERSION}/bin/apacheds stop ${APACHEDS_INSTANCE}
}

trap shutdown INT TERM
echo 'Apache DS was started...';
tail -n 0 --pid=$(cat $PIDFILE) -f ${APACHEDS_INSTANCE_DIRECTORY}/log/apacheds.log
