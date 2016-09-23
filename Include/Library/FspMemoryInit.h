/** @file
FspMemoryInit function prototype definitions.

Copyright (c) 2016 Intel Corporation.

This program and the accompanying materials are licensed and made available
under the terms and conditions of the BSD License which accompanies this
distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#ifndef __FSP_MEMORY_INIT_H__
#define __FSP_MEMORY_INIT_H__

typedef struct _FSP_STACK_DATA *PTR_FSP_STACK_DATA;

/**
CreateStackDataForPeim: Create the stack data and initialize DRAM for caller

@return EFI_SUCCESS  Memory initialization completed successfully.
                     Other error conditions are possible.
**/
EFI_STATUS
EFIAPI
CreateStackDataForPeim(
  VOID
  );

/**
DoMemoryInit: Callback from FspLib to initialize DRAM for caller

@return EFI_SUCCESS  Memory initialization completed successfully.
                     Other error conditions are possible.
**/
EFI_STATUS
DoMemoryInit(
  VOID
);

/**
This function will be called when MRC is done.
**/
VOID
EFIAPI
MrcDone(
  VOID
);

PTR_FSP_STACK_DATA GetStackData(VOID);
VOID SaveStackData(PTR_FSP_STACK_DATA StackData);

VOID *
EFIAPI
InternalPeiCreateHob (
  IN UINT16 Type,
  IN UINT16 Length
  );

#endif // __FSP_MEMORY_INIT_H__
