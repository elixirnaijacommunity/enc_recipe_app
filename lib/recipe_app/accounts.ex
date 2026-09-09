defmodule RecipeApp.Accounts do
  @moduledoc """
  The Accounts context handles user registration, authentication, and email verification.
  """

  import Ecto.Changeset
  alias RecipeApp.Repo
  alias RecipeApp.Accounts.Email
  alias RecipeApp.Mailer

  alias RecipeApp.Accounts.User

  @doc """
  Registers a new user with the given attributes.
  Returns {:ok, user} if successful, or {:error, changeset} if there are validation errors.
  """
  def register_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Authenticates a user by email and password.
  Returns {:ok, user} if successful, or {:error, reason} if authentication fails.
  """
  def authenticate_user(email, password) do
    email = RecipeApp.Accounts.UserValidation.normalize_email(email)

    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :invalid_credentials}

      %{status: "pending"} ->
        {:error, :email_not_verified}

      %{status: "active"} = user ->
        if Argon2.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end

      _user ->
        {:error, :account_inactive}
    end
  end

  @doc """
  Generates a verification token for the given user.
  The token is signed and can be used to verify the user's email address.
  """
  def generate_verification_token(user) do
    Phoenix.Token.sign(
      RecipeAppWeb.Endpoint,
      "email_verification",
      user.id
    )
  end

  @doc """
  Verifies the given email verification token.
  If the token is valid, the user's account is activated.
  Returns {:ok, user} if successful, or {:error, reason} if the token is invalid or expired.
  """

  def verify_email(token) do
    case Phoenix.Token.verify(
           RecipeAppWeb.Endpoint,
           "email_verification",
           token,
           max_age: 15 * 60
         ) do
      {:ok, user_id} ->
        activate_user(user_id)

      {:error, _reason} ->
        {:error, :invalid_token}
    end
  end

  @doc """
  Sends a verification email to the user with a verification link containing the token.
  """
  def send_verification_email(user) do
    token = generate_verification_token(user)

    user
    |> Email.verification_email(token)
    |> Mailer.deliver()
  end

  defp activate_user(user_id) do
    case Repo.get(User, user_id) do
      nil ->
        {:error, :user_not_found}

      user ->
        user
        |> change(%{
          status: "active",
          email_verified_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })
        |> Repo.update()
    end
  end
end
