#[
  Created at: 01/30/2021 13:25:52 Saturday
  Modified at: 09/17/2021 09:04:56 PM Friday

        Copyright (C) 2021 Thiago Navarro
  See file "license" for details about copyright
]#

##[
  NOTE: GT is Google Translate

  TODO

  - [ ] Cache for all translations
  - [x] Cache the token @done(02/08/2021 12:04:37)
  - [ ] Refactor to suport bulk translations using same base
  - [ ] Fix multiline translation data
]##

{.experimental: "codeReordering".}

import std/[
  re,
  uri,
  httpclient,
  json,
  strutils,
  strformat
]

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
  GT_URL = "https://translate.google.{tld}"
  GT_API_PATH = "/_/TranslateWebserverUi/data/batchexecute"

type
  Translator* = ref object
    url: Uri
    token: Tokens

  TranslatorCorrection* = object
    wrong*: bool
    value*: string

  TranslatorDefinition* = object
    description*, text*: string
    synonyms*: seq[string]

  TranslatorDefinitions* = object
    adverb*, preposition*, adjective*, noun*, verb*, prefix*, suffix*, pronoun*,
      exclamation*, interjection*, abbreviation*: seq[TranslatorDefinition]

  TranslatorMainTranslationLanguage* = object
    `from`*, to*, detected*: Languages

  TranslatorMainTranslationTerm* = object
    value*: string
    alternatives*: seq[string]

  TranslatorMainTranslation* = object
    values*: seq[TranslatorMainTranslationTerm]
    language*: TranslatorMainTranslationLanguage

  TranslatorTranslation* = object
    refer*, text*: string
    frequency*: int
    equivalents*: seq[string]

  TranslatorTranslations* = object
    adverb*, preposition*, adjective*, noun*, verb*, prefix*, suffix*, pronoun*,
      exclamation*, interjection*, abbreviation*: seq[TranslatorTranslation]

  TranslatorSynonyms* = object
    adverb*, preposition*, adjective*, noun*, verb*, prefix*, suffix*, pronoun*,
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

proc isNull(node: JsonNode): bool =
  if node.isNil:
    return true
  try:
    result =
      case node.kind:
      of JObject: node == newJObject()
      of JArray: node.len == 0
      of JInt, JString, JFloat, JBool:
        const noVal = "df3939f11965e7e75db"
        node.getStr(noVal) == noVal
      else: true
  except:
    result = false

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

  let response = client.post($url, body = fmt"f.req={reqBody}")
  var body = response.body
  if body == "":
    echo "Cannot get the response body"
    return
  
  body = body.substr(6)

  let arr = parseBodyToArr(body)
  var json: JsonNode
  try:
    json = parseJson arr[0]
    json = parseJson json{0}{2}.getStr
  except:
    echo "Cannot parse json"
    return

  result.translation.language.`from` = `from`
  result.translation.language.to = to
  result.original = text

  if json{0}.len < 4:
    return

  try:
    if not json{0, 2}.isNull:
      result.translation.language.detected = parseEnum[Languages](json{0, 2}.getStr)

    if not json{1, 0, 0}{5, 0, 0}.isNull:
      for translation in json{1, 0, 0}{5}:
        var term = TranslatorMainTranslationTerm(
          value: translation{0}.getStr,
          alternatives: @[]
        )
        if not translation{1}.isNull:
          for possibility in translation{1}:
            let possibilityStr = possibility.getStr
            if possibilityStr != term.value:
              term.alternatives.add possibilityStr
        result.translation.values.add term
    result.pronunciation = json{0, 0}.getStr

    if json{0, 1}.isNull or json{0, 1, 0}.isNull:
      result.correction.wrong = false
    else:
      result.correction.wrong = true
      result.correction.value = json{0, 1, 0}{0, 1}.
        getStr.
        replacef(re"<b><i>(.*)</i></b>", "[$1]")

    let
      values = json{3}
      definitions = values{1, 0}
      translations = values{5, 0}
      examples = values{2, 0}
      synonyms = values{4, 0}

    # get definitions
    if not definitions.isNull:
      for definition in definitions:
        let
          name = definition[0].getStr
          defs = definition[1]
        for def in defs:
          var
            defin = TranslatorDefinition(
              description: "",
              text: "",
              synonyms: newSeq[string]()
            )

          if def.len > 1:
            defin.description = def[0].getStr
            defin.text = def[1].getStr
          else:
            defin.text = def[0].getStr

          if not def{3}.isNull:
            for synonym in def{3}:
              defin.synonyms.add synonym.getStr
          case name:
          of "adverb": result.definitions.adverb.add defin
          of "preposition": result.definitions.preposition.add defin
          of "adjective": result.definitions.adjective.add defin
          of "noun": result.definitions.noun.add defin
          of "verb": result.definitions.verb.add defin
          of "prefix": result.definitions.prefix.add defin
          of "suffix": result.definitions.suffix.add defin
          of "pronoun": result.definitions.pronoun.add defin
          of "exclamation": result.definitions.exclamation.add defin
          of "interjection": result.definitions.interjection.add defin
          of "abbreviation": result.definitions.abbreviation.add defin

    # if not examples.isNull:
    #   for example in examples:
    #     result.examples.add example[1].getStr.replacef(re"<b>(.*)</b>", "[$1]")

    # # get the translations
    # if not translations.isNull:
    #   for translation in translations:
    #     let
    #       name = translation[0].getStr
    #       defs = translation[1]
    #     for def in defs:
    #       var
    #         translationPossibility = TranslatorTranslation(
    #           text: def[0].getStr,
    #           refer: def[1].getStr,
    #           equivalents: @[],
    #           frequency: def[3].getInt
    #         )

    #       for equivalent in def[2]:
    #         translationPossibility.equivalents.add equivalent.getStr

    #       case name:
    #       of "adverb": result.translations.adverb.add translationPossibility
    #       of "preposition": result.translations.preposition.add translationPossibility
    #       of "adjective": result.translations.adjective.add translationPossibility
    #       of "noun": result.translations.noun.add translationPossibility
    #       of "verb": result.translations.verb.add translationPossibility
    #       of "prefix": result.translations.prefix.add translationPossibility
    #       of "suffix": result.translations.suffix.add translationPossibility
    #       of "pronoun": result.translations.pronoun.add translationPossibility
    #       of "exclamation": result.translations.exclamation.add translationPossibility
    #       of "interjection": result.translations.interjection.add translationPossibility
    #       of "abbreviation": result.translations.abbreviation.add translationPossibility

    # # get the synonyms
    # if not synonyms.isNull:
    #   for synonym in synonyms:
    #     let
    #       name = synonym[0].getStr
    #       syns = synonym[1]
    #     for syn in syns:
    #       var synon = newSeq[seq[string]]()

    #       for val in syn:
    #         var synons = newSeq[string]()
    #         for v in val: synons.add v.getStr
    #         synon.add synons

    #       case name:
    #       of "adverb": result.synonyms.adverb.add synon
    #       of "preposition": result.synonyms.preposition.add synon
    #       of "adjective": result.synonyms.adjective.add synon
    #       of "noun": result.synonyms.noun.add synon
    #       of "verb": result.synonyms.verb.add synon
    #       of "prefix": result.synonyms.prefix.add synon
    #       of "suffix": result.synonyms.suffix.add synon
    #       of "pronoun": result.synonyms.pronoun.add synon
    #       of "exclamation": result.synonyms.exclamation.add synon
    #       of "interjection": result.synonyms.interjection.add synon
    #       of "abbreviation": result.synonyms.abbreviation.add synon
    result.success = true
  except:
    doAssert false, getCurrentExceptionMsg()
    discard



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
  echo translator.single("lunch", to = LangPortuguese)
  # echo translator.single("tchau")
  # echo translator.single("be", to = LangPortuguese)
  echo translator.single("ser")
  # echo translator.single("teste", to = LangEnglish)
  # echo translator.single("teste\nSeu Carlos", to = LangEnglish)
  # echo translator.single("ser\ncomer", to = LangEnglish)
  # echo translator.single("out", to = LangArabic)
  # echo translator.single("kind", to = LangPortuguese)
  # echo translator.single("bye", to = LangPortuguese)
  # echo translator.single("oi")
  # echo translator.single("test", to=LangSpanish)
