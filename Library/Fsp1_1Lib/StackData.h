/** @file
Temporary data on the stack.

Copyright (c) 2016 Intel Corporation.

This program and the accompanying materials are licensed and made available
under the terms and conditions of the BSD License which accompanies this
distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#ifndef __STACK_DATA_H__
#define __STACK_DATA_H__

#include <Pi/PiBootMode.h>
#include <FspUpdVpd.h>

typedef struct _FSP_STACK_DATA {
  FSP_INIT_RT_COMMON_BUFFER *InitRtBuffer;  // Input to MemoryInit
  MEMORY_INIT_UPD *Upd; // Input to MemoryInit, parameters for MemoryInit
  VOID **HobListPtr;    // Input to MemoryInit, buffer to receive HobList ptr
  VOID *HobList;        // Pointer to end of heap
  VOID *HeapStart;      // Pointer to beginning of heap
} FSP_STACK_DATA;

/**
FspMemoryInit: Initialize DRAM for caller

@param StackData     Pointer to the temporary data structure with only the
                     InitRtBuffer, Upd and HobListPtr fields initialized.

@return EFI_SUCCESS  Memory initialization completed successfully.
                     Other error conditions are possible.
**/
EFI_STATUS
FspMemoryInit(
  FSP_STACK_DATA *StackData
);

#endif // __STACK_DATA_H__
