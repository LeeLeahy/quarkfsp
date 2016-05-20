;; @file
;  Provide FSP API entry points.
;
; Copyright (c) 2016, Intel Corporation. All rights reserved.<BR>
; This program and the accompanying materials
; are licensed and made available under the terms and conditions of the BSD License
; which accompanies this distribution.  The full text of the license may be found at
; http://opensource.org/licenses/bsd-license.php.
;
; THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
; WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
;;

    SECTION .text

;
; Following are fixed PCDs
;
extern   ASM_PFX(PcdGet32 (PcdTemporaryRamBase))
extern   ASM_PFX(PcdGet32 (PcdTemporaryRamSize))
extern   ASM_PFX(PcdGet32 (PcdFspTemporaryRamSize))
extern   ASM_PFX(PcdGet32 (PcdFspReservedBufferSize))

;
; Define the data length that we saved on the stack top
;
DATA_LEN_OF_PER0         EQU   18h
DATA_LEN_OF_MCUD         EQU   18h
DATA_LEN_AT_STACK_TOP    EQU   (DATA_LEN_OF_PER0 + DATA_LEN_OF_MCUD + 4)

global ASM_PFX(FspInfoHeaderRelativeOff)
ASM_PFX(FspInfoHeaderRelativeOff):
   ;
   ; This value will be pached by the build script
   ;
   DD    0x12345678

global ASM_PFX(AsmGetFspBaseAddress)
ASM_PFX(AsmGetFspBaseAddress):
   mov   eax, ASM_PFX(AsmGetFspInfoHeader)
   sub   eax, dword [ASM_PFX(FspInfoHeaderRelativeOff)]
   add   eax, 0x1C
   mov   eax, dword [eax]
   ret

global ASM_PFX(AsmGetFspInfoHeader)
ASM_PFX(AsmGetFspInfoHeader):
   mov   eax, ASM_PFX(AsmGetFspInfoHeader)
   sub   eax, dword [ASM_PFX(FspInfoHeaderRelativeOff)]
   ret

;
; @todo: These structures are moved from MicrocodeLoadNasm.inc to avoid
;        build error. This needs to be fixed later on.
;
struc MicrocodeHdr
    .MicrocodeHdrVersion:      resd    1
    .MicrocodeHdrRevision:     resd    1
    .MicrocodeHdrDate:         resd    1
    .MicrocodeHdrProcessor:    resd    1
    .MicrocodeHdrChecksum:     resd    1
    .MicrocodeHdrLoader:       resd    1
    .MicrocodeHdrFlags:        resd    1
    .MicrocodeHdrDataSize:     resd    1
    .MicrocodeHdrTotalSize:    resd    1
    .MicrocodeHdrRsvd:         resd    3
    .size:
endstruc

struc ExtSigHdr
    .ExtSigHdrCount:          resd    1
    .ExtSigHdrChecksum:       resd    1
    .ExtSigHdrRsvd:           resd    3
    .size:
endstruc

struc ExtSig
    .ExtSigProcessor:         resd    1
    .ExtSigFlags:             resd    1
    .ExtSigChecksum:          resd    1
    .size:
endstruc

struc LoadMicrocodeParams
    ; FSP_UPD_HEADER {
    .FspUpdHeader:            resd    8
    ; }
    ; FSPT_CORE_UPD {
    .MicrocodeCodeAddr:       resd    1
    .MicrocodeCodeSize:       resd    1
    .CodeRegionBase:          resd    1
    .CodeRegionSize:          resd    1
    ; }
    .size:
endstruc


;----------------------------------------------------------------------------
; TempRamInit API
;
; This FSP API will load the microcode update, enable code caching for the
; region specified by the boot loader and also setup a temporary stack to be
; used till main memory is initialized.
;
;----------------------------------------------------------------------------
global ASM_PFX(TempRamInitApi)
ASM_PFX(TempRamInitApi):

  ;
  ; TempRamInit API is an empty API since Quark SoC does
  ; not support CAR.
  ;
  ; Check Parameter
  ;
  mov       eax, [esp + 4]
  cmp       eax, 0
  mov       eax, 80000002h
  jz        TempRamInitExit

  ;
  ; Set ECX/EDX to the bootloader temporary memory range
  ;
  mov       ecx, [ASM_PFX(PcdGet32 (PcdTemporaryRamBase))]
  mov       edx, ecx
  add       edx, [ASM_PFX(PcdGet32 (PcdTemporaryRamSize))]
  sub       edx, [ASM_PFX(PcdGet32 (PcdFspTemporaryRamSize))]

  ; EAX - error flag
  xor       eax, eax

TempRamInitExit:
  ret

;----------------------------------------------------------------------------
; Module Entrypoint API
;----------------------------------------------------------------------------
global ASM_PFX(_ModuleEntryPoint)
ASM_PFX(_ModuleEntryPoint):
  jmp $
