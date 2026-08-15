import { Controller } from "@hotwired/stimulus"

// Real-time validation: fields are checked on blur (not on every keystroke,
// which would scold the user mid-typing). The whole form is re-checked on
// submit, and a failing field is what actually blocks submission.
export default class extends Controller {
  static targets = ["field", "error", "submit"]

  check(event) {
    this.validateField(event.target)
  }

  submit(event) {
    let firstInvalid = null

    this.fieldTargets.forEach((field) => {
      const valid = this.validateField(field)
      if (!valid && !firstInvalid) firstInvalid = field
    })

    if (firstInvalid) {
      event.preventDefault()
      firstInvalid.focus()
    }
  }

  validateField(field) {
    const rules = (field.dataset.validateRule || "").split(",").map((r) => r.trim()).filter(Boolean)
    const errorEl = this.errorTargets.find((e) => e.dataset.validateFor === field.id)
    let message = null

    for (const rule of rules) {
      const [name, arg] = rule.split(":")
      message = this.checkRule(field, name, arg)
      if (message) break
    }

    const valid = !message
    field.dataset.valid = field.value.trim() === "" && !rules.includes("required") ? "" : String(valid)
    if (field.value.trim() === "" && !rules.includes("required")) field.removeAttribute("data-valid")

    if (errorEl) {
      errorEl.textContent = message || ""
      errorEl.classList.toggle("hidden", !message)
    }

    field.setAttribute("aria-invalid", String(!valid))
    return valid
  }

  checkRule(field, name, arg) {
    const value = field.value.trim()

    switch (name) {
      case "required":
        return value === "" ? (field.dataset.validateMessage || "Este campo es obligatorio") : null
      case "email":
        return value !== "" && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) ? "Correo inválido" : null
      case "number":
        return value !== "" && isNaN(Number(value)) ? "Debe ser un número" : null
      case "min":
        return value !== "" && Number(value) < Number(arg) ? `El mínimo es ${arg}` : null
      case "max":
        return value !== "" && Number(value) > Number(arg) ? `El máximo es ${arg}` : null
      case "minlength":
        return value !== "" && value.length < Number(arg) ? `Mínimo ${arg} caracteres` : null
      default:
        return null
    }
  }
}
