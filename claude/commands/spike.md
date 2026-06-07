Run a spike — a short, throwaway proof-of-concept to answer a feasibility question BEFORE committing to a plan. Use when you genuinely cannot spec first because you don't yet know if/how something works (e.g. "can the Notion API do X?", "will this integration even connect?").

## Principles

- **Goal is to learn, not to ship.** The code is throwaway.
- **No contract, no gates, no full spec.** This is deliberately outside the normal workflow.
- **Timebox it.** Smallest possible POC that answers the question — not a feature.

## What to do

1. Pick the executor: **developer** by default, or the relevant specialist (**llm-engineer** for LLM/RAG feasibility, **data-engineer** for data/pipeline feasibility, **frontend-engineer** for UI feasibility).
2. Build the **minimal POC** that answers the question: can it connect / authenticate / read / write / produce the needed shape? Hardcode and shortcut freely — this is throwaway.
3. Produce a short **findings report** (in chat, and optionally `specs/spikes/<slug>.md`):
   - **Question:** what we were testing
   - **Result:** works / doesn't / partially — with evidence
   - **Obstacles:** auth, rate limits, data shape, missing capabilities, cost
   - **Recommendation:** proceed to `/plan-feature` / different approach / not feasible
4. Append a one-line note to `specs/journal.md` (gotchas discovered feed the self-improvement loop).
5. **Do not** silently grow the POC into the real feature. If it pans out, say so and start `/plan-feature` to build it properly.

## Spike question

$ARGUMENTS
