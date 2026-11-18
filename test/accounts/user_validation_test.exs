defmodule RecipeApp.Accounts.UserValidationTest do
  use ExUnit.Case, async: true

  alias RecipeApp.Accounts.UserValidation

  describe "normalize_email/1" do
    test "trims whitespace and lowercases the address" do
      assert UserValidation.normalize_email("  Nature@Example.COM  ") == "nature@example.com"
    end

    test "returns an empty string for non-binary values" do
      assert UserValidation.normalize_email(nil) == ""
      assert UserValidation.normalize_email(123) == ""
    end
  end

  describe "valid_email?/1" do
    test "accepts a normalized email address" do
      assert UserValidation.valid_email?(" Nature@Example.COM ")
    end

    test "rejects malformed addresses and non-binary values" do
      refute UserValidation.valid_email?("nature@@example.com")
      refute UserValidation.valid_email?("nature example.com")
      refute UserValidation.valid_email?(nil)
    end
  end
end
