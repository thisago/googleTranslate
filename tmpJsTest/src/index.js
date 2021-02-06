const translate = require('@vitalets/google-translate-api');

translate("Ik spreek Engels", { to: "en" })
  .then((res) => {
    console.log(res.text);
    //=> I speak English
    console.log(res.from.language.iso);
    //=> nl
  })
  .catch((err) => {
    console.error(err);
  });

translate('I spea Dutch!', {from: 'en', to: 'nl'}).then(res => {
    console.log(res.text);
    //=> Ik spreek Nederlands!
    console.log(res.from.text.autoCorrected);
    //=> true
    console.log(res.from.text.value);
    //=> I [speak] Dutch!
    console.log(res.from.text.didYouMean);
    //=> false
}).catch(err => {
    console.error(err);
});
