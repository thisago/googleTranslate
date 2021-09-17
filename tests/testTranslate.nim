#[
  Created at: 01/30/2021 13:14:45 Saturday
  Modified at: 09/17/2021 02:00:13 AM Friday

        Copyright (C) 2021 Thiago Navarro
  See file "license" for details about copyright
]#

import std/unittest

import googleTranslate

var
  translator = newTranslator()

suite "Translate":
  test "Translator returns a TranslatorResult instance":
    check translator.single("Hi", to = LangPortuguese) of TranslatorResult

  test "'Hi' to portuguese equals 'Oi'":
    check translator.single("Hi", to = LangPortuguese).translation.values[0].value == "Oi"

  test "Error, from en to en":
    check translator.single("hello carls", to = LangEnglish).success == false

  test "Auto correction of 'hello carls' to 'Hello Carlos'":
    echo translator.single("hello carls", to = LangPortuguese)
