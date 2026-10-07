defmodule RecipeAppWebHologram.HologramCoreComponentsTest do
  use RecipeAppWebHologram.ComponentCase, async: false
  alias RecipeAppWebHologram.HologramCoreComponents.{Button, Card, Flash, Header, Icon, Input, List, NavBar, Table}

  describe "components tests" do
    test "button test" do
      assert render_markup(~HOLO"""
      <Button class="btn-ghost" type="button">Login</Button>
      """) ==  ~s'<button type="button" class="btn btn-ghost rounded-full btn-xs sm:btn-sm md:btn-md">
  Login
</button>'
    end

    test "card test" do
      assert render_markup(~HOLO"""
      <Card class="card-dash" title="test" class_figure="hero-beaker"><p>A card component has a figure, a body part, and inside body there are title and actions parts</p><div class="card-actions justify-end"></div></Card>
      """) == ~s'<div class=\"card card-dash\">\n  \n    <figure><span class=\"hero-beaker size-10\"></span></figure>\n  \n  <div class=\"card-body\">\n    \n      <h2 class=\"card-title\">test</h2>\n    \n    <p>A card component has a figure, a body part, and inside body there are title and actions parts</p><div class=\"card-actions justify-end\"></div>\n  </div>\n</div>'
    end

    test "input test" do
      assert render_markup(~HOLO"""
      <Input type="text" class="input-primary" rest={%{placeholder: "Type here"}}/>
      """) == ~s'<input type="text" class="input input-primary rounded-full input-xs sm:input-sm md:input-md" placeholder="Type here" />'
    end
  end  
end
