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
## **Modified at:** 02/08/2021 Monday 12:18:14 AM
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

{.experimental: "codeReordering".}

import httpclient, json
import strutils, strformat
import uri

import util/gToken

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

  TranslatorCorrection = object
    wrong*: bool
    text*: string

  TranslatorDefinitionExample = tuple
    description, text: string
    synonyms: seq[string]

  TranslatorDefinitions = object
    verb*, noun*, exclamation*, interjection*, adjective: seq[TranslatorDefinitionExample]
    abbreviation*: seq[string]

  TranslatorMainTranslation = object
    main: string
    alternatives: seq[string]

  TranslatorTranslation = object
    refer*, text*: string
    frequency*: int

  TranslatorTranslationAdjective = object
    text*: string
    frequency*: int

  TranslatorTranslations = object
    verb*, noun*: seq[TranslatorTranslation]
    adjective*: seq[TranslatorTranslationAdjective]

  TranslatorResult* = object
    translation*: TranslatorMainTranslation
    translations*: TranslatorTranslations
    original*: string
    pronunciation*: string
    correction*: TranslatorCorrection
    definition*: TranslatorDefinitions
    examples*: seq[string]

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

  let
    arr = parseBodyToArr(body)

  var json: JsonNode
  try:
    json = parseJson arr[0]
    json = parseJson json{0}{2}.getStr
  except:
    echo "Cannot parse json"
    return

  result.original = text
  if not json{1, 0, 0}{5, 0, 0}.isNil:
    let
      mainTranslation = json{1, 0, 0}{5, 0}

    result.translation.main = mainTranslation{0}.getStr
    for possibility in mainTranslation{1}:
      result.translation.alternatives.add possibility.getStr

  result.pronunciation = json{0, 0}.getStr

  if json{0, 1, 0}.isNil:
    result.correction.wrong = false
  else:
    result.correction.wrong = true
    result.correction.text = json{0, 1, 0, 0, 1}.
      getStr.
      replacef(re"<b><i>(.*)</i></b>", "[$1]")

  let
    values = json{3}
    definitions = values{1, 0}
    translations = values{5, 0}
    examples = values{2, 0}

  #? get definitions
  if not definitions.isNil:
    for definition in definitions:
      let
        name = definition[0].getStr
        defs = definition[1]
      for def in defs:
        if name == "abbreviation":
          result.definition.abbreviation.add def[0].getStr
        else:
          var
            example = (
              description: def[0].getStr,
              text: def[1].getStr,
              synonyms: newSeq[string]()
            )
          if not def{3}.isNil:
            for synonym in def{3}:
              example.synonyms.add synonym.getStr
          case name:
          of "verb": result.definition.verb.add example
          of "noun": result.definition.noun.add example
          of "exclamation": result.definition.exclamation.add example
          of "interjection": result.definition.interjection.add example
          of "adjective": result.definition.adjective.add example

  if not examples.isNil:
    for example in examples:
      result.examples.add example[1].getStr.replacef(re"<b>(.*)</b>", "[$1]")

  #? get the translations
  if not translations.isNil:
    for translation in translations:
      let
        name = translation[0].getStr
        defs = translation[1]
      for def in defs:
        if name == "adjective":
          result.translations.adjective.add TranslatorTranslationAdjective(
            text: def[0].getStr,
            frequency: def[3].getInt
          )
        let
          translationPossibility = TranslatorTranslation(
            text: def[0].getStr,
            refer: def[1].getStr,
            frequency: def[3].getInt
          )
        case name:
        of "noun": result.translations.noun.add translationPossibility
        of "verb": result.translations.verb.add translationPossibility


proc parseBodyToArr(body: string): seq[string] =
  ## Parse the result into a array of results
  var tmp = ""
  for row in body.split "\n":
    try:
      #? check if the row is a number
      discard row.parseInt()
      if tmp != "":
        result.add tmp
        tmp = ""
    except:
      #? if not
      tmp &= row
  if tmp != "":
    result.add tmp


when isMainModule:
  var translator = newTranslator()

  # echo translator.single("oi carlos")
  # echo translator.single("hi", to = LangPortuguese)
  # echo translator.single("lunch", to = LangPortuguese)
  # echo translator.single("tchau")
  # echo translator.single("be", to = LangPortuguese)
  echo translator.single("kind", to = LangPortuguese).translation
  # echo translator.single("bye", to = LangPortuguese)
  # echo translator.single("oi")
