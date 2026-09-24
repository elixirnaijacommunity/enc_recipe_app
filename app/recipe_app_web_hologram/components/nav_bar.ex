defmodule RecipeAppWebHologram.Components.NavBar do
  use Hologram.Component

  prop :class, :string, default: ""  

  def template do
    ~HOLO"""
    <div class="navbar {@class}">
    <slot />    
    </div>
    """
  end  
end
