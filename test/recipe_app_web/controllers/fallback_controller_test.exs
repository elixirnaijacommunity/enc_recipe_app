defmodule RecipeAppWeb.FallbackControllerTest do
  use RecipeAppWeb.ConnCase

  alias RecipeApp.Accounts.User
  alias RecipeAppWeb.FallbackController

  test "renders 422 with translated errors for a changeset error", %{conn: conn} do
    changeset =
      %User{}
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.add_error(:email, "is invalid")
      |> Ecto.Changeset.add_error(:username, "can't be blank")

    conn = FallbackController.call(conn, {:error, changeset})

    assert json_response(conn, 422) == %{
             "error" => "Unable to process request",
             "details" => %{
               "email" => ["is invalid"],
               "username" => ["can't be blank"]
             }
           }
  end

  test "renders 404 for :not_found", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :not_found})

    assert json_response(conn, 404) == %{"error" => "Resource not found"}
  end

  test "renders 400 for :invalid_input", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :invalid_input})

    assert json_response(conn, 400) == %{"error" => "Invalid input"}
  end

  test "renders 401 for :unauthorized", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :unauthorized})

    assert json_response(conn, 401) == %{"error" => "Unauthorized"}
  end

  test "renders 403 for :forbidden", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :forbidden})

    assert json_response(conn, 403) == %{"error" => "Forbidden"}
  end

  test "renders 500 for any unmatched error", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, :something_unexpected})

    assert json_response(conn, 500) == %{"error" => "Internal server error"}
  end
end
