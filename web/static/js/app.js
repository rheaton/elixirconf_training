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
let socket = new Socket("/socket", {
  logger: (kind, msg, data) => {
    console.log(`${kind}: ${msg}`, data)
  },
  params: {token: window.userToken}
})
socket.connect()
socket.onOpen(() => console.log("connected to a socket"))

let App = {
  init(){
    let docId = $("#doc-form").data("id")
    if(!docId) { return }
    let docChan = socket.channel("documents:" + docId)
    docChan.params["last_message_id"] = 0
    let docForm = $("#doc-form")
    let editor = new Quill("#doc-form #editor")
    let msgContainer = $("#messages")
    let msgInput = $("#message-input")
    let saveTimer = null

    msgInput.on("keypress", e => {
      if (e.which !== 13) { return }

      docChan.push("new_message", {body: msgInput.val()})
      msgInput.val("")
    })

    docChan.on("new_message", msg => {
      this.appendMessage(msg, msgContainer, docChan)
    })

    // text-change is quill api
    // snake-case is phoenix convention

    // ops: what made the change
    // source: can be programatically, or by user
    editor.on("text-change", (ops, source) => {
      if(source !== "user") {return}

      clearTimeout(saveTimer)
      saveTimer = setTimeout(() => {
        this.save(docChan, docForm, editor)
      }, 2500)

      // to server
      docChan.push("text_change", {opts: ops})
        // .receive("ok", console.log("sent text-change to server"))
    })

    docForm.on("submit", e => {
      e.preventDefault()
      this.save(docChan, docForm, editor)
    })

    // from server
    docChan.on("text_change", ({ops}) => {
      editor.updateContents(opts)
    })

    docChan.on("messages", ({messages}) => {
      messages.reverse().forEach(m => {
        this.appendMessage(m, msgContainer, docChan)
      })
    })

    docChan.join()
      .receive("ok", resp => console.log("joined documents channel"))
      .receive("error", resp => console.log("FAILED to join documents channel", reason))
  },
  save(docChan, docForm, editor) {
    let body = editor.getHTML()
    let title = docForm.find("#document_title").val()
    docChan.push("save", {body: body, title: title})
    .receive("ok", () => console.log("persisted document"))
    .receive("error", () => console.log("couldn't save document"))
  },
  appendMessage(msg, msgContainer, docChan) {
    if (docChan.params["last_message_id"] < msg.id) {
      docChan.params["last_message_id"] = msg.id
    }
    msgContainer.append(`<br/>${msg.body}`)
    msgContainer.scrollTop(msgContainer.prop("scrollHeight"))
  }
}

App.init()

// vendor/*js is available above your customer stuff
