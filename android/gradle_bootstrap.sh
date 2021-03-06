#!/bin/sh

if ! which jq > /dev/null 2>&1; then
    echo "This script depends on https://stedolan.github.io/jq/."
    echo "Please put the 'jq' executable into your PATH."
    exit 1
fi

current=$(curl -s https://services.gradle.org/versions/current)

version=$(echo $current | jq -r '.version')
echo "The most current Gradle version is $version."

dist=$(ls -d ~/.gradle/wrapper/dists/gradle-$version-*/*/gradle-$version 2> /dev/null)
if [ $? -eq 0 ]; then
    dist=$(echo "$dist" | head -1)
    echo "Found version in cache at $dist."
    gradle=$dist/bin/gradle
else
    url=$(echo $current | jq -r '.downloadUrl')
    echo "Downloading version from $url."
    zip=$(mktemp --suffix .zip)
    curl -o $zip -L -s $url
    unzip -o -q $zip -d /tmp
    gradle=/tmp/gradle-$version/bin/gradle
fi

$gradle wrapper --gradle-version $version

if [ -f "$zip" ]; then
    rm -r $zip /tmp/gradle-$version
fi
