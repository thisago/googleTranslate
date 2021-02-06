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
## **Modified at:** 02/06/2021 Saturday 12:36:54 PM
##
## ----
##
## Main for the Google Translate implementation module
## ----
##
## GT is Google Translate
##
## **TODO**
## - cache
## - token cache



import httpclient, json
import strutils, strformat
import uri

import util/gToken
import util/form

import re

type
  Languages* = enum
    LangAutomatic = "auto", LangAfrikaans = "af", LangAlbanian = "sq",
        LangAmharic = "am", LangArabic = "ar", LangArmenian = "hy",
        LangAzerbaijani = "az", LangBasque = "eu", LangBelarusian = "be",
        LangBengali = "bn", LangBosnian = "bs", LangBulgarian = "bg",
        LangCatalan = "ca", LangCebuano = "ceb", LangChichewa = "ny",
        LangChineseSimplified = "zh-cn", LangChineseTraditional = "zh-tw",
        LangCorsican = "co", LangCroatian = "hr", LangCzech = "cs",
        LangDanish = "da", LangDutch = "nl", LangEnglish = "en",
        LangEsperanto = "eo", LangEstonian = "et", LangFilipino = "tl",
        LangFinnish = "fi", LangFrench = "fr", LangFrisian = "fy",
        LangGalician = "gl", LangGeorgian = "ka", LangGerman = "de",
        LangGreek = "el", LangGujarati = "gu", LangHaitianCreole = "ht",
        LangHausa = "ha", LangHawaiian = "haw", LangHebrew = "iw",
        LangHindi = "hi", LangHmong = "hmn", LangHungarian = "hu",
        LangIcelandic = "is", LangIgbo = "ig", LangIndsinglesian = "id",
        LangIrish = "ga", LangItalian = "it", LangJapanese = "ja",
        LangJavanese = "jw", LangKannada = "kn", LangKazakh = "kk",
        LangKhmer = "km", LangKorean = "ko", LangKurdishKurmanji = "ku",
        LangKyrgyz = "ky", LangLao = "lo", LangLatin = "la", LangLatvian = "lv",
        LangLithuanian = "lt", LangLuxembourgish = "lb", LangMacedonian = "mk",
        LangMalagasy = "mg", LangMalay = "ms", LangMalayalam = "ml",
        LangMaltese = "mt", LangMaori = "mi", LangMarathi = "mr",
        LangMongolian = "mn", LangMyanmarBurmese = "my", LangNepali = "ne",
        LangNorwegian = "no", LangPashto = "ps", LangPersian = "fa",
        LangPolish = "pl", LangPortuguese = "pt", LangPunjabi = "ma",
        LangRomanian = "ro", LangRussian = "ru", LangSamoan = "sm",
        LangScotsGaelic = "gd", LangSerbian = "sr", LangSesotho = "st",
        LangShona = "sn", LangSindhi = "sd", LangSinhala = "si",
        LangSlovak = "sk", LangSlovenian = "sl", LangSomali = "so",
        LangSpanish = "es", LangSundanese = "su", LangSwahili = "sw",
        LangSwedish = "sv", LangTajik = "tg", LangTamil = "ta",
        LangTelugu = "te", LangThai = "th", LangTurkish = "tr",
        LangUkrainian = "uk", LangUrdu = "ur", LangUzbek = "uz",
        LangVietnamese = "vi", LangWelsh = "cy", LangXhosa = "xh",
        LangYiddish = "yi", LangYoruba = "yo", LangZulu = "zu"

const
  # GT_API_URL = "http://127.0.0.1/u2/apache/www/admins/condominos/a.php"
  GT_URL = "https://translate.google.{tld}"
  GT_API_PATH = "/_/TranslateWebserverUi/data/batchexecute"

type
  Urls = object
    single: Uri

  Translator* = ref object
    url: Urls
    token: Tokens

  TranslatorResult* = tuple
    text, original: string
    source: tuple[autoCorrected, didYouMean: bool, value: string]
    pronunciation: string
    language: tuple[didYouMean: bool, iso: Languages]

proc newTranslator*(cors = "", tld = "com"): Translator =
  let
    gTUrl = parseUri(GT_URL.replace("{tld}", tld))
    url = (if cors == "":
      gTUrl
    else:
      parseUri(cors) / $gTUrl
    ) / GT_API_PATH

  if not url.isAbsolute:
    quit "Sorry, the URL is not valid"

  Translator(
    url: Urls(
      single: url
    ),
    token: getGTokens($gTUrl, tld)
  )

proc single*(self: var Translator, text: string, lang = LangAutomatic,
             to = LangEnglish): TranslatorResult =
  ## Translate the text from `lang` to `to` params

  let
    urlParams = {
      "rpcids": "MkEWBc",
      "f.sid": self.token.fSid,
      "bl": self.token.bl,
      "hl": "en-US",
      "soc-app": "1",
      "soc-platform": "1",
      "soc-device": "1",
      "_reqid": "1015",
      "rt": "c"
    }
    url = self.url.single ? urlParams

    reqBody = encodeUrl( $ %*[[[
      "MkEWBc",
      $(%*[
        [
          text,
          lang,
          to,
          true
        ],
        [nil]
      ]),
      nil,
      "generic"
    ]]])

    client = newHttpClient()

  client.headers = newHttpHeaders({
    "content-type": "application/x-www-form-urlencoded;charset=UTF-8"
  })

  let
    response = client.post($url, body = fmt"f.req={reqBody}")
  var
    body = response.body

  if body == "":
    echo "Cannot get the response body"
    return

  body = body.substr(6)

  var length = 0
  block: #? get lenght
    var matches: array[1, string]

    if not body.match(re"^(\d+)", matches):
      echo "Cannot get length of response data"
      return

    try:
      length = matches[0].parseInt
    except:
      echo "Cannot parse matches to number"
      return

  # echo body
  let lengthLen = ($length).len

  echo body
  var json: JsonNode
  try:
    let jsonText = body.substr(
      lengthLen,
      length + lengthLen
    )
    echo jsonText
    json = parseJson(jsonText)

    json = parseJson(json{0, 2}.getStr)
  except:
    echo "Cannot parse json"
    return

  echo json

  # if json{1, 0, 0, 5}.kind == JNull:
  #   result.text = json{1, 0, 0, 0}.getStr
  # else:
  #   for obj in json{1, 0, 0, 5}:
  #     if obj{0}.kind != JNull:
  #       result.text &= obj{0}.getStr


when isMainModule:
  var translator = newTranslator()

  # echo translator.single("oi carlos")
  echo translator.single("oi")

# https://translate.google.com/translate_a/single?rpcids=MkEWBc&f.sid=boq_translate-webserver_20210202.13_p0&bl=-5408574106297180445&hl=en-US&soc-app=1&soc-platform=1&soc-device=1&_reqid=1015&rt=c
# https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=MkEWBc&hl=en-US&soc-app=1&soc-platform=1&soc-device=1&_reqid=839064&rt=c
