# ECHO

> **Your life, automatically remembered and surfaced.**
>
> Automatic context capture + instant recall + proactive suggestions.

---

## What is ECHO?

ECHO is an automatic life context capture and recall system. It passively ingests your digital life (calendar, Slack, email, browser, voice notes), extracts meaning (decisions, actions, relationships), stores it in a queryable memory graph, and proactively surfaces what you need — before you ask.

**The unpopular truth it's built on:** People don't need more tools to capture information. They need a system that captures *for* them and makes it *actionable* without asking.

---

## Quick Start

### Prerequisites
- Java 17+
- Maven 3.9+
- Docker + Docker Compose
- Flutter (for mobile app)

### Start Infrastructure

```bash
docker compose -f docker-compose-echo.yml up -d