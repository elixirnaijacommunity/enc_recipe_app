defmodule RecipeAppWeb.AuthController do
  use RecipeAppWeb, :controller

  @moduledoc """
  The AuthController handles user authentication and account management.
  """

  alias RecipeApp.Accounts
  action_fallback RecipeAppWeb.FallbackController

  @doc """
  Handles user signup by creating a new user account and sending a verification email.
  """

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
        {:error, changeset}
    end
  end

  @doc """
  Handles user login by authenticating the provided email and password.
  If successful, it creates a session and returns user information.
  """

  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> configure_session(renew: true)
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

  @doc """
  Handles user logout by clearing the session.
  """
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

  def verify_email(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Token is required"
    })
  end
end
