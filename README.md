# Quick Recipe Parser

A tool to parse, normalize, and manage recipes from spreadsheets and websites. Built with modern Rails.

## Tech Stack

- **Ruby** 3.4.8
- **Rails** 8.1 with Hotwire (Turbo + Stimulus), Importmaps, Propshaft
- **PostgreSQL** for the database
- **Tailwind CSS** via `tailwindcss-rails`
- **Docker** for containerized development and deployment

No secondary JavaScript frameworks — all UI is built with native Rails tech.

## Getting Started

### Prerequisites

- Ruby 3.4.8 (recommended: install via [rbenv](https://github.com/rbenv/rbenv))
- PostgreSQL 14+
- Or just Docker and Docker Compose

### Local Setup (without Docker)

```bash
# Install Ruby dependencies
bundle install

# Create and migrate the database
bin/rails db:prepare

# Start the development server
bin/dev
```

The app will be available at [http://localhost:3000](http://localhost:3000).

### Docker Setup

```bash
# Build and start all services
docker compose up --build

# In a separate terminal, create the database (first time only)
docker compose exec web bin/rails db:prepare
```

The app will be available at [http://localhost:3000](http://localhost:3000).

### Running Tests

```bash
bin/rails test
bin/rails test:system
```

### Linting

```bash
bin/rubocop
```

## Deployment

The app is deployed on [Fly.io](https://fly.io) with [Neon](https://neon.tech) for PostgreSQL.

**Live app**: [https://quick-recipe-parser.fly.dev](https://quick-recipe-parser.fly.dev)

### Infrastructure

| Service | Purpose | Plan |
|---------|---------|------|
| Fly.io | App hosting (Docker containers) | Free tier (shared CPU, 1GB RAM) |
| Neon | PostgreSQL database | Free tier |

### Manual Deploy

```bash
# Requires flyctl CLI and FLY_API_TOKEN
flyctl deploy
```

### Fly.io Secrets

The following secrets are configured on Fly.io (not in source control):

- `RAILS_MASTER_KEY` — Rails encrypted credentials key
- `DATABASE_URL` — Neon PostgreSQL connection string

## CI

GitHub Actions runs on every PR and push to `main`:

- **Security scans**: Brakeman (static analysis) and bundler-audit (dependency vulnerabilities)
- **Lint**: RuboCop with Rails Omakase style
- **Tests**: Unit and system tests against PostgreSQL
