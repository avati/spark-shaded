#!/bin/bash

set -e

VER="0.0.7"
SFX="-spark"
PRJ=zeromq-scala-binding
URL=git://github.com/valotrading/${PRJ}
CID=92f845d7311ca7c819bfacb9d26cd47779b77c2b

SCALA_211="2.11.0"

function main() {
    [ -d ${PRJ} ] || git clone ${URL} ${PRJ}
    cd ${PRJ}
    git reset --hard;
    git checkout ${CID}

    sed -i -e 's/org.zeromq/org.spark-project.zeromq/g' build.sbt
    sed -i -e "s/0.0.8-SNAPSHOT/${VER}${SFX}/g" build.sbt
    sed -i -e '/scalaBinaryVersion/d' build.sbt
    sed -i -e 's/.*scalaVersion.*/scalaVersion := System.getProperty("zeromq.scalaVersion", "2.10.4")/g' build.sbt
    sed -i -e 's/.*scalatest.*/"org.scalatest" %% "scalatest" % "2.1.3" % "test"/g' build.sbt

    export SBT_OPTS=-XX:MaxPermSize=256M
    sbt compile publish-m2
    sbt -Dzeromq.scalaVersion=$SCALA_211 compile publish-m2
}

main "$@"
