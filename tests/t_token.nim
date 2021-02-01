# + /data/files/dev/nim/lib/googleTranslate/tests/test1.nim
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
## **Created at:** 01/30/2021 13:14:45 Saturday
##
## **Modified at:** 02/01/2021 Monday 01:49:38 PM
##
## ----
##
## Test for the Google translate module
## ----

when not defined(js) and not defined(nimsuggest):
  {.fatal: "This test need to be used with the JavaScript backend.".}

import strformat

import googleTranslate, token

{.emit: """
const mod = require("./genKey.js");
""".}

proc jsNewApiToken(txt: cstring): cstring {.importc: "mod.newKey".}

const TO_TEST = [
  "0123456",
  "1234567",
  "abcdefg",
  "ABCDEFG",
  "test",
  "Lorem ipsum dolor sit amet consectetur adipisicing elit. Ducimus quidem harum numquam hic suscipit iusto voluptate debitis dolores qui, doloribus dolorum rem eligendi, amet at molestiae totam repellendus animi officia?",
  "ððß”ððð”ß”←¬”↓→←",
  "",
  "stgyhneu"
]

echo "\nTests"

#? "API key compare with JS"
block:
  for str in TO_TEST:
    let
      nim = newApiToken(str)
      js = jsNewApiToken(str)

      color = if nim == js: "\x1b[32m" else: "\x1b[31m"

    echo color, fmt"{nim} == {js} {nim == js}"
