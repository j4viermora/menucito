import { Controller } from "@hotwired/stimulus"

// The "Selector de Platos" for counter sales (Ventas por mostrador).
//
// UX rules this follows:
//  - searcher built in (menu commonly has well over 5 items)
//  - the primary action ("Cobrar venta") is the one visually dominant button;
//    every other action here (quantity steppers, remove line, clear cart) is
//    a secondary/ghost affordance
//  - clearing the whole cart is destructive and irreversible mid-sale, so it
//    is gated behind an explicit confirmation dialog
//  - totals recompute live as items/discount change, so the cashier always
//    sees the true total before charging
export default class extends Controller {
  static targets = [
    "search", "card", "empty", "cartList", "cartEmpty", "subtotal", "discountRow",
    "discountAmount", "total", "cartItemsField", "discountSelect", "submit", "chargeBar",
    "mobileBar", "mobileCount", "mobileTotal",
  ]
  static values = { currency: { type: String, default: "$" } }

  connect() {
    this.cart = new Map()
    this.render()
  }

  filter() {
    const q = this.searchTarget.value.trim().toLowerCase()
    let visibleCount = 0
    this.cardTargets.forEach((card) => {
      const match = card.dataset.name.toLowerCase().includes(q) || card.dataset.category.toLowerCase().includes(q)
      card.classList.toggle("hidden", !match)
      if (match) visibleCount += 1
    })
    this.emptyTarget.classList.toggle("hidden", visibleCount !== 0)
  }

  add(event) {
    const card = event.currentTarget.closest("[data-pos-cart-target='card']")
    const id = card.dataset.menuItemId
    const existing = this.cart.get(id)
    if (existing) {
      existing.quantity += 1
    } else {
      this.cart.set(id, {
        id, name: card.dataset.name, price: parseFloat(card.dataset.price), quantity: 1,
      })
    }
    this.render()
  }

  increment(event) {
    const id = event.currentTarget.dataset.itemId
    this.cart.get(id).quantity += 1
    this.render()
  }

  decrement(event) {
    const id = event.currentTarget.dataset.itemId
    const line = this.cart.get(id)
    line.quantity -= 1
    if (line.quantity <= 0) this.cart.delete(id)
    this.render()
  }

  remove(event) {
    this.cart.delete(event.currentTarget.dataset.itemId)
    this.render()
  }

  clear() {
    if (this.cart.size === 0) return
    this.confirmDestructive({
      title: "¿Vaciar el carrito?",
      message: "Se eliminarán todos los productos agregados a esta venta. Esta acción no se puede deshacer.",
      confirmLabel: "Sí, vaciar",
    }).then((confirmed) => {
      if (confirmed) {
        this.cart.clear()
        this.render()
      }
    })
  }

  recalcDiscount() {
    this.render()
  }

  scrollToCart() {
    document.getElementById("pos-cart-panel")?.scrollIntoView({ behavior: "smooth", block: "start" })
  }

  render() {
    this.cartListTarget.innerHTML = ""
    const lines = Array.from(this.cart.values())

    this.cartEmptyTarget.classList.toggle("hidden", lines.length !== 0)

    lines.forEach((line) => {
      const row = document.createElement("div")
      row.className = "flex items-center justify-between gap-2 border-b-2 border-ink py-2"
      row.innerHTML = `
        <div class="min-w-0">
          <p class="font-bold text-sm truncate">${line.name}</p>
          <p class="text-xs text-ink/60 font-mono">${this.money(line.price)} c/u</p>
        </div>
        <div class="flex items-center gap-1 shrink-0">
          <button type="button" data-item-id="${line.id}" class="btn-secondary !px-2 !py-1 text-xs" data-action="pos-cart#decrement">-</button>
          <span class="w-6 text-center font-mono font-bold">${line.quantity}</span>
          <button type="button" data-item-id="${line.id}" class="btn-secondary !px-2 !py-1 text-xs" data-action="pos-cart#increment">+</button>
          <span class="w-20 text-right font-mono font-bold text-sm">${this.money(line.price * line.quantity)}</span>
          <button type="button" data-item-id="${line.id}" class="btn-ghost !px-1 !py-1 text-red" data-action="pos-cart#remove" aria-label="Quitar">&times;</button>
        </div>
      `
      this.cartListTarget.appendChild(row)
    })

    const subtotal = lines.reduce((sum, l) => sum + l.price * l.quantity, 0)
    const discountPct = this.hasDiscountSelectTarget ? this.discountSelectTarget.selectedOptions[0]?.dataset : null
    let discountAmount = 0
    if (discountPct && discountPct.kind) {
      discountAmount = discountPct.kind === "percentage"
        ? subtotal * (parseFloat(discountPct.value) / 100)
        : Math.min(parseFloat(discountPct.value), subtotal)
    }
    const total = subtotal - discountAmount

    this.subtotalTarget.textContent = this.money(subtotal)
    this.discountRowTarget.classList.toggle("hidden", discountAmount <= 0)
    this.discountAmountTarget.textContent = `-${this.money(discountAmount)}`
    this.totalTarget.textContent = this.money(total)
    this.cartItemsFieldTarget.value = JSON.stringify(
      lines.map((l) => ({ menu_item_id: l.id, quantity: l.quantity }))
    )

    const disabled = lines.length === 0
    this.submitTarget.disabled = disabled
    this.chargeBarTarget.classList.toggle("opacity-40", disabled)

    const itemCount = lines.reduce((sum, l) => sum + l.quantity, 0)
    this.mobileCountTarget.textContent = itemCount
    this.mobileTotalTarget.textContent = this.money(total)
    this.mobileBarTarget.classList.toggle("hidden", lines.length === 0)
    this.mobileBarTarget.classList.toggle("flex", lines.length !== 0)
  }

  money(n) {
    return `${this.currencyValue} ${Math.round(n).toLocaleString("es-CO")}`
  }

  confirmDestructive({ title, message, confirmLabel }) {
    return new Promise((resolve) => {
      const dialog = document.createElement("dialog")
      dialog.className = "nb-box p-0 w-full max-w-sm backdrop:bg-ink/60"
      dialog.innerHTML = `
        <div class="p-6">
          <h2 class="nb-heading text-lg mb-2">${title}</h2>
          <p class="text-sm mb-6">${message}</p>
          <div class="flex gap-3 justify-end">
            <button type="button" class="btn-secondary text-xs" data-role="cancel">Cancelar</button>
            <button type="button" class="btn-danger text-xs" data-role="confirm">${confirmLabel}</button>
          </div>
        </div>
      `
      document.body.appendChild(dialog)
      const done = (value) => { dialog.close(); resolve(value) }
      dialog.querySelector('[data-role="cancel"]').addEventListener("click", () => done(false))
      dialog.querySelector('[data-role="confirm"]').addEventListener("click", () => done(true))
      dialog.addEventListener("cancel", () => done(false))
      dialog.addEventListener("close", () => dialog.remove())
      dialog.showModal()
    })
  }
}
