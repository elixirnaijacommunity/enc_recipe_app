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
        |> put_session(:auth_version, user.auth_version)
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

  def forgot_password(conn, %{"email" => email}) do
    :ok = Accounts.request_password_reset(email)

    json(conn, %{
      message: "If an account exists for that email, a password reset link has been sent."
    })
  end

  def forgot_password(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "Email is required"})
  end

  def reset_password(conn, %{"token" => token, "password" => password}) do
    case Accounts.reset_password(token, password) do
      {:ok, _user} ->
        conn
        |> delete_session(:user_id)
        |> delete_session(:auth_version)
        |> json(%{message: "Password updated successfully. You can now log in."})

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, :invalid_token} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Invalid or expired reset link"})
    end
  end

  def reset_password(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "Token and password are required"})
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

  def verify_email(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Token is required"
    })
  end
end
