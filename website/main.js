const API_URL = "http://localhost:8080/api/v1"

document.getElementById("submit-button").addEventListener("click", submitCode);

function submitCode(ev) {
    let code = document.getElementById("code").value;
    let lang = document.getElementById("programming-language").value;
    let codeRunRequest = { code: code };
    let reqUrl = `${API_URL}/run/${lang}`;
    fetch(reqUrl, {
            method: "post",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(codeRunRequest)
        })
        .then(resp => resp.json())
        .then(data => {
            document.getElementById("stdout").innerText = data.stdout;
            document.getElementById("stderr").innerText = data.stderr;
        })
}