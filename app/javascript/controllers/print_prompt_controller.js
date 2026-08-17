import { Controller } from "@hotwired/stimulus"

// Shown right after closing a sale (counter or table). The sale is already
// registered either way — this only asks whether to also print the
// customer's ticket.
export default class extends Controller {
  static values = { billUrl: String }

  connect() {
    window.history.replaceState({}, "", window.location.pathname)
    this.open()
  }

  open() {
    const dialog = document.createElement("dialog")
    dialog.className = "nb-box p-0 w-full max-w-sm backdrop:bg-ink/60"
    dialog.innerHTML = `
      <div class="p-6">
        <h2 class="nb-heading text-lg mb-2">¿Imprimir ticket?</h2>
        <p class="text-sm mb-6">La venta ya quedó registrada. Puedes imprimir el ticket para el cliente o continuar sin imprimir.</p>
        <div class="flex gap-3 justify-end">
          <button type="button" class="btn-secondary text-xs" data-role="skip">No, gracias</button>
          <button type="button" class="btn-primary text-xs" data-role="print">Imprimir ticket</button>
        </div>
      </div>
    `
    document.body.appendChild(dialog)
    this.dialog = dialog

    dialog.querySelector('[data-role="skip"]').addEventListener("click", () => this.close())
    dialog.querySelector('[data-role="print"]').addEventListener("click", () => this.print())
    dialog.addEventListener("cancel", () => this.close())
    dialog.addEventListener("close", () => dialog.remove())

    dialog.showModal()
  }

  print() {
    window.open(this.billUrlValue, "_blank")
    this.close()
  }

  close() {
    this.dialog?.close()
  }
}
