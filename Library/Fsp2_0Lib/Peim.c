/** @file
  FSP 2.0 PEIM support functions

  Copyright (c) 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials are licensed and made available
  under the terms and conditions of the BSD License which accompanies this
  distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include <PiPei.h>
#include <Library/DebugLib.h>
#include <Library/FspCommonLib.h>
#include <Library/FspLib.h>
#include <Library/FspMemoryLib.h>
#include <Library/FspMemoryInit.h>
#include <Library/PeiServicesLib.h>
#include "StackData.h"

EFI_STATUS CreateStackDataForPeim(VOID)
{
  FSP_STACK_DATA StackData;
  EFI_STATUS Status;

  // Initialize the temporary data
  SaveStackData(&StackData);
  StackData.Upd = GetFspMemoryInitUpdDataPointer();
  ASSERT (StackData.Upd != NULL);
  StackData.HobListPtr = (VOID *)GetFspApiParameter2();
  StackData.HeapStart = NULL;
  StackData.HobList = NULL;

  // Initialize DRAM
  Status = DoMemoryInit();
  if (!EFI_ERROR(Status)) {
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
