defmodule RecipeAppWebHologram.Pages.Register do
  use Hologram.Page

  alias Hologram.UI.Link
  alias RecipeApp.Accounts
  alias RecipeAppWebHologram.Pages.{EmailVerification, Login}
  alias RecipeAppWebHologram.HologramCoreComponents.{Brand, Button, Input, PasswordField}

  route "/register"
  layout RecipeAppWebHologram.Layouts.Root, title: "Create account — ENC Recipes"

  def init(_params, component, _server) do
    component
    |> put_state(:error, "")
    |> put_state(:loading, false)
  end

  def command(:register, params, server) do
    fields = params.event
    password = Map.get(fields, "password", "")

    if password != Map.get(fields, "password_confirmation", "") do
      put_action(server, :registration_failed, message: "Your passwords do not match.")
    else
      attrs = %{
        "username" => Map.get(fields, "username", ""),
        "email" => Map.get(fields, "email", ""),
        "password" => password
      }

      case Accounts.register_user(attrs) do
        {:ok, user} ->
          _ = Accounts.send_verification_email(user)
          put_action(server, :registration_succeeded)

        {:error, changeset} ->
          message =
            cond do
              unique_constraint_error?(changeset, :email) ->
                "An account with this email address already exists. Please log in or use a different email address."

              unique_constraint_error?(changeset, :username) ->
                "That username is already taken. Please choose another."

              Keyword.has_key?(changeset.errors, :email) ->
                "Please enter a valid email address."

              Keyword.has_key?(changeset.errors, :username) ->
                "Please choose a username."

              Keyword.has_key?(changeset.errors, :password) ->
                "Your password must contain at least 8 characters."

              true ->
                "We couldn't create your account. Please check your details."
            end

          put_action(server, :registration_failed, message: message)
      end
    end
  end

  defp unique_constraint_error?(changeset, field) do
    case Keyword.get(changeset.errors, field) do
      {"has already been taken", _opts} -> true
      _ -> false
    end
  end

  def action(:submit_registration, params, component) do
    if component.state.loading do
      component
    else
      component
      |> put_state(:loading, true)
      |> put_command(:register, event: params.event)
    end
  end

  def action(:registration_failed, params, component) do
    component
    |> put_state(:loading, false)
    |> put_state(:error, params.message)
  end

  def action(:registration_succeeded, _params, component) do
    component
    |> put_state(:loading, false)
    |> put_page(EmailVerification)
  end

  def template do
    ~HOLO"""
    <div class="auth-page">
      <header class="auth-header">
        <Brand />
        <p>Already have an account? <Link to={login_page()}>Log in</Link></p>
      </header>
      <main class="auth-main auth-main-register">
        <section class="auth-panel" aria-labelledby="auth-title">
          <h1 id="auth-title">Create your account</h1>
          {%if @error != ""}<p class="auth-alert" role="alert">{@error}</p>{/if}
          <form $submit="submit_registration" class="auth-form">
            <div class="auth-field">
              <label for="username">Username</label>
              <Input class="auth-input" rest={%{id: "username", name: "username", placeholder: "Choose a username", autocomplete: "username", required: true}} />
            </div>
            <div class="auth-field">
              <label for="email">Email</label>
              <Input class="auth-input" rest={%{id: "email", name: "email", type: "email", placeholder: "you@email.com", autocomplete: "email", required: true}} />
            </div>
            <PasswordField cid="register-password" id="password" name="password" label="Password" hint="Use 8 or more characters." />
            <PasswordField cid="register-password-confirmation" id="password-confirmation" name="password_confirmation" label="Confirm password" />
            <Button type="submit" class="auth-submit" loading={@loading} loading_text="Creating account...">Create account</Button>
          </form>
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
