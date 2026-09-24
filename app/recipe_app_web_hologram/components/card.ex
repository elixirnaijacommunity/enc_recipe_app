defmodule RecipeAppWebHologram.Components.Card do
  use Hologram.Component

  prop :class, :string, default: ""
  prop :title, :string, default: ""  
  prop :rest, :map, default: %{}
  prop :type, :string, default: ""
  prop :class_figure, :string, default: ""  
  
  def template do
    ~HOLO"""
    <div class="card {@class} bg-base-100 w-96 shadow-sm" ...{@rest}>
    <figure><span class="{@class_figure}"/></figure>
    <div class="card-body">
    <h2 class="card-title">{@title}</h2>    
    <slot />
    </div>
    </div>    
    """
  end
end
