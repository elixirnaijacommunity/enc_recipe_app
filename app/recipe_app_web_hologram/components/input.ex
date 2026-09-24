defmodule RecipeAppWebHologram.Components.Input do
  use Hologram.Component

  prop :class, :string, default: ""
  prop :type, :string, default: ""
  prop :rest, :map, default: %{}
  
  def template do
    ~HOLO"""
    <input
    type={@type}
    class="input {@class} rounded-full xs:btn-xs sm:btn-sm md:btn-md lg:btn-md xl:btn-md"
    ...{@rest}/>    
    """
  end  
end
