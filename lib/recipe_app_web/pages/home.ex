defmodule RecipeAppWebHologram.Pages.Home do
  use Hologram.Page

  alias RecipeAppWebHologram.HologramCoreComponents.{
    Brand,
    Button,
    Card,
    Icon,
    NavBar,
    RecipeCard
  }

  route "/"

  layout RecipeAppWebHologram.Layouts.Root,
    title: "ENC Recipes — A home for your recipes",
    description:
      "A place built for cooking. Share full recipes, discover food cultures, and find your community with ENC Recipes."

  def init(_params, component, _server) do
    put_state(component,
      year: Date.utc_today().year,
      recipes: [
        %{
          name: "Jollof Rice",
          slug: "jollof",
          time: "45 min",
          difficulty: "MEDIUM",
          cook: "@katorcooks"
        },
        %{
          name: "Suya Skewers",
          slug: "suya",
          time: "30 min",
          difficulty: "EASY",
          cook: "@grillmasterlagos"
        },
        %{
          name: "Egusi Soup",
          slug: "egusi",
          time: "1h 20m",
          difficulty: "HARD",
          cook: "@katorcooks"
        }
      ]
    )
  end

  def template do
    ~HOLO"""
    <div class="enc-home" id="top">
      <a href="#main-content" class="home-skip-link">Skip to content</a>
      <header>
        <NavBar class="home-header">
          <Brand />
          <div class="home-account-actions">
            <Button class="btn-ghost" rest={%{"aria-disabled": true}}>Log in</Button>
            <Button class="btn-primary" rest={%{"aria-disabled": true}}>Create account</Button>
          </div>
        </NavBar>
      </header>

      <main id="main-content" tabindex="-1">
        <section class="home-hero" aria-labelledby="hero-title">
          <div class="home-photo-wrap home-container">
            <img class="home-community-photo" src="/images/home/community-cooking.jpg"
              width="1300" height="316" fetchpriority="high"
              alt="The ENC Recipes community cooking together, with jollof rice, grilled chicken, and plantain" />
          </div>
          <div class="home-hero-content home-container">
            <div class="home-hero-copy">
              <h1 id="hero-title">Recipes get lost in Reels.<br /><span>Not here.</span></h1>
              <p>ENC Recipes is a place built for cooking, not just scrolling — post the full recipe, filter by cook or country, and find dishes people actually made.</p>
              <div class="home-hero-actions">
                <Button class="btn-primary" rest={%{"aria-disabled": true}}>Create free account</Button>
                <a href="#recipes" class="btn btn-ghost">Browse recipes</a>
              </div>
              <p class="home-trust">NO CREDIT CARD · FIRST PHASE: RECIPES + DISCOVERY</p>
            </div>
            <div class="home-recipe-stack" aria-label="Recipe inspiration">
              {%for recipe <- @recipes}
                <div class="home-index-card home-index-{recipe.slug}">
                  <div class="home-index-art"><img src="/images/home/{recipe.slug}.svg" width="56" height="56" alt="" /></div>
                  <div>
                    <h2>{recipe.name}</h2>
                    <p><Icon name="hero-clock" class="size-3" /> {recipe.time} · {recipe.difficulty}</p>
                  </div>
                </div>
              {/for}
            </div>
          </div>
        </section>

        <section id="features" class="home-section home-container" aria-labelledby="features-title">
          <p class="home-eyebrow">What's here</p>
          <h2 id="features-title">Built around two things: posting and finding</h2>
          <div class="home-feature-grid">
            <Card class="home-feature-card">
              <Icon name="hero-book-open" class="size-6 text-chili-action" />
              <h3>Recipe management</h3>
              <p>Full recipes — ingredients, steps, nutrition, tags, cook time and difficulty. Not just a photo.</p>
            </Card>
            <Card class="home-feature-card">
              <Icon name="hero-magnifying-glass" class="size-6 text-chili-action" />
              <h3>Food discovery</h3>
              <p>Filter by dish name, cook, or country, and sort newest or oldest first.</p>
            </Card>
            <Card class="home-feature-card">
              <Icon name="hero-heart" class="size-6 text-ink-soft" />
              <div class="home-feature-heading"><h3>Social layer</h3><span class="home-soon">Coming soon</span></div>
              <p>Following, likes and comments on every recipe post.</p>
            </Card>
            <Card class="home-feature-card">
              <Icon name="hero-fire" class="size-6 text-ink-soft" />
              <div class="home-feature-heading"><h3>Nutrition &amp; AI</h3><span class="home-soon">Coming soon</span></div>
              <p>AI-assisted nutrition breakdowns and personalized meal planning.</p>
            </Card>
          </div>
        </section>

        <section id="recipes" class="home-section home-container" aria-labelledby="recipes-title">
          <p class="home-eyebrow">From the community</p>
          <h2 id="recipes-title">A taste of what's cooking</h2>
          <p class="home-section-intro">A little inspiration for your next recipe. Community posts are coming soon.</p>
          <div class="home-showcase-grid">
            {%for recipe <- @recipes}
              <RecipeCard recipe={recipe} />
            {/for}
          </div>
        </section>

        <section id="join" class="home-join" aria-labelledby="join-title">
          <h2 id="join-title">Start posting your recipes</h2>
          <Button class="btn-primary" rest={%{"aria-disabled": true}}>Create free account</Button>
        </section>
      </main>

      <footer class="home-footer">
        <div class="home-footer-grid home-container">
          <div class="home-footer-brand">
            <Brand />
            <p>A dedicated home for recipes — not lost in someone else's feed.</p>
          </div>
          <div><h2>Company</h2><button type="button" aria-disabled="true">Help &amp; Contact</button></div>
          <div><h2>Legal</h2><button type="button" aria-disabled="true">Terms of Service</button><button type="button" aria-disabled="true">Privacy Policy</button></div>
        </div>
        <p class="home-copyright">© {@year} ENC Recipes · Elixir Nigeria Community</p>
      </footer>

    </div>
    """
  end
end
