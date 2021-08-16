const API_URL = "http://localhost:8080/api/v1";
const LANGUAGES_API = "http://localhost:8080/api/v1/languages";

document.getElementById("submit-button").addEventListener("click", submitCode);


let languages = []

document.getElementById("submit-button").addEventListener("click", submitCode);

// Fetch available languages from API
window.addEventListener("load", function() {
  fetch(LANGUAGES_API)
    .then((resp) => resp.json())
    .then((data) => {
      languages = data;
      const languageSelector = this.document.getElementById("language-selector");
      languageSelector.innerHTML = "";
      for(const obj of data) {
        let option = document.createElement("option");
        option.text = obj.language[0].toUpperCase() + obj.language.substring(1);
        option.value = obj.language;
        languageSelector.add(option);
      }
    })
})

function submitCode(ev) {
  let code = window.editor.getValue();
  let lang = document.getElementById("language-selector").value;
  let codeRunRequest = { code: code, stdin: "hello world" };
  let reqUrl = `${API_URL}/run/${lang}`;
  fetch(reqUrl, {
    method: "post",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(codeRunRequest),
  })
    .then((resp) => resp.json())
    .then((data) => {
      console.log(data);
      document.getElementById("stdout").innerText = data.stdout;
      document.getElementById("stderr").innerText = data.compile_stderr + data.stderr;
    });
}
