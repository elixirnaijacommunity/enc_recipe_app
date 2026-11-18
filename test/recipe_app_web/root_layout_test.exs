defmodule RecipeAppWebHologram.RootLayoutTest do
  use RecipeAppWebHologram.ComponentCase, async: true

  alias RecipeAppWebHologram.Layouts.Root

  test "builds the root document template with configurable metadata" do
    template = Root.template()
    assert is_function(template)

    document =
      template.(%{
        title: "ENC Recipes test",
        description: "Test description"
      })

    assert document
  end
end
