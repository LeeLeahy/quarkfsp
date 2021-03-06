/** @file
FspMemoryInit main routine

Copyright (c) 2015 - 2016 Intel Corporation.

This program and the accompanying materials are licensed and made available
under the terms and conditions of the BSD License which accompanies this
distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include "CommonHeader.h"
#include "MrcWrapper.h"
#include <Library/DebugLib.h>
#include <Library/FspMemoryInit.h>

/**
This function will be called when MRC is done.
**/
VOID
EFIAPI
MrcDone(
  VOID
)
{
  EFI_BOOT_MODE          BootMode;

  DEBUG((DEBUG_INFO, "MrcDone entered\n"));

  //
  // Create SMBIOS Memory Info HOB
  //
  BootMode = GetBootMode();
  if (BootMode != BOOT_ON_S3_RESUME) {
    DEBUG((DEBUG_INFO | DEBUG_INIT, "BuildFspSmbiosMemoryInfoHob\n"));
    BuildFspSmbiosMemoryInfoHob (MemoryTypeDdr3, DDRFREQ_800MHZ, 128, 16,
                                 ErrorDetectingMethodNone, NUM_CHANNELS,
                                 MAX_SOCKETS, &gFspSmbiosMemoryInfoHobGuid);
  }

  //
  // Calling use FspMemoryInit API
  // Return the control directly
  //
  ReturnHobListPointer(GetHobList());

  //
  // This is the end of the FspMemoryInit API
  // Give control back to the boot loader
  //
  DEBUG((DEBUG_INFO | DEBUG_INIT, "MrcDone exiting\n"));
}

/**
DoMemoryInit: Initialize DRAM for caller

@return EFI_SUCCESS  Memory initialization completed successfully.
                     Other error conditions are possible.
**/
EFI_STATUS
DoMemoryInit(
  VOID
)
{
  EFI_STATUS Status;

  //
  // Do SOC pre memory init.
  //
  PeiQNCPreMemInit ();

  //
  // Make legacy SPI READ/WRITE enabled if not a secure build
  //
  LpcPciCfg32And (R_QNC_LPC_BIOS_CNTL, ~B_QNC_LPC_BIOS_CNTL_BIOSWE);

  DEBUG((EFI_D_INFO, "MRC Entry\n"));
  Status = MemoryInit();

  return Status;
}
