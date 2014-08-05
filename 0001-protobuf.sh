#!/bin/bash

set -e

VER="2.5.0"
PKG=protobuf-${VER}
TGZ=${PKG}.tar.gz
URL=https://protobuf.googlecode.com/files/${TGZ}

SHASUM=7f6ea7bc1382202fb1ce8c6933f1ef8fea0c0148

function SHA() {
    if shasum --version >/dev/null 2>&1 ; then
	shasum "$@" | cut -f1 -d' '
    elif sha1sum --version >/dev/null 2>&1 ; then
	sha1sum "$@" | cut -f1 -d' '
    else
	# force fail
	echo "0"
    fi
    return
}

function main() {
    rm -rf ${PKG}
    rm -rf ${TGZ}
    wget ${URL}
    if [ $(SHA ${TGZ}) != ${SHASUM} ]; then
	echo "SHA checksum mismatch ${SHASUM} vs $(SHA ${TGZ})"
	exit 1
    fi
    tar xzf ${TGZ}
    cd ${PKG}
    grep -lrF com.google.protobuf src/ \
	| grep -vF ".pb.cc" \
	| xargs sed -i -e 's/com\.google\.protobuf/org.spark_project.protobuf/g'
    grep -lrF com.google.protobuf java/src/{main,test}/ \
	| xargs sed -i -e 's/com\.google\.protobuf/org.spark_project.protobuf/g'
    grep -lrF com.google.protobuf java/src/test/ \
	| xargs sed -i -e 's/package org.spark_project.protobuf;/package org.spark_project.org;\
import com.google.protobuf.*;/g'
    sed -i -e "s#com\.google\.protobuf#org\.spark-project\.protobuf#g" java/pom.xml
    sed -i -e "s#<version>${VER}</version>#<version>${VER}-spark</version>#g" java/pom.xml
    mv java/src/main/java/com/google java/src/main/java/com/spark_project
    mv java/src/main/java/com java/src/main/java/org
    ./configure --quiet
    make --quiet
    cd java
    mvn -DskipTests install package
}

main "$@"
