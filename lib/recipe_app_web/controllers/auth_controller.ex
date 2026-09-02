defmodule RecipeAppWeb.AuthController do
  use RecipeAppWeb, :controller

  alias RecipeApp.Accounts

  def signup(conn, params) do
    case Accounts.register_user(params) do
      {:ok, user} ->
        Accounts.send_verification_email(user)

        conn
        |> put_status(:created)
        |> json(%{
          message: "Account created successfully. Please check your email.",
          user: %{
            id: user.id,
            email: user.email,
            username: user.username
          }
        })

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Unable to create account",
          details:
            Ecto.Changeset.traverse_errors(
              changeset,
              fn {message, _opts} -> message end
            )
        })
    end
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> json(%{
          message: "Login successful",
          user: %{
            id: user.id,
            email: user.email,
            username: user.username,
            status: user.status
          }
        })

      {:error, :email_not_verified} ->
        conn
        |> put_status(:forbidden)
        |> json(%{
          error: "Please verify your email before logging in."
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          error: "Invalid email or password"
        })

      {:error, :account_inactive} ->
        conn
        |> put_status(:forbidden)
        |> json(%{
          error: "Your account is not active."
        })
    end
  end

  def login(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Email and password are required"
    })
  end

  def verify_email(conn, %{"token" => token}) do
    case Accounts.verify_email(token) do
      {:ok, _user} ->
        json(conn, %{
          message: "Email verified successfully"
        })

      {:error, :invalid_token} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: "Invalid or expired verification link"
        })

      {:error, :user_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          error: "User not found"
        })
    end
  end
end
