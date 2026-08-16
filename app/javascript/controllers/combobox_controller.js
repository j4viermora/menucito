import { Controller } from "@hotwired/stimulus"

// Progressively enhances a plain <select> with more than ~5 options into a
// searchable combobox: a text input filters the option list, arrow keys
// move through it, Enter/click selects, and the original <select> stays in
// sync so the surrounding form keeps working unmodified.
export default class extends Controller {
  static targets = ["select", "input", "list", "option"]
  static values = { placeholder: { type: String, default: "Buscar..." } }

  connect() {
    this.selectTarget.classList.add("hidden")
    this.selectTarget.setAttribute("aria-hidden", "true")
    this.buildInput()
    this.buildList()
    this.syncFromSelect()
    document.addEventListener("click", this.onOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.onOutsideClick)
  }

  buildInput() {
    // Anchor to the select's own parent, not the controller root — the
    // select isn't always a direct child of the element carrying
    // data-controller="combobox" (e.g. when it sits next to a submit button).
    this.anchor = this.selectTarget.parentElement
    this.anchor.style.position = "relative"

    const input = document.createElement("input")
    input.type = "text"
    input.className = "field-input"
    input.placeholder = this.placeholderValue
    input.autocomplete = "off"
    input.setAttribute("role", "combobox")
    input.setAttribute("aria-expanded", "false")
    input.addEventListener("input", () => this.filter(input.value))
    input.addEventListener("focus", () => this.openList())
    input.addEventListener("keydown", (e) => this.onKeydown(e))
    this.anchor.insertBefore(input, this.selectTarget)
    this.input = input
  }

  buildList() {
    const list = document.createElement("ul")
    list.className = "nb-box-sm absolute z-20 mt-1 max-h-64 w-full overflow-y-auto bg-white hidden"
    list.setAttribute("role", "listbox")
    this.anchor.appendChild(list)
    this.list = list
    this.activeIndex = -1

    Array.from(this.selectTarget.options).forEach((opt) => {
      if (!opt.value) return
      const li = document.createElement("li")
      li.textContent = opt.textContent
      li.dataset.value = opt.value
      li.setAttribute("role", "option")
      li.className = "px-3 py-2 cursor-pointer hover:bg-yellow font-display text-sm border-b-2 border-ink last:border-b-0"
      li.addEventListener("click", () => this.select(opt.value, opt.textContent))
      list.appendChild(li)
    })
  }

  syncFromSelect() {
    const selected = this.selectTarget.selectedOptions[0]
    this.input.value = selected && selected.value ? selected.textContent : ""
  }

  get items() {
    return Array.from(this.list.children)
  }

  filter(query) {
    const q = query.trim().toLowerCase()
    this.items.forEach((li) => {
      li.classList.toggle("hidden", !li.textContent.toLowerCase().includes(q))
    })
    this.openList()
  }

  openList() {
    this.list.classList.remove("hidden")
    this.input.setAttribute("aria-expanded", "true")
  }

  closeList() {
    this.list.classList.add("hidden")
    this.input.setAttribute("aria-expanded", "false")
    this.activeIndex = -1
  }

  select(value, label) {
    this.selectTarget.value = value
    this.selectTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.input.value = label
    this.closeList()
  }

  onKeydown(event) {
    const visible = this.items.filter((li) => !li.classList.contains("hidden"))
    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.activeIndex = Math.min(this.activeIndex + 1, visible.length - 1)
      this.highlight(visible)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.activeIndex = Math.max(this.activeIndex - 1, 0)
      this.highlight(visible)
    } else if (event.key === "Enter") {
      event.preventDefault()
      const active = visible[this.activeIndex]
      if (active) this.select(active.dataset.value, active.textContent)
    } else if (event.key === "Escape") {
      this.closeList()
    }
  }

  highlight(visible) {
    visible.forEach((li, i) => li.classList.toggle("bg-yellow", i === this.activeIndex))
  }

  onOutsideClick = (event) => {
    if (!this.element.contains(event.target)) this.closeList()
  }
}
