# Package

version       = "0.1.0"
author        = "Thiago Navarro"
description   = "A simple Google Translate implementation"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.4.2"


task testJs, "Test the lib using js":
  # exec "nimble test -b:js"
  exec "nim js -r -d:danger -d:release tests/test1.nim"