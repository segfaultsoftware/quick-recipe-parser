import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["urlField", "parseButton", "ingredientsContainer", "ingredientTemplate", "overlay", "notice"]
  static values = { parseUrl: String }

  connect() {
    this.updateParseButtonState()
    if (this.hasUrlFieldTarget) {
      this.urlFieldTarget.addEventListener("input", () => this.updateParseButtonState())
    }
  }

  updateParseButtonState() {
    if (this.hasParseButtonTarget && this.hasUrlFieldTarget) {
      this.parseButtonTarget.disabled = this.urlFieldTarget.value.trim() === ""
    }
  }

  async parse(event) {
    event.preventDefault()

    if (this.hasIngredientsContainerTarget) {
      const existingRows = this.ingredientsContainerTarget.querySelectorAll("[data-ingredient-row]")
      if (existingRows.length > 0) {
        if (!confirm("This will replace all existing ingredients. Continue?")) {
          return
        }
      }
    }

    this.showOverlay()
    this.hideNotice()

    try {
      const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content
      const response = await fetch(this.parseUrlValue, {
        method: "POST",
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": csrfToken
        }
      })

      const data = await response.json()

      if (!response.ok) {
        this.showNotice(data.error || "Failed to parse recipe")
        return
      }

      if (data.count === 0) {
        this.showNotice("No ingredients found on the page")
        return
      }

      this.populateIngredients(data.ingredients)
      this.showNotice(`Parsed ${data.count} ingredient(s) and saved`, "success")
    } catch (error) {
      this.showNotice("An error occurred while parsing the recipe")
    } finally {
      this.hideOverlay()
    }
  }

  populateIngredients(ingredients) {
    if (this.hasIngredientsContainerTarget) {
      this.ingredientsContainerTarget.innerHTML = ""
    }

    ingredients.forEach((ingredient, index) => {
      const timestamp = new Date().getTime() + index
      const template = this.ingredientTemplateTarget.innerHTML.replace(/NEW_RECORD/g, timestamp)
      this.ingredientsContainerTarget.insertAdjacentHTML("beforeend", template)

      const row = this.ingredientsContainerTarget.lastElementChild
      const nameInput = row.querySelector('input[type="text"]')
      const qtyInput = row.querySelector('input[type="number"]')
      const unitSelect = row.querySelector("select")

      if (nameInput) nameInput.value = ingredient.name
      if (qtyInput) qtyInput.value = ingredient.quantity
      if (unitSelect) unitSelect.value = ingredient.unit
    })
  }

  showOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("hidden")
    }
    if (this.hasParseButtonTarget) {
      this.parseButtonTarget.disabled = true
    }
  }

  hideOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("hidden")
    }
    this.updateParseButtonState()
  }

  showNotice(message, type = "warning") {
    if (this.hasNoticeTarget) {
      this.noticeTarget.textContent = message
      this.noticeTarget.classList.remove("hidden", "bg-yellow-100", "text-yellow-800", "bg-green-100", "text-green-800")
      if (type === "success") {
        this.noticeTarget.classList.add("bg-green-100", "text-green-800")
      } else {
        this.noticeTarget.classList.add("bg-yellow-100", "text-yellow-800")
      }
    }
  }

  hideNotice() {
    if (this.hasNoticeTarget) {
      this.noticeTarget.classList.add("hidden")
    }
  }
}
