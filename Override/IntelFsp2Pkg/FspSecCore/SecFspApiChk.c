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
  This function check the FSP API calling condition.

  @param[in]  ApiIdx           Internal index of the FSP API.
  @param[in]  ApiParam         Parameter of the FSP API.

**/
EFI_STATUS
EFIAPI
FspApiCallingCheck (
  IN UINT8     ApiIdx,
  IN VOID     *ApiParam
  )
{
  EFI_STATUS                Status;
  FSP_GLOBAL_DATA           *FspData;

  Status = EFI_SUCCESS;
  FspData = GetFspGlobalDataPointer ();

  if (ApiIdx == NotifyPhaseApiIndex) {
    //
    // NotifyPhase check
    //
    if ((FspData == NULL) || ((UINT32)FspData == 0xFFFFFFFF)) {
      Status = EFI_UNSUPPORTED;
    } else {
      if (FspData->Signature != FSP_GLOBAL_DATA_SIGNATURE) {
        Status = EFI_UNSUPPORTED;
      }
    }
  } else if (ApiIdx == FspMemoryInitApiIndex) {
    //
    // FspMemoryInit check
    //
    if ((UINT32)FspData != 0xFFFFFFFF) {
      Status = EFI_UNSUPPORTED;
    } else if (EFI_ERROR (FspUpdSignatureCheck (ApiIdx, ApiParam))) {
      Status = EFI_INVALID_PARAMETER;
    }
  } else if (ApiIdx == TempRamExitApiIndex) {
    //
    // TempRamExit check
    //
    if ((FspData == NULL) || ((UINT32)FspData == 0xFFFFFFFF)) {
      Status = EFI_UNSUPPORTED;
    } else {
      if (FspData->Signature != FSP_GLOBAL_DATA_SIGNATURE) {
        Status = EFI_UNSUPPORTED;
      }
    }
  } else if (ApiIdx == FspSiliconInitApiIndex) {
    //
    // FspSiliconInit check
    //
    if ((FspData == NULL) || ((UINT32)FspData == 0xFFFFFFFF)) {
      Status = EFI_UNSUPPORTED;
    } else {
      if (FspData->Signature != FSP_GLOBAL_DATA_SIGNATURE) {
        Status = EFI_UNSUPPORTED;
      } else if (EFI_ERROR (FspUpdSignatureCheck (ApiIdx, ApiParam))) {
        Status = EFI_INVALID_PARAMETER;
      }
    }
  } else {
    Status = EFI_UNSUPPORTED;
  }

  if (!EFI_ERROR (Status)) {
    if ((ApiIdx != FspMemoryInitApiIndex)) {
      //
      // For FspMemoryInit, the global data is not valid yet
      // The API index will be updated by SecCore after the global data
      // is initialized
      //
      SetFspApiCallingIndex (ApiIdx);
    }
  }

  return Status;
}

/**
This function check the signture of UPD.

@param[in]  ApiIdx           Internal index of the FSP API.
@param[in]  ApiParam         Parameter of the FSP API.

**/
EFI_STATUS
EFIAPI
FspUpdSignatureCheck(
IN UINT32   ApiIdx,
IN VOID     *ApiParam
)
{
  FSP_UPD_HEADER *FspUpdHeader;

  FspUpdHeader = ApiParam;
  if ((ApiIdx == 3) && (FspUpdHeader->Signature == FSPM_UPD_SIGNATURE)) {
    return EFI_SUCCESS;
  }
  if ((ApiIdx == 5) && (FspUpdHeader->Signature == FSPS_UPD_SIGNATURE)) {
    return EFI_SUCCESS;
  }

  return EFI_INVALID_PARAMETER;
}
