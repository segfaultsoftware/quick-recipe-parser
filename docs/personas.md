# Personas

User personas for Quick Recipe Parser. These personas guide feature design, prioritization, and acceptance criteria. Reference them in tickets as "As **Michael**, I want to..." to keep user stories grounded.

---

## Michael

**Tagline:** Meticulous home cook who doesn't trust computers but needs one anyway.

### Background

Michael is a methodical, by-the-book cook who never improvises in the kitchen. He maintained a sprawling recipe spreadsheet for years, but cascading formula failures and missing data finally pushed him to try this app. He's skeptical of software but values the structure and reliability it can offer — if it works correctly.

### Goals

- Keep a reliable, searchable collection of every recipe he uses
- Manually enter recipes by transcribing them from websites/blogs
- Standardize and auto-correct units of measurement across his collection
- Eventually track his pantry inventory against recipes for weekly meal planning and shopping
- Export his data (he doesn't want to be locked in)

### Behaviors

- **Always logged in** — Michael stays signed in on his devices
- **Manual entry** — He transcribes recipes by hand from source websites; he does not want automated website parsing
- **Desktop for entry, iPad for cooking** — He enters recipes at his desk, then pulls up recipes on his iPad in the kitchen
- **Searches by recipe name** — He knows what he wants to cook and looks it up by name
- **Enter once, rarely edit** — Once a recipe is saved, he only edits it to fix typos

### Key Data

Michael cares most about:
1. **Ingredient list** — the core of every recipe
2. **Steps/instructions** — clear, ordered preparation steps
3. **Servings** — secondary but useful
4. **Nutrition facts** — secondary, nice to have

He does not care about categories, tags, or cuisine labels.

### Pain Points

- Lost data from spreadsheet formula cascading failures — reliability is paramount
- Doesn't trust automated tools to get things right
- Wants to verify accuracy of his own transcriptions against the source

### Future Feature Interests

- **Transcription verification** — Attach a source URL to a manually entered recipe, then click "Verify" to get a confidence rating on how closely his transcription matches the original website. Could later evolve into recipe deduplication.
- **Pantry tracking** — Maintain a running inventory of ingredients on hand, then cross-reference against recipes for a weekly shopping list.
- **Data export** — Download his recipe collection in a portable format.

### Devices

| Context | Device |
|---------|--------|
| Entering/managing recipes | Desktop browser |
| Searching/viewing while cooking | iPad browser |
