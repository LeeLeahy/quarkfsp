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

VOID FspMigrateTemporaryMemory(VOID);
UINT32 GetBootLoaderTolumSize(VOID);
UINT32 GetBootMode(VOID);
UINT32 GetEccScrubBlkSize(VOID);
UINT32 GetEccScrubInterval(VOID);
UINT32 GetFspReservedMemoryLength(VOID);
UINT32 GetMrcDataLength(VOID);
UINT32 GetMrcDataPtr(VOID);
UINT32 GetRmuBaseAddress(VOID);
UINT32 GetRmuLength(VOID);
UINT8 GetSmmTsegSize(VOID);
VOID ReturnHobListPointer(VOID *HobList);

/**
  Polls a serial device to see if there is any data waiting to be read.

  Polls a serial device to see if there is any data waiting to be read.
  If there is data waiting to be read from the serial device, then TRUE is
  returned.  If there is no data waiting to be read from the serial device,
  then FALSE is returned.

  @retval TRUE       Data is waiting to be read from the serial device.
  @retval FALSE      There is no data waiting to be read from the serial device.

**/
typedef INTN EFIAPI (*FN_SERIAL_PORT_POLL_FOR_CHAR)(VOID);

/**
  Reads a data byte from the serial device.

  @return Next character from the serial device.

**/
typedef UINT8 EFIAPI (*FN_SERIAL_PORT_READ_CHAR)(VOID);

/**
  Write data from buffer to serial device.

  Writes NumberOfBytes data bytes from Buffer to the serial device.
  The number of bytes actually written to the serial device is returned.

  If NumberOfBytes is zero, don't output any data but instead wait until
  the serial port has output all data, then return 0.

  @param  Buffer           Pointer to the data buffer to be written.
  @param  NumberOfBytes    Number of bytes to written to the serial device.

  @retval 0                NumberOfBytes is 0.
  @retval >0               The number of bytes written to the serial device.
                           If this value is less than NumberOfBytes, then the
                           write operation failed.

**/
typedef UINTN EFIAPI (*FN_SERIAL_PORT_WRITE_CHAR)(
  IN UINT8     *Buffer,
  IN UINTN     NumberOfBytes
);

/* Poll for an input character.  Passing in NULL (zero, 0) tells FSP to
 * indicate that no character is available.
 */
FN_SERIAL_PORT_POLL_FOR_CHAR GetSerialPortPollForChar(VOID);

/* Read an input character.  Passing in NULL (zero) tells FSP to indicate
 * that no characters are available by returning zero (0).
 */
FN_SERIAL_PORT_READ_CHAR GetSerialPortReadChar(VOID);

/* Write a single character to the serial device/log.
 * Passing in NULL (zero, 0) tells FSP to fake a successful write operation by
 * dropping the buffer contents and returning the number of characters that
 * were in the buffer.
 */
FN_SERIAL_PORT_WRITE_CHAR GetSerialPortWriteChar(VOID);

#endif // __FSP_LIB_H__

