import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "template"]

  add(event) {
    event.preventDefault()
    const timestamp = new Date().getTime()
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, timestamp)
    this.containerTarget.insertAdjacentHTML("beforeend", content)
    this.renumber()
  }

  remove(event) {
    event.preventDefault()
    const row = event.target.closest("[data-step-row]")
    row.remove()
    this.renumber()
  }

  renumber() {
    const rows = this.containerTarget.querySelectorAll("[data-step-row]")
    rows.forEach((row, index) => {
      const label = row.querySelector("[data-step-label]")
      if (label) label.textContent = `Step ${index + 1}`
    })
  }
}
