// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"
import {Socket} from "deps/phoenix/web/static/js/phoenix"

// endpoint from endpoint.ex
let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()
socket.onOpen(() => console.log("connected to a socket"))

let App = {
  init(){
    let docId = $("#doc-form").data("id")
    let docChan = socket.channel("documents:" + docId)
    let docForm = $("#doc-form")
    let editor = new Quill("#doc-form #editor")

    // text-change is quill api
    // snake-case is phoenix convention

    // ops: what made the change
    // source: can be programatically, or by user
    editor.on("text-change", (ops, source) => {
      if( source !== "user") {return}

      // to server
      docChan.push("text_change", {opts: ops})
        // .receive("ok", console.log("sent text-change to server"))
    })

    docForm.on("submit", e => {
      e.preventDefault()
      let body = editor.getHTML()
      let title = docForm.find("#document_title").val()
      docChan.push("save", {body: body, title: title})
        .receive("ok", () => console.log("persisted document"))
        .receive("error", () => console.log("couldn't save document"))
    })

    // from server
    docChan.on("text_change", ({ops}) => {
      editor.updateContents(opts)
    })

    docChan.join()
      .receive("ok", resp => console.log("joined documents channel", resp))
      .receive("error", resp => console.log("FAILED to join documents channel", reason))
  }
}

App.init()

// vendor/*js is available above your customer stuff
