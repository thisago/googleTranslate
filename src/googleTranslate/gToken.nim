#[
  Created at: 02/03/2021 10:45:41 Wednesday
  Modified at: 09/17/2021 01:27:58 AM Friday

        Copyright (C) 2021 Thiago Navarro
  See file "license" for details about copyright
]#

##[
  This module get all used tokens in translation api (batchexecute)
]##

# {.experimental: "codeReordering".}

# from std/strutils import `

import std/[
  re,
  strformat,
  httpclient
]

type
  Tokens* = object
    ## Tokens type stores the useful tokens found in Google
    ## Translate website
    bl*, fSid*: string

proc extract(key, body: string): string =
  ## This function extracts the wanted value on the body
  var matches: array[1, string]
  if not body.match(re &".*\"{key}\":\"(.*?)\".*", matches): return
  return matches[0]

proc getGTokens*(url: string, tld = "com"): Tokens =
  ## This function access the Google translate page and gets some values
  ##
  ## It's possible to choose a different tld for the Google translate page
  let
    client = newHttpClient()
    response = client.request url

  return Tokens(
    bl: extract("FdrFJe", response.body),
    fSid: extract("cfb2h", response.body)
  )
