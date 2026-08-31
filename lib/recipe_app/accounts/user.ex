defmodule RecipeApp.Accounts.User do
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

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username, :password])
    |> validate_required([
      :email,
      :password,
      :username
    ])
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:password, min: 8)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
    |> hash_password
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))
    else
      changeset
    end
  end
end
