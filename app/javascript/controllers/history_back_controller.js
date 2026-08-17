import { Controller } from "@hotwired/stimulus"

// Generic "go back" button. Falls back to a configured URL when there's
// no previous page in this tab's history (e.g. opened in a new tab).
export default class extends Controller {
  static values = { fallbackUrl: String }

  back(event) {
    event.preventDefault()

    if (window.history.length > 1) {
      window.history.back()
    } else {
      window.location.href = this.fallbackUrlValue || "/"
    }
  }
}
