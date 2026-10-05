defmodule RecipeAppWebHologram.Pages.Components do
  use Hologram.Page
  alias RecipeAppWebHologram.CoreComponents.{Button, Card, Input, NavBar}

  route "/components"
  layout RecipeAppWebHologram.Layouts.Root

  def init(_params, component, _server) do
    put_state(component, :data, [])
  end

  def template do
    ~HOLO"""
    <div class="container mx-auto">
    <article class="my-4">
    <h1>Welcome to components Page</h1>
    <p>you can view various components styles here</p>
    </article>

    <!-- Navbar  -->
    <NavBar class="bg-base-100 shadow-sm">
    <div class="navbar-start">
    <div class="flex-none">
    <button class="btn btn-square btn-ghost" aria-label="Open menu">
    <svg data-slot="icon" fill="none" stroke-width="1.5" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
    <path stroke-linecap="round" stroke-linejoin="round" d="M12 8.25v-1.5m0 1.5c-1.355 0-2.697.056-4.024.166C6.845 8.51 6 9.473 6 10.608v2.513m6-4.871c1.355 0 2.697.056 4.024.166C17.155 8.51 18 9.473 18 10.608v2.513M15 8.25v-1.5m-6 1.5v-1.5m12 9.75-1.5.75a3.354 3.354 0 0 1-3 0 3.354 3.354 0 0 0-3 0 3.354 3.354 0 0 1-3 0 3.354 3.354 0 0 0-3 0 3.354 3.354 0 0 1-3 0L3 16.5m15-3.379a48.474 48.474 0 0 0-6-.371c-2.032 0-4.034.126-6 .371m12 0c.39.049.777.102 1.163.16 1.07.16 1.837 1.094 1.837 2.175v5.169c0 .621-.504 1.125-1.125 1.125H4.125A1.125 1.125 0 0 1 3 20.625v-5.17c0-1.08.768-2.014 1.837-2.174A47.78 47.78 0 0 1 6 13.12M12.265 3.11a.375.375 0 1 1-.53 0L12 2.845l.265.265Zm-3 0a.375.375 0 1 1-.53 0L9 2.845l.265.265Zm6 0a.375.375 0 1 1-.53 0L15 2.845l.265.265Z"></path>
    </svg>
    </button>
    </div>
    <div class="flex-1">
    <a class="btn btn-ghost text-xl">Enc Recipes</a>
    </div>
    </div>
    <div class="navbar-center">
    <ul tabindex="-1" class="menu menu-horizontal px-2">
    <li><a>Home</a></li>
    <li><a>Receipts</a></li>
    <li><a>Share</a></li>
    <li><a>Discover</a></li>
    </ul>
    </div>
    <div class="navbar-end">
    <Button class="btn-ghost" type="button">Login</Button>
    <Button class="btn-primary" type="button">Create Account</Button>
    </div>
    </NavBar>

    <!-- Buttons -->
    <h3 class="my-4">Buttons</h3>
    <div class="my-4">
    <Button class="btn-primary" type="button">Button</Button>
    </div>

    <!-- Input -->
    <h3 class="my-4">Input</h3>
    <div class="my-4">
    <div class="my-4">
    <Input type="text" class="input-primary" rest={%{placeholder: "Type here"}}/>
    </div>
    <div class="my-4">
    <Input type="datetime-local" class="input-primary" rest={%{placeholder: "Type here"}}/>
    </div>
    </div>

    <!-- Typography -->
    <h3 class="my-4">Typography</h3>
    <div class="my-4">
    <!-- Font Family -->
    <p class="font-sans">Tailwind is awesome</p>
    <p class="font-serif">Tailwind is awesome</p>
    <p class="font-mono">Tailwind is awesome</p>

    <!-- Font Size -->
    <p class="text-xs">Tailwind is awesome</p>
    <p class="text-sm">Tailwind is awesome</p>
    <p class="text-base">Tailwind is awesome</p>
    <p class="text-lg">Tailwind is awesome</p>
    <p class="text-xl">Tailwind is awesome</p>
    <p class="text-2xl">Tailwind is awesome</p>

    <!-- Font Weight -->
    <p class="font-light">Tailwind is awesome</p>
    <p class="font-normal">Tailwind is awesome</p>
    <p class="font-medium">Tailwind is awesome</p>
    <p class="font-semibold">Tailwind is awesome</p>
    <p class="font-bold">Tailwind is awesome</p>
    </div>

    <!-- Card -->
    <h3 class="my-4">Card</h3>
    <div class="my-4">
    <Card class="card-dash" title="test" class_figure="hero-beaker">
    <p>A card component has a figure, a body part, and inside body there are title and actions parts</p>
    <div class="card-actions justify-end">
    </div>
    </Card>
    </div>

    </div>
    """
  end
end
