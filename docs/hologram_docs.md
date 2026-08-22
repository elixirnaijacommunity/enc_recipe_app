# Hologram Glossary & Concept Reference

Internal reference for the team. Hologram is **not** Phoenix LiveView — it has its
own template syntax (`~HOLO`), its own component model, and its own state
management. Don't reach for LiveView patterns (`assign`, `phx-click`, `<.link>`,
`handle_event`) — none of them apply here.

---

## Mental model

Hologram apps are built from two building blocks:

- **Pages** — top-level components tied to a route
- **Components** — reusable UI elements, composed inside pages or other components

State lives **in the browser**, not on the server. Hologram compiles the Elixir
code needed to run in the browser into JavaScript automatically — you write
Elixir everywhere, and the framework decides what ships to the client vs. what
stays on the server.

Two kinds of logic drive behavior:

|              | Runs on          | Used for                                                               |
| ------------ | ---------------- | ---------------------------------------------------------------------- |
| **Actions**  | Client (browser) | State updates, navigation, triggering commands — no network round trip |
| **Commands** | Server           | Database access, API calls, session/cookies, anything privileged       |

Actions and commands can trigger each other: an action can dispatch a command,
and a command can dispatch an action back on the client.

---

## Page

A top-level component that owns a route.

```elixir
defmodule MyApp.HomePage do
  use Hologram.Page

  route "/"
  layout MyApp.MainLayout

  def init(_params, component, _server) do
    put_state(component, :message, "Welcome")
  end

  def template do
    ~HOLO"""
    <h1>{@message}</h1>
    """
  end
end
```

Key facts:

- Every page must declare `route "/path"` (supports params: `route "/posts/:id"`).
- Every page must declare a `layout`.
- Pages are always stateful and always initialized server-side via `init/3`,
  which receives **URL params**, not props.
- Use `param :id, :integer` to declare typed route parameters.
- A page's component ID (`cid`) is always the literal string `"page"`.

## Layout

A regular component (`use Hologram.Component`) that wraps every page rendered
with it — there's no special layout macro or module type.

```elixir
defmodule MyApp.MainLayout do
  use Hologram.Component
  alias Hologram.UI.Link
  alias Hologram.UI.Runtime

  def template do
    ~HOLO"""
    <!DOCTYPE html>
    <html>
      <head>
        <Runtime />
      </head>
      <body>
        <nav><Link to={MyApp.HomePage}>Home</Link></nav>
        <slot />
      </body>
    </html>
    """
  end
end
```

Requirements:

- Must include `<Hologram.UI.Runtime />` inside `<head>`.
- Must include `<slot />` where the page's content gets inserted.
- Its `cid` is always the literal string `"layout"`.
- Pages pass it props via `layout MyApp.MainLayout, prop: value`.

## Component

A reusable UI building block (`use Hologram.Component`).

```elixir
defmodule MyApp.Components.PostPreview do
  use Hologram.Component
  prop :post, :map

  def template do
    ~HOLO"""
    <article><h2>{@post.title}</h2></article>
    """
  end
end
```

- Props declared with `prop :name, :type` (optionally `default: value`).
- **Stateful** components need a `cid` attribute (`<MyComponent cid="my_id" />`)
  — only stateful components can handle events (actions/commands).
- **Stateless** components have no `cid` and can't handle events.
- `init/3` (props, component, server) runs once during server-side page render;
  `init/2` (props, component) runs when dynamically added client-side later.
  Both are optional.
- A template is either a `template/0` function using `~HOLO`, or a colocated
  `.holo` file with the same name in the same directory (markup only, no sigil).

## Runtime (`Hologram.UI.Runtime`)

The component that bootstraps Hologram's client-side JS runtime in the page —
required once in every layout's `<head>`. Without it, none of the client
interactivity (actions, events, navigation) works.

## Slot (`<slot />`)

The placeholder in a layout (or any component) where child content — the
current page, or whatever's nested inside the component — gets rendered.
Equivalent role to inner-block patterns elsewhere, but Hologram's own tag,
not HEEx's `<:slot>`.

## Link (`Hologram.UI.Link`)

The component for in-app navigation:

```elixir
<Link to={MyApp.RegisterPage}>Register</Link>
<Link to={MyApp.PostPage, id: 123}>Read more</Link>
```

Renders a real link, prefetches the target page on `$pointer_down` (so the
click feels instant), and keeps browser history/back-forward working
automatically. For navigating from inside an action instead of a template,
use `put_page/2` or `put_page/3` (see **Actions**).

## Action

Client-side event handler logic, defined on a page or stateful component:

```elixir
def action(:increment, _params, component) do
  put_state(component, :count, component.state.count + 1)
end
```

- Must return a `%Component{}` struct — chain updates with `|>`.
- Common operations: `put_state/2,3` (update state), `put_command/2,3`
  (trigger a server command), `put_page/2,3` (navigate), `put_context/3`
  (share data downward), `put_action/2,3` (chain another action, optionally
  with `delay:`).

## Command

Server-side logic, defined the same way but dispatched from the client:

```elixir
def command(:save_user, params, server) do
  case MyApp.Accounts.register_user(params) do
    {:ok, _user} -> put_action(server, :registered)
    {:error, cs} -> put_action(server, :registration_failed, message: "...")
  end
end
```

- Must return a `%Server{}` struct — chain with `|>`.
- Always run asynchronously.
- The only place to safely touch the database, external APIs, sessions, or
  cookies.
- Can trigger a client action in response via `put_action(server, ...)`.

## Events

Bound in templates with a `$`-prefixed attribute:

```elixir
<button $click="save">Save</button>
<input $change="email_changed" value={@email} />
<form $submit="register">...</form>
```

- Covers clicks, keyboard, pointer, scroll, resize, focus/blur, form change/
  submit, and more (`$click_outside`, `$reach_bottom`, `$key_down.ctrl+k`, etc.).
- Shorthand: `$click="action_name"`. With params: `$click={:action_name, id: 1}`.
  Longhand (works for actions _or_ commands): `$click={action: :name, target: "cid", params: %{...}}`.
- Modifiers compose onto the event name: `debounce(ms)`, `throttle(ms)`,
  `once`, `stop_propagation`, `prevent_default`, `allow_default`, plus key
  filters like `.enter` or `.ctrl+k`.
- `params.event` inside the handler carries the event's data (e.g. the input's
  new `value`, or the full form map on `$submit`).

## Forms

Built with plain HTML `<form>`/`<input>`/`<select>`/`<textarea>` — no Phoenix
form helpers.

- **Synchronized inputs**: `value={@state_var}` + `$change="handler"` on the
  input — component state is the single source of truth, updated on every
  keystroke.
- **Non-synchronized inputs**: no `$change` on the input itself; read all
  field values at once from `params.event` in a form-level `$change` or
  `$submit` handler.
- Validation logic (including Ecto changesets) is isomorphic — the same
  Elixir code can run client-side for instant feedback and server-side (in a
  command) for real enforcement.

## Context

A way to share data down the component tree without prop-drilling it through
every intermediate component — not a global store.

```elixir
put_context(component, :current_user, user)   # in an action or init
prop :user, :map, from_context: :current_user  # in a descendant component
```

Available to all descendants of the component that set it — not to siblings
or ancestors. Prefer plain props for direct parent → child data; reach for
context only when data needs to skip several levels.

## Middleware

Reusable server-side logic that runs before a page's `init/3` or before a
command executes — for auth, authorization, rate limiting, audit logging.
Not Phoenix `Plug`.

- Three forms: an inline function (`middleware :name` + a `def name/2` on the
  same module), a **leaf** module (`use Hologram.Middleware`, defines
  `call/2`), or a **composite** module that chains other middleware.
- Every middleware receives and returns the same `%Server{}` struct as
  `init/3` and commands.
- Stops the chain by setting a status: `put_status(server, :forbidden)` or
  redirecting with `put_redirect(server, MyApp.LoginPage)`.
- `put_user_id/2` / `delete_user_id/1` is the canonical login/logout
  mechanism (persisted to session).

## Session

Server-side, secure, **not** readable by client code. Use inside `init/3` or
commands only: `get_session/2,3`, `put_session/3`, `delete_session/2`. Keys
are atoms or strings (interchangeable).

## Cookies

Server-managed but readable by the browser. Use inside `init/3` or commands
only: `get_cookie/2,3`, `put_cookie/3,4`, `delete_cookie/2`. Keys must be
**strings**. Secure by default (`http_only: true`, `secure: true`,
`same_site: :lax`).

## Realtime

Lets server-side code push an action to connected clients without polling —
not Phoenix Channels or `PubSub` directly.

- Inside a handler (`init/3` / a command): `put_subscription`,
  `put_broadcast`, `put_broadcast_except` on the `server` struct — deferred
  until the handler succeeds.
- Outside a handler (background jobs, workers): `Hologram.Realtime.subscribe`,
  `broadcast_action`, etc. — fire immediately.
- Channels are structured values, not topic strings: `:notifications`,
  `{:room, 42}`, `{:user, user_id}`.

## JavaScript Interop

For the rare case you need an actual JS library. `use Hologram.JS`, then
`js_import`, `JS.call/2,3`, `JS.new/2`, `JS.get/set/delete`, `JS.eval/1`,
`~JS"""..."""`. Only works inside client-side action handlers — a no-op
during server-side rendering.

---

## Quick pitfall checklist

- No HEEx (`<%= %>`, `phx-click`, `<.component>`, `to_form`) — use `~HOLO`,
  `$click`, `<MyComponent />`, plain HTML form elements.
- Actions use `put_state`, not `assign`; read state as `component.state.key`.
- Commands return `%Server{}`, not `{:noreply, socket}`.
- Session keys: atoms/strings. Cookie keys: strings only.
- `init/3` on a **page** gets URL params. `init/3` on a **component** gets
  props. Don't mix these up.
- Stateless components (no `cid`) can't handle events.

---

Sources: hologram.page docs (Architecture, Components, Pages, Layouts, Events,
Forms, Navigation, Commands) and the project's `usage-rules.md`.
