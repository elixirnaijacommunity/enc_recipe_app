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
    |> put_state(:cooldown_seconds, 0)
  end

  def command(:request_reset, params, server) do
    {:ok, cooldown_seconds} =
      Accounts.request_password_reset(Map.get(params.event, "email", ""))

    put_action(server, :reset_requested, cooldown_seconds: cooldown_seconds)
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

  def action(:reset_requested, params, component) do
    component
    |> put_state(:loading, false)
    |> put_state(:submitted, true)
    |> put_state(:cooldown_seconds, params.cooldown_seconds)
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
            <div class="auth-success auth-reset-confirmation" data-reset-confirmation role="status">
              <strong>Request received</strong>
              <p>If an account exists for that email, you'll receive an email with instructions to reset your password.</p>
              <p>Please check your inbox and spam folder.</p>
            </div>
          {/if}
          <form id="forgot-password-form" $submit="submit_reset_request" class="auth-form">
            <div class="auth-field">
              <label for="email">Email</label>
              <Input class="auth-input" rest={%{id: "email", name: "email", type: "email", placeholder: "you@email.com", autocomplete: "email", required: true}} />
            </div>
            {%if @cooldown_seconds > 0}
              <Button type="submit" class="auth-submit cursor-not-allowed" loading={@loading} loading_text="Sending reset link..." disabled={true}>Send reset link</Button>
            {%else}
              <Button type="submit" class="auth-submit" loading={@loading} loading_text="Sending reset link..." disabled={@loading}>Send reset link</Button>
            {/if}
            {%if @cooldown_seconds > 0}
              <p class="auth-cooldown" role="status">You can request another email in <strong id="reset-countdown" data-reset-countdown={@cooldown_seconds}>{format_cooldown(@cooldown_seconds)}</strong>.</p>
            {/if}
          </form>
          <Link to={login_page()} class="auth-back-link">Back to log in</Link>
        </section>
      </main>
    </div>
    """
  end

  defp format_cooldown(seconds) do
    minutes = div(seconds, 60)
    remaining_seconds = rem(seconds, 60)

    "#{String.pad_leading(Integer.to_string(minutes), 2, "0")}:#{String.pad_leading(Integer.to_string(remaining_seconds), 2, "0")}"
  end

  defp login_page do
    _ = Login.__params__()
    _ = Login.__route__()
    Login
  end
end
