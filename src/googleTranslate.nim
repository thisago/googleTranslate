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
## **Modified at:** 02/02/2021 Tuesday 10:09:52 AM
##
## ----
##
## Main for the Google Translate implementation module
## ----
##
## **TODO**
## - cache



import httpclient, json
import strutils
import uri

import token
import util/form

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
        LangIcelandic = "is", LangIgbo = "ig", LangIndonesian = "id",
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
  Clients* = enum
    ClientGTX = "gtx", ClientT = "t",

const
  # GOOGLE_TRANSLATE_API_URL = "http://127.0.0.1/u2/apache/www/admins/condominos/a.php"
  GOOGLE_TRANSLATE_API_URL = "https://translate.google.{tld}/translate_a/"

type
  Translator* = ref object
    url: Uri
    client: Clients

  TranslatorResult* = tuple
    text, original: string
    source: tuple[autoCorrected, didYouMean: bool, value: string]
    pronunciation: string
    language: tuple[didYouMean: bool, iso: Languages]

proc newTranslator*(cors = "", tld = "com", client = ClientT): Translator =
  let
    gTUrl = parseUri(GOOGLE_TRANSLATE_API_URL.replace("{tld}", tld))
    url = if cors == "":
        gTUrl
      else:
        parseUri(cors) / $gTUrl

  if not url.isAbsolute:
    quit "Sorry, the URL is not valid"

  Translator(
    url: url,
    client: client
  )

proc one*(self: Translator, text: string, lang = LangAutomatic, to,
    hl: Languages = LangEnglish): TranslatorResult =
  let
    client = newHttpClient()

    params = %*{
      "client": self.client,
      "sl": lang,
      "tl": to,
      "hl": hl,
      "dt": ["at", "bd", "ex", "ld", "md", "qca", "rw", "rm", "ss", "t"],
      "ie": "UTF-8",
      "oe": "UTF-8",
      "otf": 1,
      "ssel": 0,
      "tsel": 0,
      "kc": 7,
      "q": text,
      "tk": newApiToken(text)
    }
    url = self.url / "single"

  echo url
  echo toForm params

  client.headers = newHttpHeaders({
    "Content-type": "application/x-www-form-urlencoded"
  })

  let
    response = client.post($url, body = toForm params)

  echo response.status
  echo response.body

  if response.status != "200 OK":
    return

  let
    body = parseJson response.body

  result.original = text
  result.text = getStr body{0, 0, 0}
  result.source.value = getStr body{0, 0, 1}



when isMainModule:
  let translator = newTranslator()

  echo translator.url
  echo translator.one("Olá amigps")
