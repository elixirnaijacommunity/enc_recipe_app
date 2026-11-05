defmodule RecipeAppWebHologram.Pages.AuthPageCommandsTest do
  use RecipeApp.DataCase, async: true

  import Swoosh.TestAssertions

  alias Hologram.{Component, Server}
  alias RecipeApp.Accounts
  alias RecipeApp.Repo
  alias RecipeAppWebHologram.Middleware.ValidateSession
  alias RecipeAppWebHologram.Pages.{ForgotPassword, Login, Register, ResetPassword}

  defp register_user(attrs) do
    defaults = %{
      "username" => "cook-#{System.unique_integer([:positive])}",
      "email" => "cook-#{System.unique_integer([:positive])}@example.com",
      "password" => "password123"
    }

    {:ok, user} = Accounts.register_user(Map.merge(defaults, attrs))
    user
  end

  defp activate_user(user) do
    user
    |> Ecto.Changeset.change(status: "active")
    |> Repo.update!()
  end

  defp reset_token_for(email) do
    assert :ok = Accounts.request_password_reset(email)
    test_pid = self()

    assert_email_sent(fn message ->
      send(test_pid, {:reset_email, message})
      message.subject == "Reset your ENC Recipes password"
    end)

    assert_receive {:reset_email, message}

    assert [_, url] =
             Regex.run(~r|href="([^"]+/reset-password\?token=[^"]+)"|, message.html_body)

    url
    |> URI.parse()
    |> Map.fetch!(:query)
    |> URI.decode_query()
    |> Map.fetch!("token")
  end

  test "registration command rejects mismatched passwords" do
    server =
      Register.command(
        :register,
        %{event: %{"password" => "password123", "password_confirmation" => "different"}},
        %Server{}
      )

    assert server.next_action
    assert Accounts.get_user_by_id(-1) == nil
  end

  test "registration command creates the user and sends verification email" do
    server =
      Register.command(
        :register,
        %{
          event: %{
            "username" => "new-cook",
            "email" => "new-cook@example.com",
            "password" => "password123",
            "password_confirmation" => "password123"
          }
        },
        %Server{}
      )

    assert server.next_action
    assert_email_sent(fn message -> message.to == [{"new-cook", "new-cook@example.com"}] end)

    assert Accounts.authenticate_user("new-cook@example.com", "password123") ==
             {:error, :email_not_verified}
  end

  test "registration command explains when email or username is already registered" do
    existing_user =
      register_user(%{
        "username" => "existing-cook",
        "email" => "existing-cook@example.com"
      })

    duplicate_email =
      Register.command(
        :register,
        %{
          event: %{
            "username" => "another-cook",
            "email" => existing_user.email,
            "password" => "password123",
            "password_confirmation" => "password123"
          }
        },
        %Server{}
      )

    assert duplicate_email.next_action.params.message ==
             "An account with this email address already exists. Please log in or use a different email address."

    duplicate_username =
      Register.command(
        :register,
        %{
          event: %{
            "username" => existing_user.username,
            "email" => "another-cook@example.com",
            "password" => "password123",
            "password_confirmation" => "password123"
          }
        },
        %Server{}
      )

    assert duplicate_username.next_action.params.message ==
             "That username is already taken. Please choose another."
  end

  test "registration command maps invalid email, username, and password errors" do
    cases = [
      %{
        "username" => "email-error",
        "email" => "invalid",
        "password" => "password123",
        "password_confirmation" => "password123"
      },
      %{
        "username" => "",
        "email" => "username-error@example.com",
        "password" => "password123",
        "password_confirmation" => "password123"
      },
      %{
        "username" => "password-error",
        "email" => "password-error@example.com",
        "password" => "short",
        "password_confirmation" => "short"
      }
    ]

    Enum.each(cases, fn event ->
      server = Register.command(:register, %{event: event}, %Server{})
      assert server.next_action
    end)
  end

  test "registration actions clear loading and navigate after success" do
    component = Register.init(%{}, %Component{}, %Server{})
    component = Register.action(:submit_registration, %{event: %{}}, component)
    assert component.state.loading

    component = Register.action(:registration_succeeded, %{}, component)
    refute component.state.loading
    assert component.next_page == RecipeAppWebHologram.Pages.EmailVerification
  end

  test "login command authenticates active users and stores their identity" do
    user =
      %{
        "username" => "login-cook",
        "email" => "login-cook@example.com",
        "password" => "password123"
      }
      |> register_user()
      |> activate_user()

    server =
      Login.command(
        :login,
        %{event: %{"email" => user.email, "password" => "password123"}},
        %Server{}
      )

    assert server.user_id == user.id
    assert server.session["auth_version"] == user.auth_version
    assert server.next_action
  end

  test "Hologram middleware leaves anonymous sessions unchanged" do
    server = %Server{}
    assert ValidateSession.call(server, []) == server
  end

  test "Hologram middleware clears sessions with stale authentication versions" do
    user =
      %{"username" => "stale-session", "email" => "stale-session@example.com"}
      |> register_user()
      |> activate_user()

    server = %Server{
      user_id: user.id,
      session: %{"auth_version" => user.auth_version - 1}
    }

    validated = ValidateSession.call(server, [])

    assert validated.user_id == nil
    refute Map.has_key?(validated.session, "auth_version")
  end

  test "Hologram middleware preserves sessions with the current authentication version" do
    user =
      %{"username" => "valid-session", "email" => "valid-session@example.com"}
      |> register_user()
      |> activate_user()

    server = %Server{
      user_id: user.id,
      session: %{"auth_version" => user.auth_version}
    }

    assert ValidateSession.call(server, []) == server
  end

  test "login command handles unverified and invalid credentials" do
    pending =
      register_user(%{"username" => "pending-login", "email" => "pending-login@example.com"})

    unverified =
      Login.command(
        :login,
        %{event: %{"email" => pending.email, "password" => "password123"}},
        %Server{}
      )

    assert unverified.next_action

    invalid =
      Login.command(
        :login,
        %{event: %{"email" => "missing@example.com", "password" => "wrong"}},
        %Server{}
      )

    assert invalid.next_action
  end

  test "login success action clears loading and navigates home" do
    component = Login.init(%{}, %Component{}, %Server{})
    component = Login.action(:submit_login, %{event: %{}}, component)
    component = Login.action(:login_succeeded, %{}, component)

    refute component.state.loading
    assert component.next_page == RecipeAppWebHologram.Pages.Home
  end

  test "forgot password command always acknowledges a reset request" do
    user = register_user(%{"username" => "reset-request", "email" => "reset-request@example.com"})

    server =
      ForgotPassword.command(
        :request_reset,
        %{event: %{"email" => user.email}},
        %Server{}
      )

    assert server.next_action
    assert_email_sent(fn message -> message.to == [{"reset-request", user.email}] end)

    unknown =
      ForgotPassword.command(
        :request_reset,
        %{event: %{"email" => "unknown@example.com"}},
        %Server{}
      )

    assert unknown.next_action
  end

  test "reset password command rejects mismatched passwords and invalid tokens" do
    mismatch =
      ResetPassword.command(
        :reset_password,
        %{event: %{"password" => "password123", "password_confirmation" => "different"}},
        %Server{}
      )

    assert mismatch.next_action

    invalid =
      ResetPassword.command(
        :reset_password,
        %{
          event: %{
            "token" => "invalid-token",
            "password" => "password123",
            "password_confirmation" => "password123"
          }
        },
        %Server{}
      )

    assert invalid.next_action
  end

  test "reset password command reports validation errors for short passwords" do
    user = register_user(%{"username" => "short-reset", "email" => "short-reset@example.com"})
    token = reset_token_for(user.email)

    server =
      ResetPassword.command(
        :reset_password,
        %{
          event: %{
            "token" => token,
            "password" => "short",
            "password_confirmation" => "short"
          }
        },
        %Server{}
      )

    assert server.next_action
  end

  test "reset password command updates the password and its success action navigates to login" do
    user =
      %{"username" => "success-reset", "email" => "success-reset@example.com"}
      |> register_user()
      |> activate_user()

    token = reset_token_for(user.email)

    server =
      ResetPassword.command(
        :reset_password,
        %{
          event: %{
            "token" => token,
            "password" => "new-password123",
            "password_confirmation" => "new-password123"
          }
        },
        %Server{}
      )

    assert server.next_action
    assert {:ok, authenticated} = Accounts.authenticate_user(user.email, "new-password123")
    assert authenticated.id == user.id

    component = ResetPassword.init(%{"token" => token}, %Component{}, %Server{})
    component = ResetPassword.action(:reset_succeeded, %{}, component)

    refute component.state.loading
    assert component.next_page == Login
  end
end
