defmodule RecipeAppWeb.AuthControllerTest do
  use RecipeAppWeb.ConnCase

  import Swoosh.TestAssertions

  alias RecipeApp.Accounts.User
  alias RecipeApp.Repo

  test "signup sends a verification email that can activate the account", %{conn: conn} do
    params = %{
      "email" => "nature@example.com",
      "username" => "nature",
      "password" => "password123"
    }

    conn = post(conn, ~p"/api/v1/auth/signup", params)

    assert %{"message" => "Account created successfully. Please check your email."} =
             json_response(conn, 201)

    user = Repo.get_by!(User, email: "nature@example.com")

    assert user.status == "pending"

    test_pid = self()

    assert_email_sent(fn email ->
      send(test_pid, {:verification_email, email})

      email.subject == "Verify your ENC Recipes account" and
        email.to == [{"nature", "nature@example.com"}] and
        email.html_body =~ "Verify my email" and
        email.text_body =~ "Verify your email address"
    end)

    assert_receive {:verification_email, email}

    [_, verification_url] =
      Regex.run(
        ~r/href="([^"]+\/api\/v1\/auth\/verify-email\?token=[^"]+)"/,
        email.html_body
      )

    uri = URI.parse(verification_url)
    verification_path = uri.path <> "?" <> uri.query

    verification_conn =
      build_conn()
      |> get(verification_path)

    assert json_response(verification_conn, 200) == %{
             "message" => "Email verified successfully"
           }

    verified_user = Repo.get!(User, user.id)

    assert verified_user.status == "active"
    assert verified_user.email_verified_at

    login_conn =
      build_conn()
      |> post(~p"/api/v1/auth/login", %{
        "email" => "nature@example.com",
        "password" => "password123"
      })

    assert %{"message" => "Login successful"} = json_response(login_conn, 200)
    assert get_session(login_conn, :user_id) == user.id
    assert get_session(login_conn, :auth_version) == Repo.get!(User, user.id).auth_version
  end

  test "forgot password returns a non-enumerating response", %{conn: conn} do
    conn = post(conn, ~p"/api/v1/auth/forgot-password", %{"email" => "missing@example.com"})

    assert json_response(conn, 200) == %{
             "message" =>
               "If an account exists for that email, a password reset link has been sent."
           }
  end

  test "reset password requires a token and password", %{conn: conn} do
    conn = post(conn, ~p"/api/v1/auth/reset-password", %{})

    assert json_response(conn, 400) == %{
             "error" => "Token and password are required"
           }
  end

  test "returns 400 when verification token is missing", %{conn: conn} do
    conn = get(conn, ~p"/api/v1/auth/verify-email")

    assert json_response(conn, 400) == %{
             "error" => "Token is required"
           }
  end

  test "returns 422 when email is invalid", %{conn: conn} do
    params = %{
      "email" => "nature@@example.com",
      "username" => "nature",
      "password" => "password123"
    }

    conn = post(conn, ~p"/api/v1/auth/signup", params)

    assert %{
             "error" => "Unable to process request",
             "details" => %{
               "email" => ["is invalid"]
             }
           } = json_response(conn, 422)
  end

  test "pending user cannot log in before verifying email", %{conn: conn} do
    params = %{
      "email" => "nature@example.com",
      "username" => "nature",
      "password" => "password123"
    }

    signup_conn =
      post(conn, ~p"/api/v1/auth/signup", params)

    assert %{"message" => "Account created successfully. Please check your email."} =
             json_response(signup_conn, 201)

    login_conn =
      build_conn()
      |> post(~p"/api/v1/auth/login", %{
        "email" => "nature@example.com",
        "password" => "password123"
      })

    assert %{
             "error" => "Please verify your email before logging in."
           } = json_response(login_conn, 403)
  end

  test "returns 401 when login credentials are invalid", %{conn: conn} do
    params = %{
      "email" => "nature@example.com",
      "username" => "nature",
      "password" => "password123"
    }

    signup_conn = post(conn, ~p"/api/v1/auth/signup", params)

    assert %{"message" => "Account created successfully. Please check your email."} =
             json_response(signup_conn, 201)

    test_pid = self()

    assert_email_sent(fn email ->
      send(test_pid, {:verification_email, email})
      true
    end)

    assert_receive {:verification_email, email}

    [_, verification_url] =
      Regex.run(
        ~r/href="([^"]+\/api\/v1\/auth\/verify-email\?token=[^"]+)"/,
        email.html_body
      )

    uri = URI.parse(verification_url)
    verification_path = uri.path <> "?" <> uri.query

    build_conn() |> get(verification_path)

    login_conn =
      build_conn()
      |> post(~p"/api/v1/auth/login", %{
        "email" => "nature@example.com",
        "password" => "wrong-password"
      })

    assert json_response(login_conn, 401) == %{
             "error" => "Invalid email or password"
           }
  end

  test "forgot password rejects a missing email", %{conn: conn} do
    conn = post(conn, ~p"/api/v1/auth/forgot-password", %{})

    assert json_response(conn, 400) == %{"error" => "Email is required"}
  end

  test "reset password rejects an invalid token", %{conn: conn} do
    conn =
      post(conn, ~p"/api/v1/auth/reset-password", %{
        "token" => "invalid-token",
        "password" => "new-password-123"
      })

    assert json_response(conn, 422) == %{"error" => "Invalid or expired reset link"}
  end

  test "reset password updates the password and consumes the token", %{conn: conn} do
    {:ok, user} =
      RecipeApp.Accounts.register_user(%{
        "username" => "reset-user",
        "email" => "reset-user@example.com",
        "password" => "password123"
      })

    user
    |> Ecto.Changeset.change(status: "active")
    |> Repo.update!()

    login_conn =
      post(conn, ~p"/api/v1/auth/login", %{
        "email" => user.email,
        "password" => "password123"
      })

    assert get_session(login_conn, :auth_version) == user.auth_version

    assert :ok = RecipeApp.Accounts.request_password_reset(user.email)

    test_pid = self()

    assert_email_sent(fn email ->
      send(test_pid, {:reset_email, email})
      email.subject == "Reset your ENC Recipes password"
    end)

    assert_receive {:reset_email, email}
    [_, reset_url] = Regex.run(~r|href="([^"]+/reset-password\?token=[^"]+)"|, email.html_body)

    token =
      reset_url |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query() |> Map.fetch!("token")

    conn =
      post(login_conn, ~p"/api/v1/auth/reset-password", %{
        "token" => token,
        "password" => "new-password-123"
      })

    assert json_response(conn, 200) == %{
             "message" => "Password updated successfully. You can now log in."
           }

    assert get_session(conn, :user_id) == nil
    assert get_session(conn, :auth_version) == nil

    assert {:ok, authenticated_user} =
             RecipeApp.Accounts.authenticate_user(user.email, "new-password-123")

    assert authenticated_user.id == user.id
  end

  test "login rejects a suspended account", %{conn: conn} do
    {:ok, user} =
      RecipeApp.Accounts.register_user(%{
        "username" => "suspended-user",
        "email" => "suspended@example.com",
        "password" => "password123"
      })

    user
    |> Ecto.Changeset.change(status: "suspended")
    |> Repo.update!()

    conn =
      post(conn, ~p"/api/v1/auth/login", %{
        "email" => user.email,
        "password" => "password123"
      })

    assert json_response(conn, 403) == %{"error" => "Your account is not active."}
  end

  test "password reset invalidates a different API session on its next request", %{conn: conn} do
    {:ok, user} =
      RecipeApp.Accounts.register_user(%{
        "username" => "other-session",
        "email" => "other-session@example.com",
        "password" => "password123"
      })

    user =
      user
      |> Ecto.Changeset.change(status: "active")
      |> Repo.update!()

    stale_session =
      post(conn, ~p"/api/v1/auth/login", %{
        "email" => user.email,
        "password" => "password123"
      })

    assert get_session(stale_session, :user_id) == user.id

    assert :ok = RecipeApp.Accounts.request_password_reset(user.email)

    test_pid = self()

    assert_email_sent(fn email ->
      send(test_pid, {:reset_email, email})
      email.subject == "Reset your ENC Recipes password"
    end)

    assert_receive {:reset_email, email}

    [_, reset_url] =
      Regex.run(~r|href="([^"]+/reset-password\?token=[^"]+)"|, email.html_body)

    token =
      reset_url
      |> URI.parse()
      |> Map.fetch!(:query)
      |> URI.decode_query()
      |> Map.fetch!("token")

    reset_conn =
      post(build_conn(), ~p"/api/v1/auth/reset-password", %{
        "token" => token,
        "password" => "new-password-123"
      })

    assert json_response(reset_conn, 200)

    stale_session =
      post(stale_session, ~p"/api/v1/auth/forgot-password", %{
        "email" => "missing@example.com"
      })

    assert get_session(stale_session, :user_id) == nil
    assert get_session(stale_session, :auth_version) == nil
  end
end
