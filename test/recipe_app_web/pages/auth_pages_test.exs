defmodule RecipeAppWebHologram.Pages.AuthPagesTest do
  use RecipeAppWebHologram.ComponentCase, async: true

  alias Hologram.{Component, Server}
  alias RecipeAppWebHologram.HologramCoreComponents.{Brand, Button, PasswordField}

  alias RecipeAppWebHologram.Pages.{
    EmailVerification,
    ForgotPassword,
    Login,
    Register,
    ResetPassword
  }

  test "login page renders the email and password form and navigation" do
    markup = render_markup(Login.template(), Login.init(%{}, %Component{}, %Server{}).state)
    assert markup =~ "Welcome back"
    assert markup =~ ~s(name="email")
    assert markup =~ ~s(name="password")
    assert markup =~ "Forgot password?"
    assert markup =~ "/register"
    refute markup =~ "Google"
    refute markup =~ "Apple"
  end

  test "registration page renders username, email, and password confirmation" do
    markup = render_markup(Register.template(), Register.init(%{}, %Component{}, %Server{}).state)
    assert markup =~ "Create your account"
    assert markup =~ ~s(name="username")
    assert markup =~ ~s(name="email")
    assert markup =~ ~s(name="password_confirmation")
    assert markup =~ "Use 8 or more characters."
    refute markup =~ "Google"
    refute markup =~ "Apple"
  end

  test "brand component renders without resolving a page module" do
    markup = render_markup(Brand.template(), %{})

    assert markup =~ ~s(class="home-brand")
    assert markup =~ "ENC"
    assert markup =~ "Recipes"
    refute markup =~ "href="
  end

  test "all internal navigation targets expose Hologram route metadata" do
    pages = [
      {Login, "/login"},
      {Register, "/register"},
      {ForgotPassword, "/forgot-password"},
      {ResetPassword, "/reset-password"},
      {EmailVerification, "/check-email"}
    ]

    Enum.each(pages, fn {page, expected_route} ->
      assert page.__route__() == expected_route
      assert page.__params__() == []
    end)
  end

  test "email verification page clearly explains the next step" do
    markup = render_markup(EmailVerification.template(), %{})
    assert markup =~ "Check your inbox"
    assert markup =~ "verification link"
    assert markup =~ "before logging in"
    assert markup =~ ~s(href="/login")
    assert markup =~ "btn btn-primary"
    assert markup =~ "w-full"
    assert markup =~ "items-center"
    assert markup =~ "justify-center"
    assert markup =~ "Back to log in"
  end

  test "forgot password page explains the reset flow" do
    markup =
      render_markup(
        ForgotPassword.template(),
        ForgotPassword.init(%{}, %Component{}, %Server{}).state
      )

    assert markup =~ "Reset your password"
    assert markup =~ "Send reset link"
    assert markup =~ "Back to log in"
  end

  test "shared button displays a loader and disables itself while loading" do
    markup =
      render_markup(Button.template(), %{
        type: "submit",
        class: "auth-submit",
        rest: %{},
        disabled: false,
        loading: true,
        loading_text: "Saving..."
      })

    assert markup =~ "loading-spinner"
    assert markup =~ "Saving..."
    assert markup =~ "disabled"
    assert markup =~ ~s(aria-busy="true")
  end

  test "password field toggles password visibility" do
    props = %{id: "password", name: "password", label: "Password", hint: ""}
    component = PasswordField.init(props, %Component{}, %Server{})
    refute component.state.visible

    component = PasswordField.action(:toggle_visibility, %{}, component)
    assert component.state.visible

    visible_markup =
      render_markup(PasswordField.template(), Map.merge(props, component.state))

    assert visible_markup =~ ~s(type="text")
    assert visible_markup =~ ~s(aria-label="Hide password")
  end

  test "registration submission enters loading and validation failure clears it" do
    component = Register.init(%{}, %Component{}, %Server{})
    component = Register.action(:submit_registration, %{event: %{}}, component)

    assert component.state.loading
    markup = render_markup(Register.template(), component.state)
    assert markup =~ "Creating account..."
    assert markup =~ "loading-spinner"
    assert markup =~ "disabled"

    component =
      Register.action(:registration_failed, %{message: "Invalid details."}, component)

    refute component.state.loading
    assert component.state.error == "Invalid details."
  end

  test "login submission enters loading and authentication failure clears it" do
    component = Login.init(%{}, %Component{}, %Server{})
    component = Login.action(:submit_login, %{event: %{}}, component)

    assert component.state.loading
    markup = render_markup(Login.template(), component.state)
    assert markup =~ "Logging in..."
    assert markup =~ "loading-spinner"
    assert markup =~ "disabled"

    component =
      Login.action(:login_failed, %{message: "Invalid credentials."}, component)

    refute component.state.loading
    assert component.state.error == "Invalid credentials."
  end

  test "password reset request enters loading and clears it after completion" do
    component = ForgotPassword.init(%{}, %Component{}, %Server{})
    component = ForgotPassword.action(:submit_reset_request, %{event: %{}}, component)

    assert component.state.loading
    markup = render_markup(ForgotPassword.template(), component.state)
    assert markup =~ "Sending reset link..."
    assert markup =~ "loading-spinner"
    assert markup =~ "disabled"

    component = ForgotPassword.action(:reset_requested, %{}, component)
    refute component.state.loading
    assert component.state.submitted
  end

  test "password update enters loading and clears it after a failure" do
    component = ResetPassword.init(%{"token" => "reset-token"}, %Component{}, %Server{})
    component = ResetPassword.action(:submit_password_reset, %{event: %{}}, component)

    assert component.state.loading
    markup = render_markup(ResetPassword.template(), component.state)
    assert markup =~ "Updating password..."
    assert markup =~ "loading-spinner"
    assert markup =~ "disabled"

    component =
      ResetPassword.action(:reset_failed, %{message: "Invalid token."}, component)

    refute component.state.loading
    assert component.state.error == "Invalid token."
  end

  test "reset password page reads the token from the email query string" do
    server = %Server{query: %{"token" => "email-reset-token"}}
    component = ResetPassword.init(%{}, %Component{}, server)
    markup = render_markup(ResetPassword.template(), component.state)

    assert component.state.token == "email-reset-token"
    assert markup =~ ~s(value="email-reset-token")
    assert markup =~ "Update password"
  end

  test "reset password page accepts a route token when present" do
    component = ResetPassword.init(%{"token" => "route-reset-token"}, %Component{}, %Server{})

    assert component.state.token == "route-reset-token"
  end

  test "submission actions do not queue duplicate requests while loading" do
    register = Register.init(%{}, %Component{}, %Server{})
    login = Login.init(%{}, %Component{}, %Server{})
    forgot = ForgotPassword.init(%{}, %Component{}, %Server{})
    reset = ResetPassword.init(%{"token" => "token"}, %Component{}, %Server{})

    register = %{register | state: Map.put(register.state, :loading, true)}
    login = %{login | state: Map.put(login.state, :loading, true)}
    forgot = %{forgot | state: Map.put(forgot.state, :loading, true)}
    reset = %{reset | state: Map.put(reset.state, :loading, true)}

    assert Register.action(:submit_registration, %{event: %{}}, register) == register
    assert Login.action(:submit_login, %{event: %{}}, login) == login
    assert ForgotPassword.action(:submit_reset_request, %{event: %{}}, forgot) == forgot
    assert ResetPassword.action(:submit_password_reset, %{event: %{}}, reset) == reset
  end

  test "authentication pages render their error states" do
    register = Register.init(%{}, %Component{}, %Server{})
    login = Login.init(%{}, %Component{}, %Server{})
    reset = ResetPassword.init(%{"token" => "token"}, %Component{}, %Server{})

    register_markup =
      Register.action(:registration_failed, %{message: "Registration failed."}, register)
      |> then(&render_markup(Register.template(), &1.state))

    login_markup =
      Login.action(:login_failed, %{message: "Login failed."}, login)
      |> then(&render_markup(Login.template(), &1.state))

    reset_markup =
      ResetPassword.action(:reset_failed, %{message: "Reset failed."}, reset)
      |> then(&render_markup(ResetPassword.template(), &1.state))

    assert register_markup =~ "Registration failed."
    assert login_markup =~ "Login failed."
    assert reset_markup =~ "Reset failed."
  end
end
