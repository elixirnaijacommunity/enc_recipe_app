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
end
