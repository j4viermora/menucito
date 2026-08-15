import { Controller } from "@hotwired/stimulus"

// Live difference preview while closing a cash session, plus a confirmation
// gate before submitting — closing the register is a one-way, money-affecting
// action and mistakes here are expensive to unwind.
export default class extends Controller {
  static targets = ["counted", "expected", "difference", "form"]
  static values = { expected: Number, currency: { type: String, default: "$" } }

  connect() {
    this.updateDifference()
  }

  updateDifference() {
    const counted = parseFloat(this.countedTarget.value || "0")
    const diff = counted - this.expectedValue
    this.differenceTarget.textContent = `${diff >= 0 ? "+" : ""}${this.money(diff)}`
    this.differenceTarget.classList.toggle("text-red", diff !== 0)
    this.differenceTarget.classList.toggle("font-bold", diff !== 0)
  }

  money(n) {
    return `${this.currencyValue} ${Math.round(n).toLocaleString("es-CO")}`
  }

  confirmClose(event) {
    if (this.formTarget.dataset.confirmed === "true") return
    event.preventDefault()

    const diff = parseFloat(this.countedTarget.value || "0") - this.expectedValue
    const message = diff === 0
      ? "El conteo coincide con lo esperado. Se cerrará la caja."
      : `Hay una diferencia de ${this.money(diff)} respecto a lo esperado. Se cerrará la caja de todas formas.`

    const dialog = document.createElement("dialog")
    dialog.className = "nb-box p-0 w-full max-w-sm backdrop:bg-ink/60"
    dialog.innerHTML = `
      <div class="p-6">
        <h2 class="nb-heading text-lg mb-2">¿Cerrar la caja?</h2>
        <p class="text-sm mb-6">${message}</p>
        <div class="flex gap-3 justify-end">
          <button type="button" class="btn-secondary text-xs" data-role="cancel">Cancelar</button>
          <button type="button" class="btn-danger text-xs" data-role="confirm">Sí, cerrar caja</button>
        </div>
      </div>
    `
    document.body.appendChild(dialog)
    dialog.querySelector('[data-role="cancel"]').addEventListener("click", () => dialog.close())
    dialog.querySelector('[data-role="confirm"]').addEventListener("click", () => {
      this.formTarget.dataset.confirmed = "true"
      dialog.close()
      this.formTarget.requestSubmit()
    })
    dialog.addEventListener("close", () => dialog.remove())
    dialog.showModal()
  }
}
