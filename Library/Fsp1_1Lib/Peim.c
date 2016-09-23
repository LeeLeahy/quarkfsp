/** @file
  FSP 1.1 PEIM support functions

  Copyright (c) 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials are licensed and made available
  under the terms and conditions of the BSD License which accompanies this
  distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include <PiPei.h>
#include <FspApi.h>
#include <Library/DebugLib.h>
#include <Library/FspCommonLib.h>
#include <Library/FspLib.h>
#include <Library/FspMemoryLib.h>
#include <Library/FspMemoryInit.h>
#include <Library/PeiServicesLib.h>
#include <FspUpdVpd.h>
#include "StackData.h"

EFI_STATUS CreateStackDataForPeim(VOID)
{
  FSP_MEMORY_INIT_PARAMS *FspMemoryInitParams;
  FSP_STACK_DATA StackData;
  EFI_STATUS Status;

  //
  // Initialize the temporary data
  //
  SaveStackData(&StackData);
  StackData.InitRtBuffer = (FSP_INIT_RT_COMMON_BUFFER *)((FSP_MEMORY_INIT_PARAMS *)GetFspApiParameter())->RtBufferPtr;
  ASSERT (StackData.InitRtBuffer != NULL);
  StackData.Upd = GetFspMemoryInitUpdDataPointer();
  ASSERT (StackData.Upd != NULL);
  FspMemoryInitParams = (FSP_MEMORY_INIT_PARAMS *)GetFspApiParameter();
  StackData.HobListPtr = FspMemoryInitParams->HobListPtr;
  StackData.HeapStart = NULL;
  StackData.HobList = NULL;

  //
  // Initialize DRAM
  //
  Status = DoMemoryInit();
  if (!EFI_ERROR(Status)) {
    //
    // Migrate bootloader data before destroying CAR
    //
    FspMigrateTemporaryMemory();
    MrcDone();
  }
  return Status;
}

VOID FspInstallPeiMemory(EFI_PHYSICAL_ADDRESS FspReservedArea,
  UINT64 ReservedBytes)
{
  EFI_STATUS Status;

  //
  // Assign physical memory to PEI
  //
  Status = PeiServicesInstallPeiMemory (FspReservedArea, ReservedBytes);
  ASSERT_EFI_ERROR (Status);
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
