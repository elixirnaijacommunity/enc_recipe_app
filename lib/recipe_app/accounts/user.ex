defmodule RecipeApp.Accounts.User do
  @moduledoc """
  Represents a user in the RecipeApp system.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :username, :string
    field :password, :string, virtual: true
    field :status, :string, default: "pending"
    field :email_verified_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc """
  Creates a changeset for user registration, including validations and password hashing.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([
      :email,
      :password,
      :username
    ])
    |> update_change(:email, &RecipeApp.Accounts.UserValidation.normalize_email/1)
    |> validate_change(:email, fn :email, email ->
      if RecipeApp.Accounts.UserValidation.valid_email?(email) do
        []
      else
        [email: "is invalid"]
      end
    end)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> hash_password
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
