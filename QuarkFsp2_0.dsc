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
  DEFINE FSP_HEADER_REVISION      = 0x2
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

[LibraryClasses.common.SEC]
  #
  # SEC specific phase
  #
  ReportStatusCodeLib|MdePkg/Library/BaseReportStatusCodeLibNull/BaseReportStatusCodeLibNull.inf
  PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
  TimerLib|PcAtChipsetPkg/Library/AcpiTimerLib/BaseAcpiTimerLib.inf
  HobLib|MdePkg/Library/PeiHobLib/PeiHobLib.inf
  MemoryAllocationLib|MdePkg/Library/PeiMemoryAllocationLib/PeiMemoryAllocationLib.inf
  CpuExceptionHandlerLib|UefiCpuPkg/Library/CpuExceptionHandlerLib/SecPeiCpuExceptionHandlerLib.inf

[LibraryClasses.IA32.PEIM,LibraryClasses.IA32.PEI_CORE]
  #
  # PEI phase common
  #
  PcdLib|MdePkg/Library/PeiPcdLib/PeiPcdLib.inf
  HobLib|MdePkg/Library/PeiHobLib/PeiHobLib.inf
  MemoryAllocationLib|MdePkg/Library/PeiMemoryAllocationLib/PeiMemoryAllocationLib.inf
  ReportStatusCodeLib|MdePkg/Library/BaseReportStatusCodeLibNull/BaseReportStatusCodeLibNull.inf
  ExtractGuidedSectionLib|MdePkg/Library/PeiExtractGuidedSectionLib/PeiExtractGuidedSectionLib.inf
  LockBoxLib|MdeModulePkg/Library/LockBoxNullLib/LockBoxNullLib.inf
  TimerLib|PcAtChipsetPkg/Library/AcpiTimerLib/BaseAcpiTimerLib.inf
  PlatformHelperLib|QuarkFspPkg/Library/PlatformHelperLib/PeiPlatformHelperLib.inf
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

[PcdsDynamicExDefault.common.DEFAULT]
  #
  # FSP UPD/VPD definition
  #
  !include QuarkFspPkg/QuarkFspPkgVpd.dsc

#============================================================================#
# Start of UPDs
#============================================================================#

[PcdsDynamicVpd.Upd]
  #
  # This section is not used by the normal build process
  # Howerver, FSP will use dedicated tool to handle it and generate a
  # VPD simliar binary block (User Configuration Data). This block will
  # be accessed through a generated data structure directly rather than
  # PCD services. This is for size consideration.
  # Format:
  #   gQuarkFspTokenSpaceGuid.Updxxxxxxxxxxxxn        | OFFSET | LENGTH | VALUE
  # Only simple data type is supported
  #

  #
  # Comments with !BSF will be used to generate BSF file
  # Comments with !HDR will be used to generate H header file
  #

  # Global definitions in BSF
  # !BSF PAGES:{MEM:"FSP MemoryInit Settings", SIL:"FSP SiliconInit Settings"}
  # !BSF BLOCK:{NAME:"Quark Platform", VER:"0.1"}

#============================================================================#
# FSP-T UPDs
#============================================================================#

  # !BSF FIND:{FSPT_UPD}
  # !HDR COMMENT:{FSP_UPD_HEADER:FSP UPD Header}
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:START}
  # FsptUpdSignature: {FSPT_UPD}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0000 | 0x08 | 0x4450555F54505346
  # !BSF NAME:{PcdImageRevision}  TYPE:{None}
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0008 | 0x04 | $(FSP_IMAGE_REVISION)
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:END}
  gQuarkFspTokenSpaceGuid.Reserved                    | 0x000c | 0x14 | {0x00}

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

#============================================================================#

  # Note please keep "UpdTerminator" at the end of each UPD region.
  # The tool will use this field to determine the actual end of the UPD data
  # structure.
  gQuarkFspTokenSpaceGuid.UpdTerminator               | 0x0040 | 0x02 | 0x55AA

#============================================================================#
# FSP-M UPDs - MemoryInit
#============================================================================#

  # !BSF FIND:{FSPM_UPD}
  # !HDR COMMENT:{FSP_UPD_HEADER:FSP UPD Header}
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:START}
  # FspmUpdSignature: {FSPM_UPD}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0000 | 0x08 | 0x4450555F4D505346
  # !BSF NAME:{PcdImageRevision}  TYPE:{None}
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0008 | 0x04 | $(FSP_IMAGE_REVISION)
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:END}
  gQuarkFspTokenSpaceGuid.Reserved                    | 0x000c | 0x14 | {0x00}

#============================================================================#

  # !HDR COMMENT:{FSP_M_CONFIG:Fsp M Configuration}
  # !HDR EMBED:{FSP_M_CONFIG:FspmConfig:START}
  # !BSF NAME:{Debug Serial Port Base address}
  # !BSF TYPE:{EditNum, HEX, (0x00000000,0xFFFFFFFF)}
  # !BSF HELP:{Debug serial port base address. This option will be used only when the 'Serial Port Debug Device'}
  # !BSF HELP:{+ option is set to 'External Device'. 0x00000000(Default).}
  gQuarkFspTokenSpaceGuid.PcdUartBaseAddress          | 0x0020 | 0x04 | 0x00000000

#============================================================================#

  # !BSF NAME:{MRC Parameters}  TYPE:{EditNum, HEX, (0x00,0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)}
  # !BSF HELP:{Configuration data for the Memory Reference Code}
!if $(GALILEO) == GEN1
  gEfiQuarkNcSocIdTokenSpaceGuid.PcdMrcParameters      | 0x0024 | 0x28 | {0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x00, 0x03, 0x00, 0x00, 0x02, 0x00, 0x00, 0x01, 0x01, 0x01, 0x7c, 0x92, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x40, 0x9c, 0x00, 0x00, 0x06}
!endif
!if $(GALILEO) == GEN2
  gEfiQuarkNcSocIdTokenSpaceGuid.PcdMrcParameters      | 0x0024 | 0x28 | {0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x00, 0x03, 0x00, 0x00, 0x02, 0x00, 0x00, 0x01, 0x01, 0x01, 0x7c, 0x92, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x10, 0x27, 0x00, 0x00, 0x40, 0x9c, 0x00, 0x00, 0x06}
!endif

  # !HDR EMBED:{FSP_M_CONFIG:FspmConfig:END}

#============================================================================#

  # Note please keep "UpdTerminator" at the end of each UPD region.
  # The tool will use this field to determine the actual end of the UPD data
  # structure.
  gQuarkFspTokenSpaceGuid.UpdTerminator               | 0x0050 | 0x02 | 0x55AA

#============================================================================#
# FSP-S UPDs - SiliconInit
#============================================================================#

  # !BSF FIND:{FSPS_UPD}
  # !HDR COMMENT:{FSP_UPD_HEADER:FSP UPD Header}
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:START}
  # FspsUpdSignature: {FSPS_UPD}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0000 | 0x08 | 0x4450555F53505346
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0008 | 0x04 | 0x00
  # !HDR EMBED:{FSP_UPD_HEADER:FspUpdHeader:END}
  gQuarkFspTokenSpaceGuid.Reserved                    | 0x000c | 0x14 | {0x00}

#============================================================================#

  # !HDR COMMENT:{FSP_S_CONFIG:Fsp S Configuration}
  # !HDR EMBED:{FSP_S_CONFIG:FspsConfig:START}

  # !BSF PAGE:{Ethernet}

  # !BSF NAME:{Ethernet 0 MAC Address}  TYPE:{EditNum, HEX, (0x00,0xFFFFFFFFFFFF)}
  # !BSF HELP:{Ethernet address for controller 0}
  gEfiQuarkSCSocIdTokenSpaceGuid.PcdIohEthernetMac0    | 0x0020 | 0x08 | {0xff, 0xff, 0xff, 0xff, 0xff, 0xff}
  # !BSF NAME:{Ethernet 1 MAC Address}  TYPE:{EditNum, HEX, (0x00,0xFFFFFFFFFFFF)}
  # !BSF HELP:{Ethernet address for controller 1}
  gEfiQuarkSCSocIdTokenSpaceGuid.PcdIohEthernetMac1    | 0x0028 | 0x08 | {0xff, 0xff, 0xff, 0xff, 0xff, 0xff}

  # !HDR EMBED:{FSP_S_CONFIG:FspsConfig:END}

#============================================================================#

  # Note please keep "UpdTerminator" at the end of each UPD region.
  # The tool will use this field to determine the actual end of the UPD data
  # structure.
  gQuarkFspTokenSpaceGuid.UpdTerminator               | 0x0030 | 0x02 | 0x55AA

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
