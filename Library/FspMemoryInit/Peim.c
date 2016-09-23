/** @file
PEM support

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
  EFI_STATUS Status;

  Status = CreateStackDataForPeim();
  SetFspApiReturnStatus(Status);
  Pei2LoaderSwitchStack();
  return Status;
}
