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
## **Modified at:** 01/31/2021 Sunday 11:31:58 AM
##
## ----
##
## Main for the Google Translate implementation module
## ----

import strutils
import strformat
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

# echo fmt"{$ch}:{$chCode} {$result}.lshr {$chInt} = ", result.lshr chInt
## 6:51081164 -1025772754 >>> 51081164 = 798143

# 6:768 49200 >>> 768 = 49200
# 6:801053 51267425 >>> 801053 = 0
# 6:3405018 217921198 >>> 3405018 = 3
# 6:18834810 1205427879 >>> 18834810 = 17

# b:1023747 2096634565 >>> 1023747 = 262079320

proc apiKeyCalculateSecret(key: int, secret: string): int =
  var
    i = 0
  result = key

  for _ in 0..<secret.len - 2:
    echo i

    inc i, 3
    if i >= secret.len:
      break

proc newApiKey*(seed: string): string =
  var
    code = newSeq[int]()
    i = 0

  for _ in seed:
    var chCode = int seed[i]

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

  var key = 0

  echo fmt"{code} == [ 48, 49, 50, 51 ] {code == [ 48, 49, 50, 51 ]}" # [ 48, 49, 50, 51 ]

  for codeDigit in code:
    # echo key #  0 49968 50495100 214876788
    key += codeDigit
    key = apiKeyCalculateSecret(key, "+-a^+6")

  echo fmt"{key} == 1187396573 {key == 1187396573}" # 1187396573

  key = apiKeyCalculateSecret(key, "+-3^+b+-f")
  key = key xor 0

  echo fmt"{key} == 1071285702 {key == 1071285702}" # 1071285702

  if key < 0:
    key = (key and 2147483647) + int 2147483648

  key = key mod int 1e6

  return $key & "." & $key

when isMainModule:
  # let a = newApiKey("0123")
  # echo fmt"""{a} == 285702.285702 {a == "285702.285702"}"""
  # echo a # 285702.285702

  # echo "\n\n\n--------------------------------"

  let b = apiKeyCalculateSecret(-234534544, "+-a^+6")

  echo fmt"""{b} == 121087317 {b == 121087317}"""
  echo b # -1043292958
  # echo newApiKey("0123") == "285702.285702"

  # echo newApiKey("ŋ©“")

  # echo newApiKey("!@&$")
  # echo newApiKey("!@&$") == "524995.524995"
