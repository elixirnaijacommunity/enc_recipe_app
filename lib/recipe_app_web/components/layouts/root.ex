defmodule RecipeAppWebHologram.Layouts.Root do
  use Hologram.Component
  alias Hologram.UI.Runtime

  prop :title, :string, default: "ENC Recipes"
  prop :description, :string, default: "Discover recipes and food culture with ENC Recipes."

  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html lang="en" data-theme="enc">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{@title}</title>
        <meta name="description" content={@description} />
        <link href="/assets/css/app.css" rel="stylesheet">
        <Runtime />
      </head>
      <body>
        <slot />
      </body>
    </html>
    """
  end
end
