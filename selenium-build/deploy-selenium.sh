#!/usr/bin/env bash

if [ "$1" == "" ]; then echo "Missing 1st argument - artifacts version"; exit 1; fi
if [ "$2" == "" ]; then echo "Missing 2nd argument - local maven repository folder"; exit 1; fi

VERSION="$1"
pushd "$2/org/seleniumhq/selenium"
GROUPID="org.seleniumhq.selenium"
REPO_URL=https://artifactory.propelmedia.com/artifactory/libs-release-local
DEPLOY_ARGS="deploy:deploy-file -DrepositoryId=afrepo-release -Durl=${REPO_URL} -DgroupId=${GROUPID} -Dversion=${VERSION}"

function deploy() {
    local artifactId=$1
    local FILEBASE=${artifactId}/${VERSION}/${artifactId}-${VERSION}
    ls ${FILEBASE}.jar ${FILEBASE}.pom
    mvn ${DEPLOY_ARGS} -DartifactId=${artifactId} -Dpackaging=jar -Dfile=${FILEBASE}.jar -DpomFile=${FILEBASE}.pom
    mvn ${DEPLOY_ARGS} -DartifactId=${artifactId} -Dpackaging=jar -Dclassifier=javadoc -Dfile=${FILEBASE}-javadoc.jar -DpomFile=${FILEBASE}-javadoc.pom
    mvn ${DEPLOY_ARGS} -DartifactId=${artifactId} -Dpackaging=jar -Dclassifier=sources -Dfile=${FILEBASE}-sources.jar -DpomFile=${FILEBASE}-sources.pom
}

deploy lift
deploy selenium-api
deploy selenium-chrome-driver
deploy selenium-edge-driver
deploy selenium-firefox-driver
deploy selenium-ie-driver
deploy selenium-java
deploy selenium-leg-rc
deploy selenium-opera-driver
deploy selenium-remote-driver
deploy selenium-safari-driver
deploy selenium-server
deploy selenium-support

popd
