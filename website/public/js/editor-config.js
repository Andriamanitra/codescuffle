require.config({ paths: { vs: "../monaco-editor/min/vs" } });

require(["vs/editor/editor.main"], function () {
  window.editor = monaco.editor.create(
    document.getElementById("monaco"),
    {
      value: [""].join("\n"),
      language: "none",
      theme: "vs-dark",
    }
  );
  const editor = window.editor

  window.onresize = function () {
    editor.layout();
  };

  setInterval(_=>{
    editor.layout();
  }, 100)

  window.addEventListener("message", (e) => {
      if (e.data.type === "set") {
        editor.setValue(e.data.data);
      } else if (e.data.type === "get") {
        e.source.postMessage(editor.getValue(), e.origin);
      }
    },
    false
  );
});