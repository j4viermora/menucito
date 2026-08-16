import { Controller } from "@hotwired/stimulus"

// Filters a grid of dish cards by name/category as the user types. Used on
// the table order screen, where each "Agregar" submits immediately instead
// of building a client-side cart (unlike the POS selector).
export default class extends Controller {
  static targets = ["search", "card", "empty"]

  filter() {
    const q = this.searchTarget.value.trim().toLowerCase()
    let visible = 0
    this.cardTargets.forEach((card) => {
      const match = card.dataset.name.toLowerCase().includes(q) || card.dataset.category.toLowerCase().includes(q)
      card.classList.toggle("hidden", !match)
      if (match) visible += 1
    })
    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", visible !== 0)
  }
}
