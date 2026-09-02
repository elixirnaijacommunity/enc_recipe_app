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

    assert Repo.get!(User, user.id).status == "active"

    login_conn =
      build_conn()
      |> post(~p"/api/v1/auth/login", %{
        "email" => "nature@example.com",
        "password" => "password123"
      })

    assert %{"message" => "Login successful"} = json_response(login_conn, 200)
  end
end
