var editor = CodeMirror.fromTextArea(document.getElementById("codemirror"), {
    lineNumbers: true,
    mode: "javascript",
    theme: "monokai"
})

const langModes = {
    // clike.js
    "c": "text/x-csrc",
    "c++": "text/x-c++src",
    "java": "text/x-java",
    "objectivec": "text/x-objectivec",
    "scala": "text/x-scala",
    "kotlin": "text/x-kotlin",
    "ceylon": "text/x-ceylon",
    // mllike.js
    "ocaml": "text/x-ocaml",
    "fsharp": "text/x-fsharp",
    // others
    "lisp": "text/x-common-lisp"
}
const updateLang = () => {
    const selectedLang = document.getElementById("language-selector").value
    let langMode = langModes[selectedLang] || selectedLang
    
    editor.setOption("mode", langMode)
}
document.getElementById("language-selector").onchange = updateLang
window.addEventListener("load", updateLang);
