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
## **Modified at:** 01/31/2021 Sunday 06:19:37 PM
##
## ----
##
## This file contains utilities to handle bit shifts
## ----

proc lshr*(x: int; n: int): int =
  return cast[int](cast[cuint](x) shr n)

proc lshl*(x: int; n: int): int =
  return cast[int](cast[cuint](x) shl n)

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

  echo fmt"""{$lshr(-1543503872, 1)} == 1375731712""" # "​​​-25355305 >>> 6​​​" = 66712687
  echo fmt"""{$lshr( 1543503872, 1)} == 771751936""" # "​​​-1727632372 >>> 11​​​" = 1253581
  echo fmt"""{$lshr(-1073741824, 1)} == 1610612736""" # "​​​25355305 >>> 6​​​" = 396176
  echo fmt"""{$lshl(42676448, 10)} == 751009792""" # "​​​25355305 >>> 6​​​" = 396176
