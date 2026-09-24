defmodule RecipeAppWebHologram.Layouts.Root do
  use Hologram.Component
  alias Hologram.UI.Runtime
  
  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html lang="en" data-theme="light">
     <head>
       <meta charset="utf-8" />
       <title>Recipe App</title>
       <link href="/assets/css/app.css" rel="stylesheet">
       <link href="/assets/js/app.js" type="text/javascript">       
       <Runtime />
     </head>
     <body>
     <slot />
     </body>
    </html>
    """	
  end
end
