defmodule RecipeAppWebHologram.Pages.ComponentsTest do
  use RecipeAppWebHologram.ComponentCase, async: true

  alias Hologram.{Component, Server}
  alias RecipeAppWebHologram.Pages.Components

  test "initializes the complete design token palette" do
    component = Components.init(%{}, %Component{}, %Server{})

    assert length(component.state.palette) == 13
    assert {"Ink", "--ink", "bg-ink"} in component.state.palette
    assert {"Chili", "--chili", "bg-chili"} in component.state.palette
    assert {"Sage", "--sage", "bg-sage"} in component.state.palette
  end

  test "renders the component showcase sections" do
    component = Components.init(%{}, %Component{}, %Server{})
    markup = render_markup(Components.template(), component.state)

    for section <- [
          "Color palette",
          "Navigation",
          "Buttons",
          "Form fields",
          "Typography",
          "Cards and tags",
          "Nutrition Facts",
          "Table"
        ] do
      assert markup =~ section
    end

    assert markup =~ "Grandma’s jollof rice"
    assert markup =~ "Unavailable"
    assert markup =~ "ENC Recipes"
  end

  test "exposes route metadata" do
    assert Components.__route__() == "/components"
    assert Components.__params__() == []
  end
end
