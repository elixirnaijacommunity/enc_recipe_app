defmodule RecipeAppWebHologram.Pages.Components do
  use Hologram.Page

  alias RecipeAppWebHologram.HologramCoreComponents.{
    Button,
    Card,
    Icon,
    Input,
    NavBar,
    Header,
    List,
    Table
  }

  route "/components"
  layout RecipeAppWebHologram.Layouts.Root

  def init(_params, component, _server) do
    put_state(component, :palette, [
      {"Ink", "--ink", "bg-ink"},
      {"Ink soft", "--ink-soft", "bg-ink-soft"},
      {"Parchment", "--parchment", "bg-parchment"},
      {"Parchment 2", "--parchment-2", "bg-parchment-2"},
      {"Backdrop", "--bg", "bg-backdrop"},
      {"Panel", "--panel", "bg-panel"},
      {"Chili", "--chili", "bg-chili"},
      {"Chili dark", "--chili-dark", "bg-chili-dark"},
      {"Turmeric", "--turmeric", "bg-turmeric"},
      {"Sage", "--sage", "bg-sage"},
      {"Sage soft", "--sage-soft", "bg-sage-soft"},
      {"White", "--white", "bg-white"},
      {"Line", "--line", "bg-line"}
    ])
  end

  def template do
    ~HOLO"""
    <div class="mx-auto max-w-6xl px-6 py-8 space-y-10">
      <Header title="ENC Recipes" subtitle="Our shared ingredients">
        <p class="text-ink-soft">The colors, type, and components that bring our recipes together.</p>      
      </Header>

      <section aria-labelledby="palette-title" class="space-y-4">
        <h2 id="palette-title">Color palette</h2>
        <div class="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-7 gap-3">
          {%for {label, token, color_class} <- @palette}
            <div class="card overflow-hidden">
              <div class="h-16 {color_class}"></div>
              <div class="p-3 space-y-1">
                <p class="font-semibold">{label}</p>
                <p class="font-mono text-[10.5px] text-ink-soft break-words">{token}</p>
              </div>
            </div>
          {/for}
        </div>
      </section>

      <section aria-labelledby="navigation-title" class="space-y-4">
        <h2 id="navigation-title">Navigation</h2>
        <NavBar class="gap-4 flex-wrap">
          <span class="font-serif text-xl font-semibold flex-1">ENC Recipes</span>
          <span class="text-chili font-semibold">Discover</span>
          <Button class="btn-ghost">Log in</Button>
          <Button class="btn-primary">Create account</Button>
        </NavBar>
      </section>

      <section aria-labelledby="buttons-title" class="space-y-4">
        <h2 id="buttons-title">Buttons</h2>
        <div class="flex flex-wrap items-center gap-3">
          <Button class="btn-primary">Share a recipe</Button>
          <Button class="btn-ghost">Save for later</Button>
          <Button class="btn-link">View recipe</Button>
          <Button class="btn-primary btn-sm">Follow</Button>
          <Button class="btn-primary" rest={%{disabled: true}}>Unavailable</Button>
        </div>
      </section>

      <section aria-labelledby="fields-title" class="space-y-4">
        <h2 id="fields-title">Form fields</h2>
        <div class="grid md:grid-cols-2 gap-6">
          <div class="space-y-2">
            <label for="recipe-name" class="label">Recipe name</label>
            <Input class="w-full" rest={%{id: "recipe-name", placeholder: "Grandma’s jollof rice", "aria-describedby": "recipe-hint"}} />
            <p id="recipe-hint" class="field-hint">Give your dish a name that tells its story.</p>
          </div>
          <div class="space-y-2">
            <label for="recipe-notes" class="label">Cooking notes</label>
            <textarea id="recipe-notes" class="textarea w-full" placeholder="What makes this recipe special?"></textarea>
          </div>
        </div>
        <div class="flex flex-wrap gap-6">
          <label class="flex items-center gap-2"><input type="checkbox" /> Vegetarian</label>
          <fieldset class="flex flex-wrap gap-6">
            <legend class="sr-only">Difficulty</legend>
            <label class="flex items-center gap-2"><input type="radio" name="difficulty" checked /> Easy</label>
            <label class="flex items-center gap-2"><input type="radio" name="difficulty" /> Medium</label>
          </fieldset>
        </div>
      </section>

      <section aria-labelledby="typography-title" class="space-y-4">
        <h2 id="typography-title">Typography</h2>
        <div class="grid md:grid-cols-3 gap-6">
          <div class="space-y-2">
            <p class="font-serif text-2xl font-semibold">A taste of home</p>
            <p class="text-ink-soft">Fraunces for headlines and recipe titles.</p>
          </div>
          <div class="space-y-2">
            <p class="font-sans">Good food starts with a story worth sharing.</p>
            <p class="text-ink-soft">Inter for body text, navigation, and fields.</p>
          </div>
          <div class="space-y-2">
            <p class="recipe-meta">35 MIN · 4 SERVINGS · EASY</p>
            <p class="text-ink-soft">IBM Plex Mono for tags and recipe details.</p>
          </div>
        </div>
      </section>

      <section aria-labelledby="cards-title" class="space-y-4">
        <h2 id="cards-title">Cards and tags</h2>
        <div class="grid md:grid-cols-2 gap-6">
          <Card class="overflow-hidden" title="Smoky party jollof">
            <div class="dish-art rounded-t-box -order-1">
              <Icon name="hero-fire" class="size-12" />
            </div>
            <p class="text-ink-soft">Slow-cooked rice, warm spices, and a little taste of celebration.</p>
            <p class="recipe-meta text-ink-soft">45 MIN · 6 SERVINGS</p>
            <div class="flex flex-wrap gap-2">
              <span class="tag-chip">West African</span>
              <span class="tag-chip">Vegetarian</span>
            </div>
            <div class="card-actions mt-2"><Button class="btn-primary btn-sm">View recipe</Button></div>
          </Card>
          <Card title="A place for every food story">
            <p class="text-ink-soft">Discover recipes, share your favorites, and find your community.</p>
            <div><span class="tag-chip">Coming soon</span></div>
            <div class="nutrition-box p-4 mt-4 space-y-2">
              <h3>Nutrition Facts</h3>
              <p>Per serving</p>
              <p class="border-t border-ink pt-2">Calories 320</p>
            </div>
          </Card>
        </div>
      </section>
      
      <section aria-labelledby="buttons-title" class="space-y-4">
        <h2 id="buttons-title">List</h2>
        <div class="flex flex-wrap items-center gap-3">      
         <List items={[{1,"id 1"},{2,"id 2"}]} />
        </div>
      </section>

      <section aria-labelledby="buttons-title" class="space-y-4">
        <h2 id="buttons-title">Table</h2>
        <div class="flex flex-wrap items-center gap-3">      
         <Table headers={["id","name"]} rows={[[1,"1"],[2,"2"],[3,"3"]]} />
        </div>
      </section>
    </div>
    """
  end
end
