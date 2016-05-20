#!/bin/bash
#
EDK2_DIR=$1
COREBOOT_DIR=$2
BUILD_TYPE=$3

#
# Create the necessary directories
#
if [ ! -e $COREBOOT_DIR/src/vendorcode/intel/fsp/ ]
then
  mkdir $COREBOOT_DIR/src/vendorcode/intel/fsp/
fi
if [ ! -e $COREBOOT_DIR/src/vendorcode/intel/fsp/fsp1_1/ ]
then
  mkdir $COREBOOT_DIR/src/vendorcode/intel/fsp/fsp1_1/
fi
if [ ! -e $COREBOOT_DIR/src/vendorcode/intel/fsp/fsp1_1/quark/ ]
then
  mkdir $COREBOOT_DIR/src/vendorcode/intel/fsp/fsp1_1/quark/
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

cp $EDK2_DIR/QuarkFspBinPkg/FspUpdVpd.h $COREBOOT_DIR/src/vendorcode/intel/fsp/fsp1_1/quark/FspUpdVpd.h
cp $EDK2_DIR/QuarkFspBinPkg/$BUILD_TYPE/fsp.bin $COREBOOT_DIR/3rdparty/blobs/soc/intel/quark/fsp.bin
