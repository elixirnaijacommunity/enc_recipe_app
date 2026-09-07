defmodule RecipeApp.Accounts.UserValidation do
  @moduledoc """
  Provides functions for validating and normalizing user data.
  """
  @email_regex ~r/^[^@\s]+@[^@\s]+$/

  @doc """
  Normalizes an email address by trimming whitespace and converting it to lowercase.
  """
  def normalize_email(email) when is_binary(email) do
    email
    |> String.trim()
    |> String.downcase()
  end

  def normalize_email(_), do: ""

  @doc """
  Validates an email address format.
  Returns true if the email is valid, false otherwise.
  """
  def valid_email?(email) when is_binary(email) do
    email
    |> normalize_email()
    |> String.match?(@email_regex)
  end

  def valid_email?(_), do: false
end
