## @file
# @copyright
#  Copyright (c) 2008 - 2016, Intel Corporation All rights reserved
#  This software and associated documentation (if any) is furnished
#  under a license and may only be used or copied in accordance
#  with the terms of the license. Except as permitted by such
#  license, no part of this software or documentation may be
#  reproduced, stored in a retrieval system, or transmitted in any
#  form or by any means without the express written consent of
#  Intel Corporation.
#  This file contains an 'Intel Peripheral Driver' and is
#  licensed for Intel CPUs and chipsets under the terms of your
#  license agreement with Intel or your vendor.  This file may
#  be modified by the user, subject to additional terms of the
#  license agreement
##
#!/bin/sh

FSP_PACKAGE=QuarkFspPkg
FSP_BIN_PKG_NAME=QuarkFsp2_0BinPkg
PLATFORM_NAME=QuarkFsp2_0
FSP_PKG_CONF_NAME=QuarkFspPkgConfig
FSP_PKG_EXT_CONF_NAME=QuarkFspPkgExtConfig
TOOL_CHAIN=GCC48
Edksetup=edksetup.sh
FSP_T_UPD_GUID=34686CA3-34F9-4901-B82A-BA630F0714C6
FSP_M_UPD_GUID=39A250DB-E465-4DD1-A2AC-E2BD3C0E2385
FSP_S_UPD_GUID=CAE3605B-5B34-4C85-B3D7-27D54273C40F
ErrorCode=0
OUT_DIR=Build

export TOOL_CHAIN

function USAGE()
{
  echo
  echo  "$0 \[-h \| -? \| -r32 \| -tr32 \| -d32 \| -clean\]"
  echo
  return 1
}

function Clean(){
  echo Removing Build and Conf directories ...
  if [ -d Build ]
   then
    rm -r Build
  fi
  if [ -d Conf/.cache ]
    then
     rm  -r Conf/.cache
  fi
  if [ -f *.log ]
   then
    rm *.log
  fi
  WORKSPACE=
  EDK_TOOLS_PATH=
  return 0
}


function  PreBuildFail(){
  if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspUpd.h ]
   then
    rm  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspUpd.h
  fi
  if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FsptUpd.h ]
   then
    rm  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FsptUpd.h
  fi
  if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspmUpd.h ]
   then
    rm  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspmUpd.h
  fi
  if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspsUpd.h ]
   then
    rm  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspsUpd.h
  fi
  #/q /f
  return 0
}

function PreBuildRet(){
  set $1=0
  echo End of PreBuild ...
  echo
  return 0
}


function CopyBin(){
 if [ -f $1/*.efi ]
  then
   cp $1/*.efi   $2
   #/D /U /Y > NUL
 fi
 if [ -f $1/*.inf ]
   then
     cp $1/*.inf   $2
   #/D /U /Y > NUL
 fi
 if [ -f $1/*.depex ]
   then
    cp $1/*.depex $2
   #/D /U /Y > NUL
 fi
}

function PreBuild(){

  echo Generating UPD.TXT files

  echo ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/
  ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/
  python IntelFsp2Pkg/Tools/GenCfgOpt.py \
         UPDTXT \
         $FSP_PACKAGE/$PLATFORM_NAME.dsc \
         $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV \
         $FSP_PACKAGE/$FSP_PKG_CONF_NAME.dsc \
         $FSP_PACKAGE/$FSP_PKG_EXT_CONF_NAME.dsc \
         $BD_MACRO
  echo ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/
  ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/

  error=256
  if [ $? -eq $error ]
   then
    echo  DSC is not changed, no need to recreate MAP and BIN file
  else
    error=0
    if [ $? -ne $error ]
     then
      echo   error: $?
      return 1
    fi

    echo UPD TXT file was generated successfully !

    echo Remove the UPD.BIN and UPD.MAP files ...
    rm  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_T_UPD_GUID.bin \
            $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_T_UPD_GUID.map \
    #2>nul

    rm  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_M_UPD_GUID.bin \
            $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_M_UPD_GUID.map \
    #2>nul

    rm  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_S_UPD_GUID.bin \
            $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_S_UPD_GUID.map \
    #2>nul
    echo ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/
    ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/

    echo Generating FSP-T GUID .BIN and .MAP files
    BaseTools/BinWrappers/PosixLike/BPDG  \
           -o $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_T_UPD_GUID.bin  \
           -m $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_T_UPD_GUID.map  \
           $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_T_UPD_GUID.txt
    $bpdg_command

    if [ $? -eq "1" ]
     then
      return 1
    fi
    echo ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/
    ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/

    echo Generating FSP-M GUID .BIN and .MAP files
    BaseTools/BinWrappers/PosixLike/BPDG  \
           -o $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_M_UPD_GUID.bin  \
           -m $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_M_UPD_GUID.map  \
           $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_M_UPD_GUID.txt
    $bpdg_command

    if [ $? -eq "1" ]
     then
      return 1
    fi
    echo ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/
    ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/

    echo Generating FSP-S GUID .BIN and .MAP files
    BaseTools/BinWrappers/PosixLike/BPDG  \
           -o $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_S_UPD_GUID.bin  \
           -m $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_S_UPD_GUID.map  \
           $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/$FSP_S_UPD_GUID.txt
    $bpdg_command

    if [ $? -eq "1" ]
     then
      return 1
    fi
    echo ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/
    ls $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/
  fi

  touch $FSP_PACKAGE/Include/BootLoaderPlatformData.h
  python_command="python IntelFsp2Pkg/Tools/GenCfgOpt.py HEADER  $FSP_PACKAGE/$PLATFORM_NAME.dsc  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV  $FSP_PACKAGE/Include/BootLoaderPlatformData.h  $FSP_PACKAGE/$FSP_PKG_CONF_NAME.dsc  $FSP_PACKAGE/$FSP_PKG_EXT_CONF_NAME.dsc  $BD_MACRO"
  echo $python_command
  $python_command

  if [ $? -eq "256" ]
   then
    echo
    # No need to recreate header file
   else
    if [ $? -eq "1" ]
     then
      echo
    fi

    echo Vpd header file was generated successfully !

    echo Generate BSF File ...
    if [ -f $FSP_BIN_PKG_NAME/fsp.bsf ]
     then
      rm -f $FSP_BIN_PKG_NAME/fsp.bsf
    fi
    python_command="python IntelFsp2Pkg/Tools/GenCfgOpt.py GENBSF  $FSP_PACKAGE/$PLATFORM_NAME.dsc  $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV  $FSP_BIN_PKG_NAME/Fsp.bsf  $FSP_PACKAGE/$FSP_PKG_CONF_NAME.dsc  $FSP_PACKAGE/$FSP_PKG_EXT_CONF_NAME.dsc  $BD_MACRO"
    echo $python_command
    $python_command

    if [ $? -eq "1" ]
     then
      return 1
    fi

    echo BSF file was generated successfully !

    if [ -f $WORKSPACE/$FSP_PACKAGE/Include/FspUpd.h ]
      then chmod +w $WORKSPACE/$FSP_PACKAGE/Include/FspUpd.h
    fi
    if [ -f $WORKSPACE/$FSP_PACKAGE/Include/FsptUpd.h ]
      then chmod +w $WORKSPACE/$FSP_PACKAGE/Include/FsptUpd.h
    fi
    if [ -f $WORKSPACE/$FSP_PACKAGE/Include/FspmUpd.h ]
      then chmod +w $WORKSPACE/$FSP_PACKAGE/Include/FspmUpd.h
    fi
    if [ -f $WORKSPACE/$FSP_PACKAGE/Include/FspsUpd.h ]
      then chmod +w $WORKSPACE/$FSP_PACKAGE/Include/FspsUpd.h
    fi
    if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspUpd.h ]
     then
      cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspUpd.h  $FSP_PACKAGE/Include/FspUpd.h
    fi
    if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FsptUpd.h ]
     then
      cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FsptUpd.h  $FSP_PACKAGE/Include/FsptUpd.h
    fi
    if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspmUpd.h ]
     then
      cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspmUpd.h  $FSP_PACKAGE/Include/FspmUpd.h
    fi
    if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspsUpd.h ]
     then
      cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspsUpd.h  $FSP_PACKAGE/Include/FspsUpd.h
    fi
  fi
}


function PostBuild(){
  echo Start of PostBuild ...
  if [ $? -ne 0 ]
   then
    return 1
  fi

  echo Patch FSP-T Image ...
   python IntelFsp2Pkg/Tools/PatchFv.py \
     $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV \
     FSP-T:QUARK \
     "0x0000,            _BASE_FSP-T_,                                                                                       @Temporary Base" \
     "<[0x0000]>+0x00AC, [<[0x0000]>+0x0020],                                                                                @FSP-T Size" \
     "<[0x0000]>+0x00B0, [0x0000],                                                                                           @FSP-T Base" \
     "<[0x0000]>+0x00B4, ([<[0x0000]>+0x00B4] & 0xFFFFFFFF) | 0x0001,                                                        @FSP-T Image Attribute" \
     "<[0x0000]>+0x00B6, ([<[0x0000]>+0x00B6] & 0xFFFF0FFC) | 0x1000 | $FSP_BUILD_TYPE | $FSP_RELEASE_TYPE,                  @FSP-T Component Attribute" \
     "<[0x0000]>+0x00B8, 70BCF6A5-FFB1-47D8-B1AE-EFE5508E23EA:0x1C - <[0x0000]>,                                             @FSP-T CFG Offset" \
     "<[0x0000]>+0x00BC, [70BCF6A5-FFB1-47D8-B1AE-EFE5508E23EA:0x14] & 0xFFFFFF - 0x001C,                                    @FSP-T CFG Size" \
     "<[0x0000]>+0x00C4, FspSecCoreT:_TempRamInitApi - [0x0000],                                                             @TempRamInit API" \
     "0x0000,            0x00000000,                                                                                         @Restore the value" \
     "FspSecCoreT:_FspInfoHeaderRelativeOff, FspSecCoreT:_AsmGetFspInfoHeader - {912740BE-2284-4734-B971-84B027353F0C:0x1C}, @FSP-T Header Offset"
  if [ $? -ne 0 ]
   then
    return 1
  fi

  echo Patch FSP-M Image ...
   python IntelFsp2Pkg/Tools/PatchFv.py \
     $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV \
     FSP-M:QUARK \
     "0x0000,            _BASE_FSP-M_,                                                                                       @Temporary Base" \
     "<[0x0000]>+0x00AC, [<[0x0000]>+0x0020],                                                                                @FSP-M Size" \
     "<[0x0000]>+0x00B0, [0x0000],                                                                                           @FSP-M Base" \
     "<[0x0000]>+0x00B4, ([<[0x0000]>+0x00B4] & 0xFFFFFFFF) | 0x0001,                                                        @FSP-M Image Attribute" \
     "<[0x0000]>+0x00B6, ([<[0x0000]>+0x00B6] & 0xFFFF0FFC) | 0x2000 | $FSP_BUILD_TYPE | $FSP_RELEASE_TYPE,                  @FSP-M Component Attribute" \
     "<[0x0000]>+0x00B8, D5B86AEA-6AF7-40D4-8014-982301BC3D89:0x1C - <[0x0000]>,                                             @FSP-M CFG Offset" \
     "<[0x0000]>+0x00BC, [D5B86AEA-6AF7-40D4-8014-982301BC3D89:0x14] & 0xFFFFFF - 0x001C,                                    @FSP-M CFG Size" \
     "<[0x0000]>+0x00D0, FspSecCoreM:_FspMemoryInitApi - [0x0000],                                                           @MemoryInitApi API" \
     "<[0x0000]>+0x00D4, FspSecCoreM:_TempRamExitApi - [0x0000],                                                             @TempRamExit API" \
     "FspSecCoreM:_FspPeiCoreEntryOff, PeiCore:__ModuleEntryPoint - [0x0000],                                                @PeiCore Entry" \
     "0x0000,            0x00000000,                                                                                         @Restore the value" \
     "FspSecCoreM:_FspInfoHeaderRelativeOff, FspSecCoreM:_AsmGetFspInfoHeader - {912740BE-2284-4734-B971-84B027353F0C:0x1C}, @FSP-M Header Offset"
  if [ $? -ne 0 ]
   then
    return 1
  fi

  echo Patch FSP-S Image ...
   python IntelFsp2Pkg/Tools/PatchFv.py \
     $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV \
     FSP-S:QUARK \
     "0x0000,            _BASE_FSP-S_,                                                                                       @Temporary Base" \
     "<[0x0000]>+0x00AC, [<[0x0000]>+0x0020],                                                                                @FSP-S Size" \
     "<[0x0000]>+0x00B0, [0x0000],                                                                                           @FSP-S Base" \
     "<[0x0000]>+0x00B4, ([<[0x0000]>+0x00B4] & 0xFFFFFFFF) | 0x0001,                                                        @FSP-S Image Attribute" \
     "<[0x0000]>+0x00B6, ([<[0x0000]>+0x00B6] & 0xFFFF0FFC) | 0x3000 | $FSP_BUILD_TYPE | $FSP_RELEASE_TYPE,                  @FSP-S Component Attribute" \
     "<[0x0000]>+0x00B8, E3CD9B18-998C-4F76-B65E-98B154E5446F:0x1C - <[0x0000]>,                                             @FSP-S CFG Offset" \
     "<[0x0000]>+0x00BC, [E3CD9B18-998C-4F76-B65E-98B154E5446F:0x14] & 0xFFFFFF - 0x001C,                                    @FSP-S CFG Size" \
     "<[0x0000]>+0x00D8, FspSecCoreS:_FspSiliconInitApi - [0x0000],                                                          @SiliconInit API" \
     "<[0x0000]>+0x00CC, FspSecCoreS:_NotifyPhaseApi - [0x0000],                                                             @NotifyPhase API" \
     "0x0000,            0x00000000,                                                                                         @Restore the value" \
     "FspSecCoreS:_FspInfoHeaderRelativeOff, FspSecCoreS:_AsmGetFspInfoHeader - {912740BE-2284-4734-B971-84B027353F0C:0x1C}, @FSP-S Header Offset"
  if [ $? -ne 0 ]
   then
    return 1
  fi
  return 0
}

function  Build32(){

   if [ ! -e BaseTools/BinWrappers/PosixLike/build ]
    then
     make -C ./BaseTools/Source/C
   fi
   chmod +w $FSP_PACKAGE/$PLATFORM_NAME.dsc
   OverrideBaseTools $*
   gcc -v
   echo build -m $FSP_PACKAGE/Fsp2Header/FspHeader.inf $BD_ARGS -DCFG_PREBUILD
   build -m $FSP_PACKAGE/Fsp2Header/FspHeader.inf $BD_ARGS -DCFG_PREBUILD
   if [ $? -ne 0 ]
   then
     exit 1
   fi

   PreBuild $*

   if [ $? -eq 1 ]
   then
     exit 1
   fi

   build $BD_ARGS
   if [ $? -ne 0 ]
   then
     exit 1
   fi
   PostBuild
   if [ $? -ne 0 ]
   then
     exit 1
   fi
}

function ReleaseTypeTest32(){
  BD_TARGET=RELEASE
  BD_MACRO="-D CFG_OUTDIR="$OUT_DIR
  DSCFILE="-p "$FSP_PACKAGE/$PLATFORM_NAME.dsc #" -y ReleaseBuild32Log.log"
  BD_ARGS=$DSCFILE" -b RELEASE "$BD_MACRO" -a IA32 -n 1 -t "$TOOL_CHAIN
  FSP_BUILD_TYPE=0x0001
  FSP_RELEASE_TYPE=0x0000
  Build32 $*
}

function ReleaseBuild32(){
  BD_TARGET=RELEASE
  BD_MACRO="-D CFG_OUTDIR="$OUT_DIR
  DSCFILE="-p "$FSP_PACKAGE/$PLATFORM_NAME.dsc #" -y ReleaseBuild32Log.log"
  BD_ARGS=$DSCFILE" -b RELEASE "$BD_MACRO" -a IA32 -n 1 -t "$TOOL_CHAIN
  FSP_BUILD_TYPE=0x0001
  FSP_RELEASE_TYPE=0x0002
  Build32 $*
}

function DebugBuild32(){
  BD_TARGET=DEBUG
  BD_MACRO="-D CFG_DEBUG=1 -D DEBUG_BIOS_ENABLE=TRUE -D CFG_OUTDIR="$OUT_DIR
  DSCFILE="-p "$FSP_PACKAGE/$PLATFORM_NAME.dsc   #" -y DebugBuild32Log.log"
  #echo $DSCFILE

  BD_ARGS=$DSCFILE" -b DEBUG "$BD_MACRO" -a IA32 -n 1 -t "$TOOL_CHAIN
  FSP_BUILD_TYPE=0x0000
  FSP_RELEASE_TYPE=0x0000
  Build32 $*
}

function CopyFspBinaryToBinPkg(){
    echo Copy FSP binary to $FSP_BIN_PKG_NAME

    if [ -f $WORKSPACE/$FSP_BIN_PKG_NAME/Fsp.bsf ]
      then chmod +w $WORKSPACE/$FSP_BIN_PKG_NAME/Fsp.bsf
    fi
    if [ -f $WORKSPACE/$FSP_BIN_PKG_NAME/Fsp.fd ]
      then chmod +w $WORKSPACE/$FSP_BIN_PKG_NAME/Fsp.fd
    fi

    cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/QUARK.fd $WORKSPACE/$FSP_BIN_PKG_NAME/Fsp.fd

    if [ -f $WORKSPACE/$FSP_BIN_PKG_NAME/Include/FspUpd.h ]
      then chmod +w $WORKSPACE/$FSP_BIN_PKG_NAME/Include/FspUpd.h
    fi
    if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspUpd.h ]
      then cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspUpd.h $WORKSPACE/$FSP_BIN_PKG_NAME/Include
    fi
    if [ -f $WORKSPACE/$FSP_BIN_PKG_NAME/Include/FsptUpd.h ]
      then chmod +w $WORKSPACE/$FSP_BIN_PKG_NAME/Include/FsptUpd.h
    fi
    if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FsptUpd.h ]
      then cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FsptUpd.h $WORKSPACE/$FSP_BIN_PKG_NAME/Include
    fi
    if [ -f $WORKSPACE/$FSP_BIN_PKG_NAME/Include/FspmUpd.h ]
      then chmod +w $WORKSPACE/$FSP_BIN_PKG_NAME/Include/FspmUpd.h
    fi
    if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspmUpd.h ]
      then cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspmUpd.h $WORKSPACE/$FSP_BIN_PKG_NAME/Include
    fi
    if [ -f $WORKSPACE/$FSP_BIN_PKG_NAME/Include/FspsUpd.h ]
      then chmod +w $WORKSPACE/$FSP_BIN_PKG_NAME/Include/FspsUpd.h
    fi
    if [ -f $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspsUpd.h ]
      then cp $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV/FspsUpd.h $WORKSPACE/$FSP_BIN_PKG_NAME/Include
    fi
}

function OverrideBaseTools() {
   if [ -e $FSP_PACKAGE/Override/BaseTools/Conf/build_rule.template ]
    then
     echo Overriding build_rule.template...
      cp -f $FSP_PACKAGE/Override/BaseTools/Conf/build_rule.template Conf/build_rule.txt
   fi

   if [ -e $FSP_PACKAGE/Override/BaseTools/Conf/tools_def.template ]
     then
     echo Overriding tools_def.template...
      cp -f $FSP_PACKAGE/Override/BaseTools/Conf/tools_def.template Conf/tools_def.txt
  fi

 }


if [ ! -d Conf ]
 then
   mkdir Conf
fi
. ./$Edksetup

if [ ! -d $WORKSPACE/$FSP_BIN_PKG_NAME ]
 then
   mkdir $WORKSPACE/$FSP_BIN_PKG_NAME
fi

if [ "$1" = "-clean" ]
 then
  Clean
elif [ "$1" = "-r32" ]
 then
  ReleaseBuild32
  CopyFspBinaryToBinPkg
elif [ "$1" = "-tr32" ]
 then
  ReleaseTypeTest32
  CopyFspBinaryToBinPkg
elif [ "$1" = "-d32" ]
 then
   DebugBuild32
   CopyFspBinaryToBinPkg
elif [ -z "$1" ]
 then
   DebugBuild32
else
  echo
  echo  ERROR: $1 is not valid parameter.
  USAGE
fi
