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

### Initial Setup (from scratch)

If you ever need to recreate this deployment, here are the full steps:

#### 1. Install the Fly.io CLI

```bash
curl -L https://fly.io/install.sh | sh
```

#### 2. Create the Fly.io app

Sign up at [fly.io](https://fly.io), then create the app:

```bash
fly apps create quick-recipe-parser
```

#### 3. Create a Neon PostgreSQL database

1. Sign up at [neon.tech](https://neon.tech) (free tier, no credit card required)
2. Create a new project (e.g. name: `quick-recipe-parser`, region: `US East`)
3. Copy the connection string — it looks like:
   ```
   postgresql://<user>:<password>@<host>.neon.tech/<dbname>?sslmode=require
   ```

#### 4. Configure Fly.io secrets

Set the two required secrets (these are stored encrypted on Fly.io, never in source code):

```bash
# The Rails master key (from config/master.key, gitignored)
fly secrets set RAILS_MASTER_KEY=<value from config/master.key> -a quick-recipe-parser

# The Neon PostgreSQL connection string
fly secrets set DATABASE_URL=<your-neon-connection-string> -a quick-recipe-parser
```

| Secret | Description | Where to find it |
|--------|-------------|-----------------|
| `RAILS_MASTER_KEY` | Decrypts Rails encrypted credentials | `config/master.key` (gitignored) |
| `DATABASE_URL` | Neon PostgreSQL connection string | Neon dashboard → project → Connection Details |

#### 5. Configure `fly.toml`

The `fly.toml` in the repo root configures the app. Key settings:

- **`HTTP_PORT = '8080'`** — Thruster (Rails HTTP proxy) listens on 8080 because the container runs as a non-root user and can't bind to port 80
- **`internal_port = 8080`** — Fly.io routes traffic to this port inside the container
- **`auto_stop_machines = 'stop'`** — Machines spin down when idle to save resources
- **`release_command = './bin/rails db:prepare'`** — Runs migrations automatically on each deploy

#### 6. Deploy

```bash
fly deploy
```

This builds the Docker image (using the repo's `Dockerfile`), pushes it to Fly.io's registry, runs the release command (`db:prepare`), and starts the app.

### Redeploying

After the initial setup, future deploys are just:

```bash
fly deploy
```

### Useful Fly.io commands

```bash
fly status -a quick-recipe-parser   # App status and machine info
fly logs -a quick-recipe-parser     # Tail production logs
fly secrets list -a quick-recipe-parser  # List configured secrets (names only)
fly ssh console -a quick-recipe-parser   # SSH into a running machine
fly apps open -a quick-recipe-parser     # Open the app in your browser
```

## CI

GitHub Actions runs on every PR and push to `main`:

- **Security scans**: Brakeman (static analysis) and bundler-audit (dependency vulnerabilities)
- **Lint**: RuboCop with Rails Omakase style
- **Tests**: Unit and system tests against PostgreSQL
