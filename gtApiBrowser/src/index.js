var { translate } = require("google-translate-api-browser");
var readline = require("readline");

var rl = readline.createInterface(process.stdin, process.stdout);
rl.setPrompt("translate > ");
rl.prompt();

rl.on("line", function(line) {
  translate(line, {from:"auto", to: "en" })
    .then(res => {
      console.log(res);
      rl.setPrompt(line + " > " + res.text + "\ntranslate > ");
      rl.prompt();
    })
    .catch(err => {
      console.error(err);
    });
}).on("close", function() {
  process.exit(0);
});
console.log(JSON.stringify(JSON.parse('[[["hello fat friends","olah amigos gordos",null,null,3,null,null,[[]],[[["1814a2c300f02f227bcb04312cd2671a","tea_pt_en_2019q4.md"]]]]],null,"pt",null,null,[["olah amigos gordos",null,[["hello fat friends",0,true,false],["olah fat friends",0,true,false]],[[0,18]],"olah amigos gordos",0,0]],0.98602426,["<b><i>ola</i></b> amigos gordos","ola amigos gordos",[1],null,null,false],[["pt"],null,[0.98602426],["pt"]]]'), null, 2))
