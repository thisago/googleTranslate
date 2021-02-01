# Package

version       = "0.1.0"
author        = "Thiago Navarro"
description   = "A simple Google Translate implementation"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.2"


task testJs, "Test the lib using js":
  exec "nim js -r -d:danger --hints:off --verbosity:0 -d:release tests/t_token.nim && rm tests/t_token.js"

task test, "Test all":
  exec "nimble test_js"