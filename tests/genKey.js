"use strict";
// + /data/files/dev/nim/lib/googleTranslate/tests/genKey.ts
/**
 * Copyright (c) 2021 Thiago Navarro. All rights reserved
 *
 * @workspace googleTranslate
 *
 * @author Thiago Navarro <thiago@oxyoy.com>
 */
exports.__esModule = true;
exports.newXr = exports.newKey = void 0;
//# :Author: Thiago Navarro
//# :Email: thiago@oxyoy.com
//#
//# **Created at:** 01/29/2021 11:25:52 Saturday
//#
//# **Modified at:** 02/01/2021 Monday 01:14:00 PM
//#
//# ----
//#
//# Rewrite of Google Translate API key gen
//# ----
var newXr = function (key, secret) {
    var result = key;
    // console.log(
    //   `1 key: ${key}, chInt: ${chInt}, ch: ${ch}, result: ${result}, i: ${i}`
    // );
    for (var i = 0; i < secret.length - 2; i += 3) {
        var ch = secret[i + 2], chInt = ch.charCodeAt(0);
        if (chInt >= "a".charCodeAt(0)) {
            chInt = chInt - 87;
        }
        else {
            chInt = Number(ch);
        }
        if (secret[i + 1] == "+") {
            chInt = result >>> chInt;
        }
        else {
            chInt = result << chInt;
        }
        if (secret[i] == "+") {
            result += chInt;
        }
        else {
            result = result ^ chInt;
        }
    }
    return result;
};
exports.newXr = newXr;
var newKey = function (a) {
    var code = [];
    for (var g = 0; g < a.length; g++) {
        var chCode = a.charCodeAt(g);
        if (chCode < 128) {
            code.push(chCode);
        }
        else {
            if (chCode < 2048) {
                code.push((chCode >> 6) | 192);
            }
            else {
                if (55296 == (chCode & 64512) &&
                    g + 1 < a.length &&
                    56320 == (a.charCodeAt(g + 1) & 64512)) {
                    g++;
                    chCode = 65536 + ((chCode & 1023) << 10) + a.charCodeAt(g);
                    code.push((chCode >> 18) | 240);
                    code.push(((chCode >> 12) & 63) | 128);
                }
                else {
                    code.push((chCode >> 12) | 224);
                }
                code.push(((chCode >> 6) & 63) | 128);
            }
            code.push((chCode & 63) | 128);
        }
    }
    var key = 0;
    for (var keyIndex = 0; keyIndex < code.length; keyIndex++) {
        key += code[keyIndex];
        key = newXr(key, "+-a^+6");
    }
    key = newXr(key, "+-3^+b+-f");
    key = key ^ 0;
    if (key < 0) {
        key = (key & 2147483647) + 2147483648;
    }
    key = key % 1e6;
    return key + "." + key;
};
exports.newKey = newKey;
