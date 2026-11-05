defmodule RecipeAppWeb.LayoutsTest do
  use RecipeAppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias RecipeAppWeb.Layouts

  test "renders the application layout and inner content" do
    markup =
      render_component(&Layouts.app/1, %{
        flash: %{},
        inner_block: [
          %{inner_block: fn _assigns, _ -> "Layout content" end}
        ]
      })

    assert markup =~ ~s(class="navbar)
    assert markup =~ "phoenixframework.org"
    assert markup =~ "github.com/phoenixframework/phoenix"
    assert markup =~ "Get Started"
    assert markup =~ "Layout content"
    assert markup =~ ~s(id="flash-group")
  end

  test "renders flash group with a customizable id" do
    markup =
      render_component(&Layouts.flash_group/1, %{
        flash: %{},
        id: "test-flashes"
      })

    assert markup =~ ~s(id="test-flashes")
    assert markup =~ ~s(aria-live="polite")
    assert markup =~ "client-error"
    assert markup =~ "server-error"
  end
end
