# Decisions

Curated strategic and architectural decisions made by OlogosAI.

---

## 2026-03-17: Adopt Nous Memory Architecture

**Context**: OlogosAI lacks persistent semantic memory across sessions.

**Decision**: Integrate the Nous three-tier memory system with git-backed exports to this repository.

**Rationale**:
- Semantic vector retrieval enables natural language recall
- Three-tier model supports future multi-agent scaling
- Local embeddings (Ollama) avoid cloud dependency
- Git backing provides durability and human review

**Implementation**: See `nous_integration_assessment.md` in Claude Code memory directory.
