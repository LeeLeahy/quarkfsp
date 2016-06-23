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
  This FSP API is used to notify the FSP about the different phases in the boot
  process.

  This allows the FSP to take appropriate actions as needed during different
  initialization phases. The phases will be platform dependent and will be
  documented with the FSP release. The current FSP supports two notify phases:

  * Post PCI enumeration
  * Ready To Boot


  @param[in] NotifyPhaseParamPtr  Address pointer to the NOTIFY_PHASE_PARAMS

  @return  EFI_SUCCESS            FSP execution environment was initialized
                                  successfully.
           EFI_INVALID_PARAMETER  Input parameters are invalid.
           EFI_UNSUPPORTED        The FSP calling conditions were not met.
           EFI_DEVICE_ERROR       FSP silicon initialization failed.

**/
UINT32
EFIAPI
NotifyPhaseApi (
  IN NOTIFY_PHASE_PARAMS *NotifyPhaseParamPtr
  )
{
  return EFI_SUCCESS;
}
