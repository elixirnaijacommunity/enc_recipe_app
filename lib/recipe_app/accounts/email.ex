defmodule RecipeApp.Accounts.Email do
  import Swoosh.Email
  use RecipeAppWeb, :verified_routes

  @from {"ENC Recipes", "no-reply@enc-naija-community.com"}

  def general_email(user, subject, html_content, text_content) do
    new()
    |> to({user.username, user.email})
    |> from(@from)
    |> subject(subject)
    |> html_body(layout_html(user, html_content))
    |> text_body(layout_text(user, text_content))
  end

  def verification_email(user, token) do
    verification_url =
      url(~p"/api/v1/auth/verify-email?token=#{token}")

    general_email(
      user,
      "Verify your ENC Recipes account",
      """
      <p>Thanks for creating your account.</p>

      <p>
        Please verify your email address by clicking the button below:
      </p>

      <p>
        <a
          href="#{verification_url}"
          style="
            display: inline-block;
            padding: 12px 20px;
            background: #000;
            color: #fff;
            text-decoration: none;
            border-radius: 6px;
          "
        >
          Verify my email
        </a>
      </p>

      <p>
        This verification link will expire in 15 minutes.
      </p>

      <p>
        If you didn't create an ENC Recipes account, you can safely ignore
        this email.
      </p>
      """,
      """
      Thanks for creating your account.

      Verify your email address by visiting:

      #{verification_url}

      This verification link will expire in 15 minutes.

      If you didn't create an ENC Recipes account, you can safely ignore this email.
      """
    )
  end

  defp layout_html(user, content) do
    """
    <html>
      <body>
        <h2>Welcome to ENC Recipes, #{user.username}!</h2>

        #{content}

        <p>— ENC Recipes Team</p>
      </body>
    </html>
    """
  end

  defp layout_text(user, content) do
    """
    Welcome to ENC Recipes, #{user.username}!

    #{content}

    — ENC Recipes Team
    """
  end
end
