/** @file
The header file of FspInitPreMem PEIM.

Copyright (c) 2015 - 2016 Intel Corporation.

This program and the accompanying materials
are licensed and made available under the terms and conditions of the BSD License
which accompanies this distribution.  The full text of the license may be found at
http://opensource.org/licenses/bsd-license.php

THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.

**/

#ifndef _FSP_INIT_PRE_MEM_H_
#define _FSP_INIT_PRE_MEM_H_

#include <Library/CacheLib.h>
#include <Library/FspPlatformLib.h>
#include <Library/FspSwitchStackLib.h>
#include <Guid/GuidHobFsp.h>
#include <Guid/MemoryConfigData.h>
#include <Guid/FspSiliconFv.h>
#include <Guid/FspSmbios.h>
#include <FspApi.h>
#include <Include/IndustryStandard/SmBios.h>
#include <mrc.h>

#define PEI_STALL_RESOLUTION            1

#define DDRFREQ_UNKNOWN                 0
#define DDRFREQ_800MHZ                  800
#define DDRFREQ_1066MHZ                 1066

#endif /* _FSP_INIT_PRE_MEM_H_ */
