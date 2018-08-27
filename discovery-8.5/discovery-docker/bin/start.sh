#!/bin/sh

# Java options and system properties to pass to the JVM when starting the service. For example:
# JVM_OPTIONS="-Xrs -Xms256m -Xmx512m -Dmy.system.property=/var/share"
JVM_OPTIONS="-Xrs -Xms256m -Xmx512m"
SERVER_PORT=--server.port=8082

BASEDIR=$(dirname $0)
CLASS_PATH=.:config:bin:lib/*
CLASS_NAME="com.sdl.delivery.service.ServiceContainer"
PID_FILE="sdl-service-container.pid"

cd $BASEDIR/..

ARGUMENTS=()
for ARG in $@
do
    if [[ $ARG == --server\.port=* ]]
    then
        SERVER_PORT=$ARG
    else
        ARGUMENTS+=($ARG)
    fi
done
ARGUMENTS+=($SERVER_PORT)

for SERVICE_DIR in `find services -type d`
do
    CLASS_PATH=$SERVICE_DIR:$SERVICE_DIR/*:$CLASS_PATH
done

echo "Starting service."

java -cp $CLASS_PATH $JVM_OPTIONS $CLASS_NAME ${ARGUMENTS[@]}
