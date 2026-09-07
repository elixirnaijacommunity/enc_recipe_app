defmodule RecipeApp.Accounts.UserTest do
  use RecipeApp.DataCase

  alias RecipeApp.Accounts.User

  describe "registration_changeset/2" do
    test "normalizes email before storing it" do
      changeset =
        User.registration_changeset(%User{}, %{
          email: " Nature@Example.COM ",
          username: "nature",
          password: "password123"
        })

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :email) == "nature@example.com"
    end

    test "rejects an email with multiple @ characters" do
      changeset =
        User.registration_changeset(%User{}, %{
          email: "nature@@example.com",
          username: "nature",
          password: "password123"
        })

      refute changeset.valid?

      assert "is invalid" in errors_on(changeset).email
    end

    test "rejects a password shorter than 8 characters" do
      changeset =
        User.registration_changeset(%User{}, %{
          email: "nature@example.com",
          username: "nature",
          password: "short"
        })

      refute changeset.valid?

      assert "should be at least 8 character(s)" in errors_on(changeset).password
    end
  end
end
