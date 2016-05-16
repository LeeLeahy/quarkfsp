/** @file
This PEIM initialize platform for MRC, following action is performed,
1. Initizluize GMCH
2. Detect boot mode
3. Detect video adapter to determine whether we need pre allocated memory
4. Calls MRC to initialize memory and install a PPI notify to do post memory initialization.
This file contains the main entrypoint of the PEIM.

Copyright (c) 2013 - 2016 Intel Corporation.

This program and the accompanying materials
are licensed and made available under the terms and conditions of the BSD License
which accompanies this distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/


#include "CommonHeader.h"

//
// Function prototypes to routines implemented in other source modules
// within this component.
//

EFI_STATUS
EFIAPI
PlatformErratasPostMrc (
  VOID
  );

//
// The global indicator, the FvFileLoader callback will modify it to TRUE after loading PEIM into memory
//
BOOLEAN ImageInMemory = FALSE;

/**
  This is the entrypoint of PEIM

  @param  FileHandle  Handle of the file being invoked.
  @param  PeiServices Describes the list of possible PEI Services.

  @retval EFI_SUCCESS if it completed successfully.
**/
EFI_STATUS
EFIAPI
BiosAfterMemoryInit(
  IN       EFI_PEI_FILE_HANDLE  FileHandle,
  IN CONST EFI_PEI_SERVICES     **PeiServices
  )
{
  EFI_STATUS                              Status = EFI_SUCCESS;
  EFI_BOOT_MODE                           BootMode;
  EFI_PLATFORM_TYPE                       PlatformType;

  MEMORY_INIT_UPD  *MemoryInitUpdPtr = (MEMORY_INIT_UPD *)GetFspMemoryInitUpdDataPointer();
  PlatformType = MemoryInitUpdPtr->PcdPlatformType;

  //
  // Do platform specific logic to create a boot mode
  //
  Status = PeiServicesGetBootMode(&BootMode);
  ASSERT_EFI_ERROR(Status);

  //
  // Do Early PCIe init.
  //
  DEBUG ((EFI_D_INFO, "Early PCIe controller initialization\n"));
  PlatformPciExpressEarlyInit (PlatformType);


  DEBUG ((EFI_D_INFO, "Platform Erratas After MRC\n"));
  PlatformErratasPostMrc ();

  return Status;
}
