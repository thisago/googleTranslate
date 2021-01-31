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
## **Modified at:** 01/30/2021 Saturday 02:19:23 PM
## 
## ----
## 
## Test for the Google translate module
## ----

import unittest

import googleTranslate

#? tests
suite "API key":
  
  test "0123":
    check(newApiKey("0123") == "285702.285702")
  test "test":
    check(newApiKey("test") == "684737.684737")
  test "!@&$":
    check(newApiKey("!@&$") == "524995.524995")

# suite "Translate":
#   setup:
#     echo "Setup"

#   teardown:
#     echo "Teardown"

#   test "pt to en":
#     check googleTranslate(to = Language.en, text = "Olá a todos") == "Hello everyone"