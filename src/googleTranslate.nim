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
## **Modified at:** 02/11/2021 09:36:37 PM Thursday
##
## ----
##
## Main Google Translate implementation module
## ----
##
## NOTE: GT is Google Translate
##
## **TODO**
##  | ☐ [1:1] Cache for all translations @started(!time) @done(!time)
##  | ✔ [0:2] Cache the token @done(02/08/2021 12:04:37)
##  | ☐ [0:3] Refactor to suport bulk translatons using same base @started(!time) @done(!time)

{.experimental: "codeReordering".}

import httpclientJs, json
import strutils, strformat
import uri
import re

import googleTranslate/gToken

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
  Translator* = ref object
    url: Uri
    token: Tokens

  TranslatorCorrection = object
    wrong*: bool
    text*: string

  TranslatorDefinition = tuple
    description, text: string
    synonyms: seq[string]

  TranslatorDefinitions = object
    adverb*, preposition*, adjective*, noun*, verb*, prefix*, sufix*, pronoun*,
      exclamation*, interjection*, abbreviation*: seq[TranslatorDefinition]

  TranslatorMainTranslationLanguage = object
    `from`*, to*, detected*: Languages

  TranslatorMainTranslation = object
    main*: string
    language*: TranslatorMainTranslationLanguage
    alternatives*: seq[string]

  TranslatorTranslation = object
    refer*, text*: string
    frequency*: int
    equivalents*: seq[string]

  TranslatorTranslations = object
    adverb*, preposition*, adjective*, noun*, verb*, prefix*, sufix*, pronoun*,
      exclamation*, interjection*, abbreviation*: seq[TranslatorTranslation]

  TranslatorSynonyms = object
    adverb*, preposition*, adjective*, noun*, verb*, prefix*, sufix*, pronoun*,
      exclamation*, interjection*, abbreviation*: seq[seq[string]]

  TranslatorResult* = object
    success*: bool
    translation*: TranslatorMainTranslation
    translations*: TranslatorTranslations
    synonyms*: TranslatorSynonyms
    original*: string
    pronunciation*: string
    correction*: TranslatorCorrection
    definitions*: TranslatorDefinitions
    examples*: seq[string]

proc newTranslator*(cors = "", tld = "com"): Translator =
  ## Creates new Translator object that holds the tld of the GT
  ## and a cors proxy
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
    url: url,
    token: getGTokens($gTUrl, tld)
  )


proc single*(self: var Translator, text: string, `from` = LangAutomatic,
             to = LangEnglish): TranslatorResult =
  ## Translate the text and gets all data of GT api
  ##
  ## See: `TranslatorResult<#TranslatorResult>`_

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
    url = self.url ? urlParams

    reqBody = encodeUrl( $ %*[[[
      # "jQ1olc", # unknown type; maybe autocomplete
      "MkEWBc",
      $(%*[
        [
          text,
          `from`,
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

  result.translation.language.`from` = `from`
  result.translation.language.to = to

  if json{0}.len < 4:
    return

  result.success = true

  if not json{0, 2}.isNil:
    result.translation.language.detected = parseEnum[Languages](json{0, 2}.getStr)

  result.original = text
  if not json{1, 0, 0}{5, 0, 0}.isNil:
    let
      mainTranslation = json{1, 0, 0}{5, 0}

    result.translation.main = mainTranslation{0}.getStr
    for possibility in mainTranslation{1}:
      let possibilityStr = possibility.getStr
      if possibilityStr != result.translation.main:
        result.translation.alternatives.add possibilityStr

  result.pronunciation = json{0, 0}.getStr

  if json{0, 1, 0}.isNil:
    result.correction.wrong = false
  else:
    result.correction.wrong = true
    result.correction.text = json{0, 1, 0}{0, 1}.
      getStr.
      replacef(re"<b><i>(.*)</i></b>", "[$1]")

  let
    values = json{3}
    definitions = values{1, 0}
    translations = values{5, 0}
    examples = values{2, 0}
    synonyms = values{4, 0}


  # get definitions
  if not definitions.isNil:
    for definition in definitions:
      let
        name = definition[0].getStr
        defs = definition[1]
      for def in defs:
        var
          defin = (
            description: "",
            text: "",
            synonyms: newSeq[string]()
          )

        if def.len > 1:
          defin.description = def[0].getStr
          defin.text = def[1].getStr
        else:
          defin.text = def[0].getStr

        if not def{3}.isNil:
          for synonym in def{3}:
            defin.synonyms.add synonym.getStr
        case name:
        of "adverb": result.definitions.adverb.add defin
        of "preposition": result.definitions.preposition.add defin
        of "adjective": result.definitions.adjective.add defin
        of "noun": result.definitions.noun.add defin
        of "verb": result.definitions.verb.add defin
        of "prefix": result.definitions.prefix.add defin
        of "sufix": result.definitions.sufix.add defin
        of "pronoun": result.definitions.pronoun.add defin
        of "exclamation": result.definitions.exclamation.add defin
        of "interjection": result.definitions.interjection.add defin
        of "abbreviation": result.definitions.abbreviation.add defin

  if not examples.isNil:
    for example in examples:
      result.examples.add example[1].getStr.replacef(re"<b>(.*)</b>", "[$1]")

  # get the translations
  if not translations.isNil:
    for translation in translations:
      let
        name = translation[0].getStr
        defs = translation[1]
      for def in defs:
        var
          translationPossibility = TranslatorTranslation(
            text: def[0].getStr,
            refer: def[1].getStr,
            equivalents: @[],
            frequency: def[3].getInt
          )

        for equivalent in def[2]:
          translationPossibility.equivalents.add equivalent.getStr

        case name:
        of "adverb": result.translations.adverb.add translationPossibility
        of "preposition": result.translations.preposition.add translationPossibility
        of "adjective": result.translations.adjective.add translationPossibility
        of "noun": result.translations.noun.add translationPossibility
        of "verb": result.translations.verb.add translationPossibility
        of "prefix": result.translations.prefix.add translationPossibility
        of "sufix": result.translations.sufix.add translationPossibility
        of "pronoun": result.translations.pronoun.add translationPossibility
        of "exclamation": result.translations.exclamation.add translationPossibility
        of "interjection": result.translations.interjection.add translationPossibility
        of "abbreviation": result.translations.abbreviation.add translationPossibility

  # get the synonyms
  if not synonyms.isNil:
    for synonym in synonyms:
      let
        name = synonym[0].getStr
        syns = synonym[1]
      for syn in syns:
        var synon = newSeq[seq[string]]()

        for val in syn:
          var synons = newSeq[string]()
          for v in val: synons.add v.getStr
          synon.add synons

        case name:
        of "adverb": result.synonyms.adverb.add synon
        of "preposition": result.synonyms.preposition.add synon
        of "adjective": result.synonyms.adjective.add synon
        of "noun": result.synonyms.noun.add synon
        of "verb": result.synonyms.verb.add synon
        of "prefix": result.synonyms.prefix.add synon
        of "sufix": result.synonyms.sufix.add synon
        of "pronoun": result.synonyms.pronoun.add synon
        of "exclamation": result.synonyms.exclamation.add synon
        of "interjection": result.synonyms.interjection.add synon
        of "abbreviation": result.synonyms.abbreviation.add synon


proc parseBodyToArr(body: string): seq[string] =
  ## Parse the result into a array of results
  var tmp = ""
  for row in body.split "\n":
    try:
      # check if the row is a number
      discard row.parseInt()
      if tmp != "":
        result.add tmp
        tmp = ""
    except:
      # if not
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
  # echo translator.single("ser")
  echo translator.single("fora")
  # echo translator.single("out", to = LangArabic)
  # echo translator.single("kind", to = LangPortuguese)
  # echo translator.single("bye", to = LangPortuguese)
  # echo translator.single("oi")
