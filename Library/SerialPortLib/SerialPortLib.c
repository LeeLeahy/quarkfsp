/** @file
  16550 UART Serial Port library functions

  (C) Copyright 2014 Hewlett-Packard Development Company, L.P.<BR>
  Copyright (c) 2006 - 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials are licensed and made available
  under the terms and conditions of the BSD License which accompanies this
  distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include <Base.h>
#include <Library/SerialPortLib.h>
#include <Library/FspLib.h>

/**
  Initialize the serial device hardware.

  @retval RETURN_SUCCESS        The serial device was initialized.

**/
RETURN_STATUS
EFIAPI
SerialPortInitialize (
  VOID
  )
{
  return RETURN_SUCCESS;
}

/**
  Write data from buffer to serial device.

  Writes NumberOfBytes data bytes from Buffer to the serial device.
  The number of bytes actually written to the serial device is returned.

  If NumberOfBytes is zero, then return 0.

  @param  Buffer           Pointer to the data buffer to be written.
  @param  NumberOfBytes    Number of bytes to written to the serial device.

  @retval 0                NumberOfBytes is 0.
  @retval >0               The number of bytes written to the serial device.
                           If this value is less than NumberOfBytes, then the
                           write operation failed.

**/
UINTN
EFIAPI
SerialPortWrite (
  IN UINT8     *Buffer,
  IN UINTN     NumberOfBytes
  )
{
  FN_SERIAL_PORT_WRITE_CHAR SerialPortWriteChar;

  if (Buffer == NULL) {
    return 0;
  }

  SerialPortWriteChar = GetSerialPortWriteChar();
  if (SerialPortWriteChar == 0) {
    /* Discard all of the characters */
    return NumberOfBytes;
  }

  return SerialPortWriteChar(Buffer, NumberOfBytes);
}

/**
  Reads data from a serial device into a buffer.

  @param  Buffer           Pointer to the data buffer to store the data read
                           from the serial device.
  @param  NumberOfBytes    Number of bytes to read from the serial device.

  @retval 0                NumberOfBytes is 0.
  @retval >0               The number of bytes read from the serial device.
                           If this value is less than NumberOfBytes, then the
                           read operation failed.

**/
UINTN
EFIAPI
SerialPortRead (
  OUT UINT8     *Buffer,
  IN  UINTN     NumberOfBytes
  )
{
  FN_SERIAL_PORT_READ_CHAR SerialPortReadChar;
  UINTN  Result;

  if (NULL == Buffer) {
    return 0;
  }

  SerialPortReadChar = GetSerialPortReadChar();
  if (SerialPortReadChar == 0) {
    return 0;
  }

  for (Result = 0; NumberOfBytes-- != 0; Result++, Buffer++) {
    //
    // Wait for the serial port to have some data.
    //
    while (!SerialPortPoll());

    //
    // Read byte from the receive buffer.
    //
    *Buffer = SerialPortReadChar();
  }

  return Result;
}


/**
  Polls a serial device to see if there is any data waiting to be read.

  Polls a serial device to see if there is any data waiting to be read.
  If there is data waiting to be read from the serial device, then TRUE is
  returned.  If there is no data waiting to be read from the serial device,
  then FALSE is returned.

  @retval TRUE       Data is waiting to be read from the serial device.
  @retval FALSE      There is no data waiting to be read from the serial device.

**/
BOOLEAN
EFIAPI
SerialPortPoll (
  VOID
  )
{
  FN_SERIAL_PORT_POLL_FOR_CHAR SerialPortPollForChar;

  SerialPortPollForChar = GetSerialPortPollForChar();
  if (SerialPortPollForChar == 0) {
    return FALSE;
  }

  return (BOOLEAN)SerialPortPollForChar();
}
