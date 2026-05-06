import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown"]
  static values = { url: String }

  connect() {
    this.timeout = null
    this.handleOutsideClick = this.closeDropdown.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
    if (this.timeout) clearTimeout(this.timeout)
  }

  onInput() {
    const query = this.inputTarget.value.trim()

    if (query.length < 2) {
      this.hideDropdown()
      return
    }

    if (this.timeout) clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.fetchSuggestions(query), 300)
  }

  onKeydown(event) {
    if (!this.dropdownTarget.classList.contains("hidden")) {
      const items = this.dropdownTarget.querySelectorAll("[data-autocomplete-item]")
      const active = this.dropdownTarget.querySelector(".bg-blue-100")

      if (event.key === "ArrowDown") {
        event.preventDefault()
        this.navigateItems(items, active, 1)
      } else if (event.key === "ArrowUp") {
        event.preventDefault()
        this.navigateItems(items, active, -1)
      } else if (event.key === "Enter" && active) {
        event.preventDefault()
        this.selectItem(active.textContent.trim())
      } else if (event.key === "Escape") {
        this.hideDropdown()
      }
    }
  }

  async fetchSuggestions(query) {
    try {
      const response = await fetch(`${this.urlValue}?q=${encodeURIComponent(query)}`)
      if (!response.ok) return

      const suggestions = await response.json()
      this.renderDropdown(suggestions)
    } catch {
      this.hideDropdown()
    }
  }

  renderDropdown(suggestions) {
    if (suggestions.length === 0) {
      this.hideDropdown()
      return
    }

    this.dropdownTarget.innerHTML = suggestions.map(name =>
      `<div data-autocomplete-item data-action="click->autocomplete#select"
            class="px-3 py-2 text-sm cursor-pointer hover:bg-blue-100">
        ${this.escapeHtml(name)}
      </div>`
    ).join("")

    this.dropdownTarget.classList.remove("hidden")
  }

  select(event) {
    this.selectItem(event.currentTarget.textContent.trim())
  }

  selectItem(value) {
    this.inputTarget.value = value
    this.hideDropdown()
    this.inputTarget.focus()
  }

  hideDropdown() {
    this.dropdownTarget.classList.add("hidden")
    this.dropdownTarget.innerHTML = ""
  }

  closeDropdown(event) {
    if (!this.element.contains(event.target)) {
      this.hideDropdown()
    }
  }

  navigateItems(items, active, direction) {
    if (items.length === 0) return

    let index = -1
    items.forEach((item, i) => {
      if (item === active) index = i
      item.classList.remove("bg-blue-100")
    })

    const nextIndex = Math.max(0, Math.min(items.length - 1, index + direction))
    items[nextIndex].classList.add("bg-blue-100")
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
