defmodule Docs.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Docs.Web, :controller
      use Docs.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def model do
    quote do
      use Ecto.Model
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      alias Docs.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 1, from: 2]

      import Docs.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import Docs.Router.Helpers
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  # this is used when we `use Docs.Web, :channel` by the thing at the bottom
  def channel do
    quote do
      use Phoenix.Channel

      alias Docs.Repo
      alias Docs.Document
      alias Docs.Message
      import Ecto.Model
      import Ecto.Query, only: [from: 2]

    end
  end

  # don't define shared functions in this file-- create a module
  # e.g.
  # defmodule ViewHelpers
  # end
  # ...
  # import ViewHelpers (in this file)
  # defining functions in here will make the compiler slow and sad -JV

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
