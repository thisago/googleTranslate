# + /data/files/dev/nim/lib/googleTranslate/src/googleTranslate.nim
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
## **Created at:** 01/30/2021 13:25:52 Saturday
##
## **Modified at:** 02/01/2021 Monday 01:40:30 PM
##
## ----
##
## Main for the Google Translate implementation module
## ----
##
## **Notes:**
## - unicode generates wrong token

import strutils
import util/bits

type
  Language* = enum
    Automatic = "auto", Afrikaans = "af", Albanian = "sq", Amharic = "am",
        Arabic = "ar", Armenian = "hy", Azerbaijani = "az", Basque = "eu",
        Belarusian = "be", Bengali = "bn", Bosnian = "bs", Bulgarian = "bg",
        Catalan = "ca", Cebuano = "ceb", Chichewa = "ny",
        ChineseSimplified = "zh-cn", ChineseTraditional = "zh-tw",
        Corsican = "co", Croatian = "hr", Czech = "cs", Danish = "da",
        Dutch = "nl", English = "en", Esperanto = "eo", Estonian = "et",
        Filipino = "tl", Finnish = "fi", French = "fr", Frisian = "fy",
        Galician = "gl", Georgian = "ka", German = "de", Greek = "el",
        Gujarati = "gu", HaitianCreole = "ht", Hausa = "ha", Hawaiian = "haw",
        Hebrew = "iw", Hindi = "hi", Hmong = "hmn", Hungarian = "hu",
        Icelandic = "is", Igbo = "ig", Indonesian = "id", Irish = "ga",
        Italian = "it", Japanese = "ja", Javanese = "jw", Kannada = "kn",
        Kazakh = "kk", Khmer = "km", Korean = "ko", KurdishKurmanji = "ku",
        Kyrgyz = "ky", Lao = "lo", Latin = "la", Latvian = "lv",
        Lithuanian = "lt", Luxembourgish = "lb", Macedonian = "mk",
        Malagasy = "mg", Malay = "ms", Malayalam = "ml", Maltese = "mt",
        Maori = "mi", Marathi = "mr", Mongolian = "mn", MyanmarBurmese = "my",
        Nepali = "ne", Norwegian = "no", Pashto = "ps", Persian = "fa",
        Polish = "pl", Portuguese = "pt", Punjabi = "ma", Romanian = "ro",
        Russian = "ru", Samoan = "sm", ScotsGaelic = "gd", Serbian = "sr",
        Sesotho = "st", Shona = "sn", Sindhi = "sd", Sinhala = "si",
        Slovak = "sk", Slovenian = "sl", Somali = "so", Spanish = "es",
        Sundanese = "su", Swahili = "sw", Swedish = "sv", Tajik = "tg",
        Tamil = "ta", Telugu = "te", Thai = "th", Turkish = "tr",
        Ukrainian = "uk", Urdu = "ur", Uzbek = "uz", Vietnamese = "vi",
        Welsh = "cy", Xhosa = "xh", Yiddish = "yi", Yoruba = "yo", Zulu = "zu"

proc tokenApplySecret(key: BiggestInt, secret: string): BiggestInt =
  var
    i = 0
  result = key

  for _ in 0..<secret.len - 2:
    let
      ch = secret[i + 2]
    var
      chInt = (typeof key)ch

    if chInt >= (typeof key)('a'): dec chInt, 87
    else: chInt = ($ch).parseInt

    if secret[i + 1] == '+': chInt = (typeof key)(result.lshr int chInt)
    else: chInt = result.lshl int chInt

    if secret[i] == '+': result = result + chInt
    else: result = result xor chInt

    inc i, 3
    if i >= secret.len:
      break

proc newApiToken*(seed: string): string =
  var
    code = newSeq[int]()
    i = 0
  for _ in seed:
    var
      chCode = int seed[i]
    if chCode < 128:
      code.add chCode
    else:
      if chCode < 2048:
        code.add (chCode shr 6) or 192
      else:
        if 55296 == (chCode and 64512) and
        i + 1 < seed.len and
        56320 == (int(seed[i + 1]) and 64512):
          inc i
          chCode = 65536 + ((chCode and 1023) shl 10) + int(seed[i])
          code.add (chCode shr 18) or 240
          code.add ((chCode shr 12) and 63) or 128
        else:
          code.add (chCode shr 12) or 224;

        code.add ((chCode shr 6) and 63) or 128
    inc i

  var
    key: int64 = 0
  for codeDigit in code:
    key += codeDigit
    key = tokenApplySecret(key, "+-a^+6")

  key = tokenApplySecret(key, "+-3^+b+-f")
  key = cast[int](cast[cint](key) xor 0)

  if key < 0:
    key = (key and 2147483647) + 2147483648
  key = key mod int 1e6

  return $key & "." & $key


when isMainModule:
  echo "0123: ", newApiToken("0123")
  echo "!@&$: ", newApiToken("!@&$")
  echo "test: ", newApiToken("test")
