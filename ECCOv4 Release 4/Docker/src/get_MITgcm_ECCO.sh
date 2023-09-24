#!/bin/sh

## Clone ECCO config files
cd $USER_HOME_DIR
git clone --depth 1 https://github.com/ECCO-GROUP/ECCO-v4-Configurations.git

## checkout the MITgcm
git clone --depth 1 https://github.com/MITgcm/MITgcm.git -b checkpoint66g

## Copy V4r4 config files to build directory
mkdir -p $USER_HOME_DIR/ECCOV4/release4
cp -r "ECCO-v4-Configurations/ECCOv4 Release 4/code/" $USER_HOME_DIR/ECCOV4/release4/code
cp -r "ECCO-v4-Configurations/ECCOv4 Release 4/namelist/" $USER_HOME_DIR/ECCOV4/release4/namelist

#cp ${USER_HOME_DIR}/docker_src/SIZE* $USER_HOME_DIR/ECCOV4/release/code

## build the model

cd $USER_HOME_DIR/ECCOV4/release4/code
mv SIZE.h SIZE.h_96

cp ${USER_HOME_DIR}/docker_src/SIZE* .

cd $USER_HOME_DIR/ECCOV4/release4
mkdir build
cd build

echo "Choose or create a SIZE.h file before compiling"

#$ROOTDIR/tools/genmake2 -mods=../code optfile=$USER_HOME_DIR/docker_src/linux_amd64_gfortran

#make -j depend
#make -j 

