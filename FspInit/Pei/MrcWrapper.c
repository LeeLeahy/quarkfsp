/** @file
Framework PEIM to initialize memory on a Quark Memory Controller.

Copyright (c) 2013 - 2016, Intel Corporation.

This program and the accompanying materials
are licensed and made available under the terms and conditions of the BSD License
which accompanies this distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#include "CommonHeader.h"
#include "MrcWrapper.h"

#define RESERVED_CPU_S3_SAVE_OFFSET (RESERVED_ACPI_S3_RANGE_OFFSET - sizeof (SMM_S3_RESUME_STATE))

// Strap configuration register specifying DDR setup
#define QUARK_SCSS_REG_STPDDRCFG   0x00

// Macro counting array elements
#define COUNT(a)                 (sizeof(a)/sizeof(*a))


EFI_MEMORY_TYPE_INFORMATION mDefaultQncMemoryTypeInformation[] = {
  { EfiReservedMemoryType,  EDKII_RESERVED_SIZE_PAGES },       // BIOS Reserved
  { EfiACPIMemoryNVS,       ACPI_NVS_SIZE_PAGES },             // S3, SMM, etc
  { EfiRuntimeServicesData, RUNTIME_SERVICES_DATA_SIZE_PAGES },
  { EfiRuntimeServicesCode, RUNTIME_SERVICES_CODE_SIZE_PAGES },
  { EfiACPIReclaimMemory,   ACPI_RECLAIM_SIZE_PAGES },         // ACPI ASL
  { EfiMaxMemoryType,       0 }
};

UINT64
GetFspReservedMemorySize (VOID)
{
  UINTN  Index;
  UINT64 MemorySize;
  MEMORY_INIT_UPD *MemoryInitUpd;

  //
  // Start with minimum memory
  //
  MemorySize = PEI_MIN_MEMORY_SIZE;

  //
  // Account for other memory areas
  //
  for (Index = 0; Index < sizeof(mDefaultQncMemoryTypeInformation) / sizeof (EFI_MEMORY_TYPE_INFORMATION); Index++) {
    MemorySize += mDefaultQncMemoryTypeInformation[Index].NumberOfPages * EFI_PAGE_SIZE;
  }

  //
  // Validate the memory length
  //
  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  if (MemoryInitUpd->FspReservedMemoryLength > MemorySize) {
    DEBUG((EFI_D_INFO, "FSP required memory size can be reduced to 0x%08lx\n", MemorySize));
    MemorySize = MemoryInitUpd->FspReservedMemoryLength;
  } else if (MemoryInitUpd->FspReservedMemoryLength < MemorySize) {
    DEBUG((EFI_D_INFO, "FSP required memory size must be >= 0x%08lx\n", MemorySize));
  }
  return MemorySize;
}

/**
  Find pointer to RAW data in Firmware volume file.

  @param   FvNameGuid       Firmware volume to search. If == NULL search all.
  @param   FileNameGuid     Firmware volume file to search for.
  @param   SectionData      Pointer to RAW data section of found file.
  @param   SectionDataSize  Pointer to UNITN to get size of RAW data.

  @retval  EFI_SUCCESS            Raw Data found.
  @retval  EFI_INVALID_PARAMETER  FileNameGuid == NULL.
  @retval  EFI_NOT_FOUND          Firmware volume file not found.
  @retval  EFI_UNSUPPORTED        Unsupported in current enviroment (PEI or DXE).

**/
EFI_STATUS
EFIAPI
FindFvFileRawDataSection (
  IN CONST EFI_GUID                 *FvNameGuid OPTIONAL,
  IN CONST EFI_GUID                 *FileNameGuid,
  OUT VOID                          **SectionData,
  OUT UINTN                         *SectionDataSize
  )
{
  EFI_STATUS                        Status;
  UINTN                             Instance;
  EFI_PEI_FV_HANDLE                 VolumeHandle;
  EFI_PEI_FILE_HANDLE               FileHandle;
  EFI_SECTION_TYPE                  SearchType;
  EFI_FV_INFO                       VolumeInfo;
  EFI_FV_FILE_INFO                  FileInfo;

  if (FileNameGuid == NULL || SectionData == NULL || SectionDataSize == NULL) {
    return EFI_INVALID_PARAMETER;
  }
  *SectionData = NULL;
  *SectionDataSize = 0;

  SearchType = EFI_SECTION_RAW;
  for (Instance = 0; !EFI_ERROR((PeiServicesFfsFindNextVolume (Instance, &VolumeHandle))); Instance++) {
    if (FvNameGuid != NULL) {
      Status = PeiServicesFfsGetVolumeInfo (VolumeHandle, &VolumeInfo);
      if (EFI_ERROR (Status)) {
        continue;
      }
      if (!CompareGuid (FvNameGuid, &VolumeInfo.FvName)) {
        continue;
      }
    }
    Status = PeiServicesFfsFindFileByName (FileNameGuid, VolumeHandle, &FileHandle);
    if (!EFI_ERROR (Status)) {
      Status = PeiServicesFfsGetFileInfo (FileHandle, &FileInfo);
      if (EFI_ERROR (Status)) {
        continue;
      }
      if (IS_SECTION2(FileInfo.Buffer)) {
        *SectionDataSize = SECTION2_SIZE(FileInfo.Buffer) - sizeof(EFI_COMMON_SECTION_HEADER2);
      } else {
        *SectionDataSize = SECTION_SIZE(FileInfo.Buffer) - sizeof(EFI_COMMON_SECTION_HEADER);
      }
      Status = PeiServicesFfsFindSectionData (SearchType, FileHandle, SectionData);
      if (!EFI_ERROR (Status)) {
        return Status;
      }
    }
  }
  return EFI_NOT_FOUND;
}

/**
  Configure MRC from memory controller fuse settings.

  @param  MrcData      - MRC configuration data to be updated.

  @return EFI_SUCCESS    MRC Config parameters updated from platform data.
**/
EFI_STATUS
MrcConfigureFromMcFuses (
  OUT MRC_PARAMS                          *MrcData
  )
{
  UINT32                            McFuseStat;

  McFuseStat = QNCPortRead (
                 QUARK_NC_MEMORY_CONTROLLER_SB_PORT_ID,
                 QUARK_NC_MEMORY_CONTROLLER_REG_DFUSESTAT
                 );

  DEBUG ((EFI_D_INFO, "MRC McFuseStat 0x%08x\n", McFuseStat));

  if ((McFuseStat & B_DFUSESTAT_ECC_DIS) != 0) {
    DEBUG ((EFI_D_INFO, "MRC Fuse : fus_dun_ecc_dis.\n"));
    MrcData->ecc_enables = 0;
  } else {
    MrcData->ecc_enables = 1;
  }
  return EFI_SUCCESS;
}

/**
  Configure MRC from platform info hob.

  @param  MrcData      - MRC configuration data to be updated.

  @return EFI_SUCCESS    MRC Config parameters updated from hob.
  @return EFI_NOT_FOUND  Platform Info or MRC Config parameters not found.
  @return EFI_INVALID_PARAMETER  Wrong params in hob.
**/
EFI_STATUS
MrcConfigureFromInfoHob (
  OUT MRC_PARAMS  *MrcData
  )
{
  MEMORY_INIT_UPD *MemoryInitUpd;

  //
  // Get the UPD pointer.
  //
  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();

  MrcData->channel_enables     = MemoryInitUpd->ChanMask;
  MrcData->channel_width       = MemoryInitUpd->ChanWidth;
  MrcData->address_mode        = MemoryInitUpd->AddrMode;
  // Enable scrambling if requested.
  MrcData->scrambling_enables  = (MemoryInitUpd->Flags & MRC_FLAG_SCRAMBLE_EN) != 0;
  MrcData->ddr_type            = MemoryInitUpd->DramType;
  MrcData->dram_width          = MemoryInitUpd->DramWidth;
  MrcData->ddr_speed           = MemoryInitUpd->DramSpeed;
  // Enable ECC if requested.
  MrcData->rank_enables        = MemoryInitUpd->RankMask;
  MrcData->params.DENSITY      = MemoryInitUpd->DramDensity;
  MrcData->params.tCL          = MemoryInitUpd->tCL;
  MrcData->params.tRAS         = MemoryInitUpd->tRAS;
  MrcData->params.tWTR         = MemoryInitUpd->tWTR;
  MrcData->params.tRRD         = MemoryInitUpd->tRRD;
  MrcData->params.tFAW         = MemoryInitUpd->tFAW;

  MrcData->refresh_rate        = MemoryInitUpd->SrInt;
  MrcData->sr_temp_range       = MemoryInitUpd->SrTemp;
  MrcData->ron_value           = MemoryInitUpd->DramRonVal;
  MrcData->rtt_nom_value       = MemoryInitUpd->DramRttNomVal;
  MrcData->rd_odt_value        = MemoryInitUpd->SocRdOdtVal;

  DEBUG ((EFI_D_INFO, "MRC dram_width %d\n",  MrcData->dram_width));
  DEBUG ((EFI_D_INFO, "MRC rank_enables %d\n",MrcData->rank_enables));
  DEBUG ((EFI_D_INFO, "MRC ddr_speed %d\n",   MrcData->ddr_speed));
  DEBUG ((EFI_D_INFO, "MRC flags: %s\n",
    (MrcData->scrambling_enables) ? L"SCRAMBLE_EN" : L""
    ));

  DEBUG ((EFI_D_INFO, "MRC density=%d tCL=%d tRAS=%d tWTR=%d tRRD=%d tFAW=%d\n",
    MrcData->params.DENSITY,
    MrcData->params.tCL,
    MrcData->params.tRAS,
    MrcData->params.tWTR,
    MrcData->params.tRRD,
    MrcData->params.tFAW
    ));

  return EFI_SUCCESS;
}

/**

  Configure ECC scrub

  @param MrcData - MRC configuration

**/
VOID
EccScrubSetup(
  const MRC_PARAMS *MrcData
  )
{
  UINT32 BgnAdr = 0;
  UINT32 EndAdr = MrcData->mem_size;
  MEMORY_INIT_UPD *MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  UINT32 BlkSize = MemoryInitUpd->EccScrubBlkSize & SCRUB_CFG_BLOCKSIZE_MASK;
  UINT32 Interval = MemoryInitUpd->EccScrubInterval & SCRUB_CFG_INTERVAL_MASK;

  if( MrcData->ecc_enables == 0 || MrcData->boot_mode == bmS3 || Interval == 0) {
    // No scrub configuration needed if ECC not enabled
    // On S3 resume reconfiguration is done as part of resume
    // script, see SNCS3Save.c ==> SaveRuntimeScriptTable()
    // Also if PCD disables scrub, then we do nothing.
    return;
  }

  QNCPortWrite (QUARK_NC_RMU_SB_PORT_ID, QUARK_NC_ECC_SCRUB_END_MEM_REG, EndAdr);
  QNCPortWrite (QUARK_NC_RMU_SB_PORT_ID, QUARK_NC_ECC_SCRUB_START_MEM_REG, BgnAdr);
  QNCPortWrite (QUARK_NC_RMU_SB_PORT_ID, QUARK_NC_ECC_SCRUB_NEXT_READ_REG, BgnAdr);
  QNCPortWrite (QUARK_NC_RMU_SB_PORT_ID, QUARK_NC_ECC_SCRUB_CONFIG_REG,
    Interval << SCRUB_CFG_INTERVAL_SHIFT |
    BlkSize << SCRUB_CFG_BLOCKSIZE_SHIFT);

  McD0PciCfg32 (QNC_ACCESS_PORT_MCR) = SCRUB_RESUME_MSG();
}

/** Post InstallS3Memory / InstallEfiMemory tasks given MrcData context.

  @param[in]       MrcData  MRC configuration.
  @param[in]       IsS3     TRUE if after InstallS3Memory.

**/
VOID
PostInstallMemory (
  IN MRC_PARAMS                           *MrcData,
  IN BOOLEAN                              IsS3
  )
{
  UINT32                            RmuMainDestBaseAddress;
  MEMORY_INIT_UPD                   *MemoryInitUpd;

  //
  // Setup ECC policy (All boot modes).
  //
  QNCPolicyDblEccBitErr (V_WDT_CONTROL_DBL_ECC_BIT_ERR_WARM);

  //
  // Find the 64KB of memory for Rmu Main at the top of available memory.
  //
  InfoPostInstallMemory (&RmuMainDestBaseAddress, NULL, NULL);
  DEBUG ((EFI_D_INFO, "RmuMain Base Address : 0x%x\n", RmuMainDestBaseAddress));

  //
  // Relocate RmuMain.
  //
  if (IsS3) {
    QNCSendOpcodeDramReady (RmuMainDestBaseAddress);
  } else {
    MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
    RmuMainRelocation (RmuMainDestBaseAddress, MemoryInitUpd->RmuBaseAddress, MemoryInitUpd->RmuLength);
    QNCSendOpcodeDramReady (RmuMainDestBaseAddress);
    EccScrubSetup (MrcData);
  }
}

/**

  Do memory initialisation for QNC DDR3 SDRAM Controller

  @param  FfsHeader    Not used.
  @param  PeiServices  General purpose services available to every PEIM.

  @return EFI_SUCCESS  Memory initialisation completed successfully.
          All other error conditions encountered result in an ASSERT.

**/
EFI_STATUS
MemoryInit (
  IN EFI_PEI_SERVICES          **PeiServices
  )
{
  MRC_PARAMS                                 MrcData;
  EFI_BOOT_MODE                               BootMode;
  EFI_STATUS                                  Status;
  EFI_STATUS_CODE_VALUE                       ErrorCodeValue;
  PEI_QNC_MEMORY_INIT_PPI                     *QncMemoryInitPpi;
  UINT16                                      PmswAdr;
  MEMORY_INIT_UPD                             *MemoryInitUpd;

  ErrorCodeValue  = 0;

  //
  // It is critical that both of these data structures are initialized to 0.
  // This PEIM knows the number of DIMMs in the system and works with that
  // information.  The MCH PEIM that consumes these data structures does not
  // know the number of DIMMs so it expects the entire structure to be
  // properly initialized.  By initializing these to zero, all flags indicating
  // that the SPD is present or the row should be configured are set to false.
  //
  ZeroMem (&MrcData, sizeof(MrcData));

  //
  // Determine boot mode
  //
  Status = PeiServicesGetBootMode (&BootMode);
  ASSERT_EFI_ERROR (Status);

  //
  // Initialize Error type for reporting status code
  //
  switch (BootMode) {
  case BOOT_ON_FLASH_UPDATE:
    ErrorCodeValue = EFI_COMPUTING_UNIT_MEMORY + EFI_CU_MEMORY_EC_UPDATE_FAIL;
    break;
  case BOOT_ON_S3_RESUME:
    ErrorCodeValue = EFI_COMPUTING_UNIT_MEMORY + EFI_CU_MEMORY_EC_S3_RESUME_FAIL;
    break;
  default:
    ErrorCodeValue = EFI_COMPUTING_UNIT_MEMORY;
    break;
  }

  //
  // Specify MRC boot mode
  //
  switch (BootMode) {
  case BOOT_ON_S3_RESUME:
  case BOOT_ON_FLASH_UPDATE:
    MrcData.boot_mode = bmS3;
    break;
  case BOOT_ASSUMING_NO_CONFIGURATION_CHANGES:
    MrcData.boot_mode = bmFast;
    break;
  default:
    MrcData.boot_mode = bmCold;
    break;
  }

  //
  // Configure MRC input parameters.
  //
  Status = MrcConfigureFromMcFuses (&MrcData);
  ASSERT_EFI_ERROR (Status);
  Status = MrcConfigureFromInfoHob (&MrcData);
  ASSERT_EFI_ERROR (Status);

  if (BootMode == BOOT_IN_RECOVERY_MODE) {
    //
    // Always do bmCold on recovery.
    //
    DEBUG ((DEBUG_INFO, "MemoryInit:Force bmCold on Recovery\n"));
    MrcData.boot_mode = bmCold;
  } else {

    //
    // Get the saved memory data if possible
    //
    MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
    if ((MemoryInitUpd->MrcDataPtr != 0) && (MemoryInitUpd->MrcDataLength != 0)) {
      ASSERT(MemoryInitUpd->MrcDataLength == sizeof(MrcData.timings));
      CopyMem (&MrcData.timings, (void *)MemoryInitUpd->MrcDataPtr, MemoryInitUpd->MrcDataLength);
    } else {
      switch (BootMode) {
      case BOOT_ON_S3_RESUME:
      case BOOT_ON_FLASH_UPDATE:
        DEBUG ((DEBUG_ERROR, "ERROR: MRC data missing - reboot\n"));
        REPORT_STATUS_CODE (
          EFI_ERROR_CODE + EFI_ERROR_UNRECOVERED,
          ErrorCodeValue
        );
        PeiServicesResetSystem ();
        break;

      default:
        MrcData.boot_mode = bmCold;
        break;
      }
    }
  }

  //
  // Locate Memory Reference Code PPI
  //
  Status = PeiServicesLocatePpi (
             &gQNCMemoryInitPpiGuid,        // GUID
             0,                             // INSTANCE
             NULL,                          // EFI_PEI_PPI_DESCRIPTOR
             (VOID **)&QncMemoryInitPpi     // PPI
             );
  ASSERT_EFI_ERROR (Status);

  PmswAdr = (UINT16)(LpcPciCfg32 (R_QNC_LPC_GPE0BLK) & 0xFFFF) + R_QNC_GPE0BLK_PMSW;
  if( IoRead32 (PmswAdr) & B_QNC_GPE0BLK_PMSW_DRAM_INIT) {
    // MRC did not complete last execution, force cold boot path
    MrcData.boot_mode = bmCold;
  }

  // Mark MRC pending
  IoOr32 (PmswAdr, (UINT32)B_QNC_GPE0BLK_PMSW_DRAM_INIT);

  //
  // Call Memory Reference Code's Routines
  //
  QncMemoryInitPpi->MrcStart (&MrcData);

  // Mark MRC completed
  IoAnd32 (PmswAdr, ~(UINT32)B_QNC_GPE0BLK_PMSW_DRAM_INIT);


  //
  // Note emulation platform has to read actual memory size
  // MrcData.mem_size from PcdGet32 (PcdMemorySize);

  if (BootMode == BOOT_ON_S3_RESUME) {

    DEBUG ((EFI_D_INFO, "Following BOOT_ON_S3_RESUME boot path.\n"));

    Status = InstallS3Memory (PeiServices, MrcData.mem_size);
    if (EFI_ERROR (Status)) {
      REPORT_STATUS_CODE (
        EFI_ERROR_CODE + EFI_ERROR_UNRECOVERED,
        ErrorCodeValue
      );
      PeiServicesResetSystem ();
    }
    PostInstallMemory (&MrcData, TRUE);
    return EFI_SUCCESS;
  }

  //
  // Assign physical memory to PEI and DXE
  //
  DEBUG ((EFI_D_INFO, "InstallEfiMemory, TotalSize = 0x%08x\n", MrcData.mem_size));

  Status = InstallEfiMemory (
             PeiServices,
             BootMode,
             MrcData.mem_size
             );
  ASSERT_EFI_ERROR (Status);

  PostInstallMemory (&MrcData, FALSE);

  //
  // Save current configuration into Hob and will save into Variable later in DXE
  //
  DEBUG ((EFI_D_INFO, "SaveConfig.\n"));
  Status = SaveConfig (
             &MrcData
             );
  ASSERT_EFI_ERROR (Status);

  DEBUG ((EFI_D_INFO, "MemoryInit Complete.\n"));

  return EFI_SUCCESS;
}

/**

  This function saves a config to a HOB.

  @param  RowInfo         The MCH row configuration information.
  @param  TimingData      Timing data to be saved.
  @param  RowConfArray    Row configuration information for each row in the system.
  @param  SpdData         SPD info read for each DIMM slot in the system.

  @return EFI_SUCCESS:    The function completed successfully.

**/
EFI_STATUS
SaveConfig (
  IN MRC_PARAMS *MrcData
  )
{
  //
  // Build HOB data for Memory Config
  // HOB data size (stored in variable) is required to be multiple of 8 bytes
  //
  BuildGuidDataHob (
    &gEfiMemoryConfigDataGuid,
    (VOID *) &MrcData->timings,
    ((sizeof (MrcData->timings) + 0x7) & (~0x7))
    );

  DEBUG ((EFI_D_INFO, "IIO IoApicBase  = %x IoApicLimit=%x\n", IOAPIC_BASE, (IOAPIC_BASE + IOAPIC_SIZE - 1)));
  return EFI_SUCCESS;
}

/**

  This function installs memory.

  @param   PeiServices    PEI Services table.
  @param   BootMode       The specific boot path that is being followed
  @param   Mch            Pointer to the DualChannelDdrMemoryInit PPI
  @param   RowConfArray   Row configuration information for each row in the system.

  @return  EFI_SUCCESS            The function completed successfully.
           EFI_INVALID_PARAMETER  One of the input parameters was invalid.
           EFI_ABORTED            An error occurred.

**/
EFI_STATUS
InstallEfiMemory (
  IN      EFI_PEI_SERVICES                           **PeiServices,
  IN      EFI_BOOT_MODE                              BootMode,
  IN      UINT32                                     TotalMemorySize
  )
{
  EFI_PHYSICAL_ADDRESS                  PeiMemoryBaseAddress;
  EFI_SMRAM_HOB_DESCRIPTOR_BLOCK        *SmramHobDescriptorBlock;
  EFI_STATUS                            Status;
  EFI_PEI_HOB_POINTERS                  Hob;
  PEI_DUAL_CHANNEL_DDR_MEMORY_MAP_RANGE MemoryMap[MAX_RANGES];
  UINT8                                 Index;
  UINT8                                 NumRanges;
  UINT8                                 SmramIndex;
  UINT8                                 SmramRanges;
  UINT64                                PeiMemoryLength;
  UINTN                                 BufferSize;
  UINTN                                 PeiMemoryIndex;
  UINTN                                 RequiredMemSize;
  EFI_RESOURCE_ATTRIBUTE_TYPE           Attribute;
  EFI_PHYSICAL_ADDRESS                  BadMemoryAddress;
  EFI_SMRAM_DESCRIPTOR                  DescriptorAcpiVariable;

  //
  // Test the memory from 1M->TOM
  //
  if (BootMode != BOOT_ON_FLASH_UPDATE) {
    Status = BaseMemoryTest (
              PeiServices,
              0x100000,
              (TotalMemorySize - 0x100000),
              Quick,
              &BadMemoryAddress
              );
  ASSERT_EFI_ERROR (Status);
  }


  //
  // Get the Memory Map
  //
  NumRanges = MAX_RANGES;

  ZeroMem (MemoryMap, sizeof (PEI_DUAL_CHANNEL_DDR_MEMORY_MAP_RANGE) * NumRanges);

  Status = GetMemoryMap (
             PeiServices,
             TotalMemorySize,
             (PEI_DUAL_CHANNEL_DDR_MEMORY_MAP_RANGE *) MemoryMap,
             &NumRanges
             );
  ASSERT_EFI_ERROR (Status);

  //
  // Find the highest memory range in processor native address space to give to
  // PEI. Then take the top.
  //
  PeiMemoryBaseAddress = 0;

  //
  // Query the platform for the minimum memory size
  //

  PeiMemoryLength = GetFspReservedMemorySize ();

  //
  // Get required memory size for ACPI use. This helps to put ACPI memory on the topest
  //
  RequiredMemSize = 0;
  RetriveRequiredMemorySize (PeiServices, &RequiredMemSize);

  //
  // Carve out the top memory reserved for ACPI
  //
  Status        = PeiServicesInstallPeiMemory (PeiMemoryBaseAddress, (PeiMemoryLength - RequiredMemSize));
  ASSERT_EFI_ERROR (Status);

  BuildResourceDescriptorHob (
   EFI_RESOURCE_SYSTEM_MEMORY,                       // MemoryType,
   (
   EFI_RESOURCE_ATTRIBUTE_PRESENT |
   EFI_RESOURCE_ATTRIBUTE_INITIALIZED |
   EFI_RESOURCE_ATTRIBUTE_TESTED |
   EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE |
   EFI_RESOURCE_ATTRIBUTE_WRITE_COMBINEABLE |
   EFI_RESOURCE_ATTRIBUTE_WRITE_THROUGH_CACHEABLE |
   EFI_RESOURCE_ATTRIBUTE_WRITE_BACK_CACHEABLE
   ),
   PeiMemoryBaseAddress,                             // MemoryBegin
   PeiMemoryLength                                   // MemoryLength
   );

  //
  // Install physical memory descriptor hobs for each memory range.
  //
  PeiMemoryIndex = 0;
  SmramRanges = 0;
  for (Index = 0; Index < NumRanges; Index++) {
    Attribute = 0;
    if (MemoryMap[Index].Type == DualChannelDdrMainMemory)
    {
      if (Index == PeiMemoryIndex) {
        //
        // This is a partially tested Main Memory range, give it to EFI
        //
        BuildResourceDescriptorHob (
          EFI_RESOURCE_SYSTEM_MEMORY,
          (
          EFI_RESOURCE_ATTRIBUTE_PRESENT |
          EFI_RESOURCE_ATTRIBUTE_INITIALIZED |
          EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE |
          EFI_RESOURCE_ATTRIBUTE_WRITE_COMBINEABLE |
          EFI_RESOURCE_ATTRIBUTE_WRITE_THROUGH_CACHEABLE |
          EFI_RESOURCE_ATTRIBUTE_WRITE_BACK_CACHEABLE
          ),
          MemoryMap[Index].PhysicalAddress,
          MemoryMap[Index].RangeLength - PeiMemoryLength
          );
      } else {
        //
        // This is an untested Main Memory range, give it to EFI
        //
        BuildResourceDescriptorHob (
          EFI_RESOURCE_SYSTEM_MEMORY,       // MemoryType,
          (
          EFI_RESOURCE_ATTRIBUTE_PRESENT |
          EFI_RESOURCE_ATTRIBUTE_INITIALIZED |
          EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE |
          EFI_RESOURCE_ATTRIBUTE_WRITE_COMBINEABLE |
          EFI_RESOURCE_ATTRIBUTE_WRITE_THROUGH_CACHEABLE |
          EFI_RESOURCE_ATTRIBUTE_WRITE_BACK_CACHEABLE
          ),
          MemoryMap[Index].PhysicalAddress, // MemoryBegin
          MemoryMap[Index].RangeLength      // MemoryLength
          );
      }
    } else {
      if ((MemoryMap[Index].Type == DualChannelDdrSmramCacheable) ||
          (MemoryMap[Index].Type == DualChannelDdrSmramNonCacheable)) {
        SmramRanges++;
      }
      if ((MemoryMap[Index].Type == DualChannelDdrSmramNonCacheable) ||
          (MemoryMap[Index].Type == DualChannelDdrGraphicsMemoryNonCacheable)) {
        Attribute |= EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE;
      }
      if ((MemoryMap[Index].Type == DualChannelDdrSmramCacheable)         ||
          (MemoryMap[Index].Type == DualChannelDdrGraphicsMemoryCacheable)) {
        //
        // TSEG and HSEG can be used with a write-back(WB) cache policy; however,
        // the specification requires that the TSEG and HSEG space be cached only
        // inside of the SMI handler. when using HSEG or TSEG an IA-32 processor
        // does not automatically write back and invalidate its cache before entering
        // SMM or before existing SMM therefore any MTRR defined for the active TSEG
        // or HSEG must be set to un-cacheable(UC) outside of SMM.
        //
        Attribute |= EFI_RESOURCE_ATTRIBUTE_WRITE_BACK_CACHEABLE | EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE;
      }
      if (MemoryMap[Index].Type == DualChannelDdrReservedMemory) {
        Attribute |= EFI_RESOURCE_ATTRIBUTE_WRITE_BACK_CACHEABLE |
                     EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE;
      }
      //
      // Make sure non-system memory is marked as reserved
      //
      BuildResourceDescriptorHob (
        EFI_RESOURCE_MEMORY_RESERVED,     // MemoryType,
        Attribute,                        // MemoryAttribute
        MemoryMap[Index].PhysicalAddress, // MemoryBegin
        MemoryMap[Index].RangeLength      // MemoryLength
        );
    }
  }

  if (SmramRanges == 0) {
    return EFI_SUCCESS;
  }

  //
  // Allocate one extra EFI_SMRAM_DESCRIPTOR to describe a page of SMRAM memory that contains a pointer
  // to the SMM Services Table that is required on the S3 resume path
  //
  BufferSize = sizeof (EFI_SMRAM_HOB_DESCRIPTOR_BLOCK);
  BufferSize += ((SmramRanges - 1) * sizeof (EFI_SMRAM_DESCRIPTOR));

  Hob.Raw = BuildGuidHob (
              &gEfiSmmPeiSmramMemoryReserveGuid,
              BufferSize
              );
  ASSERT (Hob.Raw);

  SmramHobDescriptorBlock = (EFI_SMRAM_HOB_DESCRIPTOR_BLOCK *) (Hob.Raw);
  SmramHobDescriptorBlock->NumberOfSmmReservedRegions = SmramRanges;

  SmramIndex = 0;
  for (Index = 0; Index < NumRanges; Index++) {
    if ((MemoryMap[Index].Type == DualChannelDdrSmramCacheable) ||
        (MemoryMap[Index].Type == DualChannelDdrSmramNonCacheable)
        ) {
      //
      // This is an SMRAM range, create an SMRAM descriptor
      //
      SmramHobDescriptorBlock->Descriptor[SmramIndex].PhysicalStart = MemoryMap[Index].PhysicalAddress;
      SmramHobDescriptorBlock->Descriptor[SmramIndex].CpuStart      = MemoryMap[Index].CpuAddress;
      SmramHobDescriptorBlock->Descriptor[SmramIndex].PhysicalSize  = MemoryMap[Index].RangeLength;
      if (MemoryMap[Index].Type == DualChannelDdrSmramCacheable) {
        SmramHobDescriptorBlock->Descriptor[SmramIndex].RegionState = EFI_SMRAM_CLOSED | EFI_CACHEABLE;
      } else {
        SmramHobDescriptorBlock->Descriptor[SmramIndex].RegionState = EFI_SMRAM_CLOSED;
      }

      SmramIndex++;
    }
  }

  //
  // Build a HOB with the location of the reserved memory range.
  //
  CopyMem(&DescriptorAcpiVariable, &SmramHobDescriptorBlock->Descriptor[SmramRanges-1], sizeof(EFI_SMRAM_DESCRIPTOR));
  DescriptorAcpiVariable.CpuStart += RESERVED_CPU_S3_SAVE_OFFSET;
  BuildGuidDataHob (
    &gEfiAcpiVariableGuid,
    &DescriptorAcpiVariable,
    sizeof (EFI_SMRAM_DESCRIPTOR)
    );

  return EFI_SUCCESS;
}

/**

  Find memory that is reserved so PEI has some to use.

  @param  PeiServices      PEI Services table.

  @return EFI_SUCCESS  The function completed successfully.
                       Error value from LocatePpi()

**/
EFI_STATUS
InstallS3Memory (
  IN      EFI_PEI_SERVICES                      **PeiServices,
  IN      UINT32                                TotalMemorySize
  )
{
  EFI_STATUS                            Status;
  UINTN                                 S3MemoryBase;
  UINTN                                 S3MemorySize;
  UINT8                                 SmramRanges;
  UINT8                                 NumRanges;
  UINT8                                 Index;
  UINT8                                 SmramIndex;
  UINTN                                 BufferSize;
  EFI_PEI_HOB_POINTERS                  Hob;
  EFI_SMRAM_HOB_DESCRIPTOR_BLOCK        *SmramHobDescriptorBlock;
  PEI_DUAL_CHANNEL_DDR_MEMORY_MAP_RANGE MemoryMap[MAX_RANGES];
  RESERVED_ACPI_S3_RANGE                *S3MemoryRangeData;
  EFI_SMRAM_DESCRIPTOR                  DescriptorAcpiVariable;

  //
  // Get the Memory Map
  //
  NumRanges = MAX_RANGES;

  ZeroMem (MemoryMap, sizeof (PEI_DUAL_CHANNEL_DDR_MEMORY_MAP_RANGE) * NumRanges);

  Status = GetMemoryMap (
             PeiServices,
             TotalMemorySize,
             (PEI_DUAL_CHANNEL_DDR_MEMORY_MAP_RANGE *) MemoryMap,
             &NumRanges
             );
  ASSERT_EFI_ERROR (Status);

  //
  // Install physical memory descriptor hobs for each memory range.
  //
  SmramRanges = 0;
  for (Index = 0; Index < NumRanges; Index++) {
    if ((MemoryMap[Index].Type == DualChannelDdrSmramCacheable)    ||
       (MemoryMap[Index].Type == DualChannelDdrSmramNonCacheable)) {
      SmramRanges++;
    }
  }

  ASSERT (SmramRanges > 0);

  //
  // Allocate one extra EFI_SMRAM_DESCRIPTOR to describe a page of SMRAM memory that contains a pointer
  // to the SMM Services Table that is required on the S3 resume path
  //
  BufferSize = sizeof (EFI_SMRAM_HOB_DESCRIPTOR_BLOCK);
  if (SmramRanges > 0) {
    BufferSize += ((SmramRanges - 1) * sizeof (EFI_SMRAM_DESCRIPTOR));
  }

  Hob.Raw = BuildGuidHob (
              &gEfiSmmPeiSmramMemoryReserveGuid,
              BufferSize
              );
  ASSERT (Hob.Raw);

  SmramHobDescriptorBlock = (EFI_SMRAM_HOB_DESCRIPTOR_BLOCK *) (Hob.Raw);
  SmramHobDescriptorBlock->NumberOfSmmReservedRegions = SmramRanges;

  SmramIndex = 0;
  for (Index = 0; Index < NumRanges; Index++) {
    if ((MemoryMap[Index].Type == DualChannelDdrSmramCacheable) ||
        (MemoryMap[Index].Type == DualChannelDdrSmramNonCacheable)
        ) {
      //
      // This is an SMRAM range, create an SMRAM descriptor
      //
      SmramHobDescriptorBlock->Descriptor[SmramIndex].PhysicalStart = MemoryMap[Index].PhysicalAddress;
      SmramHobDescriptorBlock->Descriptor[SmramIndex].CpuStart      = MemoryMap[Index].CpuAddress;
      SmramHobDescriptorBlock->Descriptor[SmramIndex].PhysicalSize  = MemoryMap[Index].RangeLength;
      if (MemoryMap[Index].Type == DualChannelDdrSmramCacheable) {
        SmramHobDescriptorBlock->Descriptor[SmramIndex].RegionState = EFI_SMRAM_CLOSED | EFI_CACHEABLE;
      } else {
        SmramHobDescriptorBlock->Descriptor[SmramIndex].RegionState = EFI_SMRAM_CLOSED;
      }

      SmramIndex++;
    }
  }

  //
  // Build a HOB with the location of the reserved memory range.
  //
  CopyMem(&DescriptorAcpiVariable, &SmramHobDescriptorBlock->Descriptor[SmramRanges-1], sizeof(EFI_SMRAM_DESCRIPTOR));
  DescriptorAcpiVariable.CpuStart += RESERVED_CPU_S3_SAVE_OFFSET;
  BuildGuidDataHob (
    &gEfiAcpiVariableGuid,
    &DescriptorAcpiVariable,
    sizeof (EFI_SMRAM_DESCRIPTOR)
    );

  //
  // Get the location and size of the S3 memory range in the reserved page and
  // install it as PEI Memory.
  //

  DEBUG ((EFI_D_INFO, "TSEG Base = 0x%08x\n", SmramHobDescriptorBlock->Descriptor[SmramRanges-1].PhysicalStart));
  S3MemoryRangeData = (RESERVED_ACPI_S3_RANGE*)(UINTN)
    (SmramHobDescriptorBlock->Descriptor[SmramRanges-1].PhysicalStart + RESERVED_ACPI_S3_RANGE_OFFSET);

  S3MemoryBase  = (UINTN) (S3MemoryRangeData->AcpiReservedMemoryBase);
  DEBUG ((EFI_D_INFO, "S3MemoryBase = 0x%08x\n", S3MemoryBase));
  S3MemorySize  = (UINTN) (S3MemoryRangeData->AcpiReservedMemorySize);
  DEBUG ((EFI_D_INFO, "S3MemorySize = 0x%08x\n", S3MemorySize));

  Status        = PeiServicesInstallPeiMemory (S3MemoryBase, S3MemorySize);
  ASSERT_EFI_ERROR (Status);

  //
  // Retrieve the system memory length and build memory hob for the system
  // memory above 1MB. So Memory Callback can set cache for the system memory
  // correctly on S3 boot path, just like it does on Normal boot path.
  //
  ASSERT_EFI_ERROR ((S3MemoryRangeData->SystemMemoryLength - 0x100000) > 0);
  BuildResourceDescriptorHob (
            EFI_RESOURCE_SYSTEM_MEMORY,
            (
            EFI_RESOURCE_ATTRIBUTE_PRESENT |
            EFI_RESOURCE_ATTRIBUTE_INITIALIZED |
            EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE |
            EFI_RESOURCE_ATTRIBUTE_WRITE_COMBINEABLE |
            EFI_RESOURCE_ATTRIBUTE_WRITE_THROUGH_CACHEABLE |
            EFI_RESOURCE_ATTRIBUTE_WRITE_BACK_CACHEABLE
            ),
            0x100000,
            S3MemoryRangeData->SystemMemoryLength - 0x100000
            );

  for (Index = 0; Index < NumRanges; Index++) {
    if ((MemoryMap[Index].Type == DualChannelDdrMainMemory) &&
        (MemoryMap[Index].PhysicalAddress + MemoryMap[Index].RangeLength < 0x100000)) {
      BuildResourceDescriptorHob (
        EFI_RESOURCE_SYSTEM_MEMORY,
        (
        EFI_RESOURCE_ATTRIBUTE_PRESENT |
        EFI_RESOURCE_ATTRIBUTE_INITIALIZED |
        EFI_RESOURCE_ATTRIBUTE_UNCACHEABLE |
        EFI_RESOURCE_ATTRIBUTE_WRITE_COMBINEABLE |
        EFI_RESOURCE_ATTRIBUTE_WRITE_THROUGH_CACHEABLE |
        EFI_RESOURCE_ATTRIBUTE_WRITE_BACK_CACHEABLE
        ),
        MemoryMap[Index].PhysicalAddress,
        MemoryMap[Index].RangeLength
        );
      DEBUG ((EFI_D_INFO, "Build resource HOB for Legacy Region on S3 patch :"));
      DEBUG ((EFI_D_INFO, " Memory Base:0x%lX Length:0x%lX\n", MemoryMap[Index].PhysicalAddress, MemoryMap[Index].RangeLength));
    }
  }

  return EFI_SUCCESS;
}

/**

  This function returns the size, in bytes, required for the DXE phase.

  @param  PeiServices    PEI Services table.
  @param  Size           Pointer to the size, in bytes, required for the DXE phase.

  @return  None

**/
VOID
RetriveRequiredMemorySize (
  IN      EFI_PEI_SERVICES                  **PeiServices,
  OUT     UINTN                             *Size
  )
{
  EFI_PEI_HOB_POINTERS           Hob;
  EFI_MEMORY_TYPE_INFORMATION    *MemoryData;
  UINT8                          Index;
  UINTN                          TempPageNum;

  MemoryData  = NULL;
  TempPageNum = 0;
  Index       = 0;

  PeiServicesGetHobList ((VOID **)&Hob.Raw);
  while (!END_OF_HOB_LIST (Hob)) {
    if (Hob.Header->HobType == EFI_HOB_TYPE_GUID_EXTENSION &&
        CompareGuid (&Hob.Guid->Name, &gEfiMemoryTypeInformationGuid)
          ) {
      MemoryData = (EFI_MEMORY_TYPE_INFORMATION *) (Hob.Raw + sizeof (EFI_HOB_GENERIC_HEADER) + sizeof (EFI_GUID));
      break;
    }

    Hob.Raw = GET_NEXT_HOB (Hob);
  }
  //
  // Platform PEIM should supply such a information. Generic PEIM doesn't assume any default value
  //
  if (!MemoryData) {
    return ;
  }

  while (MemoryData[Index].Type != EfiMaxMemoryType) {
    //
    // Accumulate default memory size requirements
    //
    TempPageNum += MemoryData[Index].NumberOfPages;
    Index++;
  }

  if (TempPageNum == 0) {
    return ;
  }

  //
  // Add additional pages used by DXE memory manager
  //
  (*Size) = (TempPageNum + EDKII_DXE_MEM_SIZE_PAGES) * EFI_PAGE_SIZE;

  return ;
}

/**

  This function returns the memory ranges to be enabled, along with information
  describing how the range should be used.

  @param  PeiServices   PEI Services Table.
  @param  TimingData    Detected DDR timing parameters for installed memory.
  @param  RowConfArray  Pointer to an array of EFI_DUAL_CHANNEL_DDR_ROW_CONFIG structures. The number
                        of items in the array must match MaxRows returned by the McGetRowInfo() function.
  @param  MemoryMap     Buffer to record details of the memory ranges tobe enabled.
  @param  NumRanges     On input, this contains the maximum number of memory ranges that can be described
                        in the MemoryMap buffer.

  @return MemoryMap     The buffer will be filled in
          NumRanges     will contain the actual number of memory ranges that are to be anabled.
          EFI_SUCCESS   The function completed successfully.

**/
EFI_STATUS
GetMemoryMap (
  IN     EFI_PEI_SERVICES                                    **PeiServices,
  IN     UINT32                                              TotalMemorySize,
  IN OUT PEI_DUAL_CHANNEL_DDR_MEMORY_MAP_RANGE               *MemoryMap,
  IN OUT UINT8                                               *NumRanges
  )
{
  EFI_PHYSICAL_ADDRESS              MemorySize;
  EFI_PHYSICAL_ADDRESS              RowLength;
  PEI_MEMORY_RANGE_SMRAM            SmramMask;
  PEI_MEMORY_RANGE_SMRAM            TsegMask;
  UINT32                            BlockNum;
  UINT8                             ExtendedMemoryIndex;
  UINT32                            Register;
  MEMORY_INIT_UPD                   *MemoryInitUpd;

  if ((*NumRanges) < MAX_RANGES) {
    return EFI_BUFFER_TOO_SMALL;
  }

  *NumRanges = 0;

  //
  // Find out which memory ranges to reserve on this platform
  //
  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  SmramMask = PEI_MR_SMRAM_CACHEABLE_MASK | PEI_MR_SMRAM_TSEG_MASK
             | (UINT32)MemoryInitUpd->SmmTsegSize;

  //
  // Generate Memory ranges for the memory map.
  //
  MemorySize = 0;

  RowLength = TotalMemorySize;

  //
  // Add memory below 640KB to the memory map. Make sure memory between
  // 640KB and 1MB are reserved, even if not used for SMRAM
  //
  MemoryMap[*NumRanges].PhysicalAddress = MemorySize;
  MemoryMap[*NumRanges].CpuAddress      = MemorySize;
  MemoryMap[*NumRanges].RangeLength     = 0xA0000;
  MemoryMap[*NumRanges].Type            = DualChannelDdrMainMemory;
  (*NumRanges)++;

  //
  // Just mark this range reserved
  //
  MemoryMap[*NumRanges].PhysicalAddress = 0xA0000;
  MemoryMap[*NumRanges].CpuAddress      = 0xA0000;
  MemoryMap[*NumRanges].RangeLength     = 0x60000;
  MemoryMap[*NumRanges].Type            = DualChannelDdrReservedMemory;
  (*NumRanges)++;

  RowLength -= (0x100000 - MemorySize);
  MemorySize = 0x100000;

  //
  // Add remaining memory to the memory map
  //
  MemoryMap[*NumRanges].PhysicalAddress = MemorySize;
  MemoryMap[*NumRanges].CpuAddress      = MemorySize;
  MemoryMap[*NumRanges].RangeLength     = RowLength;
  MemoryMap[*NumRanges].Type            = DualChannelDdrMainMemory;
  (*NumRanges)++;
  MemorySize += RowLength;

  ExtendedMemoryIndex = (UINT8) (*NumRanges - 1);

  // ------------------------ Top of physical memory
  // S3 Memory base structure
  // ------------------------ RESERVED_ACPI_S3_RANGE_OFFSET
  // CPU S3 data
  // ------------------------ RESERVED_CPU_S3_SAVE_OFFSET
  //
  // ------------------------ TSEG Base
  // Copy of RMU binary
  // ------------------------ RmuBaseAddress
  // BIOS reserved area
  // ------------------------
  // FSP reserved area
  // ------------------------
  // DRAM
  // ------------------------ 0x00100000
  // DRAM
  // ------------------------ 0x000A0000
  // DRAM
  // ------------------------ 0

  // See if we need to trim TSEG out of the highest memory range
  //
  if (SmramMask & PEI_MR_SMRAM_TSEG_MASK) {//pcd
    //
    // Create the new range for TSEG and remove that range from the previous SdrDdrMainMemory range
    //
    TsegMask  = (SmramMask & PEI_MR_SMRAM_SIZE_MASK);

    BlockNum  = 1;
    while (TsegMask) {
      TsegMask >>= 1;
      BlockNum <<= 1;
    }

    BlockNum >>= 1;

    if (BlockNum) {

      MemoryMap[*NumRanges].RangeLength           = (BlockNum * 128 * 1024);
      Register = (UINT32)((MemorySize - 1) & SMM_END_MASK);
      MemorySize                                 -= MemoryMap[*NumRanges].RangeLength;
      MemoryMap[*NumRanges].PhysicalAddress       = MemorySize;
      MemoryMap[*NumRanges].CpuAddress            = MemorySize;
      MemoryMap[ExtendedMemoryIndex].RangeLength -= MemoryMap[*NumRanges].RangeLength;
      MemoryMap[*NumRanges].Type = DualChannelDdrSmramCacheable;
      (*NumRanges)++;

      //
      // Update QuarkNcSoc HSMMCTL register
      //
      Register |= (UINT32)(((RShiftU64(MemorySize, 16)) & SMM_START_MASK) + (SMM_WRITE_OPEN | SMM_READ_OPEN | SMM_CODE_RD_OPEN));
      QncHsmmcWrite (Register);
    }
  }

  //
  // trim 64K memory from highest memory range for Rmu Main binary shadow
  //
  MemoryInitUpd = GetFspMemoryInitUpdDataPointer();
  MemoryMap[*NumRanges].RangeLength           = 0x10000;
  ASSERT(MemoryMap[*NumRanges].RangeLength >= MemoryInitUpd->RmuLength);
  MemorySize                                 -= MemoryMap[*NumRanges].RangeLength;
  MemoryMap[*NumRanges].PhysicalAddress       = MemorySize;
  MemoryMap[*NumRanges].CpuAddress            = MemorySize;
  MemoryMap[ExtendedMemoryIndex].RangeLength -= MemoryMap[*NumRanges].RangeLength;
  MemoryMap[*NumRanges].Type = DualChannelDdrReservedMemory;
  (*NumRanges)++;

  return EFI_SUCCESS;
}

EFI_STATUS
BaseMemoryTest (
  IN  EFI_PEI_SERVICES                   **PeiServices,
  IN  EFI_PHYSICAL_ADDRESS               BeginAddress,
  IN  UINT64                             MemoryLength,
  IN  PEI_MEMORY_TEST_OP                 Operation,
  OUT EFI_PHYSICAL_ADDRESS               *ErrorAddress
  )
{
  UINT32                TestPattern;
  EFI_PHYSICAL_ADDRESS  TempAddress;
  UINT32                SpanSize;

  TestPattern = 0x5A5A5A5A;
  SpanSize    = 0;

  //
  // Make sure we don't try and test anything above the max physical address range
  //
  ASSERT (BeginAddress + MemoryLength < MAX_ADDRESS);

  switch (Operation) {
  case Extensive:
    SpanSize = 0x4;
    break;

  case Sparse:
  case Quick:
    SpanSize = 0x40000;
    break;

  case Ignore:
    goto Done;
    break;
  }
  //
  // Write the test pattern into memory range
  //
  TempAddress = BeginAddress;
  while (TempAddress < BeginAddress + MemoryLength) {
    (*(UINT32 *) (UINTN) TempAddress) = TestPattern;
    TempAddress += SpanSize;
  }
  //
  // Read pattern from memory and compare it
  //
  TempAddress = BeginAddress;
  while (TempAddress < BeginAddress + MemoryLength) {
    if ((*(UINT32 *) (UINTN) TempAddress) != TestPattern) {
      *ErrorAddress = TempAddress;
      DEBUG ((EFI_D_ERROR, "Memory test failed at 0x%x.\n", TempAddress));
      return EFI_DEVICE_ERROR;
    }

    TempAddress += SpanSize;
  }

Done:
  return EFI_SUCCESS;
}

/** Return info derived from Installing Memory by MemoryInit.

  @param[out]      RmuMainBaseAddressPtr   Return RmuMainBaseAddress to this location.
  @param[out]      SmramDescriptorPtr  Return start of Smram descriptor list to this location.
  @param[out]      NumSmramRegionsPtr  Return numbers of Smram regions to this location.

  @return Address of RMU shadow region at the top of available memory.
  @return List of Smram descriptors for each Smram region.
  @return Numbers of Smram regions.
**/
VOID
EFIAPI
InfoPostInstallMemory (
  OUT     UINT32                    *RmuMainBaseAddressPtr OPTIONAL,
  OUT     EFI_SMRAM_DESCRIPTOR      **SmramDescriptorPtr OPTIONAL,
  OUT     UINTN                     *NumSmramRegionsPtr OPTIONAL
  )
{
  EFI_STATUS                            Status;
  EFI_PEI_HOB_POINTERS                  Hob;
  UINT64                                CalcLength;
  EFI_SMRAM_HOB_DESCRIPTOR_BLOCK        *SmramHobDescriptorBlock;

  if ((RmuMainBaseAddressPtr == NULL) && (SmramDescriptorPtr == NULL) && (NumSmramRegionsPtr == NULL)) {
    return;
  }

  SmramHobDescriptorBlock = NULL;
  if (SmramDescriptorPtr != NULL) {
    *SmramDescriptorPtr = NULL;
  }
  if (NumSmramRegionsPtr != NULL) {
    *NumSmramRegionsPtr = 0;
  }

  //
  // Calculate RMU shadow region base address.
  // Set to 1 MB. Since 1MB cacheability will always be set
  // until override by CSM.
  //
  CalcLength = 0x100000;

  Status = PeiServicesGetHobList ((VOID **) &Hob.Raw);
  ASSERT_EFI_ERROR (Status);
  while (!END_OF_HOB_LIST (Hob)) {
    if (Hob.Header->HobType == EFI_HOB_TYPE_RESOURCE_DESCRIPTOR) {
      if (Hob.ResourceDescriptor->ResourceType == EFI_RESOURCE_SYSTEM_MEMORY) {
        //
        // Skip the memory region below 1MB
        //
        if (Hob.ResourceDescriptor->PhysicalStart >= 0x100000) {
          CalcLength += (UINT64) (Hob.ResourceDescriptor->ResourceLength);
        }
      }
    } else if (Hob.Header->HobType == EFI_HOB_TYPE_GUID_EXTENSION) {
      if (CompareGuid (&(Hob.Guid->Name), &gEfiSmmPeiSmramMemoryReserveGuid)) {
        SmramHobDescriptorBlock = (VOID*) (Hob.Raw + sizeof (EFI_HOB_GUID_TYPE));
        if (SmramDescriptorPtr != NULL) {
          *SmramDescriptorPtr = SmramHobDescriptorBlock->Descriptor;
        }
        if (NumSmramRegionsPtr != NULL) {
          *NumSmramRegionsPtr = SmramHobDescriptorBlock->NumberOfSmmReservedRegions;
        }
      }
    }
    Hob.Raw = GET_NEXT_HOB (Hob);
  }

  if (RmuMainBaseAddressPtr != NULL) {
    *RmuMainBaseAddressPtr = (UINT32) CalcLength;
  }
}
