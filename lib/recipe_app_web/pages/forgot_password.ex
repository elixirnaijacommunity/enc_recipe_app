defmodule RecipeAppWebHologram.Pages.ForgotPassword do
  use Hologram.Page

  alias Hologram.UI.Link
  alias RecipeApp.Accounts
  alias RecipeAppWebHologram.Pages.Login
  alias RecipeAppWebHologram.HologramCoreComponents.{Brand, Button, Input}

  route "/forgot-password"
  layout RecipeAppWebHologram.Layouts.Root, title: "Reset your password — ENC Recipes"

  def init(_params, component, _server) do
    component
    |> put_state(:submitted, false)
    |> put_state(:loading, false)
  end

  def command(:request_reset, params, server) do
    Accounts.request_password_reset(Map.get(params.event, "email", ""))
    put_action(server, :reset_requested)
  end

  def action(:submit_reset_request, params, component) do
    if component.state.loading do
      component
    else
      component
      |> put_state(:loading, true)
      |> put_command(:request_reset, event: params.event)
    end
  end

  def action(:reset_requested, _params, component) do
    component
    |> put_state(:loading, false)
    |> put_state(:submitted, true)
  end

  def template do
    ~HOLO"""
    <div class="auth-page">
      <header class="auth-header"><Brand /></header>
      <main class="auth-main">
        <section class="auth-panel auth-panel-centered" aria-labelledby="auth-title">
          <h1 id="auth-title">Reset your password</h1>
          <p class="auth-description">Enter the email on your account and we'll send a link to reset it.</p>
          {%if @submitted}
            <p class="auth-success" role="status">If an account exists for that email, we'll send a password reset link shortly.</p>
          {%else}
            <form $submit="submit_reset_request" class="auth-form">
              <div class="auth-field">
                <label for="email">Email</label>
                <Input class="auth-input" rest={%{id: "email", name: "email", type: "email", placeholder: "you@email.com", autocomplete: "email", required: true}} />
              </div>
              <Button type="submit" class="auth-submit" loading={@loading} loading_text="Sending reset link...">Send reset link</Button>
            </form>
          {/if}
          <Link to={login_page()} class="auth-back-link">Back to log in</Link>
        </section>
      </main>
    </div>
    """
  end

  defp login_page do
    _ = Login.__params__()
    _ = Login.__route__()
    Login
  end
end
