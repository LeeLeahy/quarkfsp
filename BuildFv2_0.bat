@REM
@REM This file contains an 'Intel Peripheral Driver' and is      
@REM licensed for Intel CPUs and chipsets under the terms of your
@REM license agreement with Intel or your vendor.  This file may 
@REM be modified by the user, subject to additional terms of the 
@REM license agreement                                           
@REM
@REM
@REM Copyright (c) 2008 - 2016, Intel Corporation All rights reserved
@REM This software and associated documentation (if any) is furnished
@REM under a license and may only be used or copied in accordance
@REM with the terms of the license. Except as permitted by such
@REM license, no part of this software or documentation may be
@REM reproduced, stored in a retrieval system, or transmitted in any
@REM form or by any means without the express written consent of
@REM Intel Corporation.
@REM

@echo off
set FSP_PKG_CONF_NAME=QuarkFspPkgConfig
set FSP_PKG_EXT_CONF_NAME=QuarkFspPkgExtConfig
set PLATFORM_NAME=QuarkFsp2_0
@if /I "%1"=="/h" goto Usage
@if /I "%1"=="/?" goto Usage

@if not defined WORKSPACE (
  call %~dp0\..\edksetup.bat
)
@if not defined EDK_TOOLS_BIN (
  set EDK_TOOLS_BIN=%EDK_TOOLS_PATH%\Bin\Win32
)
call %BASE_TOOLS_PATH%\toolsetup.bat   Rebuild

@echo off
set VS_VERSION=
set VSCOMNTOOLS=

@if defined VS120COMNTOOLS (
  echo.
  echo Set the VS2013 environment.
  echo.
  if /I "%VS120COMNTOOLS%" == "C:\Program Files\Microsoft Visual Studio 12.0\Common7\Tools\" (
    set VS_VERSION=VS2013
  ) else (
    set VS_VERSION=VS2013x86
  )
)else if defined VS110COMNTOOLS (
  echo.
  echo Set the VS2012 environment.
  echo.
  if /I "%VS110COMNTOOLS%" == "C:\Program Files\Microsoft Visual Studio 11.0\Common7\Tools\" (
    set VS_VERSION=VS2012
  ) else (
    set VS_VERSION=VS2012x86
  )
) else if defined VS100COMNTOOLS (
  echo.
  echo Set the VS2010 environment.
  echo.
  if /I "%VS100COMNTOOLS%" == "C:\Program Files\Microsoft Visual Studio 10.0\Common7\Tools\" (
    set VS_VERSION=VS2010
  ) else (
    set VS_VERSION=VS2010x86
  )
) else if defined VS90COMNTOOLS (
  echo.
  echo Set the VS2008 environment.
  echo.
  if /I "%VS90COMNTOOLS%" == "C:\Program Files\Microsoft Visual Studio 9.0\Common7\Tools\" (
    set VS_VERSION=VS2008
  ) else (
    set VS_VERSION=VS2008x86
  )
) else if defined VS80COMNTOOLS (
  echo.
  echo Set the VS2005 environment.
  echo.
  if /I "%VS80COMNTOOLS%" == "C:\Program Files\Microsoft Visual Studio 8\Common7\Tools\" (
    set VS_VERSION=VS2005
  ) else (
    set VS_VERSION=VS2005x86
  )
) else (
  echo.
  echo !!! ERROR !!! VS2008/2005 not installed correctly. !!!
  echo !!! ERROR !!! VS120COMNTOOLS/VS90COMNTOOLS/VS80COMNTOOLS not defined. !!!
  echo.
  set SCRIPT_ERROR=1
  goto :End
)

@echo off
set OUT_DIR=Build
set FSP_BASENAME=Quark
set FSP_PKG_NAME=%FSP_BASENAME%FspPkg
set FSP_PKG_VPD_NAME=%FSP_PKG_NAME%Vpd
@REM Set build TARGET.
if exist %FSP_PKG_NAME%\Bsf\%FSP_BASENAME%Fsp2_0.bsf attrib -r %FSP_PKG_NAME%\Bsf\%FSP_BASENAME%Fsp2_0.bsf
if exist %FSP_PKG_NAME%\Include\FspUpdVpd.h attrib -r %FSP_PKG_NAME%\Include\FspUpdVpd.h
@if /I "%1" == "" (
  goto DebugBuild32
) else if /I "%1" == "/d32" (
  goto DebugBuild32
) else if /I "%1" == "/r32" (
  goto ReleaseBuild32
) else if /I "%1" == "/clean" (
  goto Clean
) else (
  echo.
  echo  ERROR: "%1" is not valid parameter.
  echo.
  goto Usage
)

:Clean
echo Removing Build and Conf directories ...
if exist Build rmdir Build /s /q
if exist Conf\.cache  rmdir Conf\.cache  /s /q
if exist Conf\target.txt  del Conf\target.txt /q /f
if exist Conf\build_rule.txt  del Conf\build_rule.txt /q /f
if exist Conf\tools_def.txt  del Conf\tools_def.txt /q /f
if exist %~dp0\*.log  del %~dp0\*.log /q /f
if exist %~dp0\..\*.log  del %~dp0\..\*.log /q /f
if exist %~dp0\%FSP_PKG_NAME%\*.log  del %~dp0\%FSP_PKG_NAME%\*.log /q /f
if exist %~dp0\..\*.bin  del %~dp0\..\*.bin /q /f
if exist %~dp0\..\*.fd  del %~dp0\..\*.fd /q /f
if exist %~dp0\..\*.bsf  del %~dp0\..\*.bsf /q /f
set WORKSPACE=
set EDK_TOOLS_PATH=
goto End

:ReleaseBuild32
set  BD_TARGET=RELEASE
set  DEBUG_PRINT_ERROR_LEVEL=-DDEBUG_PRINT_ERROR_LEVEL=0x80000000
set  DEBUG_PROPERTY_MASK=-DDEBUG_PROPERTY_MASK=0x23
set  BD_MACRO=-D CFG_OUTDIR=%OUT_DIR% %DEBUG_PRINT_ERROR_LEVEL% %DEBUG_PROPERTY_MASK%
set  BD_ARGS=-p %FSP_PKG_NAME%\%PLATFORM_NAME%.dsc  -Y PCD -Y LIBRARY -y %~dp0\Report%BD_TARGET%.log -b %BD_TARGET% %BD_MACRO% -a IA32 -n 4 -t %VS_VERSION%
set  FSP_BUILD_TYPE=0x0001
set  FSP_RELEASE_TYPE=0x0000
goto Build32

:DebugBuild32
set  BD_TARGET=DEBUG
set  DEBUG_PRINT_ERROR_LEVEL=-DDEBUG_PRINT_ERROR_LEVEL=0x80000042
set  DEBUG_PROPERTY_MASK=-DDEBUG_PROPERTY_MASK=0x27
set  BD_MACRO=-D CFG_DEBUG=1 -D CFG_OUTDIR=%OUT_DIR% %DEBUG_PRINT_ERROR_LEVEL% %DEBUG_PROPERTY_MASK%
set  BD_ARGS=-p %FSP_PKG_NAME%\%PLATFORM_NAME%.dsc -Y PCD -Y LIBRARY -y %~dp0\Report%BD_TARGET%.log -b %BD_TARGET% %BD_MACRO% -a IA32 -n 4 -t %VS_VERSION%
set  FSP_BUILD_TYPE=0x0000
set  FSP_RELEASE_TYPE=0x0000
goto Build32

:Build32
build  -m %FSP_PKG_NAME%\Fsp2Header\FspHeader.inf -D CFG_PREBUILD=1 %BD_ARGS%
if ERRORLEVEL 1 goto DIE
call :PreBuild  CALL_RET
if "%CALL_RET%"=="1" goto DIE 
build  %BD_ARGS%
if ERRORLEVEL 1 goto DIE
call :PostBuild
goto End

:Usage
echo.
echo  Usage: "%0 [/h | /? | /r32 | /d32 | /clean]"
echo.
goto End

:CopyBin
@if exist %1\*.efi   xcopy %1\*.efi   %2 /D /U /Y > NUL
@if exist %1\*.inf   xcopy %1\*.inf   %2 /D /U /Y > NUL
@if exist %1\*.depex xcopy %1\*.depex %2 /D /U /Y > NUL
goto:EOF

:PreBuild
echo Start of PreBuild ...
set %~1=1
set FSP_T_UPD_GUID=34686CA3-34F9-4901-B82A-BA630F0714C6
set FSP_M_UPD_GUID=39A250DB-E465-4DD1-A2AC-E2BD3C0E2385
set FSP_S_UPD_GUID=CAE3605B-5B34-4C85-B3D7-27D54273C40F
if not exist  %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV (
     mkdir    %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV
)

echo Generate UPD Header File ...
python IntelFsp2Pkg\Tools\GenCfgOpt.py UPDTXT ^
     %FSP_PKG_NAME%\%PLATFORM_NAME%.dsc ^
     %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV ^
     %BD_MACRO%
if "%ERRORLEVEL%"=="256" (
  REM  DSC is not changed, no need to recreate MAP and BIN file    
) else (
  if ERRORLEVEL 1 goto:PreBuildFail  
  echo UPD TXT file was generated successfully !
    
  echo Remove the UPD.BIN and UPD.MAP files ...
  del /q /f %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_T_UPD_GUID%.bin ^
            %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_T_UPD_GUID%.map 2>nul
  del /q /f %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_M_UPD_GUID%.bin ^
            %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_M_UPD_GUID%.map 2>nul
  del /q /f %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_S_UPD_GUID%.bin ^
            %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_S_UPD_GUID%.map 2>nul

  echo Generating FSP-T GUID .BIN and .MAP files
  %EDK_TOOLS_BIN%\BPDG.exe ^
       %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_T_UPD_GUID%.txt ^
       -o %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_T_UPD_GUID%.bin ^
       -m %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_T_UPD_GUID%.map
  if ERRORLEVEL 1 goto:PreBuildFail

  echo Generating FSP-M GUID .BIN and .MAP files
  %EDK_TOOLS_BIN%\BPDG.exe ^
       %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_M_UPD_GUID%.txt ^
       -o %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_M_UPD_GUID%.bin ^
       -m %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_M_UPD_GUID%.map
  if ERRORLEVEL 1 goto:PreBuildFail

  echo Generating FSP-S GUID .BIN and .MAP files
  %EDK_TOOLS_BIN%\BPDG.exe ^
       %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_S_UPD_GUID%.txt ^
       -o %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_S_UPD_GUID%.bin ^
       -m %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\%FSP_S_UPD_GUID%.map
  if ERRORLEVEL 1 goto:PreBuildFail
)

echo Generate the UPD header files
python IntelFsp2Pkg\Tools\GenCfgOpt.py HEADER ^
         %FSP_PKG_NAME%\%PLATFORM_NAME%.dsc ^
         %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV ^
         %FSP_PKG_NAME%\Include\BootLoaderPlatformData.h ^
		 %FSP_PKG_NAME%\%FSP_PKG_CONF_NAME%.dsc ^
		 %FSP_PKG_NAME%\%FSP_PKG_EXT_CONF_NAME%.dsc ^
         %BD_MACRO%
if "%ERRORLEVEL%"=="256" (
    REM  No need to recreate the UPD header files
) else (    
    if ERRORLEVEL 1 goto:PreBuildFail       
    echo UPD header files were generated successfully!

    if not exist  %FSP_PKG_NAME%\Bsf (
        mkdir  %FSP_PKG_NAME%\Bsf
    )

    echo Generate BSF File ...
	python IntelFsp2Pkg/Tools/GenCfgOpt.py  \
          GENBSF  \
          $FSP_PACKAGE/$PLATFORM_NAME.dsc  \
          $OUT_DIR/$PLATFORM_NAME/$BD_TARGET"_"$TOOL_CHAIN/FV  \
          $FSP_BIN_PKG_NAME/Fsp.bsf  \
          $BD_MACRO
  
    python IntelFsp2Pkg\Tools\GenCfgOpt.py GENBSF ^
         %FSP_PKG_NAME%\%PLATFORM_NAME%.dsc ^
         %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV ^
         %FSP_PKG_NAME%\Bsf\%FSP_BASENAME%Fsp2_0.bsf ^
         %BD_MACRO%
         
    if ERRORLEVEL 1 goto:PreBuildFail
    echo BSF file was generated successfully !
    copy %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\*.h  %FSP_PKG_NAME%\Include\*
)

:PreBuildRet
set %~1=0
echo End of PreBuild ...
echo.
goto:EOF

:PreBuildFail
del /q /f %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV\FspUpdVpd.h
echo.
goto:EOF

:PostBuild
echo Start of PostBuild ...
echo Patch FSP-T Image ...
python IntelFsp2Pkg\Tools\PatchFv.py ^
     %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV ^
     FSP-T:QUARK ^
     "0x0000,            _BASE_FSP-T_,                                                                                       @Temporary Base" ^
     "<[0x0000]>+0x00AC, [<[0x0000]>+0x0020],                                                                                @FSP-T Size" ^
     "<[0x0000]>+0x00B0, [0x0000],                                                                                           @FSP-T Base" ^
     "<[0x0000]>+0x00B4, ([<[0x0000]>+0x00B4] & 0xFFFFFFFF) | 0x0001,                                                        @FSP-T Image Attribute" ^
     "<[0x0000]>+0x00B6, ([<[0x0000]>+0x00B6] & 0xFFFF0FFC) | 0x1000 | %FSP_BUILD_TYPE% | %FSP_RELEASE_TYPE%,                @FSP-T Component Attribute" ^
     "<[0x0000]>+0x00B8, 70BCF6A5-FFB1-47D8-B1AE-EFE5508E23EA:0x1C - <[0x0000]>,                                             @FSP-T CFG Offset" ^
     "<[0x0000]>+0x00BC, [70BCF6A5-FFB1-47D8-B1AE-EFE5508E23EA:0x14] & 0xFFFFFF - 0x001C,                                    @FSP-T CFG Size" ^
     "<[0x0000]>+0x00C4, FspSecCoreT:_TempRamInitApi - [0x0000],                                                             @TempRamInit API" ^
     "0x0000,            0x00000000,                                                                                         @Restore the value"
if ERRORLEVEL 1 exit /b 1

echo Patch FSP-M Image ...
python IntelFsp2Pkg\Tools\PatchFv.py ^
     %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV ^
     FSP-M:QUARK ^
     "0x0000,            _BASE_FSP-M_,                                                                                       @Temporary Base" ^
     "<[0x0000]>+0x00AC, [<[0x0000]>+0x0020],                                                                                @FSP-M Size" ^
     "<[0x0000]>+0x00B0, [0x0000],                                                                                           @FSP-M Base" ^
     "<[0x0000]>+0x00B4, ([<[0x0000]>+0x00B4] & 0xFFFFFFFF) | 0x0001,                                                        @FSP-M Image Attribute" ^
     "<[0x0000]>+0x00B6, ([<[0x0000]>+0x00B6] & 0xFFFF0FFC) | 0x2000 | %FSP_BUILD_TYPE% | %FSP_RELEASE_TYPE%,                @FSP-M Component Attribute" ^
     "<[0x0000]>+0x00B8, D5B86AEA-6AF7-40D4-8014-982301BC3D89:0x1C - <[0x0000]>,                                             @FSP-M CFG Offset" ^
     "<[0x0000]>+0x00BC, [D5B86AEA-6AF7-40D4-8014-982301BC3D89:0x14] & 0xFFFFFF - 0x001C,                                    @FSP-M CFG Size" ^
     "<[0x0000]>+0x00D0, FspSecCoreM:_FspMemoryInitApi - [0x0000],                                                           @MemoryInitApi API" ^
     "<[0x0000]>+0x00D4, FspSecCoreM:_TempRamExitApi - [0x0000],                                                             @TempRamExit API" ^
     "FspSecCoreM:_FspPeiCoreEntryOff, PeiCore:__ModuleEntryPoint - [0x0000],                                                @PeiCore Entry" ^
     "0x0000,            0x00000000,                                                                                         @Restore the value" ^
     "FspSecCoreM:_FspInfoHeaderRelativeOff, FspSecCoreM:_AsmGetFspInfoHeader - {912740BE-2284-4734-B971-84B027353F0C:0x1C}, @FSP-M Header Offset"
if ERRORLEVEL 1 exit /b 1

echo Patch FSP-S Image ...
python IntelFsp2Pkg\Tools\PatchFv.py ^
     %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV ^
     FSP-S:QUARK ^
     "0x0000,            _BASE_FSP-S_,                                                                                       @Temporary Base" ^
     "<[0x0000]>+0x00AC, [<[0x0000]>+0x0020],                                                                                @FSP-S Size" ^
     "<[0x0000]>+0x00B0, [0x0000],                                                                                           @FSP-S Base" ^
     "<[0x0000]>+0x00B4, ([<[0x0000]>+0x00B4] & 0xFFFFFFFF) | 0x0001,                                                        @FSP-S Image Attribute" ^
     "<[0x0000]>+0x00B6, ([<[0x0000]>+0x00B6] & 0xFFFF0FFC) | 0x3000 | %FSP_BUILD_TYPE% | %FSP_RELEASE_TYPE%,                @FSP-S Component Attribute" ^
     "<[0x0000]>+0x00B8, E3CD9B18-998C-4F76-B65E-98B154E5446F:0x1C - <[0x0000]>,                                             @FSP-S CFG Offset" ^
     "<[0x0000]>+0x00BC, [E3CD9B18-998C-4F76-B65E-98B154E5446F:0x14] & 0xFFFFFF - 0x001C,                                    @FSP-S CFG Size" ^
     "<[0x0000]>+0x00D8, FspSecCoreS:_FspSiliconInitApi - [0x0000],                                                          @SiliconInit API" ^
     "<[0x0000]>+0x00CC, FspSecCoreS:_NotifyPhaseApi - [0x0000],                                                             @NotifyPhase API" ^
     "0x0000,            0x00000000,                                                                                         @Restore the value"
if ERRORLEVEL 1 exit /b 1

echo Split the FSP Image ...
python IntelFsp2Pkg/Tools/SplitFspBin.py  ^
    split  ^
    -n "FSP.fd"  ^
    -f %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FVQUARK.fd  ^
    -o %OUT_DIR%\%PLATFORM_NAME%\%BD_TARGET%_%VS_VERSION%\FV
if ERRORLEVEL 1 exit /b 1

echo Patch is DONE

goto:EOF

:DIE
rem ---------------------------------------------------------------------------
rem Exit returning a failure error code
rem ---------------------------------------------------------------------------
    if exist %FSP_PKG_NAME%\Bsf\%FSP_BASENAME%Fsp2_0.bsf attrib +r %FSP_PKG_NAME%\Bsf\%FSP_BASENAME%Fsp2_0.bsf
    if exist %FSP_PKG_NAME%\Include\FspUpdVpd.h attrib +r %FSP_PKG_NAME%\Include\FspUpdVpd.h
    exit /B 1

:End
if exist %FSP_PKG_NAME%\Bsf\%FSP_BASENAME%Fsp2_0.bsf attrib +r %FSP_PKG_NAME%\Bsf\%FSP_BASENAME%Fsp2_0.bsf
if exist %FSP_PKG_NAME%\Include\FspUpdVpd.h attrib +r %FSP_PKG_NAME%\Include\FspUpdVpd.h
echo.
