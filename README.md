# ECHO — Automatic Life Context Capture & Recall

> **Your life, automatically remembered and surfaced.**  
> *The unpopular truth: People don't need more tools to capture information. They need a system that captures for them and makes it actionable without asking.*

---

## What is ECHO?

ECHO passively ingests your digital life (calendar, Slack, email, browser, voice), extracts structured meaning (entities, decisions, actions, relationships), stores it in a local-first memory graph, and proactively surfaces context exactly when you need it.

### Core Principles
- **Local-first & Private**: Ollama runs locally. Your data never leaves your machine unless you opt-in.
- **Invisible**: Zero extra effort — it works in the background.
- **Actionable**: Morning briefs, pre-meeting context, post-meeting summaries, serendipity suggestions.
- **Fast**: Memory search < 100ms, extraction < 500ms.

---

## Quick Start

### 1. Prerequisites
- Java 17+
- Maven 3.9+
- Docker + Docker Compose
- Ollama (running locally on port 11434)
- Flutter (for mobile)

### 2. Start Infrastructure

```bash
# Start core services (Postgres, Redis, MinIO)
docker-compose -f docker-compose-echo.yml up -d postgres redis minio