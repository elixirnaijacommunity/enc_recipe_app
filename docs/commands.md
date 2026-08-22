# Elixir `mix` Command Reference

`mix` is Elixir's build tool — it handles project creation, dependency management, compiling, testing, releases, and more. Run `mix help` anytime to see the full list for your installed version, or `mix help <task>` for details on one task.

---

## Project Creation

### `mix new`

Creates a new Elixir project with standard folder structure (`lib/`, `test/`, `mix.exs`).

```bash
mix new my_app
```

### `mix new --sup`

Same as above, but generates an OTP application with a supervision tree.

```bash
mix new my_app --sup
```

---

## Dependencies

### `mix deps.get`

Fetches all dependencies listed in `mix.exs`.

```bash
mix deps.get
```

### `mix deps.update`

Updates one or all dependencies to the latest allowed version.

```bash
mix deps.update phoenix
mix deps.update --all
```

### `mix deps.clean`

Removes fetched dependencies (optionally all of them).

```bash
mix deps.clean phoenix
mix deps.clean --all
```

### `mix deps.compile`

Compiles dependencies without recompiling your own app.

```bash
mix deps.compile
```

### `mix deps.tree`

Prints a tree of your dependency graph.

```bash
mix deps.tree
```

### `mix deps.unlock`

Unlocks dependencies so they can be re-resolved (e.g. after editing `mix.exs`).

```bash
mix deps.unlock --all
```

---

## Compiling

### `mix compile`

Compiles the project's source files into `.beam` files.

```bash
mix compile
```

### `mix compile --force`

Forces a full recompile, ignoring cached compilation state.

```bash
mix compile --force
```

### `mix clean`

Deletes compiled artifacts (build cache).

```bash
mix clean
```

---

## Running Code

### `mix run`

Runs the given script/module, starting your application first.

```bash
mix run -e "IO.puts(1 + 1)"
```

### `iex -S mix`

Not a `mix` subcommand technically, but the standard way to boot your app into an interactive shell.

```bash
iex -S mix
```

---

## Testing

### `mix test`

Runs the test suite (files in `test/` ending in `_test.exs`).

```bash
mix test
```

### `mix test path/to/file_test.exs`

Runs a single test file.

```bash
mix test test/my_app/user_test.exs
```

### `mix test --failed`

Reruns only the tests that failed last time.

```bash
mix test --failed
```

### `mix test.watch` (requires `mix_test_watch` dep)

Reruns tests automatically on file changes.

```bash
mix test.watch
```

---

## Code Quality

### `mix format`

Formats code according to `.formatter.exs` rules.

```bash
mix format
```

### `mix format --check-formatted`

Fails (non-zero exit) if any file isn't formatted — useful in CI.

```bash
mix format --check-formatted
```

### `mix credo` (requires `credo` dep)

Runs static code analysis / linting.

```bash
mix credo
```

### `mix dialyzer` (requires `dialyxir` dep)

Runs static type analysis via Dialyzer.

```bash
mix dialyzer
```

### `mix xref`

Analyzes cross-references between modules (e.g. finds unreachable/deprecated calls).

```bash
mix xref unreachable
```

---

## Documentation

### `mix docs` (requires `ex_doc` dep)

Generates HTML/EPUB documentation from `@doc`/`@moduledoc`.

```bash
mix docs
```

---

## Releases & Packaging

### `mix release`

Builds an OTP release (self-contained deployable artifact).

```bash
mix release
```

### `mix escript.build`

Builds an executable script (escript) from your project.

```bash
mix escript.build
```

### `mix hex.publish` (requires Hex account)

Publishes your package to Hex.pm.

```bash
mix hex.publish
```

---

## Environment & Info

### `mix help`

Lists all available Mix tasks.

```bash
mix help
```

### `mix help <task>`

Shows detailed docs for a specific task.

```bash
mix help deps.get
```

### `mix app.tree`

Shows the tree of applications your app depends on (OTP apps, not just Hex deps).

```bash
mix app.tree
```

### `mix local.hex`

Installs/updates the Hex package manager locally.

```bash
mix local.hex
```

### `mix local.rebar`

Installs/updates Rebar (used to build some Erlang deps).

```bash
mix local.rebar
```

### `MIX_ENV=<env> mix <task>`

Not a task itself — sets the environment (`dev`, `test`, `prod`) a task runs under.

```bash
MIX_ENV=prod mix compile
```

---

## Phoenix-Specific (if using Phoenix, via `mix phx.*`)

### `mix phx.new`

Scaffolds a new Phoenix project.

```bash
mix phx.new my_app
```

### `mix phx.server`

Starts the Phoenix server.

```bash
mix phx.server
```

### `mix phx.routes`

Lists all routes defined in the router.

```bash
mix phx.routes
```

### `mix ecto.create`

Creates the configured database.

```bash
mix ecto.create
```

### `mix ecto.migrate`

Runs pending database migrations.

```bash
mix ecto.migrate
```

### `mix ecto.gen.migration <name>`

Generates a new migration file.

```bash
mix ecto.gen.migration add_users_table
```

### `mix ecto.rollback`

Rolls back the most recent migration (or `-n <count>` for more).

```bash
mix ecto.rollback
mix ecto.rollback -n 3
```

### `mix ecto.drop`

Drops the configured database.

```bash
mix ecto.drop
```

### `mix ecto.reset`

Common alias (often defined in `mix.exs`) that drops, recreates, and migrates the database in one go.

```bash
mix ecto.reset
```

### `mix phx.gen.schema`

Generates an Ecto schema module + a migration, without any web-facing code.

```bash
mix phx.gen.schema Accounts.User users name:string email:string
```

### `mix phx.gen.context`

Generates a context module (public API functions) plus the schema and migration behind it.

```bash
mix phx.gen.context Accounts User users name:string email:string
```

### `mix phx.gen.html`

Generates a context, schema, migration, and full HTML CRUD interface (controller, templates, routes reminder).

```bash
mix phx.gen.html Accounts User users name:string email:string
```

### `mix phx.gen.json`

Same as `phx.gen.html`, but generates a JSON API (controller + views) instead of HTML templates.

```bash
mix phx.gen.json Accounts User users name:string email:string
```

### `mix phx.gen.live`

Same as `phx.gen.html`, but generates Phoenix LiveView modules (index/show/form) instead of controller+templates.

```bash
mix phx.gen.live Accounts User users name:string email:string
```

### `mix phx.gen.auth`

Generates a complete, ready-to-use authentication system (registration, login, sessions, tokens).

```bash
mix phx.gen.auth Accounts User users
```

> Note: `phx.gen.*` commands only generate files — they remind you to run `mix ecto.migrate` and to add the generated routes to your router yourself.

---

## Quick Reference Table

| Command               | Meaning                               |
| --------------------- | ------------------------------------- |
| `mix new`             | Create new project                    |
| `mix deps.get`        | Fetch dependencies                    |
| `mix deps.update`     | Update dependencies                   |
| `mix compile`         | Compile the project                   |
| `mix clean`           | Remove compiled artifacts             |
| `mix run`             | Run a script/module                   |
| `mix test`            | Run test suite                        |
| `mix format`          | Auto-format code                      |
| `mix credo`           | Lint code                             |
| `mix dialyzer`        | Type-check code                       |
| `mix docs`            | Generate documentation                |
| `mix release`         | Build a release                       |
| `mix help`            | List/describe tasks                   |
| `mix phx.server`      | Start Phoenix server                  |
| `mix ecto.migrate`    | Run DB migrations                     |
| `mix ecto.rollback`   | Undo last migration                   |
| `mix ecto.reset`      | Drop, recreate, migrate DB            |
| `mix phx.gen.schema`  | Generate schema + migration only      |
| `mix phx.gen.context` | Generate context + schema + migration |
| `mix phx.gen.html`    | Generate context + HTML CRUD          |
| `mix phx.gen.json`    | Generate context + JSON API           |
| `mix phx.gen.live`    | Generate context + LiveView CRUD      |
| `mix phx.gen.auth`    | Generate full auth system             |
| `mix holo`            | Start a hologram app                  |
