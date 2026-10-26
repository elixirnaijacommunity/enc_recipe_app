defmodule RecipeAppWebHologram.Pages.HomeTest do
  use RecipeAppWebHologram.ComponentCase, async: true

  alias Hologram.{Component, Server}
  alias RecipeAppWebHologram.Pages.Home

  setup do
    component = Home.init(%{}, %Component{}, %Server{})
    markup = render_markup(Home.template(), component.state)
    {:ok, markup: markup}
  end

  test "renders the homepage's main content and recipe inspiration", %{markup: markup} do
    assert markup =~ "Recipes get lost in Reels."
    assert markup =~ "Built around two things: posting and finding"
    assert markup =~ "Community posts are coming soon."
    assert markup =~ "Jollof Rice"
    assert markup =~ "Suya Skewers"
    assert markup =~ "Egusi Soup"
    refute markup =~ "Peace of mind from prototype to production"
  end

  test "navigation stays within the homepage", %{markup: markup} do
    ids = Regex.scan(~r/\bid="([^"]+)"/, markup, capture: :all_but_first) |> List.flatten()

    for [target] <- Regex.scan(~r/href="#([^"]+)"/, markup, capture: :all_but_first) do
      assert target in ids, "Missing anchor target: #{target}"
    end

    assert markup =~ "Skip to content"
    refute markup =~ ~s(href="/signup")
    refute markup =~ ~s(href="/login")
    refute markup =~ "popovertarget"
    refute markup =~ ~s(role="dialog")
  end

  test "serves the reference artwork from local static assets", %{markup: markup} do
    for [path] <- Regex.scan(~r|src="(/images/[^"]+)"|, markup, capture: :all_but_first) do
      assert File.exists?("priv/static" <> path), "Missing homepage image: #{path}"
    end

    assert markup =~ ~s(width="1300" height="316")
    refute markup =~ "data:image/"
  end
end
