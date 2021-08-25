const LANGUAGES_API = "https://emkc.org/api/v2/piston/runtimes"
const EXECUTE_API = "https://emkc.org/api/v2/piston/execute"

let languages = []
let preferredLanguage = localStorage.getItem("preferred_language") || "python"

document.getElementById("test-button").addEventListener("click", testCode);

window.addEventListener("load", fetchLanguages);

function fetchLanguages() {
  fetch(LANGUAGES_API)
    .then(resp => resp.json())
    .then(data => {
      languages = data
      languages.sort((a,b) => a.value < b.value ? 1 : -1)
      const languageSelector = this.document.getElementById("language-selector");
      languageSelector.innerHTML = "";
      for(const obj of languages) {
        let option = document.createElement("option");
        option.text = obj.language[0].toUpperCase() + obj.language.substring(1);
        option.value = obj.language;
        if (option.value == preferredLanguage) option.defaultSelected = true
        languageSelector.add(option);
      }
    })
}

function testCode(ev) {
  let code = window.editor.getValue();
  let selectedLanguage = document.getElementById("language-selector").value;
  let languageVersion = languages.find(x => x.language == selectedLanguage).version;

  // TODO: get inputString from currently selected test case
  let inputString = document.querySelector(".test-input")?.innerText || ""
  
  let codeRunRequest = {
    language: selectedLanguage,
    version: languageVersion,
    files: [
      {
        content: code
      }
    ],
    stdin: inputString
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
      console.log(data)
      document.getElementById("stdout").innerText = data.run.stdout;
      document.getElementById("stderr").innerText = data.run.stderr;
    });
}
