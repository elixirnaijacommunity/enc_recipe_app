defmodule RecipeAppWebHologram.Pages.HomeTest do
  use RecipeApp.DataCase, async: true

  import RecipeAppWebHologram.ComponentCase, only: [render_markup: 2]

  alias Hologram.{Component, Server}
  alias RecipeApp.Accounts
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
    assert markup =~ ~s(href="/login")
    refute markup =~ "popovertarget"
    refute markup =~ ~s(role="dialog")
  end

  test "shows login actions to visitors", %{markup: markup} do
    assert markup =~ ~s(href="/login")
    assert markup =~ ~s(href="/register")
    assert markup =~ "Create free account"
    refute markup =~ "Log out"
  end

  test "loads the authenticated user from Hologram's user identity" do
    assert {:ok, user} =
             Accounts.register_user(%{
               "username" => "katorcooks",
               "email" => "katorcooks@example.com",
               "password" => "secure-password"
             })

    component = Home.init(%{}, %Component{}, %Server{user_id: user.id})
    markup = render_markup(Home.template(), component.state)

    assert component.state.current_user.username == "katorcooks"
    assert markup =~ "Hi, katorcooks"
    assert markup =~ "Log out"
    assert markup =~ "Browse recipes"
    refute markup =~ "Create free account"
    refute markup =~ "Start posting your recipes"
    refute markup =~ ~s(href="/login")
    refute markup =~ ~s(href="/register")
  end

  test "logout clears the authenticated identity and updates the navbar" do
    component = Home.init(%{}, %Component{}, %Server{user_id: 123})
    component = Home.action(:submit_logout, %{}, component)

    assert component.state.logging_out

    server = Home.command(:logout, %{}, %Server{user_id: 123})
    assert server.user_id == nil

    component = Home.action(:logout_succeeded, %{}, component)
    refute component.state.logging_out
    assert component.state.current_user == nil

    markup = render_markup(Home.template(), component.state)
    assert markup =~ ~s(href="/login")
    assert markup =~ ~s(href="/register")
    refute markup =~ "Log out"
  end

  test "serves the reference artwork from local static assets", %{markup: markup} do
    for [path] <- Regex.scan(~r|src="(/images/[^"]+)"|, markup, capture: :all_but_first) do
      assert File.exists?("priv/static" <> path), "Missing homepage image: #{path}"
    end

    assert markup =~ ~s(width="1300" height="316")
    refute markup =~ "data:image/"
  end
end
