defmodule Docs.DocumentChannel do
  use Docs.Web, :channel

  # plural by convention 'documents'
  # socket is passed around like plug
  # socket holds the state (gen server under the hood)
  def join("documents:" <> doc_id, _params, socket) do
    {:ok, assign(socket, :doc_id, doc_id)}
  end


  # send string key to avoid vulnerability to arbitray atoms
  def handle_in("text_change", %{"ops" => ops}, socket) do
    # broadcast: broadcast to everyone including broadcaster
    # broadcast_from: broadcast to everyone except broadcaster
    broadcast_from! socket, "text_change", %{
      ops: ops
    }
    # {:noreply, socket} # this is okay
    {:reply, :ok, socket} # this is slightly more expensive, but clearer (for example, could hide spinner)
  end
  # cannot broadcast directly from the client

end
