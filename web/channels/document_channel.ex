defmodule Docs.DocumentChannel do
  use Docs.Web, :channel

  # plural by convention 'documents'
  # socket is passed around like plug
  # socket holds the state (gen server under the hood)
  def join("documents:" <> doc_id, params, socket) do
    # need to wait until after subscribed to genserver for messages:
    send(self, {:after_join, params})
    {:ok, assign(socket, :doc_id, doc_id)}
  end

  # cannot throw it into an agent if we are running on more than one node/computer
  def handle_info({:after_join,  params}, socket) do
    doc = Repo.get(Document, socket.assigns.doc_id)
    messages = Repo.all(
      from m in assoc(doc, :messages),
        order_by: [desc: m.inserted_at],
        select: %{id: m.id, body: m.body},
        where: m.id > ^params["last_message_id"],
        limit: 100
    )
    push socket, "messages", %{messages: messages}
    # ^ should encode with a view, but lazy for class
    {:noreply, socket}
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

  def handle_in("save", params, socket) do
    Document
    |> Repo.get(socket.assigns.doc_id)
    |> Document.changeset(params)
    |> Repo.update()
    |> case do
      {:ok, _document} ->
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{reasons: changeset}}, socket}
    end
  end

  def handle_in("new_message", params, socket) do
    changeset =
      Document
      |> Repo.get(socket.assigns.doc_id)
      |> Ecto.Model.build(:messages)
      |> Message.changeset(params)

    case Repo.insert(changeset) do
      {:ok, msg} ->
        broadcast! socket, "new_message", %{body: params["body"]}
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{reasons: changeset}}, socket}
    end
  end
end
