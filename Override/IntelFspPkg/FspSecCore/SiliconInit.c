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
  This API should be called only once after the FspMemoryInit API.

  This API tears down the temporary memory area set up in the cache and returns
  the cache to normal mode of operation. After the cache is returned to normal
  mode of operation, any data that was in the temporary memory is destroyed. It
  is therefore expected that the bootloader migrates any data that it might have
  had in the temporary memory area and also set up a stack in the system memory
  before calling TempRamExit API.

  After the TempRamExit API returns, the bootloader is expected to set up the
  BSP MTRRs to enable caching. The bootloader can collect the system memory map
  information by parsing the HOB data structures and use this to set up the MTRR
  and enable caching.

  FspMemoryInit, TempRamExit and FspSiliconInit API provide an alternate method
  to complete the silicon initialization and provides bootloader an opportunity
  to get control after system memory is available and before the temporary
  memory is torn down.

  @param[in] FspSiliconInitParamPtr   Pointer to the Silicon Init parameters
                                      structure.  This structure is normally
                                      defined in the Integration Guide. If it
                                      is not defined in the Integration Guide,
                                      pass NULL.

  @return  EFI_SUCCESS            FSP execution environment was initialized
                                  successfully.
           EFI_INVALID_PARAMETER  Input parameters are invalid.
           EFI_UNSUPPORTED        The FSP calling conditions were not met.
           EFI_DEVICE_ERROR       FSP silicon initialization failed.

**/
UINT32
EFIAPI
FspSiliconInitApi (
  IN OUT VOID *FspSiliconInitParamPtr
  )
{
  return EFI_SUCCESS;
}
