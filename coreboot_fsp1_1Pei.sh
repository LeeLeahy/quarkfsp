#!/bin/bash
#
EDK2_DIR=$1
COREBOOT_DIR=$2
EDK2_BUILD_TYPE=$3

COREBOOT_BUILD_TYPE=$EDK2_BUILD_TYPE
COREBOOT_FSP_VERSION_DIR=fsp1_1
EDK2_FSP_SUB_DIR=Fsp1_1Pei
COREBOOT_FSP_SUB_DIR=$EDK2_FSP_SUB_DIR
SOC_TYPE=quark
COREBOOT_INCLUDE_DIR=$COREBOOT_DIR/src/vendorcode/intel/fsp/$COREBOOT_FSP_VERSION_DIR/$SOC_TYPE
COREBOOT_FSP_DIR=$COREBOOT_DIR/3rdparty/blobs/soc/intel/$SOC_TYPE/$COREBOOT_FSP_SUB_DIR/$COREBOOT_BUILD_TYPE

#
# Create the necessary directories
#
if [ ! -e $COREBOOT_DIR/src/vendorcode/intel/fsp/ ]
then
  mkdir $COREBOOT_DIR/src/vendorcode/intel/fsp/
fi
if [ ! -e $COREBOOT_DIR/src/vendorcode/intel/fsp/$COREBOOT_FSP_VERSION_DIR/ ]
then
  mkdir $COREBOOT_DIR/src/vendorcode/intel/fsp/$COREBOOT_FSP_VERSION_DIR/
fi
if [ ! -e $COREBOOT_DIR/src/vendorcode/intel/fsp/$COREBOOT_FSP_VERSION_DIR/$SOC_TYPE/ ]
then
  mkdir $COREBOOT_DIR/src/vendorcode/intel/fsp/$COREBOOT_FSP_VERSION_DIR/$SOC_TYPE/
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
if [ ! -e $COREBOOT_DIR/3rdparty/blobs/soc/intel/$SOC_TYPE/ ]
then
  mkdir $COREBOOT_DIR/3rdparty/blobs/soc/intel/$SOC_TYPE/
fi
if [ ! -e $COREBOOT_DIR/3rdparty/blobs/soc/intel/$SOC_TYPE/$COREBOOT_FSP_SUB_DIR/ ]
then
  mkdir $COREBOOT_DIR/3rdparty/blobs/soc/intel/$SOC_TYPE/$COREBOOT_FSP_SUB_DIR/
fi
if [ ! -e $COREBOOT_DIR/3rdparty/blobs/soc/intel/$SOC_TYPE/$COREBOOT_FSP_SUB_DIR/$COREBOOT_BUILD_TYPE/ ]
then
  mkdir $COREBOOT_DIR/3rdparty/blobs/soc/intel/$SOC_TYPE/$COREBOOT_FSP_SUB_DIR/$COREBOOT_BUILD_TYPE/
fi

#
# Copy the files
#
cp $EDK2_DIR/QuarkFspBinPkg/$EDK2_FSP_SUB_DIR/Include/*.h $COREBOOT_INCLUDE_DIR/
cp $EDK2_DIR/QuarkFspBinPkg/$EDK2_FSP_SUB_DIR/$EDK2_BUILD_TYPE/*.fd $COREBOOT_FSP_DIR/

#
# Display the files
#
echo $COREBOOT_INCLUDE_DIR
ls -l $COREBOOT_INCLUDE_DIR
echo $COREBOOT_FSP_DIR
ls -l $COREBOOT_FSP_DIR
