import { Controller } from "@hotwired/stimulus"

// Suggests a subdomain slug from the restaurant name as the user types.
// Stops suggesting as soon as the user edits the subdomain field directly,
// so we never fight with a deliberate choice.
const DIACRITICS_REGEX = new RegExp("[̀-ͯ]", "g")

export default class extends Controller {
  static targets = ["source", "output"]

  connect() {
    this.editedManually = this.outputTarget.value.trim() !== ""
  }

  suggest() {
    if (this.editedManually) return
    this.outputTarget.value = this.slugify(this.sourceTarget.value)
  }

  markEdited() {
    this.editedManually = true
  }

  slugify(value) {
    return value
      .normalize("NFD")
      .replace(DIACRITICS_REGEX, "")
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "")
      .slice(0, 63)
  }
}
