defmodule RecipeAppWebHologram.Pages.ResetPassword do
  use Hologram.Page

  alias Hologram.UI.Link
  alias RecipeApp.Accounts
  alias RecipeAppWebHologram.Pages.Login
  alias RecipeAppWebHologram.HologramCoreComponents.{Brand, Button, PasswordField}

  route "/reset-password"
  layout RecipeAppWebHologram.Layouts.Root, title: "Choose a new password — ENC Recipes"

  def init(params, component, server) do
    token = Map.get(server.query, "token") || Map.get(params, "token", "")

    component
    |> put_state(:token, token)
    |> put_state(:error, "")
    |> put_state(:loading, false)
  end

  def command(:reset_password, params, server) do
    fields = params.event

    if Map.get(fields, "password", "") != Map.get(fields, "password_confirmation", "") do
      put_action(server, :reset_failed, message: "Your passwords do not match.")
    else
      case Accounts.reset_password(Map.get(fields, "token", ""), Map.get(fields, "password", "")) do
        {:ok, _user} ->
          put_action(server, :reset_succeeded)

        {:error, %Ecto.Changeset{}} ->
          put_action(server, :reset_failed,
            message: "Your password must contain at least 8 characters."
          )

        {:error, :invalid_token} ->
          put_action(server, :reset_failed,
            message: "This reset link is invalid or has expired. Request a new one."
          )
      end
    end
  end

  def action(:submit_password_reset, params, component) do
    if component.state.loading do
      component
    else
      component
      |> put_state(:loading, true)
      |> put_command(:reset_password, event: params.event)
    end
  end

  def action(:reset_failed, params, component) do
    component
    |> put_state(:loading, false)
    |> put_state(:error, params.message)
  end

  def action(:reset_succeeded, _params, component) do
    component
    |> put_state(:loading, false)
    |> put_page(Login)
  end

  def template do
    ~HOLO"""
    <div class="auth-page">
      <header class="auth-header"><Brand /></header>
      <main class="auth-main">
        <section class="auth-panel" aria-labelledby="auth-title">
          <h1 id="auth-title">Choose a new password</h1>
          {%if @error != ""}<p class="auth-alert" role="alert">{@error}</p>{/if}
          <form $submit="submit_password_reset" class="auth-form">
            <input type="hidden" name="token" value={@token} />
            <PasswordField cid="new-password" id="password" name="password" label="New password" hint="Use 8 or more characters." />
            <PasswordField cid="new-password-confirmation" id="password-confirmation" name="password_confirmation" label="Confirm password" />
            <Button type="submit" class="auth-submit" loading={@loading} loading_text="Updating password...">Update password</Button>
          </form>
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
