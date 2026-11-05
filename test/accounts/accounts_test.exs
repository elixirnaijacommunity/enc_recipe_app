defmodule RecipeApp.AccountsTest do
  use RecipeApp.DataCase

  import Swoosh.TestAssertions

  alias RecipeApp.Accounts

  defp create_user do
    {:ok, user} =
      Accounts.register_user(%{
        "username" => "nature",
        "email" => "nature@example.com",
        "password" => "password123"
      })

    user
    |> Ecto.Changeset.change(status: "active")
    |> RecipeApp.Repo.update!()
  end

  test "password reset requests send an expiring reset link" do
    user = create_user()
    test_pid = self()

    assert :ok = Accounts.request_password_reset(user.email)

    assert_email_sent(fn email ->
      send(test_pid, {:reset_email, email})

      email.subject == "Reset your ENC Recipes password" and
        email.to == [{"nature", "nature@example.com"}] and
        email.text_body =~ "one hour"
    end)

    assert_receive {:reset_email, email}

    assert [_, reset_url] =
             Regex.run(~r|href="([^"]+/reset-password\?token=[^"]+)"|, email.html_body)

    token =
      reset_url |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query() |> Map.fetch!("token")

    assert {:ok, updated_user} = Accounts.reset_password(token, "new-password-123")
    assert updated_user.password_reset_token_hash == nil
    assert updated_user.auth_version == user.auth_version + 1
    assert {:error, :invalid_token} = Accounts.reset_password(token, "another-password")
    assert {:ok, authenticated_user} = Accounts.authenticate_user(user.email, "new-password-123")
    assert authenticated_user.id == user.id
  end

  test "password reset request does not disclose unknown email addresses" do
    assert :ok = Accounts.request_password_reset("missing@example.com")
  end

  test "password reset rejects invalid and expired tokens" do
    user = create_user()
    assert {:error, :invalid_token} = Accounts.reset_password("not-a-token", "new-password-123")

    user
    |> Ecto.Changeset.change(%{
      password_reset_token_hash: :crypto.hash(:sha256, "expired") |> Base.encode16(case: :lower),
      password_reset_sent_at:
        DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.add(-3_700, :second)
    })
    |> RecipeApp.Repo.update!()

    assert {:error, :invalid_token} = Accounts.reset_password("expired", "new-password-123")
  end

  test "password reset enforces the minimum password length" do
    user = create_user()
    assert :ok = Accounts.request_password_reset(user.email)
    test_pid = self()

    assert_email_sent(fn email ->
      send(test_pid, {:reset_email, email})
      email.subject == "Reset your ENC Recipes password"
    end)

    assert_receive {:reset_email, email}
    [_, reset_url] = Regex.run(~r|href="([^"]+/reset-password\?token=[^"]+)"|, email.html_body)

    token =
      reset_url |> URI.parse() |> Map.fetch!(:query) |> URI.decode_query() |> Map.fetch!("token")

    assert {:error, %Ecto.Changeset{}} = Accounts.reset_password(token, "short")
  end

  test "gets an existing user by id" do
    user = create_user()
    assert Accounts.get_user_by_id(user.id).id == user.id
  end

  test "returns nil when a user id does not exist" do
    assert Accounts.get_user_by_id(-1) == nil
  end

  test "authentication distinguishes pending, inactive, and invalid credentials" do
    {:ok, pending_user} =
      Accounts.register_user(%{
        "username" => "pending-user",
        "email" => "pending@example.com",
        "password" => "password123"
      })

    assert {:error, :email_not_verified} =
             Accounts.authenticate_user("PENDING@example.com", "password123")

    active_user =
      pending_user
      |> Ecto.Changeset.change(status: "active")
      |> RecipeApp.Repo.update!()

    assert {:error, :invalid_credentials} =
             Accounts.authenticate_user(active_user.email, "incorrect-password")

    inactive_user =
      active_user
      |> Ecto.Changeset.change(status: "suspended")
      |> RecipeApp.Repo.update!()

    assert {:error, :account_inactive} =
             Accounts.authenticate_user(inactive_user.email, "password123")

    assert {:error, :invalid_credentials} =
             Accounts.authenticate_user("missing@example.com", "password123")
  end

  test "verification rejects malformed tokens and tokens for missing users" do
    assert {:error, :invalid_token} = Accounts.verify_email("not-a-signed-token")

    token = Phoenix.Token.sign(RecipeAppWeb.Endpoint, "email_verification", -1)
    assert {:error, :user_not_found} = Accounts.verify_email(token)
  end

  test "verification activates an existing pending user" do
    user = create_pending_user()
    token = Accounts.generate_verification_token(user)

    assert {:ok, verified_user} = Accounts.verify_email(token)
    assert verified_user.status == "active"
    assert verified_user.email_verified_at
  end

  defp create_pending_user do
    {:ok, user} =
      Accounts.register_user(%{
        "username" => "verify-me",
        "email" => "verify-me@example.com",
        "password" => "password123"
      })

    user
  end
end
