# Ambaji Sarees ERP — Build Plans (Claude → Gemini)

> **Architect**: Claude (planning, context, prompts)  
> **Builder**: Gemini (execution in Antigravity IDE)  
> **Created**: 2026-07-15

Each `.md` file in this directory is a self-contained task brief with:
1. **Business Context** — Why this matters to the textile workflow
2. **Technical Context** — Existing code, schemas, patterns to follow
3. **Acceptance Criteria** — What "done" looks like
4. **Gemini Prompt** — Copy-paste ready prompt for execution

---

## Plan Index

| # | File | Feature | Status |
|---|------|---------|--------|
| 01 | [01_media_library.md](file:///c:/Users/smitt/.gemini/antigravity/scratch/textile_erp/docs/plans/01_media_library.md) | Media Library — Central File Management Hub | 🟡 Draft |

---

## Execution Rules for Gemini

1. **Read `/flutter` workflow** before starting any task
2. **Follow the Audit-First workflow**: Schema docs → Model → Service → Screen
3. **Never hardcode colors** — use `OrganismTheme.colorsOf(context)`
4. **Never import `index.dart`** inside the organism_design library
5. **Use Edge Functions** for all database writes (never `.insert()`)
6. **Include `TYPE` in all BILLS joins** to prevent row explosions
7. **Check `if (!mounted) return;`** after every `await` in StatefulWidgets
8. **Defensive JSON parsing** — `(json['X'] as num?)?.toDouble() ?? 0.0`
