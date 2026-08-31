defmodule RecipeApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias RecipeApp.Repo
  alias RecipeApp.Accounts.Email
  alias RecipeApp.Mailer

  alias RecipeApp.Accounts.User

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def authenticate_user(email, password) do
    email =
      email
      |> String.trim()
      |> String.downcase()

    case Repo.get_by(User, email: email) do
      nil ->
        {:error, :invalid_credentials}

      %{status: "pending"} ->
        {:error, :email_not_verified}

      %{status: "active"} = user ->
        if Bcrypt.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end

      _user ->
        {:error, :account_inactive}
    end
  end

  def generate_verification_token(user) do
    Phoenix.Token.sign(
      RecipeAppWeb.Endpoint,
      "email_verification",
      user.id
    )
  end

  def verify_email(token) do
    case Phoenix.Token.verify(
           RecipeAppWeb.Endpoint,
           "email_verification",
           token,
           max_age: 96
         ) do
      {:ok, user_id} ->
        activate_user(user_id)

      {:error, _reason} ->
        {:error, :invalid_token}
    end
  end

  defp activate_user(user_id) do
    case Repo.get(User, user_id) do
      nil ->
        {:error, :user_not_found}

      user ->
        user
        |> change(%{status: "active"})
        |> Repo.update()
    end
  end

  def send_verification_email(user) do
    token = generate_verification_token(user)

    user
    |> Email.verification_email(token)
    |> Mailer.deliver()
  end
end
