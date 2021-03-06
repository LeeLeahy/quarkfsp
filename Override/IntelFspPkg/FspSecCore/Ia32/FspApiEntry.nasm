;------------------------------------------------------------------------------
;
; Copyright (c) 2014 - 2016, Intel Corporation. All rights reserved.<BR>
; This program and the accompanying materials
; are licensed and made available under the terms and conditions of the BSD License
; which accompanies this distribution.  The full text of the license may be found at
; http://opensource.org/licenses/bsd-license.php.
;
; THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
; WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
;
; Abstract:
;
;   Provide FSP API entry points.
;
;------------------------------------------------------------------------------

          section       .text

;
; Following are fixed PCDs
;
extern    ASM_PFX(_gPcd_FixedAtBuild_PcdTemporaryRamBase)
extern    ASM_PFX(_gPcd_FixedAtBuild_PcdTemporaryRamSize)
extern    ASM_PFX(_gPcd_FixedAtBuild_PcdFspTemporaryRamSize)
extern    ASM_PFX(_gPcd_FixedAtBuild_PcdFspAreaSize)

;
; Following functions will be provided in C
;
extern    ASM_PFX(SecStartup)
extern    ASM_PFX(FspApiCallingCheck)
extern    ASM_PFX(TempRamExitApi)
extern    ASM_PFX(FspSiliconInitApi)
extern    ASM_PFX(NotifyPhaseApi)

;
; Following functions will be provided in PlatformSecLib
;
extern    ASM_PFX(AsmGetFspBaseAddress)
extern    ASM_PFX(AsmGetFspInfoHeader)
extern    ASM_PFX(GetBootFirmwareVolumeOffset)
extern    ASM_PFX(Loader2PeiSwitchStack)

;
; Define the data length that we saved on the stack top
;
DATA_LEN_OF_PER0        equ     0x018
DATA_LEN_OF_MCUD        equ     0x018
DATA_LEN_AT_STACK_TOP   equ     (DATA_LEN_OF_PER0 + DATA_LEN_OF_MCUD + 4)

;----------------------------------------------------------------------------
; TempRamInit API
;
; TempRamInit API is an empty API since Quark SoC does not support CAR.
;
;----------------------------------------------------------------------------
          global        ASM_PFX(TempRamInitApi)
ASM_PFX(TempRamInitApi):
  ;
  ; Check Parameter
  ;
  mov     eax, [esp+4]
  cmp     eax, 0
  mov     eax, 0x80000002
  jz      TempRamInitExit

  ;
  ; Set ECX/EDX to the bootloader temporary memory range
  ;
  mov     ecx, [ASM_PFX(PcdGet32 (PcdTemporaryRamBase))]
  mov     edx, ecx
  add     edx, [ASM_PFX(PcdGet32 (PcdTemporaryRamSize))]
  sub     edx, [ASM_PFX(PcdGet32 (PcdFspTemporaryRamSize))]

  ; EAX - error flag
  xor     eax, eax

TempRamInitExit:
  ret

;----------------------------------------------------------------------------
; FspInit API
;
; This FSP API will perform the processor and chipset initialization.
; This API will not return.  Instead, it transfers the control to the
; ContinuationFunc provided in the parameter.
;
;----------------------------------------------------------------------------
          global        ASM_PFX(FspInitApi)
ASM_PFX(FspInitApi):
  mov     eax, 1
  jmp     FspApiCommon

;----------------------------------------------------------------------------
; FspMemoryInit API
;
; This FSP API is called after TempRamInit and initializes the memory.
;
;----------------------------------------------------------------------------
          global        ASM_PFX(FspMemoryInitApi)
ASM_PFX(FspMemoryInitApi):
  ;
  ; Save stack address in ecx
  ;
  pushad
  mov     ecx, esp

  ;
  ; Enable FSP STACK
  ;
  mov     esp, [ASM_PFX(PcdGet32 (PcdTemporaryRamBase))]
  add     esp, [ASM_PFX(PcdGet32 (PcdTemporaryRamSize))]

  push    DATA_LEN_OF_MCUD     ; Size of the data region
  push    0x4455434D           ; Signature of the  data region 'MCUD'
  push    0x00800000           ; Code size
  push    0xff800000           ; Code base
  push    0                    ; Microcode size, 0, no ucode for Quark
  push    0                    ; Microcode base, 0, no ucode for Quark

  ;
  ; Save API entry/exit timestamp into stack
  ;
  push    DATA_LEN_OF_PER0    ; Size of the data region
  push    0x30524550          ; Signature of the  data region 'PER0'
  xor     edx, edx
  push    edx
  xor     eax, eax
  push    eax
  rdtsc
  push    edx
  push    eax

  ;
  ; Terminator for the data on stack
  ;
  push    0

  ;
  ; Restore stack address
  ;
  mov     esp, ecx
  popad

  ;
  ; Call MemoryInit
  ;
  mov     eax, 3
  jmp     FspApiCommon

;----------------------------------------------------------------------------
; FspApiCommon API
;
; This is the FSP API common entry point to resume the FSP execution
;
;----------------------------------------------------------------------------
FspApiCommon:
  ;
  ; EAX holds the API index
  ;

  ;
  ; Stack must be ready
  ;
  push    eax
  add     esp, 4
  cmp     eax, [esp-4]
  jz      FspApiCommonL0
  mov     eax, 0x80000003
  jmp     FspApiCommonExit

FspApiCommonL0:
  ;
  ; Verify the calling condition
  ;
  pushad
  push    dword [esp+(4*8)+4]                ; push ApiParam
  push    eax                                ; push ApiIdx
  call    ASM_PFX(FspApiCallingCheck)
  add     esp, 8
  cmp     eax, 0
  jz      FspApiCommonL1
  mov     [esp+(4*7)], eax
  popad
  ret

FspApiCommonL1:
  popad
  cmp     eax, 1                             ; FspInit API
  jz      FspApiCommonL2
  cmp     eax, 3                             ; FspMemoryInit API
  jz      FspApiCommonL2
  call    ASM_PFX(AsmGetFspInfoHeader)
  jmp     ASM_PFX(Loader2PeiSwitchStack)

FspApiCommonL2:
  ;
  ; FspInit and FspMemoryInit APIs, setup the initial stack frame
  ;

  ;
  ; Place holder to store the FspInfoHeader pointer
  ;
  push    eax

  ;
  ; Update the FspInfoHeader pointer
  ;
  push    eax
  call    ASM_PFX(AsmGetFspInfoHeader)
  mov     [esp+4], eax
  pop     eax

  ;
  ; Create a Task Frame in the stack for the Boot Loader
  ;
  pushfd                                     ; 2 pushf for 4 byte alignment
  cli
  pushad

  ;
  ; Reserve 8 bytes for IDT save/restore
  ;
  sub     esp, 8
  sidt    [esp]

  ;
  ; Setup new FSP stack
  ;
  mov     edi, esp
  mov     esp, [ASM_PFX(PcdGet32(PcdTemporaryRamBase))]
  add     esp, [ASM_PFX(PcdGet32(PcdTemporaryRamSize))]
  sub     esp, (DATA_LEN_AT_STACK_TOP + 0x40)

  ;
  ; Pass the API Idx to SecStartup
  ;
  push    eax

  ;
  ; Pass the BootLoader stack to SecStartup
  ;
  push    edi

  ;
  ; Pass entry point of the PEI core
  ;
  call    ASM_PFX(AsmGetFspBaseAddress)
  mov     edi, eax
  add     edi, [ASM_PFX(PcdGet32(PcdFspAreaSize))]
  sub     edi, 0x20
  add     eax, [ds:edi]
  push    eax

  ;
  ; Pass BFV into the PEI Core
  ; It uses relative address to calucate the actual boot FV base
  ; For FSP implementation with single FV, PcdFspBootFirmwareVolumeBase and
  ; PcdFspAreaBaseAddress are the same. For FSP with mulitple FVs,
  ; they are different. The code below can handle both cases.
  ;
  call    ASM_PFX(AsmGetFspBaseAddress)
  mov     edi, eax
  call    ASM_PFX(GetBootFirmwareVolumeOffset)
  add     eax, edi
  push    eax

  ;
  ; Pass stack base and size into the PEI Core
  ;
  mov     eax, [ASM_PFX(PcdGet32(PcdTemporaryRamBase))]
  add     eax, [ASM_PFX(PcdGet32(PcdTemporaryRamSize))]
  sub     eax, [ASM_PFX(PcdGet32(PcdFspTemporaryRamSize))]
  push    eax
  push    dword [ASM_PFX(PcdGet32(PcdFspTemporaryRamSize))]

  ;
  ; Pass Control into the PEI Core
  ;
  call    ASM_PFX(SecStartup)
  add     esp, 4
FspApiCommonExit:
  ret

;----------------------------------------------------------------------------
;
; Procedure:    _ModuleEntryPoint
;
; Input:        None
;
; Output:       None
;
; Destroys:     Assume all registers
;
; Description:
;
;   Transition to non-paged flat-model protected mode from a
;   hard-coded GDT that provides exactly two descriptors.
;   This is a bare bones transition to protected mode only
;   used for a while in PEI and possibly DXE.
;
;   After enabling protected mode, a far jump is executed to
;   transfer to PEI using the newly loaded GDT.
;
; Return:       None
;
;----------------------------------------------------------------------------
          global        ASM_PFX(_ModuleEntryPoint)
ASM_PFX(_ModuleEntryPoint):

  jmp     $

  ;
  ; Reference the routines to get the linker to pull them in
  ;
  jmp     ASM_PFX(TempRamInitApi)
  jmp     ASM_PFX(FspInitApi)
  jmp     ASM_PFX(TempRamExitApi)
  jmp     ASM_PFX(FspSiliconInitApi)
  jmp     ASM_PFX(NotifyPhaseApi)
