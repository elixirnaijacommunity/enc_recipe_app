defmodule RecipeAppWebHologram.Layouts.Root do
  use Hologram.Component
  alias Hologram.UI.Runtime

  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html lang="en" data-theme="light">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Recipe App</title>
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
