#!/bin/bash

checkout $DOTFILES_REPO $DOTFILES_DIR 
git submodule init
git submodule update

#TODO: move me to arduino ability
#elegoo_version=V2.0.2020.8.21
#wget https://www.elegoo.com/tutorial/Elegoo%20The%20Most%20Complete%20Starter%20Kit%20for%20UNO%20$elegoo_version.zip 
#unzip Elegoo\ The\ Most\ Complete\ Starter\ Kit\ for\ UNO\ $elegoo_version.zip
#mv Elegoo\ The\ Most\ Complete\ Starter\ Kit\ for\ UNO\ $elegoo_version/ uno-$elegoo_version
#cd uno-$elegoo_version && rm -rf French Italian Spanish German Japan
#cd .. && rm *.zip
