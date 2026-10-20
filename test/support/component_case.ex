defmodule RecipeAppWebHologram.ComponentCase do
  use ExUnit.CaseTemplate

  alias Hologram.Server
  alias Hologram.Template.Renderer

  using do
    quote do
      import Hologram.Template, only: [sigil_HOLO: 2]
      import RecipeAppWebHologram.ComponentCase
    end
  end

  def render_markup(template, vars \\ %{}) do
    vars
    |> template.()
    |> Renderer.render_dom(%Renderer.Env{}, %Server{})
    |> elem(0)
  end
end
