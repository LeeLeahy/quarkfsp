/** @file
  FSP 1.1 support library functions

  Copyright (c) 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials are licensed and made available
  under the terms and conditions of the BSD License which accompanies this
  distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include <Uefi.h>
#include <FspApi.h>
#include <Library/DebugLib.h>
#include <Library/FspCommonLib.h>
#include <Library/FspLib.h>
#include <Library/FspMemoryLib.h>
#include <Library/FspMemoryInit.h>
#include <Pi/PiBootMode.h>
#include <Pi/PiHob.h>
#include <Library/HobLib.h>
#include <FspUpdVpd.h>
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

static FSP_INIT_RT_COMMON_BUFFER *FspGetInitRtBuffer(VOID)
{
  return (FSP_INIT_RT_COMMON_BUFFER *)((FSP_MEMORY_INIT_PARAMS *)GetFspApiParameter())->RtBufferPtr;
}

UINT32 GetBootLoaderTolumSize(VOID)
{
  FSP_INIT_RT_COMMON_BUFFER *FspInitRtBuffer;

  FspInitRtBuffer = FspGetInitRtBuffer();
  ASSERT (FspInitRtBuffer != NULL);
  return FspInitRtBuffer->BootLoaderTolumSize;
}

UINT32 GetBootMode(VOID)
{
  FSP_STACK_DATA *StackData;

  StackData = GetStackData();
  return StackData->InitRtBuffer->BootMode;
}

UINT32 GetEccScrubBlkSize(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Return the requested value
  //
  return MemoryInitUpd->EccScrubBlkSize;
}

UINT32 GetEccScrubInterval(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Return the requested value
  //
  return MemoryInitUpd->EccScrubInterval;
}

UINT32 GetFspReservedMemoryLength(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Return the requested value
  //
  return MemoryInitUpd->FspReservedMemoryLength;
}

VOID GetMemoryParameters (
  OUT MRC_PARAMS  *MrcData
  )
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Initialize the MRC data
  //
  MrcData->channel_enables     = MemoryInitUpd->ChanMask;
  MrcData->channel_width       = MemoryInitUpd->ChanWidth;
  MrcData->address_mode        = MemoryInitUpd->AddrMode;
  // Enable scrambling if requested.
  MrcData->scrambling_enables  = (UINT8)MemoryInitUpd->Flags;
  MrcData->ddr_type            = MemoryInitUpd->DramType;
  MrcData->dram_width          = MemoryInitUpd->DramWidth;
  MrcData->ddr_speed           = MemoryInitUpd->DramSpeed;
  // Enable ECC if requested.
  MrcData->rank_enables        = MemoryInitUpd->RankMask;
  MrcData->params.DENSITY      = MemoryInitUpd->DramDensity;
  MrcData->params.tCL          = MemoryInitUpd->tCL;
  MrcData->params.tRAS         = MemoryInitUpd->tRAS;
  MrcData->params.tWTR         = MemoryInitUpd->tWTR;
  MrcData->params.tRRD         = MemoryInitUpd->tRRD;
  MrcData->params.tFAW         = MemoryInitUpd->tFAW;

  MrcData->refresh_rate        = MemoryInitUpd->SrInt;
  MrcData->sr_temp_range       = MemoryInitUpd->SrTemp;
  MrcData->ron_value           = MemoryInitUpd->DramRonVal;
  MrcData->rtt_nom_value       = MemoryInitUpd->DramRttNomVal;
  MrcData->rd_odt_value        = MemoryInitUpd->SocRdOdtVal;
}

UINT32 GetMrcDataLength(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Return the requested value
  //
  return MemoryInitUpd->MrcDataLength;
}

UINT32 GetMrcDataPtr(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Return the requested value
  //
  return MemoryInitUpd->MrcDataPtr;
}

UINT32 GetRmuBaseAddress(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Return the requested value
  //
  return MemoryInitUpd->RmuBaseAddress;
}

UINT32 GetRmuLength(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Return the requested value
  //
  return MemoryInitUpd->RmuLength;
}

FN_SERIAL_PORT_POLL_FOR_CHAR GetSerialPortPollForChar(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;

  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (MemoryInitUpd != NULL);
  return (FN_SERIAL_PORT_POLL_FOR_CHAR)MemoryInitUpd->SerialPortPollForChar;
}

FN_SERIAL_PORT_READ_CHAR GetSerialPortReadChar(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;

  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (MemoryInitUpd != NULL);
  return (FN_SERIAL_PORT_READ_CHAR)MemoryInitUpd->SerialPortReadChar;
}

FN_SERIAL_PORT_WRITE_CHAR GetSerialPortWriteChar(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;

  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (MemoryInitUpd != NULL);
  return (FN_SERIAL_PORT_WRITE_CHAR)MemoryInitUpd->SerialPortWriteChar;
}

UINT8 GetSmmTsegSize(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  FSP_STACK_DATA *StackData;

  //
  // Get the UPD pointer
  //
  StackData = GetStackData();
  MemoryInitUpd = StackData->Upd;
  ASSERT (MemoryInitUpd != NULL);

  //
  // Return the requested value
  //
  return MemoryInitUpd->SmmTsegSize;
}

FSP_STACK_DATA *GetStackData(VOID)
{
  FSP_STACK_DATA *StackData;

  StackData = (FSP_STACK_DATA *)QNCPortRead(
    QUARK_NC_MEMORY_CONTROLLER_SB_PORT_ID, SSKPD0);
  ASSERT(StackData != NULL);
  return StackData;
}

VOID ReturnHobListPointer(VOID *HobList)
{
  FSP_MEMORY_INIT_PARAMS   *FspMemoryInitParams;

  FspMemoryInitParams = (FSP_MEMORY_INIT_PARAMS *)GetFspApiParameter();
  if ((FspMemoryInitParams->HobListPtr) != NULL) {
    *(FspMemoryInitParams->HobListPtr) = (VOID *)GetHobList();
  }
}

VOID SaveStackData(FSP_STACK_DATA *StackData)
{
  /* Use a scratch pad register to hold the pointer */
  QNCPortWrite(QUARK_NC_MEMORY_CONTROLLER_SB_PORT_ID, SSKPD0,
    (UINT32)StackData);
}

EFI_STATUS CreateStackData(MEMORY_INIT_START MemoryInitStart)
{
  FSP_STACK_DATA StackData;
  EFI_STATUS Status;

  // Initialize the temporary data
  SaveStackData(&StackData);
  StackData.InitRtBuffer = FspGetInitRtBuffer();
  ASSERT (StackData.InitRtBuffer != NULL);
DEBUG((EFI_D_ERROR, "  Calling GetFspMemoryInitUpdDataPointer\n"));
  StackData.Upd = GetFspMemoryInitUpdDataPointer();
DEBUG((EFI_D_ERROR, "  0x%08x: StackData.Upd\n", StackData.Upd));
  ASSERT (StackData.Upd != NULL);

  // Initialize DRAM
  Status = MemoryInitStart();
  return Status;
}
