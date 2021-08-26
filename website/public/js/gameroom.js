const u = new URL(document.location)
const room_id = u.searchParams.get("rid")
const nickname = localStorage.getItem("nickname") || "Player" + Math.floor(10 + 70 * Math.random())
const WS_URL = `ws://${u.host}/play?rid=${room_id}&name=${nickname}`
const socket = new WebSocket(WS_URL)

let ownerStatus = false
let roundInProgress = false
let startButton = document.getElementById("start-button")
let submitButton = document.getElementById("submit-button")

startButton.addEventListener("click", startRound)
submitButton.addEventListener("click", submitCode)

function updateButtonVisibility() {
    if (roundInProgress) {
        startButton.style.display = "none"
        submitButton.style.display = "block"
    } else {
        if (ownerStatus) {
            startButton.style.display = "block"
        }
        submitButton.style.display = "none"
    }
}

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

function startRound() {
    socket.send("START_ROUND:")
}

function showTestCase(testcase) {
    let testInputEl = document.createElement("div")
    let testOutputEl = document.createElement("div")
    testInputEl.classList.add("mono-box")
    testInputEl.classList.add("test-input")
    testOutputEl.classList.add("mono-box")
    testOutputEl.classList.add("test-output")
    testInputEl.innerText = testcase.input
    testOutputEl.innerText = testcase.output

    let testcaseRoot = document.getElementById("test-cases")
    let parent = document.createElement("div")
    parent.classList.add("test-case")
    parent.appendChild(testInputEl)
    parent.appendChild(testOutputEl)
    testcaseRoot.appendChild(parent)

}

function showPuzzle(puzzle) {
    document.getElementById("problem-title").innerText = puzzle.title
    document.getElementById("problem-statement").innerText = puzzle.statement
    document.getElementById("input-description").innerText = puzzle.inputDescription
    document.getElementById("output-description").innerText = puzzle.outputDescription
    const testContainer = document.getElementById("test-cases")
    testContainer.innerHTML = ""
    puzzle.tests.forEach(showTestCase)
}

socket.addEventListener("open", function (event) {
    console.info("Connected to game room!")
})

socket.addEventListener("message", function (event) {
    let colonIndex = event.data.indexOf(":")
    let cmd = event.data.slice(0, colonIndex)
    let msgContent = event.data.slice(colonIndex + 1)
    console.log(`Received message of type ${cmd}`)
    if (cmd == "PUZZLE") {
        const puzzle = JSON.parse(msgContent)
        showPuzzle(puzzle)
    } else if (cmd == "OWNER") {
        // users can of course set ownerStatus themselves but it is
        // actually stored serverside, so setting it to true here will
        // just show some buttons that won't work if you're not the
        // client connected to the owner websocket
        if (msgContent == nickname) {
            ownerStatus = true
            // make start round button visible if owner change happened
            // when round wasn't in progress
            updateButtonVisibility()
        }
    } else if (cmd == "TIME_LEFT") {
        console.info(`${msgContent} seconds left in this round`)
        roundInProgress = true
        updateButtonVisibility()
    } else if (cmd == "ROUND_END") {
        roundInProgress = false
        updateButtonVisibility()
        console.log(JSON.parse(msgContent)) // TODO
    } else {
        console.warn(`Did not handle ${cmd} message`)
    }
})