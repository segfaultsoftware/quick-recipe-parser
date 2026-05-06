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

---

## Molly

**Tagline:** Tech-savvy food enthusiast who trusts the app to do the heavy lifting.

### Background

Molly loves cooking and loves technology in equal measure. She finds recipes all over the internet — food blogs, NYT Cooking, TikTok compilations, niche culinary forums — and wants a single place to store them without the tedium of manual transcription. She's the opposite of Michael: she fully trusts the app to parse, organize, and manage her recipe collection. If something goes wrong, she assumes it's a bug that'll get fixed, not a reason to distrust the system.

### Goals

- Build a recipe collection by pasting URLs and letting the app do all the work
- Never manually type out a recipe — paste a URL, click "Parse", done
- Plan weekly grocery runs by tagging recipes, then auto-generate a consolidated shopping list
- Eventually integrate with grocery delivery services (e.g., Instacart) for one-click ordering
- Maximize automation at every step — the less manual effort, the better

### Behaviors

- **URL-first workflow** — Molly creates a recipe by pasting a URL and clicking "Parse"; she expects the app to fill out name, ingredients, steps, servings, everything
- **No review** — She trusts the parsed output and saves immediately; she's okay living with the consequences if something parses incorrectly
- **Skip or report** — If the app can't parse a URL, she'd like to submit a bug report so it can be fixed, but otherwise she skips that recipe and moves on
- **Laptop for collection, iPad for cooking** — She curates her recipe collection on a laptop, then reads recipes on her iPad while cooking
- **Always logged in** — Like Michael, Molly stays signed in on her devices

### Key Data

Molly cares about the same recipe data as Michael but expects the app to extract it automatically:
1. **Ingredient list** — auto-parsed from the source URL
2. **Steps/instructions** — auto-parsed from the source URL
3. **Servings** — auto-parsed
4. **Nutrition facts** — auto-parsed if available

She does not care about categories or tags beyond the grocery run workflow.

### Pain Points

- Hates manual data entry — if she has to type it out, she'll find another app
- Browses a huge variety of recipe sites, so the parser needs to handle diverse HTML structures
- Wants the grocery/pantry workflow to be seamless, not a spreadsheet exercise

### Future Feature Interests

- **Automated recipe parsing** — Paste a URL, click "Parse", get a fully structured recipe. This is her primary reason for using the app.
- **Grocery runs** — Create a grocery run for a specific date, add recipes to it, and get a consolidated ingredient list across all linked recipes. Cross-reference with her real-world pantry to see what she actually needs to buy.
- **Pantry tracking** — Maintain an inventory of what's on hand to auto-calculate what's needed for a grocery run.
- **Instacart integration** — Auto-populate a grocery delivery order from a grocery run's shopping list.
- **Bug reporting for parse failures** — When a URL can't be parsed, submit it so the team can improve coverage.
- **Release notes** — Likes to know when new features and improvements ship.

### Devices

| Context | Device |
|---------|--------|
| Curating recipe collection (pasting URLs) | Laptop browser |
| Viewing recipes while cooking | iPad browser |
| Checking grocery list while shopping | Phone (future) |
