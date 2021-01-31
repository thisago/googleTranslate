// + /data/files/dev/nim/lib/googleTranslate/tests/genKey.ts
/**
 * Copyright (c) 2021 Thiago Navarro. All rights reserved
 *
 * @workspace googleTranslate
 *
 * @author Thiago Navarro <thiago@oxyoy.com>
 */

//# :Author: Thiago Navarro
//# :Email: thiago@oxyoy.com
//#
//# **Created at:** 01/29/2021 11:25:52 Saturday
//#
//# **Modified at:** 01/31/2021 Sunday 12:56:21 PM
//#
//# ----
//#
//# Rewrite of Google Translate API key gen
//# ----

const newXr = (key: number, secret: string) => {
  for (let i = 0; i < secret.length - 2; i += 3) {
    let ch: string = secret.charAt(i + 2),
      chInt = ch.charCodeAt(0);
    // console.log(`key: ${key},i: ${i}, ch: ${ch}, chInt: ${chInt}`);

    if (chInt >= "a".charCodeAt(0)) {
      chInt = chInt - 87;
    } else {
      chInt = Number(ch);
    }

    if (secret.charAt(i + 1) == "+") {
      chInt = key >>> chInt;
      console.log(`${ch}:${chInt} ${key} >>> ${chInt} = ${key >>> chInt}`);
    } else {
      chInt = key << chInt;
    }

    if (secret.charAt(i) == "+") {
      key = key + chInt;
    } else {
      key = key ^ chInt;
    }
  }
  return key;
};

const newKey = (a: string) => {
  let code: number[] = [];

  for (let g = 0; g < a.length; g++) {
    let chCode = a.charCodeAt(g); //? l
    if (chCode < 128) {
      code.push(chCode);
    } else {
      if (chCode < 2048) {
        code.push((chCode >> 6) | 192);
      } else {
        if (
          55296 == (chCode & 64512) &&
          g + 1 < a.length &&
          56320 == (a.charCodeAt(g + 1) & 64512)
        ) {
          g++;
          chCode = 65536 + ((chCode & 1023) << 10) + a.charCodeAt(g);
          code.push((chCode >> 18) | 240);
          code.push(((chCode >> 12) & 63) | 128);
        } else {
          code.push((chCode >> 12) | 224);
        }
        code.push(((chCode >> 6) & 63) | 128);
      }
      code.push((chCode & 63) | 128);
    }
  }

  let key: number = 0;

  console.log(code);

  for (let keyIndex = 0; keyIndex < code.length; keyIndex++) {
    console.log(key);

    key += code[keyIndex];
    key = newXr(key, "+-a^+6");
  }
  console.log(key);

  key = newXr(key, "+-3^+b+-f");
  key = key ^ 0;

  if (key < 0) {
    key = (key & 2147483647) + 2147483648;
  }

  key = key % 1e6;

  return `${key}.${key}`;
};

console.log(newXr(1234, "+-a^+6"));
console.log(newXr(-1234, "+-a^+6"));
console.log(newXr(42676448, "+-a^+6"));
// console.log(xr(-234534544, "+-a^+6"));

// console.log(newKey("0123"), newKey("0123") == sM("0123"));
// console.log(newKey("test"), newKey("test") == sM("test"));
// console.log(newKey("!@&$"), newKey("!@&$") == sM("!@&$"));

// console.log(newKey("0123"));
// console.log(newKey("test"));
// console.log(newKey("!@&$"));

// console.log(newKey("0123") == "285702.285702");
// console.log(newKey("test") == "684737.684737");
// console.log(newKey("!@&$") == "524995.524995");

// console.log(-25355305 >>> 6);
// console.log(-25355305 >> 6);

// console.log(-1727632372 >>> 11);
// console.log(-1727632372 >> 11);

// console.log(25355305 >>> 6);
// console.log(25355305 >> 6);

// console.log(1727632372 >>> 11);
// console.log(1727632372 >> 11);

// console.log(newXr(12, "+-a^+6"));

console.log(42676448 >>> 43700682752);
console.log(431238989898912374335920 >>> 12401347);
