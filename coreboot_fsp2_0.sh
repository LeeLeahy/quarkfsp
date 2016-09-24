#!/bin/bash
#

EDK2_DIR=$1
COREBOOT_DIR=$2
BUILD_TYPE=$3

pushd $EDK2_DIR
EDK2_DIR=$PWD
popd

#
# Create the necessary directories
#
if [ ! -e $COREBOOT_DIR/src/soc/intel/quark/include/soc/fsp ]
  then mkdir $COREBOOT_DIR/src/soc/intel/quark/include/soc/fsp
fi

if [ ! -e $COREBOOT_DIR/3rdparty/ ]
then
  mkdir $COREBOOT_DIR/3rdparty/
fi
if [ ! -e $COREBOOT_DIR/3rdparty/blobs/ ]
then
  mkdir $COREBOOT_DIR/3rdparty/blobs/
fi
if [ ! -e $COREBOOT_DIR/3rdparty/blobs/soc/ ]
then
  mkdir $COREBOOT_DIR/3rdparty/blobs/soc/
fi
if [ ! -e $COREBOOT_DIR/3rdparty/blobs/soc/intel/ ]
then
  mkdir $COREBOOT_DIR/3rdparty/blobs/soc/intel/
fi
if [ ! -e $COREBOOT_DIR/3rdparty/blobs/soc/intel/quark/ ]
then
  mkdir $COREBOOT_DIR/3rdparty/blobs/soc/intel/quark/
fi

pushd $COREBOOT_DIR/src/soc/intel/quark/include/soc/fsp
cp   $EDK2_DIR/QuarkFsp2_0BinPkg/Include/FspmUpd.h   FspmUpd.h
cp   $EDK2_DIR/QuarkFsp2_0BinPkg/Include/FspsUpd.h   FspsUpd.h
cp   $EDK2_DIR/QuarkFsp2_0BinPkg/Include/FsptUpd.h   FsptUpd.h
cp   $EDK2_DIR/QuarkFsp2_0BinPkg/Include/FspUpd.h    FspUpd.h
popd
cp $EDK2_DIR/QuarkFsp2_0BinPkg/$BUILD_TYPE/*.fd $COREBOOT_DIR/3rdparty/blobs/soc/intel/quark/
