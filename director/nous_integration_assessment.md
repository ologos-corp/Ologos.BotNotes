# Nous Integration Assessment — OlogosAI Memory Enhancement

**Date:** 2026-03-17
**Author:** Claude (OlogosAI)
**Status:** Infrastructure Ready

## Executive Summary

Nous is a three-tier persistent memory architecture library built for always-on AI agent systems. It provides exactly what OlogosAI currently lacks: durable semantic memory that survives restarts, structured recall, and conversation continuity. This document assesses integration feasibility and proposes the Ologos.BotNotes architecture.

---

## Current OlogosAI Memory State

**What exists:**
- Claude Code auto-memory in `~/.claude/projects/.../memory/` — markdown files loaded into context
- SQLite `memory.db` (tracked but unclear usage)
- No semantic search, no embeddings, no cross-session recall
- Memory is flat files, manually curated, context-window dependent

**Pain points:**
- No persistent conversation history across sessions
- No semantic retrieval (can't ask "what did we decide about X?")
- No structured knowledge graph
- Memory grows stale without importance-weighted retention
- No worker/agent isolation if we scale to multi-agent

---

## Nous Architecture Summary

### Three-Tier Model

| Tier | Storage | Access | Search | OlogosAI Use Case |
|------|---------|--------|--------|-------------------|
| **1. Director** | PostgreSQL | Global | Semantic + keyword | My curated knowledge, decisions, lessons |
| **2. Worker Shared** | PostgreSQL (name-scoped) | Per-worker | Keyword | Future worker agents (Telegram bot, etc.) |
| **3. Worker Shell** | SQLite per-worker | Worker-exclusive | Keyword | Portable identity for specialized agents |

### Key Capabilities

1. **Embedded vector retrieval** — Local embeddings via Ollama (nomic-embed-text) or OpenAI
2. **Context injection** — `ContextAssembler` builds memory-enriched prompts before every LLM call
3. **Knowledge graph** — Triplets (subject, predicate, object) for relational reasoning
4. **Conversation logging** — Durable conversation history with graph-linked retrieval
5. **Importance-weighted retention** — Automatic pruning of low-value memories
6. **Crash recovery** — WAL mode, session continuity

### Dependencies

- Python 3.11+
- PostgreSQL (shared state)
- Ollama (optional, for semantic search)

---

## Proposed Integration: Ologos.BotNotes

### Concept

Create a dedicated GitHub repository `ologos-repos/Ologos.BotNotes` that serves as my long-term memory backing store, synced with Nous. This gives:

1. **Git-backed durability** — Memory state is versioned and recoverable
2. **Human-readable format** — Markdown exports for inspection
3. **Cross-system portability** — Other Ologos agents can read/write
4. **Separation of concerns** — Memory lives outside the code repo

### Proposed Directory Structure

```
Ologos.BotNotes/
├── README.md                    # Overview and access instructions
├── director/
│   ├── decisions.md             # Curated decisions (human-readable export)
│   ├── lessons.md               # Lessons learned
│   ├── facts.md                 # Factual knowledge
│   └── projects.md              # Project context
├── workers/
│   ├── telegram_bot/
│   │   └── memories.md          # Telegram bot worker memories
│   └── chatbot/
│       └── memories.md          # Web chatbot worker memories
├── graph/
│   └── triplets.jsonl           # Knowledge graph export (JSONL)
├── conversations/
│   └── digests/                 # Session summaries (not full logs)
│       └── 2026-03-17.md
├── shells/                      # Worker SQLite shells (gitignored, large)
│   └── .gitkeep
└── sync/
    └── last_sync.json           # Sync metadata
```

### Sync Strategy

1. **On session end** — Export Nous director memories to `director/*.md`
2. **On session start** — Load recent exports into Nous if DB is cold
3. **Periodic** — Push digests to `conversations/digests/`
4. **Manual** — Export graph triplets to `graph/triplets.jsonl`

SQLite shells are NOT committed (too large, binary). They live locally in `~/nous-shells/` with backup scripts.

---

## Integration Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                          OlogosAI Runtime                           │
│  (Telegram Bot, Web Chatbot, Claude Code sessions)                  │
├─────────────────────────────────────────────────────────────────────┤
│                      ContextAssembler (Nous)                        │
│  build_director_context() / build_worker_context()                  │
├───────────────────────────────────────────────────────────────────┤
│                         MemoryStore (Nous)                          │
│  PostgreSQL (shared) + SQLite shells (per-worker)                   │
├───────────────────────────────────────────────────────────────────┤
│                      EmbeddingProvider                              │
│  Ollama nomic-embed-text (local) — no cloud dependency              │
├───────────────────────────────────────────────────────────────────┤
│                      Git Sync Layer                                 │
│  Export to Ologos.BotNotes repo on session boundaries               │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Implementation Phases

### Phase 1: Foundation (Week 1) — COMPLETE
- [x] Create `ologos-corp/Ologos.BotNotes` repo with structure above
- [ ] Install Nous (`pip install nous-memory[ollama]`) on OlogosAI-Host
- [ ] Set up PostgreSQL database `ologos_nous`
- [ ] Verify Ollama has `nomic-embed-text` model
- [ ] Create `nous.toml` config in `~/repos/ologos-ai/`

**BotNotes Repo:** https://github.com/ologos-corp/Ologos.BotNotes

### Phase 2: Director Memory (Week 2)
- [ ] Migrate existing `MEMORY.md` content into Nous director tier
- [ ] Implement session-end export script to BotNotes
- [ ] Implement session-start import from BotNotes
- [ ] Test semantic recall ("what did we decide about X?")

### Phase 3: Telegram Bot Integration (Week 3)
- [ ] Give Telegram bot its own worker shell
- [ ] Wire `build_worker_context()` into bot's prompt injection
- [ ] Enable bot to `remember` and `recall` via Nous
- [ ] Test cross-session memory persistence

### Phase 4: Knowledge Graph (Week 4)
- [ ] Enable triplet extraction from conversations
- [ ] Implement graph-enhanced recall
- [ ] Export graph to `Ologos.BotNotes/graph/triplets.jsonl`

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| PostgreSQL adds complexity | Use existing OlogosAI-Host Postgres or spin up Docker container |
| Embedding model quality | Start with nomic-embed-text (proven), upgrade later if needed |
| Memory bloat | Use RetentionPolicy with importance weighting |
| Sync conflicts | BotNotes is append-mostly; director is single-writer |
| SQLite shells grow large | Exclude from git, implement backup rotation |

---

## Decision Required

Before proceeding, confirm:

1. **PostgreSQL** — Use existing instance or spin up dedicated `ologos_nous` database?
2. **Embedding model** — Ollama nomic-embed-text (768d, local) or OpenAI text-embedding-3-small (cloud)?
3. **BotNotes repo** — Create in `ologos-repos` org now?

---

## Next Steps

1. Create `ologos-repos/Ologos.BotNotes` repository
2. Commit this assessment document
3. Begin Phase 1 implementation

---

## References

- Nous repo: https://github.com/ologos-repos/Nous
- Nous README: Full API and architecture documentation
- OlogosAI current memory: `/home/Ologos/.claude/projects/-home-Ologos-repos-ologos-ai/memory/`
