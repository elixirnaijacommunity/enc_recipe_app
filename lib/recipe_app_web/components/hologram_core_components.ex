defmodule RecipeAppWebHologram.HologramCoreComponents do
  @moduledoc """
  Core UI components for Hologram (daisyUI + Tailwind).
  Hologram needs one module per component, so they are nested here.

  Usage in a page or component:

      alias RecipeAppWebHologram.HologramCoreComponents.{
        Button, Card, Flash, Header, Icon, Input, List, NavBar, Table
      }
  """

  defmodule Icon do
    use Hologram.Component

    prop :name, :string
    prop :class, :string, default: "size-4"

    def template do
      ~HOLO"""
      <span class="{@name} {@class}"></span>
      """
    end
  end

  defmodule Button do
    use Hologram.Component

    prop :type, :string, default: "button"
    prop :class, :string, default: ""
    prop :rest, :map, default: %{}

    def template do
      ~HOLO"""
      <button type={@type}
        class="btn {@class}"
        ...{@rest}>
        <slot />
      </button>
      """
    end
  end

  defmodule Input do
    use Hologram.Component

    prop :type, :string, default: "text"
    prop :class, :string, default: ""
    prop :rest, :map, default: %{}

    def template do
      ~HOLO"""
      <input
        type={@type}
        class="input {@class}"
        ...{@rest} />
      """
    end
  end

  defmodule NavBar do
    use Hologram.Component

    prop :class, :string, default: ""

    def template do
      ~HOLO"""
      <nav class="navbar {@class}">
        <slot />
      </nav>
      """
    end
  end

  defmodule Card do
    use Hologram.Component

    prop :class, :string, default: ""
    prop :title, :string, default: ""
    prop :class_figure, :string, default: ""
    prop :rest, :map, default: %{}

    def template do
      ~HOLO"""
      <div class="card {@class}" ...{@rest}>
        {%if @class_figure != ""}
          <figure><span class="{@class_figure} size-10"></span></figure>
        {/if}
        <div class="card-body">
          {%if @title != ""}
            <h2 class="card-title">{@title}</h2>
          {/if}
          <slot />
        </div>
      </div>
      """
    end
  end

  defmodule Flash do
    use Hologram.Component

    prop :kind, :string, default: "info"
    prop :title, :string, default: ""
    prop :class, :string, default: ""
    prop :rest, :map, default: %{}

    def template do
      ~HOLO"""
      <div role="alert" class="toast toast-top toast-end z-50 {@class}" ...{@rest}>
        <div class="alert w-80 sm:w-96 max-w-80 sm:max-w-96 text-wrap alert-{@kind}">
          <div>
            {%if @title != ""}
              <p class="font-semibold">{@title}</p>
            {/if}
            <p><slot /></p>
          </div>
        </div>
      </div>
      """
    end
  end

  defmodule Header do
    use Hologram.Component

    prop :title, :string, default: ""
    prop :subtitle, :string, default: ""
    prop :class, :string, default: ""

    def template do
      ~HOLO"""
      <header class="space-y-3">
      <p class="font-mono text-xs text-ink-soft uppercase tracking-widest">{@title}</p>
      <h1>{@subtitle}</h1>
      <slot />
      </header>
      """
    end
  end

  defmodule Table do
    use Hologram.Component

    prop :headers, :list, default: []
    prop :rows, :list, default: []
    prop :class, :string, default: ""

    def template do
      ~HOLO"""
      <table class="table table-zebra {@class}">
        <thead>
          <tr>
            {%for header <- @headers}
              <th>{header}</th>
            {/for}
          </tr>
        </thead>
        <tbody>
          {%for row <- @rows}
            <tr>
              {%for cell <- row}
                <td>{cell}</td>
              {/for}
            </tr>
          {/for}
        </tbody>
      </table>
      """
    end
  end

  defmodule List do
    use Hologram.Component

    prop :items, :list, default: []
    prop :class, :string, default: ""

    def template do
      ~HOLO"""
      <ul class="list {@class}">
        {%for {title, value} <- @items}
          <li class="list-row">
            <div class="list-col-grow">
              <div class="font-bold">{title}</div>
              <div>{value}</div>
            </div>
          </li>
        {/for}
      </ul>
      """
    end
  end
end
