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
## **Modified at:** 02/08/2021 01:17:09 PM Monday
##
## ----
##
## Test for the Google translate module
## ----

import googleTranslate
import unittest

var
  translator = newTranslator()

suite "Translate":

  test "Translator returns a TranslatorResult instance":
    check translator.single("Hi", to = LangPortuguese) of TranslatorResult

  test "'Hi' to portuguese equals 'Oi'":
    check translator.single("Hi", to = LangPortuguese).translation.main == "Oi"

  test "Error, from en to en":
    check translator.single("hello carls", to = LangEnglish).success == false

  test "Auto correction of 'hello carls' to 'Hello Carlos'":
    echo translator.single("hello carls", to = LangPortuguese)
