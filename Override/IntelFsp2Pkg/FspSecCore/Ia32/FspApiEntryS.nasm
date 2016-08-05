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
; Following functions will be provided in C
;
extern ASM_PFX(FspApiCommon)

;----------------------------------------------------------------------------
; FspApiCommonContinue API
;
; This is the FSP API common entry point to resume the FSP execution
;
;----------------------------------------------------------------------------
global ASM_PFX(FspApiCommonContinue)
ASM_PFX(FspApiCommonContinue):
  jmp    $
  ret

;----------------------------------------------------------------------------
; Module Entrypoint API
;----------------------------------------------------------------------------
global ASM_PFX(_ModuleEntryPoint)
ASM_PFX(_ModuleEntryPoint):
  jmp $

;----------------------------------------------------------------------------
; Reference the following functions to pull them into the image
;----------------------------------------------------------------------------

extern ASM_PFX(FspSiliconInitApi)
extern ASM_PFX(NotifyPhaseApi)

  jmp    FspApiCommon
  jmp    FspSiliconInitApi
  jmp    NotifyPhaseApi
