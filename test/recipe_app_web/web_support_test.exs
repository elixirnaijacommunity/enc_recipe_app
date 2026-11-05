defmodule RecipeAppWebSupportTest do
  use ExUnit.Case, async: true

  test "web entrypoint exposes static paths and quote builders" do
    assert RecipeAppWeb.static_paths() ==
             ~w(assets fonts images favicon.ico robots.txt)

    assert is_tuple(RecipeAppWeb.router())
    assert is_tuple(RecipeAppWeb.channel())
    assert is_tuple(RecipeAppWeb.controller())
    assert is_tuple(RecipeAppWeb.live_view())
    assert is_tuple(RecipeAppWeb.live_component())
    assert is_tuple(RecipeAppWeb.html())
    assert is_tuple(RecipeAppWeb.verified_routes())
  end

  test "telemetry exposes application and VM metrics" do
    metrics = RecipeAppWeb.Telemetry.metrics()

    assert Enum.any?(metrics, &(&1.name == [:phoenix, :endpoint, :start, :system_time]))
    assert Enum.any?(metrics, &(&1.name == [:recipe_app, :repo, :query, :total_time]))
    assert Enum.any?(metrics, &(&1.name == [:vm, :memory, :total]))

    assert {:ok, _supervisor} = RecipeAppWeb.Telemetry.init([])
  end

  test "error html maps templates to status messages" do
    assert RecipeAppWeb.ErrorHTML.render("404.html", %{}) == "Not Found"
    assert RecipeAppWeb.ErrorHTML.render("500.html", %{}) == "Internal Server Error"
  end
end
