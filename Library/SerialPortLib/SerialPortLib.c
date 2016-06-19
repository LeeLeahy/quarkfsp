/** @file
  16550 UART Serial Port library functions

  (C) Copyright 2014 Hewlett-Packard Development Company, L.P.<BR>
  Copyright (c) 2006 - 2016, Intel Corporation. All rights reserved.<BR>
  This program and the accompanying materials
  are licensed and made available under the terms and conditions of the BSD License
  which accompanies this distribution.  The full text of the license may be found at
  http://opensource.org/licenses/bsd-license.php

  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include <Base.h>
#include <IndustryStandard/Pci.h>
#include <Library/SerialPortLib.h>
#include <Library/PcdLib.h>
#include <Library/IoLib.h>
#include <Library/BaseLib.h>
#include <Library/FspCommonLib.h>
#include <FspUpdVpd.h>
#include <Library/DebugLib.h>

//
// 16550 UART register offsets and bitfields
//
#define R_UART_RXBUF          0
#define R_UART_TXBUF          0
#define R_UART_BAUD_LOW       0
#define R_UART_BAUD_HIGH      4
#define R_UART_FCR            8
#define   B_UART_FCR_FIFOE    BIT0
#define   B_UART_FCR_FIFO64   BIT5
#define R_UART_LCR            12
#define   B_UART_LCR_DLAB     BIT7
#define R_UART_MCR            16
#define   B_UART_MCR_DTRC     BIT0
#define   B_UART_MCR_RTS      BIT1
#define R_UART_LSR            20
#define   B_UART_LSR_RXRDY    BIT0
#define   B_UART_LSR_TXRDY    BIT5
#define   B_UART_LSR_TEMT     BIT6
#define R_UART_MSR            24
#define   B_UART_MSR_CTS      BIT4
#define   B_UART_MSR_DSR      BIT5
#define   B_UART_MSR_RI       BIT6
#define   B_UART_MSR_DCD      BIT7

/**
  Get the serial port register base

  @retval BaseRegisterAddress   The serial port register base address

**/
UINTN GetSerialPortRegisterBase (void)
{
  MEMORY_INIT_UPD *MemoryInitUpd;
  UINTN SerialPortRegisterBase;

  SerialPortRegisterBase = 0;
  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  if (MemoryInitUpd != NULL) {
    SerialPortRegisterBase = MemoryInitUpd->SerialPortBaseAddress;
  }
  return SerialPortRegisterBase;
}

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
  UINT8 *BufferEnd;
  UINTN  SerialRegisterBase;

  if (Buffer == NULL) {
    return 0;
  }

  SerialRegisterBase = GetSerialPortRegisterBase ();
  if (SerialRegisterBase == 0) {
    /* Discard all of the characters */
    return NumberOfBytes;
  }

  if (NumberOfBytes == 0) {
    //
    // Flush the hardware
    // Wait for both the transmit FIFO and shift register empty.
    //
    while ((MmioRead8 (SerialRegisterBase + R_UART_LSR)
      & (B_UART_LSR_TEMT | B_UART_LSR_TXRDY))
      != (B_UART_LSR_TEMT | B_UART_LSR_TXRDY));
    return 0;
  } else {
    BufferEnd = &Buffer[NumberOfBytes];
    while (Buffer < BufferEnd) {
      //
      // Wait for the serial port to be ready, to make sure both the transmit FIFO
      // and shift register empty.
      //
      while ((MmioRead8 (SerialRegisterBase + R_UART_LSR)
        & B_UART_LSR_TXRDY) == 0);

      //
      // Write byte to the transmit buffer.
      //
      MmioWrite8 (SerialRegisterBase + R_UART_TXBUF, *Buffer++);
    }
  }
  return NumberOfBytes;
}

/**
  Reads data from a serial device into a buffer.

  @param  Buffer           Pointer to the data buffer to store the data read from the serial device.
  @param  NumberOfBytes    Number of bytes to read from the serial device.

  @retval 0                NumberOfBytes is 0.
  @retval >0               The number of bytes read from the serial device.
                           If this value is less than NumberOfBytes, then the read operation failed.

**/
UINTN
EFIAPI
SerialPortRead (
  OUT UINT8     *Buffer,
  IN  UINTN     NumberOfBytes
  )
{
  UINTN  SerialRegisterBase;
  UINTN  Result;
  UINT8  Mcr;

  if (NULL == Buffer) {
    return 0;
  }

  SerialRegisterBase = GetSerialPortRegisterBase ();
  if (SerialRegisterBase == 0) {
    return 0;
  }

  Mcr = MmioRead8 (SerialRegisterBase + R_UART_MCR);

  for (Result = 0; NumberOfBytes-- != 0; Result++, Buffer++) {
    //
    // Set RTS to let the peer send some data
    //
    if ((MmioRead8 (SerialRegisterBase + R_UART_LSR) & B_UART_LSR_RXRDY) == 0) {
      MmioWrite8 (SerialRegisterBase + R_UART_MCR, Mcr | B_UART_MCR_RTS);
    }

    //
    // Wait for the serial port to have some data.
    //
    while ((MmioRead8 (SerialRegisterBase + R_UART_LSR) & B_UART_LSR_RXRDY)
      == 0);

    //
    // Clear RTS to prevent peer from sending data
    //
    MmioWrite8 (SerialRegisterBase + R_UART_MCR, Mcr & ~B_UART_MCR_RTS);

    //
    // Read byte from the receive buffer.
    //
    *Buffer = MmioRead8 (SerialRegisterBase + R_UART_RXBUF);
  }

  return Result;
}


/**
  Polls a serial device to see if there is any data waiting to be read.

  Polls aserial device to see if there is any data waiting to be read.
  If there is data waiting to be read from the serial device, then TRUE is returned.
  If there is no data waiting to be read from the serial device, then FALSE is returned.

  @retval TRUE             Data is waiting to be read from the serial device.
  @retval FALSE            There is no data waiting to be read from the serial device.

**/
BOOLEAN
EFIAPI
SerialPortPoll (
  VOID
  )
{
  UINT8  Mcr;
  UINTN  SerialRegisterBase;

  SerialRegisterBase = GetSerialPortRegisterBase ();
  if (SerialRegisterBase == 0) {
    return FALSE;
  }

  //
  // Read the serial port status
  //
  Mcr = MmioRead8 (SerialRegisterBase + R_UART_MCR);
  if ((MmioRead8 (SerialRegisterBase + R_UART_LSR) & B_UART_LSR_RXRDY) != 0) {
    //
    // Clear RTS to prevent peer from sending data
    //
    if ((Mcr & B_UART_MCR_RTS) != 0) {
      MmioWrite8 (SerialRegisterBase + R_UART_MCR, Mcr & ~B_UART_MCR_RTS);
    }
    return TRUE;
  }

  //
  // Set RTS to let the peer send some data
  //
  if ((Mcr & B_UART_MCR_RTS) != 0) {
    MmioWrite8 (SerialRegisterBase + R_UART_MCR, Mcr | B_UART_MCR_RTS);
  }
  return FALSE;
}
