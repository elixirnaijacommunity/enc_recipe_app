defmodule RecipeAppWebHologram.Pages.EmailVerification do
  use Hologram.Page

  alias Hologram.UI.Link
  alias RecipeAppWebHologram.Pages.Login
  alias RecipeAppWebHologram.HologramCoreComponents.{Brand, Icon}

  route "/check-email"
  layout RecipeAppWebHologram.Layouts.Root, title: "Verify your email — ENC Recipes"

  def template do
    ~HOLO"""
    <div class="auth-page">
      <header class="auth-header">
        <Brand />
      </header>
      <main class="auth-main">
        <section class="auth-panel auth-panel-centered email-confirmation-panel" aria-labelledby="auth-title">
          <div class="email-confirmation-icon" aria-hidden="true">
            <Icon name="hero-envelope" class="size-8" />
          </div>
          <p class="email-confirmation-eyebrow">One more step</p>
          <h1 id="auth-title">Check your inbox</h1>
          <p class="auth-description">
            We've sent you an email with a verification link. Open it and click the link to verify your email address before logging in.
          </p>
          <p class="auth-success" role="status">
            Your account is ready. It will become active as soon as you verify your email.
          </p>
          <Link to={login_page()} class="btn btn-primary flex w-full min-h-[58px] items-center justify-center px-6 text-center no-underline">Back to log in</Link>
          <p class="email-confirmation-help">
            Can't find the email? Check your spam or junk folder.
          </p>
        </section>
      </main>
    </div>
    """
  end

  defp login_page do
    _ = Login.__params__()
    _ = Login.__route__()
    Login
  end
end
