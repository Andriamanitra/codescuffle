const u = new URL(document.location)
const room_id = u.searchParams.get("rid")
const nickname = localStorage.getItem("nickname") || "Player" + Math.floor(10 + 70 * Math.random())
const WS_URL = `ws://${u.host}/play?rid=${room_id}&name=${nickname}`
const socket = new WebSocket(WS_URL)

document.getElementById("submit-button").addEventListener("click", submitCode);

function submitCode() {
    let code = window.editor.getValue();
    let selectedLanguage = document.getElementById("language-selector").value;
    if (code == "") {
        alert("Cannot submit empty code!")
        return
    }
    let submission = {
        language: selectedLanguage,
        code: code
    };
    socket.send("SUBMIT:" + JSON.stringify(submission))
}


socket.addEventListener("open", function (event) {
    console.info("Connected to game room!")
})

socket.addEventListener("message", function (event) {
    console.log(event.data)
})