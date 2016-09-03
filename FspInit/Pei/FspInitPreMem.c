/** @file
This FspInitPreMem PEIM initialize system before MRC, following action is performed,
1. Get boot mode from boot loader.
2. Initialize MRC
3. TODO

Copyright (c) 2015 - 2016 Intel Corporation.

This program and the accompanying materials
are licensed and made available under the terms and conditions of the BSD License
which accompanies this distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include "FspInitPreMem.h"
#include "CommonHeader.h"
#include "MrcWrapper.h"
#include <Library/DebugLib.h>

EFI_PEI_NOTIFY_DESCRIPTOR mMemoryDiscoveredNotifyList[] = {
  {
    (EFI_PEI_PPI_DESCRIPTOR_NOTIFY_CALLBACK | EFI_PEI_PPI_DESCRIPTOR_TERMINATE_LIST),
    &gEfiPeiMemoryDiscoveredPpiGuid,
    MemoryDiscoveredPpiNotifyCallback
  }
};

/**
  This function will be called when MRC is done.

  @param  PeiServices General purpose services available to every PEIM.

  @retval EFI_SUCCESS If the function completed successfully.
**/
EFI_STATUS
EFIAPI
FspSpecificMemoryDiscoveredHook (
  IN EFI_PEI_SERVICES           **PeiServices,
  IN EFI_BOOT_MODE                BootMode
)
{
  EFI_STATUS                            Status = EFI_SUCCESS;
  UINT32                                RegData32;
  UINT8                                 CpuAddressWidth;
  UINT32                                RegEax;

  DEBUG ((EFI_D_INFO, "FSP Specific PEIM Memory Callback\n"));

  //
  // Do QNC initialization after MRC
  //
  PeiQNCPostMemInit ();

  //
  // Set E000/F000 Routing
  //
  RegData32 = QNCPortRead (QUARK_NC_HOST_BRIDGE_SB_PORT_ID, QNC_MSG_FSBIC_REG_HMISC);
  RegData32 |= (BIT2|BIT1);
  QNCPortWrite (QUARK_NC_HOST_BRIDGE_SB_PORT_ID, QNC_MSG_FSBIC_REG_HMISC, RegData32);

  if (BootMode == BOOT_ON_S3_RESUME) {
    return EFI_SUCCESS;
  }

  //
  // Build flash HOB, it's going to be used by GCD and E820 building
  // Map full SPI flash decode range (regardless of smaller SPI flash parts installed)
  //
  BuildResourceDescriptorHob (
    EFI_RESOURCE_FIRMWARE_DEVICE,
    (EFI_RESOURCE_ATTRIBUTE_PRESENT    |
    EFI_RESOURCE_ATTRIBUTE_INITIALIZED |
    EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE),
    (SIZE_4GB - SIZE_8MB),
    SIZE_8MB
    );

  //
  // Create a CPU hand-off information
  //
  CpuAddressWidth = 32;
  AsmCpuid (CPUID_EXTENDED_FUNCTION, &RegEax, NULL, NULL, NULL);
  if (RegEax >= CPUID_VIR_PHY_ADDRESS_SIZE) {
    AsmCpuid (CPUID_VIR_PHY_ADDRESS_SIZE, &RegEax, NULL, NULL, NULL);
    CpuAddressWidth = (UINT8) (RegEax & 0xFF);
  }
  DEBUG ((EFI_D_INFO, "CpuAddressWidth: %d\n", CpuAddressWidth));

  BuildCpuHob (CpuAddressWidth, 16);

  ASSERT_EFI_ERROR (Status);

  return Status;
}

/**
This function will be called when MRC is done.

@param  PeiServices General purpose services available to every PEIM.

@param  NotifyDescriptor Information about the notify event..

@param  Ppi The notify context.

@retval EFI_SUCCESS If the function completed successfully.
**/
EFI_STATUS
EFIAPI
MemoryDiscoveredPpiNotifyCallback(
IN EFI_PEI_SERVICES           **PeiServices,
IN EFI_PEI_NOTIFY_DESCRIPTOR  *NotifyDescriptor,
IN VOID                       *Ppi
)
{
  EFI_BOOT_MODE          BootMode;
  EFI_HOB_GUID_TYPE      *GuidHob;

  DEBUG((DEBUG_INFO, "Memory Discovered Notify invoked ...\n"));

  //============================================================
  //  MemoryInit
  //============================================================
  //
  // Migrate bootloader data before destroying CAR
  //
  FspMigrateTemporaryMemory();

  //
  // Get Boot Mode
  //
  BootMode = GetBootMode();

  //
  // FSP specific hook
  //
  FspSpecificMemoryDiscoveredHook(PeiServices, BootMode);

  //
  // Build FSP Non-Volatile Storage Hob
  //
  if (BootMode  != BOOT_ON_S3_RESUME) {
    GuidHob = GetFirstGuidHob (&gEfiMemoryConfigDataGuid);
    if (GuidHob != NULL) {
      //
      // Include the EFI_HOB_GENERIC_HEADER header in HOB.
      //
      BuildGuidDataHob (&gFspNonVolatileStorageHobGuid, (void *)((UINTN)GET_GUID_HOB_DATA (GuidHob) - sizeof (EFI_HOB_GUID_TYPE)), GET_GUID_HOB_DATA_SIZE (GuidHob) + sizeof (EFI_HOB_GUID_TYPE));
    }
  }

  // Create SMBIOS Memory Info HOB
  DEBUG((DEBUG_INFO | DEBUG_INIT, "BuildFspSmbiosMemoryInfoHob\n"));
  BuildFspSmbiosMemoryInfoHob (MemoryTypeDdr3, DDRFREQ_800MHZ, 128, 16,
                               ErrorDetectingMethodNone, NUM_CHANNELS,
                               MAX_SOCKETS, &gFspSmbiosMemoryInfoHobGuid);

  //
  // Calling use FspMemoryInit API
  // Return the control directly
  //
  ReturnHobListPointer(GetHobList());

  //
  // This is the end of the FspMemoryInit API
  // Give control back to the boot loader
  //
  DEBUG((DEBUG_INFO | DEBUG_INIT, "FspMemoryInitApi() - End\n"));
  SetFspApiReturnStatus(EFI_SUCCESS);
  Pei2LoaderSwitchStack();
  return EFI_SUCCESS;
}

/**

Do FSP Pre-Memory initialization

@param  FfsHeader    Not used.
@param  PeiServices  General purpose services available to every PEIM.

@return EFI_SUCCESS  Memory initialization completed successfully.
All other error conditions encountered result in an ASSERT.

**/
EFI_STATUS
PeimFspInitPreMem(
IN       EFI_PEI_FILE_HANDLE  FileHandle,
IN CONST EFI_PEI_SERVICES     **PeiServices
)
{
  EFI_STATUS                 Status;

  //
  // Now that all of the pre-permament memory activities have
  // been taken care of, post a call-back for the permament-memory
  // resident services, such as HOB construction.
  // PEI Core will switch stack after this PEIM exit.  After that the MTRR
  // can be set.
  //
DEBUG((EFI_D_ERROR, "PeimFspInitPreMem Calling NotifyPpi\r\n"));
  Status = (**PeiServices).NotifyPpi(PeiServices, &mMemoryDiscoveredNotifyList[0]);
  ASSERT_EFI_ERROR(Status);

  //
  // Do SOC Init Pre memory init.
  //
DEBUG((EFI_D_ERROR, "PeimFspInitPreMem Calling PeiQNCPreMemInit\r\n"));
  PeiQNCPreMemInit ();

  //
  // Make legacy SPI READ/WRITE enabled if not a secure build
  //
DEBUG((EFI_D_ERROR, "PeimFspInitPreMem Calling LpcPciCfg32And\r\n"));
  LpcPciCfg32And (R_QNC_LPC_BIOS_CNTL, ~B_QNC_LPC_BIOS_CNTL_BIOSWE);

DEBUG((EFI_D_ERROR, "PeimFspInitPreMem Calling MemoryInit\r\n"));
  DEBUG((EFI_D_INFO, "MRC Entry\n"));
  MemoryInit((EFI_PEI_SERVICES**)PeiServices);

  return Status;
}
