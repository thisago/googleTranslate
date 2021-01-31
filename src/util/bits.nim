# + /data/files/dev/nim/lib/googleTranslate/src/util/bits.nim
#[*
 * Copyright (c) 2021 Thiago Navarro. All rights reserved
 * 
 * @workspace googleTranslate
 * 
 * @author Thiago Navarro <thiago@oxyoy.com>
]#

## :Author: Thiago Navarro
## :Email: thiago@oxyoy.com
##
## **Created at:** 01/31/2021 09:05:48 Sunday
##
## **Modified at:** 01/31/2021 Sunday 11:26:27 AM
##
## ----
##
## This file contains utilities to handle bit shifts
## ----

# proc lshr*(x: SomeNumber, y: int): SomeNumber =
#   ## Logical right shift
#   result = x
#   if result < 0:
#     result = (typeof x)(0xffff_ffff + result)
#   result = result shr y

{.compile: "shift.c".}

proc lshr*(x: int; n: int): int {.importc: "logicalRightShift".}

import strformat

when isMainModule:
  echo fmt"""{$lshr(int -25355305, 6)} == 66712687""" # "​​​-25355305 >>> 6​​​" = 66712687
  echo fmt"""{$lshr(int -1727632372, 11)} == 1253581""" # "​​​-1727632372 >>> 11​​​" = 1253581
  echo fmt"""{$lshr(int 25355305, 6)} == 396176""" # "​​​25355305 >>> 6​​​" = 396176
  echo fmt"""{$lshr(int 1727632372, 11)} == 843570""" # "​​​1727632372 >>> 11​​​" = 843570

  echo "\n\n", fmt"""{$(-25355305 shr 6)} == -396177""" # "​​​-25355305 >> 6​​​" = -396177
  echo fmt"""{$((-1727632372) shr 11)} == -843571""" # "​​​-1727632372 >> 11​​​" = -843571
  echo fmt"""{$(25355305 shr 6)} == 396176""" # "​​​25355305 >> 6​​​" = 396176
  echo fmt"""{$(1727632372 shr 11)} == 843570""" # "​​​1727632372 >> 11​​​" = 843570
