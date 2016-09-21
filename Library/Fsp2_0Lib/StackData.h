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
#include <FspmUpd.h>

typedef struct _FSP_STACK_DATA {
  FSPM_UPD *Upd;
} FSP_STACK_DATA;

#endif // __STACK_DATA_H__
