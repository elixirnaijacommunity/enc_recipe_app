defmodule RecipeAppWeb.PageController do
  use RecipeAppWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
