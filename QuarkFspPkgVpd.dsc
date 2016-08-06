## @file
# Configuration file of Firmware Service Package (FSP) for Quark X1000 SoC.
#
# This package provides specific modules of FSP for Quark X1000 SoC.
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

[Defines]
  #
  # UPD/VPD tool definition
  #
  VPD_TOOL_GUID           = 8C3D856A-9BE6-468E-850A-24F7A8D38E08
  DEFINE UPD_TOOL_GUID           = 3E18A0B3-C3B5-492b-86B4-53E3D401C249

[PcdsDynamicVpd.Upd]
  #
  # This section is not used by the normal build process
  # Howerver, FSP will use dedicated tool to handle it and generate a
  # VPD simliar binary block (User Platform Data). This block will
  # be accessed through a generated data structure directly rather than
  # PCD services. This is for size and performance consideration.
  # Format:
  #   gQuarkFspTokenSpaceGuid.Updxxxxxxxxxxxxn        | OFFSET | LENGTH | VALUE
  # Only simple data type is supported
  #

  #
  # Comments with !BSF will be used to generate BSF file
  # Comments with !HDR will be used to generate H header file
  #

  # Global definitions in BSF
  # !BSF PAGES:{MRC:"Memory Settings", SCT:"Chipset Settings", PLT:"Platform Settings"}
  # !BSF BLOCK:{NAME:"Quark FSP", VER:"0.1"}

  # !BSF FIND:{$QRKUPD$}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0000 | 8    | 0x244450554B525124
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0008 | 0x8  | 0

  #
  # MemoryInitUpdOffset must match the first UPD's offset in the structure of MemoryInitUpd
  #
  gQuarkFspTokenSpaceGuid.MemoryInitUpdOffset         | 0x0010 | 0x04 | 0x00000018
  #
  # SiliconInitUpdOffset must match the first UPD's offset in the structure of SiliconInitUpd
  #
  gQuarkFspTokenSpaceGuid.SiliconInitUpdOffset        | 0x0014 | 0x04 | 0x00000080

  ################################################################################
  #
  # UPDs consumed in FspMemoryInit API
  #
  ################################################################################
  # !HDR EMBED:{MEMORY_INIT_UPD:MemoryInitUpd:START}
  # MemoryInitUpdSignature: {$MEMUPD$}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0018 | 0x08 | 0x244450554D454D24
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0020 | 0x08 | 0x00

  gQuarkFspTokenSpaceGuid.RmuBaseAddress              | 0x0028 | 0x04 | 0xFFF00000
  gQuarkFspTokenSpaceGuid.RmuLength                   | 0x002C | 0x04 | 0x02000
  gQuarkFspTokenSpaceGuid.Reserved_30                 | 0x0030 | 0x04 | 0

  #
  # ACT to PRE command period in picoseconds.
  #
  gQuarkFspTokenSpaceGuid.tRAS                        | 0x0034 | 0x04 | 37500
  #
  # Delay from start of internal write transaction to internal read command in picoseconds.
  #
  gQuarkFspTokenSpaceGuid.tWTR                        | 0x0038 | 0x04 | 10000
  #
  # ACT to ACT command period (JESD79 specific to page size 1K/2K) in picoseconds.
  #
  gQuarkFspTokenSpaceGuid.tRRD                        | 0x003C | 0x04 | 10000
  #
  # Four activate window (JESD79 specific to page size 1K/2K) in picoseconds.
  #
  gQuarkFspTokenSpaceGuid.tFAW                        | 0x0040 | 0x04 | 40000
  #
  # Bitmap of MRC_FLAG_XXX:
  #
  # ECC_EN            BIT0
  # SCRAMBLE_EN       BIT1
  # MEMTEST_EN        BIT2
  # TOP_TREE_EN       BIT3  0b DDR "fly-by" topology else 1b DDR "tree" topology.
  # WR_ODT_EN         BIT4  If set ODR signal is asserted to DRAM devices on writes.
  #
  gQuarkFspTokenSpaceGuid.Flags                       | 0x0044 | 0x04 | 0x00000002
  #
  # 0=x8, 1=x16, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.DramWidth                   | 0x0048 | 0x01 | 0
  #
  # 0=DDRFREQ_800, 1=DDRFREQ_1066, others=RESERVED. Only 533MHz SKU support 1066 memory.
  #
  gQuarkFspTokenSpaceGuid.DramSpeed                   | 0x0049 | 0x01 | 0
  #
  # 0=DDR3, 1=DDR3L, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.DramType                    | 0x004A | 0x01 | 0
  #
  # bit[0] RANK0_EN, bit[1] RANK1_EN, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.RankMask                    | 0x004B | 0x01 | 1
  #
  # bit[0] CHAN0_EN, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.ChanMask                    | 0x004C | 0x01 | 1
  #
  # 1=x16, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.ChanWidth                   | 0x004D | 0x01 | 1
  #
  # 0, 1, 2 (mode 2 forced if ecc enabled), others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.AddrMode                    | 0x004E | 0x01 | 0
  #
  # 1=1.95us, 2=3.9us, 3=7.8us, others=RESERVED. REFRESH_RATE.
  #
  gQuarkFspTokenSpaceGuid.SrInt                       | 0x004F | 0x01 | 3
  #
  # 0=normal, 1=extended, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.SrTemp                      | 0x0050 | 0x01 | 0
  #
  # 0=34ohm, 1=40ohm, others=RESERVED. RON_VALUE Select MRS1.DIC driver impedance control.
  #
  gQuarkFspTokenSpaceGuid.DramRonVal                  | 0x0051 | 0x01 | 0
  #
  # 0=40ohm, 1=60ohm, 2=120ohm, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.DramRttNomVal               | 0x0052 | 0x01 | 2
  #
  # 0=off others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.DramRttWrVal                | 0x0053 | 0x01 | 0
  #
  # 0=off, 1=60ohm, 2=120ohm, 3=180ohm, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.SocRdOdtVal                 | 0x0054 | 0x01 | 0
  #
  # 0=27ohm, 1=32ohm, 2=40ohm, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.SocWrRonVal                 | 0x0055 | 0x01 | 1
  #
  # 0=2.5V/ns, 1=4V/ns, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.SocWrSlewRate               | 0x0056 | 0x01 | 1
  #
  # 0=512Mb, 1=1Gb, 2=2Gb, 3=4Gb, others=RESERVED.
  #
  gQuarkFspTokenSpaceGuid.DramDensity                 | 0x0057 | 0x01 | 1
  #
  # DRAM CAS Latency in clocks.
  #
  gQuarkFspTokenSpaceGuid.tCL                         | 0x0058 | 0x01 | 6

  # ECC scrub interval in miliseconds 1..255 (0 works as feature disable)
  gQuarkFspTokenSpaceGuid.EccScrubInterval            | 0x0059 | 0x01 | 0

  # Number of 32B blocks read for ECC scrub 2..16
  gQuarkFspTokenSpaceGuid.EccScrubBlkSize             | 0x005A | 0x01 | 2

  #
  # Size of the SMM region in 1 MiB chunks
  #
  gQuarkFspTokenSpaceGuid.SmmTsegSize                 | 0x005B | 0x01 | 2

  #
  # FSP reserved memory length in bytes
  #
  gQuarkFspTokenSpaceGuid.FspReservedMemoryLength     | 0x005C | 0x04 | 0x00100000

  #
  # Pointer to saved MRC data
  #
  gQuarkFspTokenSpaceGuid.MrcDataPtr                  | 0x0060 | 0x04 | 0

  #
  # Length of saved MRC data
  #
  gQuarkFspTokenSpaceGuid.MrcDataLength               | 0x0064 | 0x04 | 0

  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # The following three fields need be in a common header!
  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  #
  # Poll for an input character.  Passing in NULL (zero, 0) tells FSP to
  # indicate that no character is available.
  #
  gQuarkFspTokenSpaceGuid.SerialPortPollForChar       | 0x0068 | 0x04 | 0

  #
  # Read an input character.  Passing in NULL (zero) tells FSP to indicate
  # that no characters are available by returning zero (0).
  #
  gQuarkFspTokenSpaceGuid.SerialPortReadChar          | 0x006C | 0x04 | 0

  #
  # Write a single character to the serial device/log.
  # Passing in NULL (zero, 0) tells FSP to fake a successful write operation by
  # dropping the buffer contents and returning the number of characters that
  # were in the buffer.
  #
  gQuarkFspTokenSpaceGuid.SerialPortWriteChar         | 0x0070 | 0x04 | 0

  # !HDR EMBED:{MEMORY_INIT_UPD:MemoryInitUpd:END}

  gQuarkFspTokenSpaceGuid.ReservedMemoryInitUpd       | 0x0074 | 0x0C | {0x00}

  ################################################################################
  #
  # UPDs consumed in FspSiliconInit API
  #
  ################################################################################
  # !HDR EMBED:{SILICON_INIT_UPD:SiliconInitUpd:START}
  # SiliconInitUpdSignature: {$SI_UPD$}
  gQuarkFspTokenSpaceGuid.Signature                   | 0x0080 | 0x08 | 0x244450555F495324
  gQuarkFspTokenSpaceGuid.Revision                    | 0x0088 | 0x08 | 0x00

  # !HDR EMBED:{SILICON_INIT_UPD:SiliconInitUpd:END}

  # Note please keep "PcdRegionTerminator" at the end of the UPD region.
  # The tool will use this field to determine the actual end of the UPD data
  # structure. Anything after this field will still be in the UPD binary block,
  # but will be excluded in the final UPD_DATA_REGION data structure.
  gQuarkFspTokenSpaceGuid.PcdRegionTerminator         | 0x0090 | 2 | 0x55AA

[PcdsDynamicVpd]
  #
  # VPD Region Signature "QUK-FSP0"
  #

  # !BSF FIND:{QUK-FSP0}
  gQuarkFspTokenSpaceGuid.PcdVpdRegionSign            | 0x0000 | 0x305053462D4B5551

  #
  # VPD Region Revision
  #
  # !BSF NAME:{PcdImageRevision}  TYPE:{None}
  gQuarkFspTokenSpaceGuid.PcdImageRevision            | 0x0008 | 0x00000000

  # This is a offset pointer to the UCD regions used by FSP
  # The offset will be patched to point to the actual region during the build process
  #
  gQuarkFspTokenSpaceGuid.PcdUpdRegionOffset          | 0x000C | 0x12345678
