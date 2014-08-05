#!/bin/bash

set -e

VER="2.3.4"
SFX="-spark"
PRJ=akka
URL=git://github.com/akka/${PRJ}

PBVER="2.5.0"

SCALA_211="2.11.0"

SBT_ARGS="-Dakka.build.useLocalMavenResolver=true -Dakka.scaladoc.diagrams=false -Dakka.scaladoc.autoapi=false -Dakka.test.multi-node=false -Dakka.build.scalaZeroMQVersion=0.0.7${SFX}"

function main() {
    [ -d ${PRJ} ] || git clone ${URL} ${PRJ}
    cd ${PRJ}
    git reset --hard;
    git checkout v${VER}
    rm -rf akka-multi-node-testkit akka-samples

    grep -lrF com.google.protobuf . | grep -v 'project/' | xargs sed -i -e 's/com.google.protobuf/org.spark_project.protobuf/g'
    sed -i -e 's/com.google.protobuf/org.spark-project.protobuf/g' project/*.scala
    sed -i -e 's/org.zeromq/org.spark-project.zeromq/g' project/*.scala
    sed -i -e "s/\(.*\)protobuf-java\(.*\)${PBVER}\(.*\)/\1protobuf-java\2${PBVER}${SFX}\3/g" project/*.scala
    sed -i -e "s/\(.*\)organization\(.*\)com.typesafe.akka\(.*\)/\1organization\2org.spark-project.akka\3/g" project/*.scala
    sed -i -e "s/\(.*\)version\(.*\)${VER}\(.*\)/\1version\2${VER}${SFX}\3/g" project/*.scala

    export SBT_OPTS=-XX:MaxPermSize=256M
    sbt $SBT_ARGS compile publish-m2
    sbt -Dakka.scalaVersion=$SCALA_211 $SBT_ARGS compile publish-m2
}

main "$@"
