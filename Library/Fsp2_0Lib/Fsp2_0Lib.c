/** @file
  16550 UART Serial Port library functions

  (C) Copyright 2014 Hewlett-Packard Development Company, L.P.<BR>
  Copyright (c) 2006 - 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials
  are licensed and made available under the terms and conditions of the BSD License
  which accompanies this distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include <Base.h>
#include <Library/DebugLib.h>
#include <Library/FspCommonLib.h>
#include <Library/FspLib.h>
#include <Library/FspMemoryLib.h>
#include <Library/FspMemoryInit.h>
#include <Pi/PiBootMode.h>
#include <Uefi/UefiMultiPhase.h>
#include <Pi/PiHob.h>
#include <Library/HobLib.h>
#include <FspmUpd.h>
#include <FspsUpd.h>
#include <BootLoaderPlatformData.h>
#include <Library/QNCAccessLib.h>
#include "StackData.h"

#define SSKPD0			0x4a

VOID
BuildFspSmbiosMemoryInfoHob (
  UINT8  MemoryType,
  UINT16 MemoryFrequencyInMHz,
  UINT32 SizeInMb,
  UINT16 DataWidth,
  UINT8  ErrorCorrectionType,
  UINT32 NumChannels,
  UINT32 MaxSockets,
  EFI_GUID *HobGuid
  )
{
  FSP_SMBIOS_MEMORY_INFO      FspSmbiosMemoryInfo;
  UINT8                       ChannelIndex;
  UINT8                       ChannelCount;
  UINT8                       DimmIndex;
  UINT8                       DimmCount;

  FspSmbiosMemoryInfo.Revision = 0x01;
  FspSmbiosMemoryInfo.MemoryType = MemoryType;
  FspSmbiosMemoryInfo.MemoryFrequencyInMHz = MemoryFrequencyInMHz;
  FspSmbiosMemoryInfo.ErrorCorrectionType = ErrorCorrectionType;

  ChannelCount = 0;
  for (ChannelIndex = 0; ChannelIndex < NumChannels; ChannelIndex++) {
    DimmCount = 0;
    FspSmbiosMemoryInfo.ChannelInfo[ChannelIndex].ChannelId = ChannelIndex;
    for (DimmIndex = 0; DimmIndex < MaxSockets; DimmIndex++) {
      FspSmbiosMemoryInfo.ChannelInfo[ChannelIndex].DimmInfo[DimmIndex].DimmId = DimmIndex;
      FspSmbiosMemoryInfo.ChannelInfo[ChannelIndex].DimmInfo[DimmIndex].SizeInMb = SizeInMb;
        ///
        /// Dimm is present in slot
        /// Get the Memory DataWidth info
        /// SPD Offset 8 Bits [2:0] DataWidth aka Primary Bus Width
        ///
        FspSmbiosMemoryInfo.DataWidth = DataWidth;
      DimmCount++;
    }
    FspSmbiosMemoryInfo.ChannelInfo[ChannelIndex].DimmCount = DimmCount;
    ChannelCount++;
  }
  FspSmbiosMemoryInfo.ChannelCount = ChannelCount;

  //
  // Build HOB for FspSmbiosMemoryInfo
  //
  BuildGuidDataHob (
    HobGuid,
    &FspSmbiosMemoryInfo,
    sizeof (FSP_SMBIOS_MEMORY_INFO)
    );
}

UINT32 GetBootLoaderTolumSize(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmArchUpd.BootLoaderTolumSize;
}

UINT32 GetBootMode(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmArchUpd.BootMode;
}

UINT32 GetEccScrubBlkSize(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmConfig.EccScrubBlkSize;
}

UINT32 GetEccScrubInterval(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmConfig.EccScrubInterval;
}

UINT32 GetFspReservedMemoryLength(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmConfig.FspReservedMemoryLength;
}

VOID GetMemoryParameters (
  OUT MRC_PARAMS  *MrcData
  )
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);

  MrcData->channel_enables     = FspmUpd->FspmConfig.ChanMask;
  MrcData->channel_width       = FspmUpd->FspmConfig.ChanWidth;
  MrcData->address_mode        = FspmUpd->FspmConfig.AddrMode;
  // Enable scrambling if requested.
  MrcData->scrambling_enables  = (UINT8)FspmUpd->FspmConfig.Flags;
  MrcData->ddr_type            = FspmUpd->FspmConfig.DramType;
  MrcData->dram_width          = FspmUpd->FspmConfig.DramWidth;
  MrcData->ddr_speed           = FspmUpd->FspmConfig.DramSpeed;
  // Enable ECC if requested.
  MrcData->rank_enables        = FspmUpd->FspmConfig.RankMask;
  MrcData->params.DENSITY      = FspmUpd->FspmConfig.DramDensity;
  MrcData->params.tCL          = FspmUpd->FspmConfig.tCL;
  MrcData->params.tRAS         = FspmUpd->FspmConfig.tRAS;
  MrcData->params.tWTR         = FspmUpd->FspmConfig.tWTR;
  MrcData->params.tRRD         = FspmUpd->FspmConfig.tRRD;
  MrcData->params.tFAW         = FspmUpd->FspmConfig.tFAW;

  MrcData->refresh_rate        = FspmUpd->FspmConfig.SrInt;
  MrcData->sr_temp_range       = FspmUpd->FspmConfig.SrTemp;
  MrcData->ron_value           = FspmUpd->FspmConfig.DramRonVal;
  MrcData->rtt_nom_value       = FspmUpd->FspmConfig.DramRttNomVal;
  MrcData->rd_odt_value        = FspmUpd->FspmConfig.SocRdOdtVal;
}

UINT32 GetMrcDataLength(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmConfig.MrcDataLength;
}

UINT32 GetMrcDataPtr(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmConfig.MrcDataPtr;
}

UINT32 GetRmuBaseAddress(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmConfig.RmuBaseAddress;
}

UINT32 GetRmuLength(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmConfig.RmuLength;
}

FN_SERIAL_PORT_POLL_FOR_CHAR GetSerialPortPollForChar(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return (FN_SERIAL_PORT_POLL_FOR_CHAR)FspmUpd->FspmConfig.SerialPortPollForChar;
}

FN_SERIAL_PORT_READ_CHAR GetSerialPortReadChar(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return (FN_SERIAL_PORT_READ_CHAR)FspmUpd->FspmConfig.SerialPortReadChar;
}

FN_SERIAL_PORT_WRITE_CHAR GetSerialPortWriteChar(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return (FN_SERIAL_PORT_WRITE_CHAR)FspmUpd->FspmConfig.SerialPortWriteChar;
}

UINT8 GetSmmTsegSize(VOID)
{
  FSPM_UPD *FspmUpd;

  FspmUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (FspmUpd != NULL);
  return FspmUpd->FspmConfig.SmmTsegSize;
}

VOID ReturnHobListPointer(VOID *HobList)
{
  VOID **HobListPtr;

  /* Return the address of the HOB list */
  HobListPtr = (VOID *)GetFspApiParameter2();
  if (HobListPtr != NULL) {
    *HobListPtr = HobList;
  }
}

VOID SaveStackData(FSP_STACK_DATA *StackData)
{
  /* Use a scratch pad register to hold the pointer */
  QNCPortWrite(QUARK_NC_MEMORY_CONTROLLER_SB_PORT_ID, SSKPD0,
    (UINT32)StackData);
}

EFI_STATUS
CreateStackData(
  MEMORY_INIT_START MemoryInitStart
)
{
  FSP_STACK_DATA StackData;
  EFI_STATUS Status;

  // Initialize the temporary data
  SaveStackData(&StackData);

  // Initialize DRAM
  Status = MemoryInitStart();
  return Status;
}

VOID FspMigrateTemporaryMemory(VOID)
{
}
