defmodule RecipeApp.Accounts do
  @moduledoc """
  The Accounts context handles user registration, authentication, and email verification.
  """

  import Ecto.Changeset
  import Ecto.Query
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
  Fetches a user by their primary key.
  """
  def get_user_by_id(user_id), do: Repo.get(User, user_id)

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

  @password_reset_max_age_seconds 60 * 60

  @doc """
  Requests a password reset. The response is intentionally the same whether or
  not the email exists, preventing account enumeration.
  """
  def request_password_reset(email) do
    normalized_email = RecipeApp.Accounts.UserValidation.normalize_email(email)

    case Repo.get_by(User, email: normalized_email) do
      nil ->
        :ok

      user ->
        token = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
        now = DateTime.utc_now() |> DateTime.truncate(:second)

        user
        |> change(%{
          password_reset_token_hash: hash_reset_token(token),
          password_reset_sent_at: now
        })
        |> Repo.update!()

        user
        |> Email.password_reset_email(token)
        |> Mailer.deliver()

        :ok
    end
  end

  @doc """
  Resets a password with a valid, single-use password reset token.
  """
  def reset_password(token, password) when is_binary(token) do
    token_hash = hash_reset_token(token)
    cutoff = DateTime.add(DateTime.utc_now(), -@password_reset_max_age_seconds, :second)

    Repo.transaction(fn ->
      user =
        Repo.one(
          from user in User,
            where: user.password_reset_token_hash == ^token_hash,
            where: user.password_reset_sent_at >= ^cutoff,
            lock: "FOR UPDATE"
        )

      case user do
        nil ->
          Repo.rollback(:invalid_token)

        user ->
          case user |> User.password_reset_changeset(%{password: password}) |> Repo.update() do
            {:ok, updated_user} -> updated_user
            {:error, changeset} -> Repo.rollback(changeset)
          end
      end
    end)
    |> case do
      {:ok, user} -> {:ok, user}
      {:error, reason} -> {:error, reason}
    end
  end

  def reset_password(_token, _password), do: {:error, :invalid_token}

  defp hash_reset_token(token), do: :crypto.hash(:sha256, token) |> Base.encode16(case: :lower)

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
