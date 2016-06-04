/** @file
DirectSerial function prototype definitions.

Copyright (c) 2016 Intel Corporation.

This program and the accompanying materials are licensed and made available
under the terms and conditions of the BSD License which accompanies this
distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#ifndef __DIRECT_SERIAL_H__
#define __DIRECT_SERIAL_H__

UINT8
EFIAPI
NibbleToAscii (
  UINTN Data
  );

VOID
EFIAPI
SerialPortWriteHex1 (
  UINTN Data
  );

VOID
EFIAPI
SerialPortWriteHex2 (
  UINTN Data
  );

VOID
EFIAPI
SerialPortWriteHex4 (
  UINTN Data
  );

VOID
EFIAPI
SerialPortWriteAddress (
  VOID * Address
  );

VOID
EFIAPI
SerialPortWriteString (
  CONST CHAR8 *String
  );

VOID
EFIAPI
SerialPortWriteCrLf (
  VOID
  );

#endif // #ifndef __DIRECT_SERIAL_H__
