/** @file
  Serial support functions using FspCommon library

  Copyright (c) 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials are licensed and made available
  under the terms and conditions of the BSD License which accompanies this
  distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include <PiPei.h>
#include <FspApi.h>
#include <Library/DebugLib.h>
#include <Library/FspCommonLib.h>
#include <Library/FspLib.h>
#include <Library/FspMemoryLib.h>
#include <Library/FspMemoryInit.h>
#include <FspUpdVpd.h>
#include "StackData.h"

FN_SERIAL_PORT_POLL_FOR_CHAR GetSerialPortPollForChar(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;

  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (MemoryInitUpd != NULL);
  return (FN_SERIAL_PORT_POLL_FOR_CHAR)MemoryInitUpd->SerialPortPollForChar;
}

FN_SERIAL_PORT_READ_CHAR GetSerialPortReadChar(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;

  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (MemoryInitUpd != NULL);
  return (FN_SERIAL_PORT_READ_CHAR)MemoryInitUpd->SerialPortReadChar;
}

FN_SERIAL_PORT_WRITE_CHAR GetSerialPortWriteChar(VOID)
{
  MEMORY_INIT_UPD *MemoryInitUpd;

  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  ASSERT (MemoryInitUpd != NULL);
  return (FN_SERIAL_PORT_WRITE_CHAR)MemoryInitUpd->SerialPortWriteChar;
}
