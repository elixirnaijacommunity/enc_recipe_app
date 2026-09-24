defmodule RecipeAppWebHologram.Components.Button do
  use Hologram.Component

  prop :class, :string, default: ""
  prop :type, :string, default: ""
  prop :rest, :map, default: %{}
  
  def template do
    ~HOLO"""
    <button type={@type}
    class="btn {@class} rounded-full xs:btn-xs sm:btn-sm md:btn-md lg:btn-md xl:btn-md"
    ...{@rest}>
    <slot />
    </button>
    """
  end  
end
