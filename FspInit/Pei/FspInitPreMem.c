/** @file
This FspInitPreMem PEIM initialize system before MRC, following action is performed,
1. Get boot mode from boot loader.
2. Initialize MRC
3. TODO

Copyright (c) 2015 - 2016 Intel Corporation.

This program and the accompanying materials
are licensed and made available under the terms and conditions of the BSD License
which accompanies this distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include "CommonHeader.h"
#include "FspInitPreMem.h"
#include "MrcWrapper.h"
#include <Library/DebugLib.h>

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
  EFI_HOB_GUID_TYPE      *GuidHob;
  UINT32                 RegData32;

  DEBUG((DEBUG_INFO, "MrcDone entered\n"));

  //============================================================
  //  MemoryInit
  //============================================================
  //
  // Migrate bootloader data before destroying CAR
  //
  FspMigrateTemporaryMemory();

  //
  // Get Boot Mode
  //
  BootMode = GetBootMode();

  //
  // Do QNC initialization after MRC
  //
  PeiQNCPostMemInit ();

  //
  // Set E000/F000 Routing
  //
  RegData32 = QNCPortRead (QUARK_NC_HOST_BRIDGE_SB_PORT_ID, QNC_MSG_FSBIC_REG_HMISC);
  RegData32 |= (BIT2|BIT1);
  QNCPortWrite (QUARK_NC_HOST_BRIDGE_SB_PORT_ID, QNC_MSG_FSBIC_REG_HMISC, RegData32);

  //
  // Build FSP Non-Volatile Storage Hob
  //
  if (BootMode  != BOOT_ON_S3_RESUME) {
    GuidHob = GetFirstGuidHob (&gEfiMemoryConfigDataGuid);
    if (GuidHob != NULL) {
      //
      // Include the EFI_HOB_GENERIC_HEADER header in HOB.
      //
      BuildGuidDataHob (&gFspNonVolatileStorageHobGuid, (void *)((UINTN)GET_GUID_HOB_DATA (GuidHob) - sizeof (EFI_HOB_GUID_TYPE)), GET_GUID_HOB_DATA_SIZE (GuidHob) + sizeof (EFI_HOB_GUID_TYPE));
    }
  }

  // Create SMBIOS Memory Info HOB
  DEBUG((DEBUG_INFO | DEBUG_INIT, "BuildFspSmbiosMemoryInfoHob\n"));
  BuildFspSmbiosMemoryInfoHob (MemoryTypeDdr3, DDRFREQ_800MHZ, 128, 16,
                               ErrorDetectingMethodNone, NUM_CHANNELS,
                               MAX_SOCKETS, &gFspSmbiosMemoryInfoHobGuid);

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

Do FSP Pre-Memory initialization

@param  FfsHeader    Not used.
@param  PeiServices  General purpose services available to every PEIM.

@return EFI_SUCCESS  Memory initialization completed successfully.
All other error conditions encountered result in an ASSERT.

**/
EFI_STATUS
PeimFspInitPreMem(
IN       EFI_PEI_FILE_HANDLE  FileHandle,
IN CONST EFI_PEI_SERVICES     **PeiServices
)
{
  //
  // Do SOC Init Pre memory init.
  //
DEBUG((EFI_D_ERROR, "PeimFspInitPreMem Calling PeiQNCPreMemInit\r\n"));
  PeiQNCPreMemInit ();

  //
  // Make legacy SPI READ/WRITE enabled if not a secure build
  //
DEBUG((EFI_D_ERROR, "PeimFspInitPreMem Calling LpcPciCfg32And\r\n"));
  LpcPciCfg32And (R_QNC_LPC_BIOS_CNTL, ~B_QNC_LPC_BIOS_CNTL_BIOSWE);

DEBUG((EFI_D_ERROR, "PeimFspInitPreMem Calling MemoryInit\r\n"));
  DEBUG((EFI_D_INFO, "MRC Entry\n"));
  MemoryInit((EFI_PEI_SERVICES**)PeiServices);
  MrcDone();

  SetFspApiReturnStatus(EFI_SUCCESS);
  Pei2LoaderSwitchStack();
  return EFI_SUCCESS;
}
