defmodule RecipeAppWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid HTTP responses.
  """

  use RecipeAppWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{
      error: "Unable to process request",
      details:
        Ecto.Changeset.traverse_errors(
          changeset,
          fn {message, _opts} -> message end
        )
    })
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> json(%{
      error: "Resource not found"
    })
  end

  def call(conn, {:error, :invalid_input}) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      error: "Invalid input"
    })
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> json(%{
      error: "Unauthorized"
    })
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> json(%{
      error: "Forbidden"
    })
  end

  def call(conn, _error) do
    conn
    |> put_status(:internal_server_error)
    |> json(%{
      error: "Internal server error"
    })
  end
end
