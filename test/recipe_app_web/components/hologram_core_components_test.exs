defmodule RecipeAppWebHologram.HologramCoreComponentsTest do
  use RecipeAppWebHologram.ComponentCase, async: false

  alias RecipeAppWebHologram.HologramCoreComponents.{
    Button,
    Card,
    Flash,
    Header,
    Icon,
    Input,
    List,
    NavBar,
    Table
  }

  describe "components tests" do
    test "button test" do
      assert render_markup(~HOLO"""
             <Button class="btn-ghost rounded-full btn-xs sm:btn-sm md:btn-md" type="button">Login</Button>
             """) ==
               ~s'<button type="button" class="btn btn-ghost rounded-full btn-xs sm:btn-sm md:btn-md">
  Login
</button>'
    end

    test "card test" do
      assert render_markup(~HOLO"""
             <Card class="card-dash" title="test" class_figure="hero-beaker"><p>A card component has a figure, a body part, and inside body there are title and actions parts</p><div class="card-actions justify-end"></div></Card>
             """) ==
               ~s'<div class=\"card card-dash\">\n  \n    <figure><span class=\"hero-beaker size-10\"></span></figure>\n  \n  <div class=\"card-body\">\n    \n      <h2 class=\"card-title\">test</h2>\n    \n    <p>A card component has a figure, a body part, and inside body there are title and actions parts</p><div class=\"card-actions justify-end\"></div>\n  </div>\n</div>'
    end

    test "input test" do
      assert render_markup(~HOLO"""
             <Input type="text" class="input-primary rounded-full input-xs sm:input-sm md:input-md" rest={%{placeholder: "Type here"}}/>
             """) ==
               ~s'<input type="text" class="input input-primary rounded-full input-xs sm:input-sm md:input-md" placeholder="Type here" />'
    end

    test "header test" do
      assert render_markup(~HOLO"""
             <Header title="ENC Recipes" subtitle="Our shared ingredients">
               <p class="text-ink-soft">The colors, type, and components that bring our recipes together.</p>      
             </Header>
             """) ==
               ~s'<header class=\"space-y-3\">\n<p class=\"font-mono text-xs text-ink-soft uppercase tracking-widest\">ENC Recipes</p>\n<h1>Our shared ingredients</h1>\n\n  <p class=\"text-ink-soft\">The colors, type, and components that bring our recipes together.</p>      \n\n</header>'
    end

    test "icon test" do
      assert render_markup(~HOLO"""
             <Icon name="hero-fire" class="size-12" />
             """) == ~s'<span class=\"hero-fire size-12\"></span>'
    end

    test "navbar test" do
      assert render_markup(~HOLO"""
             <NavBar class="gap-4 flex-wrap">
             <span class="font-serif text-xl font-semibold flex-1">ENC Recipes</span>
             <span class="text-chili font-semibold">Discover</span>
             <Button class="btn-ghost">Log in</Button>
             <Button class="btn-primary">Create account</Button>
             </NavBar>
             """) ==
               ~s'<nav class=\"navbar gap-4 flex-wrap\">\n  \n<span class=\"font-serif text-xl font-semibold flex-1\">ENC Recipes</span>\n<span class=\"text-chili font-semibold\">Discover</span>\n<button type=\"button\" class=\"btn btn-ghost\">\n  Log in\n</button>\n<button type=\"button\" class=\"btn btn-primary\">\n  Create account\n</button>\n\n</nav>'
    end

    test "flash test" do
      assert render_markup(~HOLO"""
             <Flash title="test" class="">
             testing flash functionality out
             </Flash>
             """) ==
               ~s'<div role=\"alert\" class=\"toast toast-top toast-end z-50 \">\n  <div class=\"alert w-80 sm:w-96 max-w-80 sm:max-w-96 text-wrap alert-info\">\n    <div>\n      \n        <p class=\"font-semibold\">test</p>\n      \n      <p>\ntesting flash functionality out\n</p>\n    </div>\n  </div>\n</div>'
    end

    test "list test" do
      assert render_markup(~HOLO"""
              <List items={[{1,"id 1"},{2,"id 2"}]} />
             """) ==
               ~s'<ul class=\"list \">\n  \n    <li class=\"list-row\">\n      <div class=\"list-col-grow\">\n        <div class=\"font-bold\">1</div>\n        <div>id 1</div>\n      </div>\n    </li>\n  \n    <li class=\"list-row\">\n      <div class=\"list-col-grow\">\n        <div class=\"font-bold\">2</div>\n        <div>id 2</div>\n      </div>\n    </li>\n  \n</ul>'
    end

    test "table test" do
      assert render_markup(~HOLO"""
              <Table headers={["id","name"]} rows={[[1,"1"],[2,"2"],[3,"3"]]} />
             """) ==
               ~s'<table class=\"table table-zebra \">\n  <thead>\n    <tr>\n      \n        <th>id</th>\n      \n        <th>name</th>\n      \n    </tr>\n  </thead>\n  <tbody>\n    \n      <tr>\n        \n          <td>1</td>\n        \n          <td>1</td>\n        \n      </tr>\n    \n      <tr>\n        \n          <td>2</td>\n        \n          <td>2</td>\n        \n      </tr>\n    \n      <tr>\n        \n          <td>3</td>\n        \n          <td>3</td>\n        \n      </tr>\n    \n  </tbody>\n</table>'
    end
  end
end
