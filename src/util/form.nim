# + /data/files/dev/nim/lib/googleTranslate/src/util/form.nim
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
## **Created at:** 02/01/2021 23:35:02 Monday
##
## **Modified at:** 02/02/2021 Tuesday 12:43:27 AM
##
## ----
##
## Transform JSON into a form encoded values
## ----

import json, uri
import strutils

func getStrFromJsVal(val: JsonNode): string =
  result = val.getStr
  if result == "" and $val != "\"\"":
    result = $val

proc toForm*(obj: JsonNode): string =
  var
    values = newSeq[string]()
  for key, val in obj.pairs:
    var
      value = getStrFromJsVal val

    try:
      let json = parseJson value
      for item in json.items:
        values.add(encodeUrl(key) & "=" & encodeUrl getStrFromJsVal item)
    except: discard

    values.add(encodeUrl(key) & "=" & encodeUrl(value))

  return values.join "&"

when isMainModule:
  echo toForm(%*{
    "test": "rest=&&",
     "dt": ["at", "bd", "ex", "ld", "md", "qca", "rw", "rm", "ss", "t"],
    "num": "1"
  })
