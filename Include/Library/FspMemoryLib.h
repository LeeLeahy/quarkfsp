/** @file
FspLib memory function prototype definitions.

Copyright (c) 2016 Intel Corporation.

This program and the accompanying materials are licensed and made available
under the terms and conditions of the BSD License which accompanies this
distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#ifndef __FSP_MEMORY_LIB_H__
#define __FSP_MEMORY_LIB_H__

#include <Ppi/QNCMemoryInit.h>

VOID
BuildFspSmbiosMemoryInfoHob (
  UINT8  MemoryType,
  UINT16 MemoryFrequencyInMHz,
  UINT32 SizeInMb,
  UINT16 DataWidth,
  UINT8  ErrorCorrectionType,
  UINT32 NumChannels,
  UINT32 MaxSockets,
  EFI_GUID *HobGuid
  );
VOID GetMemoryParameters (
  OUT MRC_PARAMS  *MrcData
  );

#endif // __FSP_MEMORY_LIB_H__

