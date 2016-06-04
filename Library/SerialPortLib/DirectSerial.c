/** @file
  Early serial debug functions to display values

  Copyright (c) 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials are licensed and made available
  under the terms and conditions of the BSD License which accompanies this
  distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include <Base.h>
#include <Library/BaseLib.h>
#include <Library/DirectSerial.h>
#include <Library/SerialPortLib.h>

UINT8
EFIAPI
NibbleToAscii (
  UINTN Data
  )
{
  UINTN Digit;

  /* Get the nibble and convert it to an ASCII HEX digit */
  Digit = Data & 0xf;
  Digit += '0';
  if ( Digit > '9' ) {
    Digit += 'A' - '0' - 10;
  }
  return (UINT8)Digit;
}

VOID
EFIAPI
SerialPortWriteHex1 (
  UINTN Data
  )
{
  UINT8 Buffer[3];

  Buffer[0] = NibbleToAscii(Data >> 4);
  Buffer[1] = NibbleToAscii(Data);
  Buffer[2] = 0;
  SerialPortWrite (&Buffer[0], sizeof(Buffer));
}

VOID
EFIAPI
SerialPortWriteHex2 (
  UINTN Data
  )
{
  SerialPortWriteHex1(Data >> 8);
  SerialPortWriteHex1(Data);
}

VOID
EFIAPI
SerialPortWriteHex4 (
  UINTN Data
  )
{
  SerialPortWriteHex2(Data >> 16);
  SerialPortWriteHex2(Data);
}

VOID
EFIAPI
SerialPortWriteAddress (
  VOID * Address
  )
{
  SerialPortWriteHex4((UINTN)Address);
}

VOID
EFIAPI
SerialPortWriteString (
  CONST CHAR8 *String
  )
{
  SerialPortWrite((UINT8 *)String, AsciiStrLen(String));
}

VOID
EFIAPI
SerialPortWriteCrLf (
  VOID
  )
{
  SerialPortWriteString ("\r\n");
}
