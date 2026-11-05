defmodule RecipeAppWebHologram.Middleware.ValidateSession do
  use Hologram.Middleware

  alias RecipeApp.Accounts

  @impl Hologram.Middleware
  def call(%{user_id: nil} = server, _opts), do: server

  def call(server, _opts) do
    user = Accounts.get_user_by_id(server.user_id)

    if user && get_session(server, :auth_version) == user.auth_version do
      server
    else
      server
      |> delete_user_id()
      |> delete_session(:auth_version)
    end
  end
end
