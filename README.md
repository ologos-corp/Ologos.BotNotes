# Ologos.BotNotes

**Persistent long-term memory repository for OlogosAI agents.**

This repository serves as the git-backed durability layer for OlogosAI's memory system, synchronized with the [Nous](https://github.com/ologos-repos/Nous) memory architecture.

## Purpose

- **Human-readable exports** of curated AI agent memories
- **Cross-session persistence** for decisions, lessons, and facts
- **Knowledge graph storage** for relational reasoning
- **Session digests** for conversation continuity

## Structure

```
Ologos.BotNotes/
├── director/           # Curated director-tier memories (semantic, embedded)
│   ├── decisions.md    # Strategic and architectural decisions
│   ├── lessons.md      # Lessons learned from operations
│   ├── facts.md        # Factual knowledge about systems/people
│   └── projects.md     # Project-specific context
├── workers/            # Worker-tier memories (name-scoped)
│   ├── telegram_bot/   # Telegram bot agent memories
│   └── chatbot/        # Web chatbot agent memories
├── graph/              # Knowledge graph exports
│   └── triplets.jsonl  # Subject-predicate-object triplets
├── conversations/      # Session summaries (not full logs)
│   └── digests/        # Daily/session digests
├── shells/             # Worker SQLite shells (gitignored)
└── sync/               # Sync metadata
```

## Sync Protocol

1. **Session end**: Director memories exported to `director/*.md`
2. **Session start**: Recent exports loaded if Nous DB is cold
3. **Periodic**: Session digests pushed to `conversations/digests/`
4. **On-demand**: Graph triplets exported to `graph/triplets.jsonl`

## Access

This repository is read/write for OlogosAI agents. Human review is encouraged for quality control.

---

*Part of the Ologos Corp AI infrastructure. See [Nous](https://github.com/ologos-repos/Nous) for the underlying memory architecture.*
