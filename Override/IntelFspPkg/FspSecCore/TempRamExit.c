/** @file

  Copyright (c) 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials are licensed and made available
  under the terms and conditions of the BSD License which accompanies this
  distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php.

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include "SecFsp.h"

/**
  This FSP API is called after FspMemoryInit API. This FSP API tears down the
  temporary memory set up by TempRamInit API. This FSP API accepts a pointer to
  a data structure that will be platform dependent and defined for each FSP
  binary. This will be documented in the Integration Guide.

  FspMemoryInit, TempRamExit and FspSiliconInit API provide an alternate method
  to complete the silicon initialization and provides bootloader an opportunity
  to get control after system memory is available and before the temporary
  memory is torn down.

  @param[in,out] TempRamExitParamPtr  Pointer to the TempRamExit parameters
                                      structure.  This structure is normally
                                      defined in the Integration Guide. If it
                                      is not defined in the Integration Guide,
                                      pass NULL.

  @return  EFI_SUCCESS            FSP execution environment was initialized
                                  successfully.
           EFI_INVALID_PARAMETER  Input parameters are invalid.
           EFI_UNSUPPORTED        The FSP calling conditions were not met.
           EFI_DEVICE_ERROR       Temporary memory exit failed.

**/
UINT32
EFIAPI
TempRamExitApi (
  IN OUT VOID *TempRamExitParamPtr
  )
{
  return EFI_SUCCESS;
}
