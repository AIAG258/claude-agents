## Learned Patterns — Always Active (cross-project memory)

> This is the squad's **long-term, cross-project memory**. It loads in every session, every project. Entries are durable lessons that apply broadly to the user's work (automations, integrations, optimizations) — recurring gotchas, reliable patterns, things that wasted time once and never should again.

**How entries get here:** at end-of-phase harvest (or `/retro`), **teamlead proposes** a candidate cross-project lesson and the **user approves** before it is written here. After a change, run `sync.ps1` to deploy to `~/.claude/rules/`. Do not auto-write to this file without approval.

**Keep it tight.** One line per lesson, signal only — this is read on every session, so noise costs context everywhere. Prune stale or superseded entries.

**Entry format:**
```
- [<area> · added <YYYY-MM-DD>] <lesson / pattern>  (why: <one-clause rationale>)
```

---

### Integrations & APIs
<!-- e.g. - [Notion API · added 2026-06-07] Paginate with start_cursor; page size caps at 100  (why: silent truncation otherwise) -->

### Automations & pipelines
<!-- recurring patterns for the user's automation work -->

### Stack & tooling gotchas
<!-- version pins, config traps, build quirks worth remembering across projects -->

<!-- (empty until the first harvest writes approved lessons here) -->
