const API_URL = "http://localhost:8080/api/v1";

document.getElementById("submit-button").addEventListener("click", submitCode);

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
