const parseData = (audio = "") => {
  let data = [],
    tmp = "";

  for (let row of audio.slice(6).split("\n")) {
    if (isNaN(row)) {
      tmp += row;
    } else {
      if (tmp != "") {
        data.push(tmp);
        tmp = "";
      }
    }
  }
  if (tmp != "") {
    data.push(tmp);
  }

  return data;
};
const getAudio = async (text = "") => {
  const audio = await (
    await fetch(
      "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=jQ1olc&f.sid=-4310402817379782673&bl=boq_translate-webserver_20210204.11_p0&hl=en-US&soc-app=1&soc-platform=1&soc-device=1&_reqid=1053863&rt=c",
      {
        headers: {
          accept: "*/*",
          "accept-language": "en-US,en;q=0.9",
          "cache-control": "no-cache",
          "content-type": "application/x-www-form-urlencoded;charset=UTF-8",
          pragma: "no-cache",
          "sec-fetch-dest": "empty",
          "sec-fetch-mode": "cors",
          "sec-fetch-site": "same-origin",
          "x-goog-batchexecute-bgr":
            '["FNLSecurityError: Blocked a frame with origin \\"https://translate.google.com\\" from accessing a cross-origin frame.",null,null,28,null,null,null,0]',
          "x-same-domain": "1",
        },
        referrer: "https://translate.google.com/",
        referrerPolicy: "origin",
        body: `f.req=%5B%5B%5B%22jQ1olc%22%2C%22%5B%5C%22${encodeURIComponent(
          text
        )}%5C%22%2C%5C%22en%5C%22%2Ctrue%2C%5C%22null%5C%22%5D%22%2Cnull%2C%22generic%22%5D%5D%5D&`,
        method: "POST",
        mode: "cors",
        credentials: "include",
      }
    )
  ).text();

  const data = parseData(audio)[0];
  const a = JSON.parse(JSON.parse(data)[0][2])[0];

  return `data:audio/mp3;base64,${a}`;
};

const createLink = async (text = "") => {
  const link = await getAudio(text);

  const a = document.createElement("a");
  a.href = link;
  a.innerHTML = text;
  a.target = "_blank";
  document.head.appendChild(a);
};

(async () => {
  createLink(prompt("text"));
})();
