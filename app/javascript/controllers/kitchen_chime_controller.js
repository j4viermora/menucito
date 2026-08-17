import { Controller } from "@hotwired/stimulus"

// Plays a short chime whenever a "kitchen-chime" Turbo Stream ping arrives
// (broadcast from OrdersController#send_to_kitchen) — signals a new order
// just landed on this screen, as opposed to routine board updates (no sound).
export default class extends Controller {
  connect() {
    this.unlock = this.unlock.bind(this)
    this.onStreamRender = this.onStreamRender.bind(this)
    document.addEventListener("click", this.unlock, { once: true })
    document.addEventListener("turbo:before-stream-render", this.onStreamRender)
  }

  disconnect() {
    document.removeEventListener("click", this.unlock)
    document.removeEventListener("turbo:before-stream-render", this.onStreamRender)
  }

  unlock() {
    this.audioContext ||= new (window.AudioContext || window.webkitAudioContext)()
    if (this.audioContext.state === "suspended") this.audioContext.resume()
  }

  onStreamRender(event) {
    if (event.target.target === "kitchen-chime") this.play()
  }

  play() {
    this.unlock()
    const ctx = this.audioContext
    if (!ctx) return

    const now = ctx.currentTime
    ;[880, 1320].forEach((freq, i) => {
      const start = now + i * 0.15
      const osc = ctx.createOscillator()
      const gain = ctx.createGain()
      osc.type = "sine"
      osc.frequency.value = freq
      gain.gain.setValueAtTime(0, start)
      gain.gain.linearRampToValueAtTime(0.3, start + 0.02)
      gain.gain.exponentialRampToValueAtTime(0.001, start + 0.3)
      osc.connect(gain).connect(ctx.destination)
      osc.start(start)
      osc.stop(start + 0.35)
    })
  }
}
