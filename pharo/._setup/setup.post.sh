#!/bin/bash

cd ~/install
curl -o pharo-launcher.zip -L https://files.pharo.org/pharo-launcher/linux64
unzip pharo-launcher.zip
hub-install-bin.sh pharo-launcher
