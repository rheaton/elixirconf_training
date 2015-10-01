defmodule Docs.UserSocket do
  use Phoenix.Socket

  ## Channels
  # channel "rooms:*", Docs.RoomChannel
  channel "documents:*", Docs.DocumentChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket, check_origin: false
  # transport :longpoll, Phoenix.Transports.LongPoll

  # by default, we will check the origin for security
  #   maybe a service like Pusher would not want to check, but usually you would
  #   want to check clients from the same webapp
  #   check_origin: ["urwebsite.com"]
  #   need to do this as there is no cross-origin projection like AJAX

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  #  To deny connection, return `:error`.
  def connect(_params, socket) do
    {:ok, assign(socket, :user_id, :guest)}
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Docs.Endpoint.broadcast("users_socket:" <> user.id, "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil

  # ^ so we could ban a user
end
