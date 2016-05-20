#!/bin/bash
#

EDK2_DIR=$1
COREBOOT_DIR=$2
BUILD_TYPE=$3

#
# Create the necessary directories
#
if [ ! -e src/soc/intel/quark/include/soc/fsp ]
  then mkdir src/soc/intel/quark/include/soc/fsp
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

pushd $COREBOOT_DIR/src/drivers/intel/fsp2_0/header_util/
chmod +x fspupdvpd_sanitize.sh
cp   $EDK2_DIR/QuarkFsp2_0BinPkg/Include/FspmUpd.h   ../../../../soc/intel/quark/include/soc/fsp/FspmUpd.h
./fspupdvpd_sanitize.sh   ../../../../soc/intel/quark/include/soc/fsp/FspmUpd.h > /dev/null
echo FspmUpd.h - Updated
cp   $EDK2_DIR/QuarkFsp2_0BinPkg/Include/FspsUpd.h   ../../../../soc/intel/quark/include/soc/fsp/FspsUpd.h
./fspupdvpd_sanitize.sh   ../../../../soc/intel/quark/include/soc/fsp/FspsUpd.h > /dev/null
echo FspsUpd.h - Updated
cp   $EDK2_DIR/QuarkFsp2_0BinPkg/Include/FsptUpd.h   ../../../../soc/intel/quark/include/soc/fsp/FsptUpd.h
./fspupdvpd_sanitize.sh   ../../../../soc/intel/quark/include/soc/fsp/FsptUpd.h > /dev/null
echo FsptUpd.h - Updated
cp   $EDK2_DIR/QuarkFsp2_0BinPkg/Include/FspUpd.h   ../../../../soc/intel/quark/include/soc/fsp/FspUpd.h
./fspupdvpd_sanitize.sh   ../../../../soc/intel/quark/include/soc/fsp/FspUpd.h > /dev/null
echo FspUpd.h  - Updated
popd
cp $EDK2_DIR/QuarkFsp2_0BinPkg/$BUILD_TYPE/*.fd $COREBOOT_DIR/3rdparty/blobs/soc/intel/quark/
