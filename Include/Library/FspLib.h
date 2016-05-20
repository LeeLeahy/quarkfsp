/** @file
FspLib function prototype definitions.

Copyright (c) 2016 Intel Corporation.

This program and the accompanying materials are licensed and made available
under the terms and conditions of the BSD License which accompanies this
distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#ifndef __FSP_LIB_H__
#define __FSP_LIB_H__

UINT32 GetBootLoaderTolumSize(VOID);
UINT32 GetBootMode(VOID);
UINT32 GetEccScrubBlkSize(VOID);
UINT32 GetEccScrubInterval(VOID);
UINT32 GetFspReservedMemoryLength(VOID);
UINT32 GetMrcDataLength(VOID);
UINT32 GetMrcDataPtr(VOID);
UINT32 GetRmuBaseAddress(VOID);
UINT32 GetRmuLength(VOID);
UINTN GetSerialPortRegisterBase(VOID);
UINT8 GetSmmTsegSize(VOID);
VOID ReturnHobListPointer(VOID *HobList);

#endif // __FSP_LIB_H__

