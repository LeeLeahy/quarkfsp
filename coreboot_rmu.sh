#!/bin/bash
#
EDK2_NON_OSI_DIR=$1
COREBOOT_DIR=$2

#
# Create the necessary directories
#
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

cp $EDK2_NON_OSI_DIR/QuarkSocBinPkg/QuarkNorthCluster/Binary/QuarkMicrocode/RMU.bin $COREBOOT_DIR/3rdparty/blobs/soc/intel/quark/rmu.bin
