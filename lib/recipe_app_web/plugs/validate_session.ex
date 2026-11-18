defmodule RecipeAppWeb.Plugs.ValidateSession do
  import Plug.Conn

  alias RecipeApp.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    if is_nil(user_id) do
      conn
    else
      user = Accounts.get_user_by_id(user_id)

      if user && get_session(conn, :auth_version) == user.auth_version do
        conn
      else
        conn
        |> delete_session(:user_id)
        |> delete_session(:auth_version)
      end
    end
  end
end
