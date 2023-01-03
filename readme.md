<!--
  Created at: 09/17/2021 01:41:05 Friday
  Modified at: 09/17/2021 01:49:16 AM Friday

        Copyright (C) 2021 Thiago Navarro
  See file "license" for details about copyright
-->

<!-- Are you interested? Feel free to open an issue or PR! -->

# googleTranslate

Google translate free implementation of `batchexecute`

## Usage

```nim
import googleTranslate

let translator = initTranslator()
echo translator.single("Hello World!", to = LangPortuguese)
```

## TODO

- [x] Add to nimble
- [ ] Add docs
- [ ] import modules with `from module import proc` insted of `import module`
- [ ] Installation guide
- [ ] Better usage guide
- [ ] Github actions

## License

MIT
