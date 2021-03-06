/** @file
Memory reference code wrapper for the Quark Memory Controller.

Copyright (c) 2013 - 2016 Intel Corporation.

This program and the accompanying materials are licensed and made available
under the terms and conditions of the BSD License which accompanies this
distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#ifndef _MRC_WRAPPER_H
#define _MRC_WRAPPER_H

//
// Define the default memory areas required
//
#define EDKII_RESERVED_SIZE_PAGES         0x20
#define ACPI_NVS_SIZE_PAGES               0x60
#define RUNTIME_SERVICES_DATA_SIZE_PAGES  0x20
#define RUNTIME_SERVICES_CODE_SIZE_PAGES  0x80
#define ACPI_RECLAIM_SIZE_PAGES           0x20
#define EDKII_DXE_MEM_SIZE_PAGES          0x20

#define AP_STARTUP_VECTOR                 0x00097000

//
// Maximum number of "Socket Sets", where a "Socket Set is a set of matching
// DIMM's from the various channels
//
#define MAX_SOCKET_SETS      2

//
// Maximum number of memory ranges supported by the memory controller
//
#define MAX_RANGES (MAX_ROWS + 5)

#define PEI_MEMORY_RANGE_OPTION_ROM UINT32
#define PEI_MR_OPTION_ROM_NONE      0x00000000

//
// SMRAM Memory Range
//
#define PEI_MEMORY_RANGE_SMRAM      UINT32
#define PEI_MR_SMRAM_ALL            0xFFFFFFFF
#define PEI_MR_SMRAM_NONE           0x00000000
#define PEI_MR_SMRAM_CACHEABLE_MASK 0x80000000
#define PEI_MR_SMRAM_SEGTYPE_MASK   0x00FF0000
#define PEI_MR_SMRAM_ABSEG_MASK     0x00010000
#define PEI_MR_SMRAM_HSEG_MASK      0x00020000
#define PEI_MR_SMRAM_TSEG_MASK      0x00040000
//
// SMRAM Size is a multiple of 128KB.
//
#define PEI_MR_SMRAM_SIZE_MASK          0x0000FFFF

//
// Pci Memory Hole
//
#define PEI_MEMORY_RANGE_PCI_MEMORY       UINT32

typedef enum {
  Ignore,
  Quick,
  Sparse,
  Extensive
} PEI_MEMORY_TEST_OP;

//
// MRC Params Variable structure.
//

typedef struct {
  MrcTimings_t timings;              // Actual MRC config values saved in variable store.
  UINT8        VariableStorePad[8];  // Allow for data stored in variable is required to be multiple of 8bytes.
} PLATFORM_VARIABLE_MEMORY_CONFIG_DATA;

///
/// MRC Params Platform Data Flags bits
///
#define MRC_FLAG_ECC_EN            BIT0
#define MRC_FLAG_SCRAMBLE_EN       BIT1
#define MRC_FLAG_MEMTEST_EN        BIT2
#define MRC_FLAG_TOP_TREE_EN       BIT3  ///< 0b DDR "fly-by" topology else 1b DDR "tree" topology.
#define MRC_FLAG_WR_ODT_EN         BIT4  ///< If set ODR signal is asserted to DRAM devices on writes.

//
// Memory range types
//
typedef enum {
  DualChannelDdrMainMemory,
  DualChannelDdrSmramCacheable,
  DualChannelDdrSmramNonCacheable,
  DualChannelDdrGraphicsMemoryCacheable,
  DualChannelDdrGraphicsMemoryNonCacheable,
  DualChannelDdrBiosReservedMemory,
  DualChannelDdrFspReservedMemory,
  DualChannelDdrGraphicsReservedMemory,
  DualChannelDdrRmuReservedMemory,
  DualChannelDdrMaxMemoryRangeType
} PEI_DUAL_CHANNEL_DDR_MEMORY_RANGE_TYPE;

//
// Memory map range information
//
typedef struct {
  EFI_PHYSICAL_ADDRESS                          PhysicalAddress;
  EFI_PHYSICAL_ADDRESS                          CpuAddress;
  EFI_PHYSICAL_ADDRESS                          RangeLength;
  PEI_DUAL_CHANNEL_DDR_MEMORY_RANGE_TYPE        Type;
} PEI_DUAL_CHANNEL_DDR_MEMORY_MAP_RANGE;

//
// Function prototypes.
//

EFI_STATUS
MemoryInit (
  VOID
  );

#endif
