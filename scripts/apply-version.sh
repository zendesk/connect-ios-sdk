#!/usr/bin/env bash

sed -Ei '' "s/[0-9]\.[0-9]\.[0-9](-SNAPSHOT)?/${ZEN_SDK_VERSION}/g" $ZEN_SDK_VERSION_FILE $ZEN_SDK_PODSPEC_FILE
