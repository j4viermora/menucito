import { Controller } from "@hotwired/stimulus"

// Attach to a <form> (typically rendered by `button_to`) that performs a
// destructive action. Intercepts submit, shows an on-brand confirmation
// dialog instead of the native window.confirm, and only re-submits the form
// once the user explicitly confirms.
export default class extends Controller {
  static values = {
    title: { type: String, default: "¿Confirmar acción?" },
    message: String,
    confirmLabel: { type: String, default: "Sí, continuar" },
    cancelLabel: { type: String, default: "Cancelar" },
  }

  connect() {
    this.confirmed = false
    this.element.addEventListener("submit", this.onSubmit)
  }

  disconnect() {
    this.element.removeEventListener("submit", this.onSubmit)
    this.dialog?.remove()
  }

  onSubmit = (event) => {
    if (this.confirmed) return
    event.preventDefault()
    this.open()
  }

  open() {
    const dialog = document.createElement("dialog")
    dialog.className = "nb-box p-0 w-full max-w-sm backdrop:bg-ink/60"
    dialog.innerHTML = `
      <div class="p-6">
        <h2 class="nb-heading text-lg mb-2">${this.titleValue}</h2>
        <p class="text-sm mb-6">${this.messageValue || "Esta acción no se puede deshacer."}</p>
        <div class="flex gap-3 justify-end">
          <button type="button" class="btn-secondary text-xs" data-role="cancel">${this.cancelLabelValue}</button>
          <button type="button" class="btn-danger text-xs" data-role="confirm">${this.confirmLabelValue}</button>
        </div>
      </div>
    `
    document.body.appendChild(dialog)
    this.dialog = dialog

    dialog.querySelector('[data-role="cancel"]').addEventListener("click", () => this.close())
    dialog.querySelector('[data-role="confirm"]').addEventListener("click", () => this.confirmSubmit())
    dialog.addEventListener("cancel", () => this.close())
    dialog.addEventListener("close", () => dialog.remove())

    dialog.showModal()
  }

  close() {
    this.dialog?.close()
  }

  confirmSubmit() {
    this.confirmed = true
    this.close()
    this.element.requestSubmit()
  }
}
