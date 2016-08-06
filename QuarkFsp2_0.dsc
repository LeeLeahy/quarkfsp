## @file
# DSC file of Firmware Service Package (FSP) for Intel Quark X1000 SoC.
#
# This package provides specific modules of FSP for Intel Quark X1000 SoC.
# Copyright (c) 2013 - 2016 Intel Corporation.
#
# This program and the accompanying materials are licensed and made available
# under the terms and conditions of the BSD License which accompanies this
# distribution.  The full text of the license may be found at
# http://opensource.org/licenses/bsd-license.php
#
# THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
# WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
#
##

################################################################################
#
# Defines Section - statements that will be processed to create a Makefile.
#
################################################################################
[Defines]
  DEFINE      FSP_PACKAGE        = QuarkFspPkg
  DEFINE      SOC_PACKAGE        = QuarkSocPkg

  PLATFORM_NAME                  = QuarkFsp2_0

  PLATFORM_GUID                  = 2655F3CF-4CC7-4e17-A62D-77FE3F10AE7F
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010005
  FLASH_DEFINITION               = $(FSP_PACKAGE)/$(PLATFORM_NAME).fdf
  OUTPUT_DIRECTORY               = Build/$(PLATFORM_NAME)
  SUPPORTED_ARCHITECTURES        = IA32
  BUILD_TARGETS                  = DEBUG|RELEASE
  SKUID_IDENTIFIER               = DEFAULT

  #
  # Platform On/Off features are defined here
  #
  DEFINE GALILEO             = GEN2
  DEFINE SECURE_BOOT_ENABLE  = FALSE
  DEFINE SOURCE_DEBUG_ENABLE = FALSE
  DEFINE PERFORMANCE_ENABLE  = FALSE
  DEFINE LOGGING             = FALSE

  !if $(TARGET) == DEBUG
    DEFINE LOGGING = TRUE
  !endif

  !if $(PERFORMANCE_ENABLE) == TRUE
    DEFINE SOURCE_DEBUG_ENABLE = FALSE
    DEFINE LOGGING             = FALSE
  !endif

  #
  # Defines FSP Revisions
  #
  DEFINE FSP_HEADER_REVISION      = 0x3
  DEFINE FSP_IMAGE_REVISION       = 0x00000000

  #
  # UPD tool definition
  #
  FSP_T_UPD_TOOL_GUID            = 34686CA3-34F9-4901-B82A-BA630F0714C6
  FSP_M_UPD_TOOL_GUID            = 39A250DB-E465-4DD1-A2AC-E2BD3C0E2385
  FSP_S_UPD_TOOL_GUID            = CAE3605B-5B34-4C85-B3D7-27D54273C40F
  FSP_T_UPD_FFS_GUID             = 70BCF6A5-FFB1-47D8-B1AE-EFE5508E23EA
  FSP_M_UPD_FFS_GUID             = D5B86AEA-6AF7-40D4-8014-982301BC3D89
  FSP_S_UPD_FFS_GUID             = E3CD9B18-998C-4F76-B65E-98B154E5446F

################################################################################
#
# SKU Identification section - list of all SKU IDs supported by this
#                              Platform.
#
################################################################################
[SkuIds]
  0|DEFAULT              # The entry: 0|DEFAULT is reserved and always required.

################################################################################
#
# Library Class section - list of all Library Classes needed by this Platform.
#
################################################################################
[LibraryClasses]
  #
  # Entry point
  #
  PeiCoreEntryPoint|MdePkg/Library/PeiCoreEntryPoint/PeiCoreEntryPoint.inf
  PeimEntryPoint|MdePkg/Library/PeimEntryPoint/PeimEntryPoint.inf

  #
  # Basic
  #
  BaseLib|MdePkg/Library/BaseLib/BaseLib.inf
  BaseMemoryLib|MdePkg/Library/BaseMemoryLibRepStr/BaseMemoryLibRepStr.inf
  PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
  CpuLib|MdePkg/Library/BaseCpuLib/BaseCpuLib.inf
  IoLib|MdePkg/Library/BaseIoLibIntrinsic/BaseIoLibIntrinsic.inf
  PciLib|MdePkg/Library/BasePciLibPciExpress/BasePciLibPciExpress.inf
  PciCf8Lib|MdePkg/Library/BasePciCf8Lib/BasePciCf8Lib.inf
  PciExpressLib|MdePkg/Library/BasePciExpressLib/BasePciExpressLib.inf
  CacheMaintenanceLib|MdePkg/Library/BaseCacheMaintenanceLib/BaseCacheMaintenanceLib.inf
  PeCoffLib|MdePkg/Library/BasePeCoffLib/BasePeCoffLib.inf
  PeCoffExtraActionLib|MdePkg/Library/BasePeCoffExtraActionLibNull/BasePeCoffExtraActionLibNull.inf
  DebugAgentLib|MdeModulePkg/Library/DebugAgentLibNull/DebugAgentLibNull.inf
  PeCoffGetEntryPointLib|MdePkg/Library/BasePeCoffGetEntryPointLib/BasePeCoffGetEntryPointLib.inf

  #
  # UEFI & PI
  #
  UefiBootServicesTableLib|MdePkg/Library/UefiBootServicesTableLib/UefiBootServicesTableLib.inf
  UefiLib|MdePkg/Library/UefiLib/UefiLib.inf
  UefiDecompressLib|IntelFrameworkModulePkg/Library/BaseUefiTianoCustomDecompressLib/BaseUefiTianoCustomDecompressLib.inf
  PeiServicesTablePointerLib|MdePkg/Library/PeiServicesTablePointerLibIdt/PeiServicesTablePointerLibIdt.inf
  PeiServicesLib|MdePkg/Library/PeiServicesLib/PeiServicesLib.inf
  UefiCpuLib|UefiCpuPkg/Library/BaseUefiCpuLib/BaseUefiCpuLib.inf
  SortLib|MdeModulePkg/Library/UefiSortLib/UefiSortLib.inf

  #
  # Generic Modules
  #
  S3IoLib|MdePkg/Library/BaseS3IoLib/BaseS3IoLib.inf
  S3PciLib|MdePkg/Library/BaseS3PciLib/BaseS3PciLib.inf
  UefiUsbLib|MdePkg/Library/UefiUsbLib/UefiUsbLib.inf
  UefiScsiLib|MdePkg/Library/UefiScsiLib/UefiScsiLib.inf
  OemHookStatusCodeLib|MdeModulePkg/Library/OemHookStatusCodeLibNull/OemHookStatusCodeLibNull.inf
  SynchronizationLib|MdePkg/Library/BaseSynchronizationLib/BaseSynchronizationLib.inf
  MemoryAllocationLib|MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf
  ReportStatusCodeLib|MdePkg/Library/BaseReportStatusCodeLibNull/BaseReportStatusCodeLibNull.inf
  LockBoxLib|MdeModulePkg/Library/LockBoxNullLib/LockBoxNullLib.inf
  VarCheckLib|MdeModulePkg/Library/VarCheckLib/VarCheckLib.inf
  DebugPrintErrorLevelLib|MdePkg/Library/BaseDebugPrintErrorLevelLib/BaseDebugPrintErrorLevelLib.inf
!if $(LOGGING)
  DebugLib|MdePkg/Library/BaseDebugLibSerialPort/BaseDebugLibSerialPort.inf
!else
  DebugLib|MdePkg/Library/BaseDebugLibNull/BaseDebugLibNull.inf
!endif
  PerformanceLib|MdePkg/Library/BasePerformanceLibNull/BasePerformanceLibNull.inf
  TpmMeasurementLib|MdeModulePkg/Library/TpmMeasurementLibNull/TpmMeasurementLibNull.inf
  AuthVariableLib|MdeModulePkg/Library/AuthVariableLibNull/AuthVariableLibNull.inf

  #
  # CPU
  #
  MtrrLib|QuarkSocPkg/QuarkNorthCluster/Library/MtrrLib/MtrrLib.inf
  LocalApicLib|UefiCpuPkg/Library/BaseXApicLib/BaseXApicLib.inf

  #
  # Quark North Cluster
  #
  SmmLib|QuarkSocPkg/QuarkNorthCluster/Library/QNCSmmLib/QNCSmmLib.inf
  SmbusLib|QuarkSocPkg/QuarkNorthCluster/Library/SmbusLib/SmbusLib.inf
  TimerLib|PcAtChipsetPkg/Library/AcpiTimerLib/DxeAcpiTimerLib.inf
  ResetSystemLib|QuarkSocPkg/QuarkNorthCluster/Library/ResetSystemLib/ResetSystemLib.inf
  IntelQNCLib|QuarkSocPkg/QuarkNorthCluster/Library/IntelQNCLib/IntelQNCLib.inf
  QNCAccessLib|QuarkSocPkg/QuarkNorthCluster/Library/QNCAccessLib/QNCAccessLib.inf
  IoApicLib|PcAtChipsetPkg/Library/BaseIoApicLib/BaseIoApicLib.inf

  #
  # Quark South Cluster
  #
  IohLib|QuarkSocPkg/QuarkSouthCluster/Library/IohLib/IohLib.inf
  I2cLib|QuarkSocPkg/QuarkSouthCluster/Library/I2cLib/I2cLib.inf
  SerialPortLib|QuarkFspPkg/Library/SerialPortLib/SerialPortLib.inf

  #
  # FSP common
  #
  CacheAsRamLib|IntelFsp2Pkg/Library/BaseCacheAsRamLibNull/BaseCacheAsRamLibNull.inf
  CacheLib|IntelFsp2Pkg/Library/BaseCacheLib/BaseCacheLib.inf
  FspSwitchStackLib|IntelFsp2Pkg/Library/BaseFspSwitchStackLib/BaseFspSwitchStackLib.inf
  FspCommonLib|IntelFsp2Pkg/Library/BaseFspCommonLib/BaseFspCommonLib.inf
  FspPlatformLib|IntelFsp2Pkg/Library/BaseFspPlatformLib/BaseFspPlatformLib.inf
  FspLib|QuarkFspPkg/Library/Fsp2_0Lib/Fsp2_0Lib.inf
  HobLib|MdePkg/Library/PeiHobLib/PeiHobLib.inf

[LibraryClasses.common.SEC]
  #
  # SEC specific phase
  #
  ReportStatusCodeLib|MdePkg/Library/BaseReportStatusCodeLibNull/BaseReportStatusCodeLibNull.inf
  PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
  TimerLib|PcAtChipsetPkg/Library/AcpiTimerLib/BaseAcpiTimerLib.inf
  MemoryAllocationLib|MdePkg/Library/PeiMemoryAllocationLib/PeiMemoryAllocationLib.inf
  CpuExceptionHandlerLib|UefiCpuPkg/Library/CpuExceptionHandlerLib/SecPeiCpuExceptionHandlerLib.inf

[LibraryClasses.IA32.PEIM,LibraryClasses.IA32.PEI_CORE]
  #
  # PEI phase common
  #
  PcdLib|MdePkg/Library/PeiPcdLib/PeiPcdLib.inf
  MemoryAllocationLib|MdePkg/Library/PeiMemoryAllocationLib/PeiMemoryAllocationLib.inf
  ReportStatusCodeLib|MdePkg/Library/BaseReportStatusCodeLibNull/BaseReportStatusCodeLibNull.inf
  ExtractGuidedSectionLib|MdePkg/Library/PeiExtractGuidedSectionLib/PeiExtractGuidedSectionLib.inf
  LockBoxLib|MdeModulePkg/Library/LockBoxNullLib/LockBoxNullLib.inf
  TimerLib|PcAtChipsetPkg/Library/AcpiTimerLib/BaseAcpiTimerLib.inf
  CpuExceptionHandlerLib|UefiCpuPkg/Library/CpuExceptionHandlerLib/SecPeiCpuExceptionHandlerLib.inf

################################################################################
#
# Pcd Section - list of all EDK II PCD Entries defined by this Platform
#
################################################################################
[PcdsFeatureFlag]

[PcdsFixedAtBuild]
  gEfiIntelFrameworkModulePkgTokenSpaceGuid.PcdS3AcpiReservedMemorySize|0x20000
  gEfiMdeModulePkgTokenSpaceGuid.PcdResetOnMemoryTypeInformationChange|FALSE
!if $(LOGGING)
    gEfiMdePkgTokenSpaceGuid.PcdDebugPropertyMask|0x27
  gEfiMdePkgTokenSpaceGuid.PcdReportStatusCodePropertyMask|0x07
!else
  gEfiMdePkgTokenSpaceGuid.PcdDebugPropertyMask|0x0
  gEfiMdePkgTokenSpaceGuid.PcdPostCodePropertyMask|0x0
  gEfiMdePkgTokenSpaceGuid.PcdReportStatusCodePropertyMask|0x3
!endif
  gEfiMdePkgTokenSpaceGuid.PcdPostCodePropertyMask|0x18
  gEfiMdePkgTokenSpaceGuid.PcdDefaultTerminalType|0
  gEfiMdePkgTokenSpaceGuid.PcdPerformanceLibraryPropertyMask|0x00
  gEfiMdeModulePkgTokenSpaceGuid.PcdLoadModuleAtFixAddressEnable|0
  gEfiMdeModulePkgTokenSpaceGuid.PcdHwErrStorageSize|0x00002000
  gEfiMdeModulePkgTokenSpaceGuid.PcdMaxHardwareErrorVariableSize|0x1000
  ## RTC Update Timeout Value, need to increase timeout since also
  # waiting for RTC to be busy.
  gEfiMdeModulePkgTokenSpaceGuid.PcdRealTimeClockUpdateTimeout|500000

  gEfiMdeModulePkgTokenSpaceGuid.PcdSerialRegisterBase|0xA0019000

  #
  #  typedef struct {
  #    UINT16  VendorId;          ///< Vendor ID to match the PCI device.  The value 0xFFFF terminates the list of entries.
  #    UINT16  DeviceId;          ///< Device ID to match the PCI device
  #    UINT32  ClockRate;         ///< UART clock rate.  Set to 0 for default clock rate of 1843200 Hz
  #    UINT64  Offset;            ///< The byte offset into to the BAR
  #    UINT8   BarIndex;          ///< Which BAR to get the UART base address
  #    UINT8   RegisterStride;    ///< UART register stride in bytes.  Set to 0 for default register stride of 1 byte.
  #    UINT16  ReceiveFifoDepth;  ///< UART receive FIFO depth in bytes. Set to 0 for a default FIFO depth of 16 bytes.
  #    UINT16  TransmitFifoDepth; ///< UART transmit FIFO depth in bytes. Set to 0 for a default FIFO depth of 16 bytes.
  #    UINT8   Reserved[2];
  #  } PCI_SERIAL_PARAMETER;
  #
  # Vendor 8086 Device 0936 Prog Interface 2, BAR #0, Offset 0, Stride = 4, Clock 44236800 (0x2a300000)
  # Vendor 8086 Device 0936 Prog Interface 2, BAR #0, Offset 0, Stride = 4, Clock 44236800 (0x2a300000)
  #
  #                                                       [Vendor]   [Device]  [---ClockRate---]  [------------Offset-----------] [Bar] [Stride] [RxFifo] [TxFifo]   [Rsvd]   [Vendor]
  gEfiMdeModulePkgTokenSpaceGuid.PcdPciSerialParameters|{0x86,0x80, 0x36,0x09, 0x0,0x0,0xA3,0x02, 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0, 0x00,    0x04, 0x0,0x0, 0x0,0x0, 0x0,0x0, 0xff,0xff}

  gPcAtChipsetPkgTokenSpaceGuid.PcdAcpiIoPciBusNumber           |0
  gPcAtChipsetPkgTokenSpaceGuid.PcdAcpiIoPciDeviceNumber        |31
  gPcAtChipsetPkgTokenSpaceGuid.PcdAcpiIoPciFunctionNumber      |0
  gPcAtChipsetPkgTokenSpaceGuid.PcdAcpiIoPciEnableRegisterOffset|0x4b
  gPcAtChipsetPkgTokenSpaceGuid.PcdAcpiIoBarEnableMask          |0x80
  gPcAtChipsetPkgTokenSpaceGuid.PcdAcpiIoPciBarRegisterOffset   |0x48
  gPcAtChipsetPkgTokenSpaceGuid.PcdAcpiIoPortBaseAddress        |0x1000
  gPcAtChipsetPkgTokenSpaceGuid.PcdAcpiPm1TmrOffset             |0x0008

  gEfiMdeModulePkgTokenSpaceGuid.PcdBootManagerMenuFile|{ 0x21, 0xaa, 0x2c, 0x46, 0x14, 0x76, 0x03, 0x45, 0x83, 0x6e, 0x8a, 0xb6, 0xf4, 0x66, 0x23, 0x31 }

  gEfiMdeModulePkgTokenSpaceGuid.PcdConInConnectOnDemand|FALSE

  #
  # FSP Definiation
  #
  gQuarkFspTokenSpaceGuid.PcdFspImageAttributes         | 0x00000000
  gQuarkFspTokenSpaceGuid.PcdFspHeaderRevision          | $(FSP_HEADER_REVISION)
  gQuarkFspTokenSpaceGuid.PcdFspImageRevision           | $(FSP_IMAGE_REVISION)
  ##@note PcdFspImageIdString and PcdVpdRegionSign must be identical. Don't change one without the other.
  gQuarkFspTokenSpaceGuid.PcdFspImageIdString           | 0x305053462D4B5551  #QUK-FSP0
  gIntelFsp2PkgTokenSpaceGuid.PcdTemporaryRamBase             | 0x80070000
  gIntelFsp2PkgTokenSpaceGuid.PcdTemporaryRamSize             | 0x00010000
  gIntelFsp2PkgTokenSpaceGuid.PcdFspTemporaryRamSize          | 0x00008000
  gIntelFsp2PkgTokenSpaceGuid.PcdFspAreaBaseAddress           | 0x80000000
  gIntelFsp2PkgTokenSpaceGuid.PcdFspAreaSize                  | 0x00040000
  gIntelFsp2PkgTokenSpaceGuid.PcdGlobalDataPointerAddress     | 0xFED00148

[PcdsPatchableInModule]
!if $(TARGET) == DEBUG
  gEfiMdePkgTokenSpaceGuid.PcdDebugPrintErrorLevel         | 0x803000C7
!else
  gEfiMdePkgTokenSpaceGuid.PcdDebugPrintErrorLevel         | 0x00000001
!endif
  gEfiMdeModulePkgTokenSpaceGuid.PcdVpdBaseAddress         | 0x12345678
  gEfiMdePkgTokenSpaceGuid.PcdPciExpressBaseAddress        | 0xE0000000

###################################################################################################
#
# FSP UPD/VPD definition
#
###################################################################################################

[PcdsDynamicVpd.Upd]
  #
  # This section is not used by the normal build process
  # However, FSP will use dedicated tool to handle it and generate a
  # VPD similar binary block (User Configuration Data). This block will
  # be accessed through a generated data structure directly rather than
  # PCD services. This is for size consideration.
  # Format:
  #   gQuarkFspTokenSpaceGuid.Updxxxxxxxxxxxxn      | OFFSET | LENGTH | VALUE
  # Only simple data type is supported
  #

  #
  # Comments with !BSF will be used to generate BSF file
  # Comments with !HDR will be used to generate H header file
  #

  # Global definitions in BSF
  # !BSF PAGES:{MEM:"FSP MemoryInit Settings", SIL:"FSP SiliconInit Settings"}
  # !BSF BLOCK:{NAME:"Quark FSP", VERSION:"0.1"}

#============================================================================#
# FSP-T (TempRamInit) UPDs
#============================================================================#

  # !BSF FIND:{QRKUPD_T}
  # !HDR COMMENT:{FSP_UPD_HEADER:FSP UPD Header}
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:START}
  # FsptUpdSignature: {QRKUPD_T}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0000 | 0x08 | 0x545F4450554B5251
  # !BSF NAME:{FsptUpdRevision}  TYPE:{None}
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0008 | 0x01 | 0x01
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:END}
  gQuarkFspTokenSpaceGuid.Reserved                    | 0x0009 | 0x17 | {0x00}

#============================================================================#

  # !HDR COMMENT:{FSPT_COMMON_UPD:Fsp T Common UPD}
  # !HDR EMBED:{FSPT_COMMON_UPD:FsptCommonUpd:START}
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0020 | 0x01 | 0x01
  gQuarkFspTokenSpaceGuid.Reserved                    | 0x0021 | 0x03 | {0x00}

  # Base address of the microcode region.
  gQuarkFspTokenSpaceGuid.MicrocodeRegionBase         | 0x0024 | 0x04 | 0x00000000

  # Length of the microcode region.
  gQuarkFspTokenSpaceGuid.MicrocodeRegionLength       | 0x0028 | 0x04 | 0x00000000

  # Base address of the cacheable flash region.
  gQuarkFspTokenSpaceGuid.CodeRegionBase              | 0x002C | 0x04 | 0x00000000

  # Length of the cacheable flash region.
  gQuarkFspTokenSpaceGuid.CodeRegionLength            | 0x0030 | 0x04 | 0x00000000

  # !HDR EMBED:{FSPT_COMMON_UPD:FsptCommonUpd:END}
  gQuarkFspTokenSpaceGuid.Reserved1                   | 0x0034 | 0x0C | {0x00}

  # !HDR COMMENT:{FSP_T_CONFIG:Fsp T Configuration}

#============================================================================#

  # Note please keep "UpdTerminator" at the end of each UPD region.
  # The tool will use this field to determine the actual end of the UPD data
  # structure.
  gQuarkFspTokenSpaceGuid.UpdTerminator               | 0x0040 | 0x02 | 0x55AA

#============================================================================#
# FSP-M (MemoryInit) UPDs
#============================================================================#

  # !BSF FIND:{QRKUPD_M}
  # !HDR COMMENT:{FSP_UPD_HEADER:FSP UPD Header}
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:START}
  # FspmUpdSignature: {QRKUPD_M}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0000 | 0x08 | 0x4D5F4450554B5251
  # !BSF NAME:{FspmUpdRevision}  TYPE:{None}
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0008 | 0x01 | 0x01
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:END}
  gQuarkFspTokenSpaceGuid.Reserved                    | 0x0009 | 0x17 | {0x00}

#============================================================================#

  # !HDR COMMENT:{FSPM_ARCH_UPD:Fsp M Architectural UPD}
  # !HDR EMBED:{FSPM_ARCH_UPD:FspmArchUpd:START}
  # !BSF PAGE:{MEM}

  gQuarkFspTokenSpaceGuid.Revision                    | 0x0020 | 0x01 | 0x01

  gQuarkFspTokenSpaceGuid.Reserved                    | 0x0021 | 0x03 | {0x00}

  # !HDR STRUCT:{VOID*}
  gQuarkFspTokenSpaceGuid.NvsBufferPtr                | 0x0024 | 0x04 | 0x00000000

  # !HDR STRUCT:{VOID*}
  # !BSF NAME:{StackBase}
  # !BSF HELP:{Stack base for FSP use. Default: 0xFEF16000}
  gQuarkFspTokenSpaceGuid.StackBase                   | 0x0028 | 0x04 | 0xFEF16000

  # !BSF NAME:{StackSize}
  # !BSF HELP:{To pass the stack size for FSP use. Bootloader can}
  # !BSF HELP:{+ programmatically get the FSP requested StackSize by using the}
  # !BSF HELP:{+ defaults in the FSP-M component. This is the minimum stack size}
  # !BSF HELP:{+ expected by this revision of FSP. Default: 0x2A000}
  gQuarkFspTokenSpaceGuid.StackSize                   | 0x002C | 0x04 | 0x0002A000

  # !BSF NAME:{BootLoaderTolumSize}
  # !BSF HELP:{To pass Bootloader Tolum size.}
  gQuarkFspTokenSpaceGuid.BootLoaderTolumSize         | 0x0030 | 0x04 | 0x00000000

  # !BSF NAME:{Bootmode}
  # !BSF HELP:{To maintain Bootmode details.}
  gQuarkFspTokenSpaceGuid.Bootmode                    | 0x0034 | 0x04 | 0x00000000

  # !HDR EMBED:{FSPM_ARCH_UPD:FspmArchUpd:END}
  gQuarkFspTokenSpaceGuid.Reserved1                   | 0x0038 | 0x08 | {0x00}

#============================================================================#

  # !HDR COMMENT:{FSP_M_CONFIG:Fsp M Configuration}
  # !HDR EMBED:{FSP_M_CONFIG:FspmConfig:START}

  # !BSF NAME:{RmuBaseAddress}
  # !BSF HELP:{RMU microcode binary base address in SPI flash'}
  gQuarkFspTokenSpaceGuid.RmuBaseAddress              | 0x0040 | 0x04 | 0xFFF00000

  # !BSF NAME:{RmuLength}
  # !BSF TYPE:{EditNum, HEX, (0x00000000,0x00010000)}
  # !BSF HELP:{RMU microcode binary length in bytes}
  gQuarkFspTokenSpaceGuid.RmuLength                   | 0x0044 | 0x04 | 0x02000

  # !BSF NAME:{SerialPortBaseAddress}
  # !BSF HELP:{Debug serial port base address set by BIOS. Zero disables debug}
  # !BSF HELP:{+ serial output.}
  gQuarkFspTokenSpaceGuid.Reserved_48                 | 0x0048 | 0x04 | 0

  # !BSF NAME:{tRAS}
  # !BSF TYPE:{EditNum, HEX, (0x00000000,0xFFFFFFFF)}
  # !BSF HELP:{ACT to PRE command period in picoseconds.}
  gQuarkFspTokenSpaceGuid.tRAS                        | 0x004C | 0x04 | 37500

  # !BSF NAME:{tWTR}
  # !BSF TYPE:{EditNum, HEX, (0x00000000,0xFFFFFFFF)}
  # !BSF HELP:{Delay from start of internal write transaction to internal read}
  # !BSF HELP:{+ command in picoseconds.}
  gQuarkFspTokenSpaceGuid.tWTR                        | 0x0050 | 0x04 | 10000

  # !BSF NAME:{tRRD}
  # !BSF TYPE:{EditNum, HEX, (0x00000000,0xFFFFFFFF)}
  # !BSF HELP:{ACT to ACT command period (JESD79 specific to page size 1K/2K)}
  # !BSF HELP:{+ in picoseconds.}
  gQuarkFspTokenSpaceGuid.tRRD                        | 0x0054 | 0x04 | 10000

  # !BSF NAME:{tFAW}
  # !BSF TYPE:{EditNum, HEX, (0x00000000,0xFFFFFFFF)}
  # !BSF HELP:{Four activate window (JESD79 specific to page size 1K/2K) in}
  # !BSF HELP:{+ picoseconds.}
  gQuarkFspTokenSpaceGuid.tFAW                        | 0x0058 | 0x04 | 40000

  # !BSF NAME:{Flags}
  # !BSF TYPE:{EditNum, HEX, (0x00000000,0xFFFFFFFF)}
  # !BSF HELP:{Bitmap of MRC_FLAG_XXX:}
  # !BSF HELP:{+ ECC_EN            BIT0,}
  # !BSF HELP:{+ SCRAMBLE_EN       BIT1,}
  # !BSF HELP:{+ MEMTEST_EN        BIT2,}
  # !BSF HELP:{+ TOP_TREE_EN       BIT3  0b DDR "fly-by" topology else 1b DDR}
  # !BSF HELP:{+ "tree" topology,}
  # !BSF HELP:{+ WR_ODT_EN         BIT4  If set ODR signal is asserted to DRAM}
  # !BSF HELP:{+ devices on writes.}
  gQuarkFspTokenSpaceGuid.Flags                       | 0x005C | 0x04 | 0x00000002

  # !BSF NAME:{DramWidth}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x1)}
  # !BSF HELP:{0=x8, 1=x16, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.DramWidth                   | 0x0060 | 0x01 | 0

  # !BSF NAME:{DramSpeed}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x1)}
  # !BSF HELP:{0=DDRFREQ_800, 1=DDRFREQ_1066, others=RESERVED. Only 533MHz SKU}
  # !BSF HELP:{+ support 1066 memory.}
  gQuarkFspTokenSpaceGuid.DramSpeed                   | 0x0061 | 0x01 | 0

  # !BSF NAME:{DramType}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x1)}
  # !BSF HELP:{0=DDR3, 1=DDR3L, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.DramType                    | 0x0062 | 0x01 | 0

  # !BSF NAME:{RankMask}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x3)}
  # !BSF HELP:{bit[0] RANK0_EN, bit[1] RANK1_EN, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.RankMask                    | 0x0063 | 0x01 | 1

  # !BSF NAME:{ChanMask}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x1)}
  # !BSF HELP:{bit[0] CHAN0_EN, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.ChanMask                    | 0x0064 | 0x01 | 1

  # !BSF NAME:{ChanWidth}
  # !BSF HELP:{1=x16, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.ChanWidth                   | 0x0065 | 0x01 | 1

  # !BSF NAME:{AddrMode}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x2)}
  # !BSF HELP:{0, 1, 2 (mode 2 forced if ecc enabled), others=RESERVED.}
  gQuarkFspTokenSpaceGuid.AddrMode                    | 0x0066 | 0x01 | 0

  # !BSF NAME:{SrInt}
  # !BSF TYPE:{EditNum, HEX, (0x1,0x3)}
  # !BSF HELP:{1=1.95us, 2=3.9us, 3=7.8us, others=RESERVED. REFRESH_RATE.}
  gQuarkFspTokenSpaceGuid.SrInt                       | 0x0067 | 0x01 | 3

  # !BSF NAME:{SrTemp}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x1)}
  # !BSF HELP:{0=normal, 1=extended, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.SrTemp                      | 0x0068 | 0x01 | 0

  # !BSF NAME:{DramRonVal}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x1)}
  # !BSF HELP:{0=34ohm, 1=40ohm, others=RESERVED. RON_VALUE Select MRS1.DIC}
  # !BSF HELP:{+ driver impedance control.}
  gQuarkFspTokenSpaceGuid.DramRonVal                  | 0x0069 | 0x01 | 0

  # !BSF NAME:{DramRttNomVal}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x2)}
  # !BSF HELP:{0=40ohm, 1=60ohm, 2=120ohm, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.DramRttNomVal               | 0x006A | 0x01 | 2

  # !BSF NAME:{DramRttWrVal}
  # !BSF HELP:{0=off others=RESERVED.}
  gQuarkFspTokenSpaceGuid.DramRttWrVal                | 0x006B | 0x01 | 0

  # !BSF NAME:{SocRdOdtVal}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x3)}
  # !BSF HELP:{0=off, 1=60ohm, 2=120ohm, 3=180ohm, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.SocRdOdtVal                 | 0x006C | 0x01 | 0

  # !BSF NAME:{SocWrRonVal}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x2)}
  # !BSF HELP:{0=27ohm, 1=32ohm, 2=40ohm, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.SocWrRonVal                 | 0x006D | 0x01 | 1

  # !BSF NAME:{SocWrSlewRate}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x1)}
  # !BSF HELP:{0=2.5V/ns, 1=4V/ns, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.SocWrSlewRate               | 0x006E | 0x01 | 1

  # !BSF NAME:{DramDensity}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x3)}
  # !BSF HELP:{0=512Mb, 1=1Gb, 2=2Gb, 3=4Gb, others=RESERVED.}
  gQuarkFspTokenSpaceGuid.DramDensity                 | 0x006F | 0x01 | 1

  # !BSF NAME:{tCL}
  # !BSF TYPE:{EditNum, HEX, (0x00,0xFF)}
  # !BSF HELP:{DRAM CAS Latency in clocks}
  gQuarkFspTokenSpaceGuid.tCL                         | 0x0070 | 0x01 | 6

  # !BSF NAME:{EccScrubInterval}
  # !BSF TYPE:{EditNum, HEX, (0x00,0xFF)}
  # !BSF HELP:{ECC scrub interval in miliseconds 1..255 (0 works as feature}
  # !BSF HELP:{+ disable}
  gQuarkFspTokenSpaceGuid.EccScrubInterval            | 0x0071 | 0x01 | 0

  # !BSF NAME:{EccScrubBlkSize}
  # !BSF TYPE:{EditNum, HEX, (0x2,0x10)}
  # !BSF HELP:{Number of 32B blocks read for ECC scrub 2..16}
  gQuarkFspTokenSpaceGuid.EccScrubBlkSize             | 0x0072 | 0x01 | 2

  # !BSF NAME:{SmmTsegSize}
  # !BSF TYPE:{EditNum, HEX, (0x0,0x8)}
  # !BSF HELP:{Size of the SMM region in 1 MiB chunks}
  gQuarkFspTokenSpaceGuid.SmmTsegSize                 | 0x0073 | 0x01 | 2

  # !BSF NAME:{FspReservedMemoryLength}
  # !BSF TYPE:{EditNum, HEX, (0x00000000,0xFFFFFFFF)}
  # !BSF HELP:{FSP reserved memory length in bytes}
  gQuarkFspTokenSpaceGuid.FspReservedMemoryLength     | 0x0074 | 0x04 | 0x00100000

  # !BSF NAME:{MrcDataPtr}
  # !BSF HELP:{Pointer to saved MRC data}
  gQuarkFspTokenSpaceGuid.MrcDataPtr                  | 0x0078 | 0x04 | 0

  # !BSF NAME:{MrcDataLength}
  # !BSF HELP:{Length of saved MRC data}
  gQuarkFspTokenSpaceGuid.MrcDataLength               | 0x007C | 0x04 | 0

  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # The following three fields need be in a common header!
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  #
  # Poll for an input character.  Passing in NULL (zero, 0) tells FSP to
  # indicate that no character is available.
  #
  gQuarkFspTokenSpaceGuid.SerialPortPollForChar       | 0x0080 | 0x04 | 0

  #
  # Read an input character.  Passing in NULL (zero) tells FSP to indicate
  # that no characters are available by returning zero (0).
  #
  gQuarkFspTokenSpaceGuid.SerialPortReadChar          | 0x0084 | 0x04 | 0

  #
  # Write a single character to the serial device/log.
  # Passing in NULL (zero, 0) tells FSP to fake a successful write operation by
  # dropping the buffer contents and returning the number of characters that
  # were in the buffer.
  #
  gQuarkFspTokenSpaceGuid.SerialPortWriteChar         | 0x0088 | 0x04 | 0

  # !HDR EMBED:{FSP_M_CONFIG:FspmConfig:END}

#============================================================================#

  # Note please keep "UpdTerminator" at the end of each UPD region.
  # The tool will use this field to determine the actual end of the UPD data
  # structure.
  gQuarkFspTokenSpaceGuid.UpdTerminator               | 0x008C | 0x02 | 0x55AA

#============================================================================#
# FSP-S (SiliconInit) UPDs
#============================================================================#

  # !BSF FIND:{QRKUPD_S}
  # !HDR COMMENT:{FSP_UPD_HEADER:FSP UPD Header}
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:START}
  # FspsUpdSignature: {QRKUPD_S}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0000 | 0x08 | 0x535F4450554B5251
  # !BSF NAME:{FspsUpdRevision}  TYPE:{None}
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0008 | 0x01 | 0x01
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:END}
  gQuarkFspTokenSpaceGuid.Reserved                    | 0x0009 | 0x17 | {0x00}

#============================================================================#

  # Note please keep "UpdTerminator" at the end of each UPD region.
  # The tool will use this field to determine the actual end of the UPD data
  # structure.
  gQuarkFspTokenSpaceGuid.UpdTerminator               | 0x0020 | 0x02 | 0x55AA

###################################################################################################
#
# Components Section - list of the modules and components that will be processed by compilation
#                      tools and the EDK II tools to generate PE32/PE32+/Coff image files.
#
# Note: The EDK II DSC file is not used to specify how compiled binary images get placed
#       into firmware volume images. This section is just a list of modules to compile from
#       source into UEFI-compliant binaries.
#       It is the FDF file that contains information on combining binary files into firmware
#       volume images, whose concept is beyond UEFI and is described in PI specification.
#       Binary modules do not need to be listed in this section, as they should be
#       specified in the FDF file. For example: Shell binary, FAT binary (Fat.efi),
#       Logo (Logo.bmp), and etc.
#       There may also be modules listed in this section that are not required in the FDF file,
#       When a module listed here is excluded from FDF file, then UEFI-compliant binary will be
#       generated for it, but the binary will not be put into any firmware volume.
#
###################################################################################################

[Components.IA32]
  #
  # SEC
  #
  $(FSP_PACKAGE)/Override/IntelFsp2Pkg/FspSecCore/FspSecCoreT.inf
  $(FSP_PACKAGE)/Override/IntelFsp2Pkg/FspSecCore/FspSecCoreM.inf
  $(FSP_PACKAGE)/Override/IntelFsp2Pkg/FspSecCore/FspSecCoreS.inf

  #
  # PEI Core
  #
  MdeModulePkg/Core/Pei/PeiMain.inf

  #
  # PEIM
  #
  MdeModulePkg/Universal/PCD/Pei/Pcd.inf {
    <LibraryClasses>
      PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
  }

  #
  # FSP INFO Header
  #
  QuarkFspPkg/Fsp2Header/FspHeader.inf

  QuarkFspPkg/FspInit/Pei/FspInitPreMem.inf
  QuarkSocPkg/QuarkNorthCluster/MemoryInit/Pei/MemoryInitPei.inf

  #
  # FSP IPL
  #
  MdeModulePkg/Core/DxeIplPeim/DxeIpl.inf
