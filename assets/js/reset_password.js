const formatCountdown = totalSeconds => {
  const minutes = Math.floor(totalSeconds / 60)
  const seconds = totalSeconds % 60

  return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`
}

let cooldownExpiresAt = 0
let countdownInterval = null
let confirmationTimeout = null

const getForm = () => document.getElementById("forgot-password-form")
const getTimer = () => document.getElementById("reset-countdown")
const getButton = () => getForm()?.querySelector("button[type='submit']")

const renderCountdown = () => {
  const remaining = Math.max(0, Math.ceil((cooldownExpiresAt - Date.now()) / 1000))
  const timer = getTimer()
  const button = getButton()

  if (timer) timer.textContent = formatCountdown(remaining)

  if (button) {
    button.disabled = remaining > 0
    button.classList.toggle("cursor-not-allowed", remaining > 0)
  }

  if (remaining === 0 && countdownInterval !== null) {
    window.clearInterval(countdownInterval)
    countdownInterval = null
    document.querySelector(".auth-cooldown")?.remove()
  }
}

const startCountdown = seconds => {
  const duration = Math.max(0, Number(seconds) || 0)

  if (countdownInterval !== null) {
    window.clearInterval(countdownInterval)
    countdownInterval = null
  }

  if (duration <= 0) {
    cooldownExpiresAt = 0
    renderCountdown()
    return
  }

  cooldownExpiresAt = Date.now() + duration * 1000

  const form = getForm()
  let timer = getTimer()

  if (form && !timer) {
    const message = document.createElement("p")
    message.className = "auth-cooldown"
    message.setAttribute("role", "status")
    message.append("You can request another email in ")

    timer = document.createElement("strong")
    timer.id = "reset-countdown"
    message.append(timer, ".")
    form.append(message)
  }

  renderCountdown()
  countdownInterval = window.setInterval(renderCountdown, 1000)
}

const fetchCooldown = async () => {
  const email = getForm()?.querySelector("input[name='email']")?.value?.trim()
  if (!email) return

  try {
    const response = await fetch("/api/v1/auth/password-reset-cooldown", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: JSON.stringify({email}),
    })

    if (!response.ok) return

    const data = await response.json()
    startCountdown(data.cooldown_seconds)
  } catch (_error) {
    // The backend remains authoritative if the cooldown lookup fails.
  }
}

const dismissConfirmation = () => {
  const confirmation = document.querySelector("[data-reset-confirmation]")
  if (!confirmation) return

  if (confirmationTimeout !== null) {
    window.clearTimeout(confirmationTimeout)
  }

  confirmationTimeout = window.setTimeout(() => {
    confirmation.remove()
    confirmationTimeout = null
  }, 15000)
}

const initializeResetPassword = () => {
  const form = getForm()
  if (!form) return

  // Start immediately from the server-rendered value, then reconcile with backend time.
  const serverSeconds = Number(getTimer()?.dataset.resetCountdown)
  if (serverSeconds > 0 && cooldownExpiresAt === 0) {
    startCountdown(serverSeconds)
  }

  if (!form.dataset.resetPasswordInitialized) {
    form.dataset.resetPasswordInitialized = "true"

    form.addEventListener("submit", () => {
      // Hologram handles the command; then ask the backend for the authoritative expiry.
      window.setTimeout(fetchCooldown, 500)
      window.setTimeout(dismissConfirmation, 500)
    })

    form.querySelector("input[name='email']")?.addEventListener("blur", fetchCooldown)
  }

  dismissConfirmation()
  fetchCooldown()
}

const scheduleInitialization = () => {
  window.setTimeout(initializeResetPassword, 0)
  window.setTimeout(initializeResetPassword, 100)
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", initializeResetPassword, {once: true})
} else {
  initializeResetPassword()
}

// Hologram client-side navigation does not reload this module.
window.addEventListener("popstate", scheduleInitialization)
document.addEventListener("click", event => {
  const link = event.target.closest("a[href]")
  if (link && new URL(link.href, window.location.href).pathname === "/forgot-password") {
    scheduleInitialization()
  }
})
window.addEventListener("pageshow", initializeResetPassword)
