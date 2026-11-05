defmodule RecipeAppWeb.PageControllerTest do
  use RecipeAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias RecipeAppWeb.{PageController, PageHTML}

  test "renders the legacy home page", %{conn: conn} do
    conn =
      conn
      |> Plug.Conn.fetch_query_params()
      |> Phoenix.Controller.accepts(["html"])
      |> Phoenix.Controller.put_view(html: PageHTML)
      |> Plug.Conn.assign(:flash, %{})

    conn = PageController.home(conn, %{})

    assert conn.status == 200
    assert conn.resp_body =~ "Discuss on the Elixir Forum"
    assert conn.resp_body =~ "Deploy your application"
  end

  test "renders the embedded home template directly" do
    markup =
      render_component(&PageHTML.home/1, %{
        flash: %{}
      })

    assert markup =~ "Discuss on the Elixir Forum"
    assert markup =~ "Deploy your application"
  end
end
