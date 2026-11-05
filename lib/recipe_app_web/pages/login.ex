defmodule RecipeAppWebHologram.Pages.Login do
  use Hologram.Page

  alias Hologram.UI.Link
  alias RecipeApp.Accounts
  alias RecipeAppWebHologram.Pages.{ForgotPassword, Home, Register}
  alias RecipeAppWebHologram.HologramCoreComponents.{Brand, Button, Input, PasswordField}

  route "/login"
  layout RecipeAppWebHologram.Layouts.Root, title: "Log in — ENC Recipes"

  def init(_params, component, _server) do
    component
    |> put_state(:error, "")
    |> put_state(:loading, false)
  end

  def command(:login, params, server) do
    fields = params.event

    case Accounts.authenticate_user(Map.get(fields, "email", ""), Map.get(fields, "password", "")) do
      {:ok, user} ->
        server
        |> put_user_id(user.id)
        |> put_session(:auth_version, user.auth_version)
        |> put_action(:login_succeeded)

      {:error, :email_not_verified} ->
        put_action(server, :login_failed, message: "Please verify your email before logging in.")

      {:error, _reason} ->
        put_action(server, :login_failed, message: "Invalid email or password.")
    end
  end

  def action(:submit_login, params, component) do
    if component.state.loading do
      component
    else
      component
      |> put_state(:loading, true)
      |> put_command(:login, event: params.event)
    end
  end

  def action(:login_failed, params, component) do
    component
    |> put_state(:loading, false)
    |> put_state(:error, params.message)
  end

  def action(:login_succeeded, _params, component) do
    component
    |> put_state(:loading, false)
    |> put_page(Home)
  end

  def template do
    ~HOLO"""
    <div class="auth-page">
      <header class="auth-header">
        <Brand />
        <p>New here? <Link to={register_page()}>Create account</Link></p>
      </header>
      <main class="auth-main">
        <section class="auth-panel" aria-labelledby="auth-title">
          <h1 id="auth-title">Welcome back</h1>
          {%if @error != ""}<p class="auth-alert" role="alert">{@error}</p>{/if}
          <form $submit="submit_login" class="auth-form">
            <div class="auth-field">
              <label for="email">Email</label>
              <Input class="auth-input" rest={%{id: "email", name: "email", type: "email", placeholder: "you@email.com", autocomplete: "email", required: true}} />
            </div>
            <PasswordField cid="login-password" id="password" name="password" label="Password" />
            <div class="auth-forgot"><Link to={forgot_password_page()}>Forgot password?</Link></div>
            <Button type="submit" class="auth-submit" loading={@loading} loading_text="Logging in...">Log in</Button>
          </form>
        </section>
      </main>
    </div>
    """
  end

  defp register_page do
    _ = Register.__params__()
    _ = Register.__route__()
    Register
  end

  defp forgot_password_page do
    _ = ForgotPassword.__params__()
    _ = ForgotPassword.__route__()
    ForgotPassword
  end
end
