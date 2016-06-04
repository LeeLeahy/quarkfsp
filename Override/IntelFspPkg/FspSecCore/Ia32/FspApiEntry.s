#------------------------------------------------------------------------------
#
# Copyright (c) 2014 - 2016, Intel Corporation. All rights reserved.<BR>
# This program and the accompanying materials
# are licensed and made available under the terms and conditions of the BSD License
# which accompanies this distribution.  The full text of the license may be found at
# http://opensource.org/licenses/bsd-license.php.
#
# THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
# WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
#
# Abstract:
#
#   Provide FSP API entry points.
#
#------------------------------------------------------------------------------

#
# Following are fixed PCDs
#
ASM_GLOBAL    ASM_PFX(_gPcd_FixedAtBuild_PcdTemporaryRamBase)
ASM_GLOBAL    ASM_PFX(_gPcd_FixedAtBuild_PcdTemporaryRamSize)
ASM_GLOBAL    ASM_PFX(_gPcd_FixedAtBuild_PcdFspTemporaryRamSize)
ASM_GLOBAL    ASM_PFX(_gPcd_FixedAtBuild_PcdFspAreaBaseAddress)

#
# Following functions will be provided in C
#
ASM_GLOBAL    ASM_PFX(SecStartup)
ASM_GLOBAL    ASM_PFX(FspApiCallingCheck)

#
# Following functions will be provided in PlatformSecLib
#
ASM_GLOBAL    ASM_PFX(AsmGetFspBaseAddress)
ASM_GLOBAL    ASM_PFX(AsmGetFspInfoHeader)
ASM_GLOBAL    ASM_PFX(GetBootFirmwareVolumeOffset)
ASM_GLOBAL    ASM_PFX(Loader2PeiSwitchStack)

#
# Define the data length that we saved on the stack top
#
.equ          DATA_LEN_OF_PER0, 0x018
.equ          DATA_LEN_OF_MCUD, 0x018
.equ          DATA_LEN_AT_STACK_TOP, (DATA_LEN_OF_PER0 + DATA_LEN_OF_MCUD + 4)

#----------------------------------------------------------------------------
# TempRamInit API
#
# This FSP API will load the microcode update, enable code caching for the
# region specified by the boot loader and also setup a temporary stack to be
# used till main memory is initialized.
#
#----------------------------------------------------------------------------
ASM_GLOBAL ASM_PFX(TempRamInitApi)
ASM_PFX(TempRamInitApi):
################ Quark SoC - Start ###################
# TempRamInit API is an empty API since Quark SoC does
# not support CAR.
  #
  # Check Parameter
  #
  movl      4(%esp), %eax
  cmpl      $0, %eax
  movl      $0x80000002, %eax
  jz        TempRamInitExit

  #
  # Set ECX/EDX to the bootloader temporary memory range
  #
  movl      PcdGet32 (PcdTemporaryRamBase), %ecx
  movl      %ecx, %edx
  addl      PcdGet32 (PcdTemporaryRamSize), %edx
  subl      PcdGet32 (PcdFspTemporaryRamSize), %edx

  # EAX - error flag
  xorl      %eax, %eax

TempRamInitExit:
  ret
################ Quark SoC - End ###################

#----------------------------------------------------------------------------
# FspInit API
#
# This FSP API will perform the processor and chipset initialization.
# This API will not return.  Instead, it transfers the control to the
# ContinuationFunc provided in the parameter.
#
#----------------------------------------------------------------------------
ASM_GLOBAL ASM_PFX(FspInitApi)
ASM_PFX(FspInitApi):
  movl   $0x01, %eax
  jmp    FspApiCommon

#----------------------------------------------------------------------------
# NotifyPhase API
#
# This FSP API will notify the FSP about the different phases in the boot
# process
#
#----------------------------------------------------------------------------
ASM_GLOBAL ASM_PFX(NotifyPhaseApi)
ASM_PFX(NotifyPhaseApi):
  movl   $0x02, %eax
  jmp    FspApiCommon

#----------------------------------------------------------------------------
# FspMemoryInit API
#
# This FSP API is called after TempRamInit and initializes the memory.
#
#----------------------------------------------------------------------------
ASM_GLOBAL ASM_PFX(FspMemoryInitApi)
ASM_PFX(FspMemoryInitApi):
  #
  # Save stack address in ecx
  #
  pushal
  movl      %esp, %ecx

  #
  # Enable FSP STACK
  #
  movl      PcdGet32 (PcdTemporaryRamBase), %esp
  addl      PcdGet32 (PcdTemporaryRamSize), %esp

  pushl     $DATA_LEN_OF_MCUD     # Size of the data region
  pushl     $0x4455434D           # Signature of the  data region 'MCUD'
  pushl     $0x00800000           # Code size
  pushl     $0xff800000           # Code base
  pushl     $0                    # Microcode size, 0, no ucode for Quark
  pushl     $0                    # Microcode base, 0, no ucode for Quark

  #
  # Save API entry/exit timestamp into stack
  #
  pushl     $DATA_LEN_OF_PER0    # Size of the data region
  pushl     $0x30524550          # Signature of the  data region 'PER0'
  xorl      %edx, %edx
  pushl     %edx
  xorl      %eax, %eax
  pushl     %eax
  rdtsc
  pushl     %edx
  pushl     %eax

  #
  # Terminator for the data on stack
  #
  pushl     $0

  #
  # Restore stack address
  #
  movl      %ecx, %esp
  popal

  #
  # Call MemoryInit
  #
  movl   $0x03, %eax
  jmp    FspApiCommon

#----------------------------------------------------------------------------
# TempRamExitApi API
#
# This API tears down temporary RAM
#
#----------------------------------------------------------------------------
ASM_GLOBAL ASM_PFX(TempRamExitApi)
ASM_PFX(TempRamExitApi):
  movl   $0x04, %eax
  jmp    FspApiCommon

#----------------------------------------------------------------------------
# FspSiliconInit API
#
# This FSP API initializes the CPU and the chipset including the IO
# controllers in the chipset to enable normal operation of these devices.
#
#----------------------------------------------------------------------------
ASM_GLOBAL ASM_PFX(FspSiliconInitApi)
ASM_PFX(FspSiliconInitApi):
  movl   $0x05, %eax
  jmp    FspApiCommon

#----------------------------------------------------------------------------
# FspApiCommon API
#
# This is the FSP API common entry point to resume the FSP execution
#
#----------------------------------------------------------------------------
ASM_GLOBAL ASM_PFX(FspApiCommon)
ASM_PFX(FspApiCommon):
  #
  # EAX holds the API index
  #

  #
  # Stack must be ready
  #
  pushl   %eax
  addl    $0x04, %esp
  cmpl    -4(%esp), %eax
  jz      FspApiCommonL0
  movl    $0x080000003, %eax
  jmp     FspApiCommonExit

FspApiCommonL0:
  #
  # Verify the calling condition
  #
  pushal
  pushl   36(%esp)  #push ApiParam  [esp + 4 * 8 + 4]
  pushl   %eax      #push ApiIdx
  call    ASM_PFX(FspApiCallingCheck)
  addl    $0x08, %esp
  cmpl    $0x00, %eax
  jz      FspApiCommonL1
  movl    %eax, 0x1C(%esp)                   # mov    dword ptr [esp + 4 * 7], eax
  popal
  ret

FspApiCommonL1:
  popal
  cmpl    $0x01, %eax                        # FspInit API
  jz      FspApiCommonL2
  cmpl    $0x03, %eax                        # FspMemoryInit API
  jz      FspApiCommonL2
  call    ASM_PFX(AsmGetFspInfoHeader)
  jmp     Loader2PeiSwitchStack

FspApiCommonL2:
  #
  # FspInit and FspMemoryInit APIs, setup the initial stack frame
  #

  #
  # Place holder to store the FspInfoHeader pointer
  #
  pushl  %eax

  #
  # Update the FspInfoHeader pointer
  #
  pushl  %eax
  call   ASM_PFX(AsmGetFspInfoHeader)
  movl   %eax, 4(%esp)
  popl   %eax

  #
  # Create a Task Frame in the stack for the Boot Loader
  #
  pushfl                                     # 2 pushf for 4 byte alignment
  cli
  pushal

  #
  # Reserve 8 bytes for IDT save/restore
  #
  subl    $0x08, %esp
  sidt    (%esp)

  #
  # Setup new FSP stack
  #
  movl    %esp, %edi
  movl    PcdGet32(PcdTemporaryRamBase), %esp
  addl    PcdGet32(PcdTemporaryRamSize), %esp
  subl    $(DATA_LEN_AT_STACK_TOP + 0x40), %esp

  #
  # Pass the API Idx to SecStartup
  #
  pushl   %eax

  #
  # Pass the BootLoader stack to SecStartup
  #
  pushl   %edi

  #
  # Pass entry point of the PEI core
  #
  call    ASM_PFX(AsmGetFspBaseAddress)
  movl    %eax, %edi
  addl    PcdGet32(PcdFspAreaSize), %edi
  subl    $0x20, %edi
  addl    %ds:(%edi), %eax
  pushl   %eax

  #
  # Pass BFV into the PEI Core
  # It uses relative address to calucate the actual boot FV base
  # For FSP implementation with single FV, PcdFspBootFirmwareVolumeBase and
  # PcdFspAreaBaseAddress are the same. For FSP with mulitple FVs,
  # they are different. The code below can handle both cases.
  #
  call    ASM_PFX(AsmGetFspBaseAddress)
  movl    %eax, %edi
  call    ASM_PFX(GetBootFirmwareVolumeOffset)
  addl    %edi, %eax
  pushl   %eax

  #
  # Pass stack base and size into the PEI Core
  #
  movl    PcdGet32(PcdTemporaryRamBase), %eax
  addl    PcdGet32(PcdTemporaryRamSize), %eax
  subl    PcdGet32(PcdFspTemporaryRamSize), %eax
  pushl   %eax
  pushl   PcdGet32(PcdFspTemporaryRamSize)

  #
  # Pass Control into the PEI Core
  #
  call    ASM_PFX(SecStartup)
  addl    $4, %esp
FspApiCommonExit:
  ret

#----------------------------------------------------------------------------
#
# Procedure:    _ModuleEntryPoint
#
# Input:        None
#
# Output:       None
#
# Destroys:     Assume all registers
#
# Description:
#
#   Transition to non-paged flat-model protected mode from a
#   hard-coded GDT that provides exactly two descriptors.
#   This is a bare bones transition to protected mode only
#   used for a while in PEI and possibly DXE.
#
#   After enabling protected mode, a far jump is executed to
#   transfer to PEI using the newly loaded GDT.
#
# Return:       None
#
#----------------------------------------------------------------------------
ASM_GLOBAL ASM_PFX(_ModuleEntryPoint)
ASM_PFX(_ModuleEntryPoint):

    jmp     .

    #
    # Reference the routines to get the linker to pull them in
    #
    jmp     TempRamInitApi
    jmp     FspInitApi
