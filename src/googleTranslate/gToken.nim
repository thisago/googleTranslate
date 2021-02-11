# + /data/files/dev/nim/lib/googleTranslate/src/util/gToken.nim
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
## **Created at:** 02/03/2021 10:45:41 Wednesday
##
## **Modified at:** 02/08/2021 12:24:16 PM Monday
##
## ----
##
## Google translate tokens getter
## ----

## This module get all used tokens in translation api (batchexecute)

{.experimental: "codeReordering".}

import httpclient
import strformat

import re

type
  Tokens* = object
    ## Tokens type stores the useful tokens found in Google
    ## Translate website
    bl*, fSid*: string

proc getGTokens*(url: string, tld = "com"): Tokens =
  ## This proc access the Google translate page and gets some values
  ##
  ## It's possible to choose a different tld for the Google translate page
  let
    client = newHttpClient()

    response = client.request url

  return Tokens(
    bl: extract("FdrFJe", response.body),
    fSid: extract("cfb2h", response.body)
  )

proc extract(key, body: string): string =
  ## This proc extracts the wanted value on the body
  var
    matches: array[1, string]

  if not body.match(re &".*\"{key}\":\"(.*?)\".*", matches): return

  return matches[0]
