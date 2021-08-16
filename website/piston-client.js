const LANGUAGES_API = "https://emkc.org/api/v2/piston/runtimes"
const EXECUTE_API = "https://emkc.org/api/v2/piston/execute"

let languages = []

document.getElementById("submit-button").addEventListener("click", submitCode);

window.addEventListener("load", fetchLanguages);

function fetchLanguages() {
  fetch(LANGUAGES_API)
    .then(resp => resp.json())
    .then(data => {
      languages = data
      const languageSelector = this.document.getElementById("language-selector");
      languageSelector.innerHTML = "";
      for(const obj of data) {
        let option = document.createElement("option");
        option.text = obj.language[0].toUpperCase() + obj.language.substring(1);
        option.value = obj.language;
        languageSelector.add(option);
      }
    })
}

function submitCode(ev) {
  let code = window.editor.getValue();
  let selectedLanguage = document.getElementById("language-selector").value;
  let languageVersion = languages.find(x => x.language == selectedLanguage).version;
  let codeRunRequest = {
    language: selectedLanguage,
    version: languageVersion,
    files: [
      {
        content: code
      }
    ],
    stdin: ""
  };
  fetch(EXECUTE_API, {
    method: "post",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(codeRunRequest),
  })
    .then((resp) => resp.json())
    .then((data) => {
      document.getElementById("stdout").innerText = data.run.stdout;
      document.getElementById("stderr").innerText = data.run.stderr;
    });
}
