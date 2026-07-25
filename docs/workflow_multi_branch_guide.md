# Multi-Branch & Multi-Chat Workflow SOP (Antigravity 2.0 + Multi-IDE)

This document specifies the standard operating procedure (SOP) for conducting parallel module development across multiple Antigravity surfaces (**Mac Antigravity 2.0**, **Mac Antigravity IDE**, and **Windows Antigravity IDE**) on the `textile_erp` codebase.

---

## Core Rule: 1 Module = 1 Feature Branch = 1 Task Plan

To work on multiple ERP modules concurrently without context drift, merge conflicts, or unstable `master` builds:

1. **Feature Branching**: Never write feature code directly on `master`. Create a dedicated branch for every module:
   ```bash
   git checkout -b feature/<module-name>
   # Example: git checkout -b feature/02-print-recipes
   ```

2. **In-Repo Task Brief (`docs/plans/*.md`)**:
   Every feature branch MUST have a matching task brief in `docs/plans/` (e.g. `docs/plans/02_print_recipes.md`).
   Because Antigravity chat transcripts are local to each device, the `docs/plans/*.md` file acts as the persistent cross-device memory anchor.

3. **Standard Chat Orientation Prompt Header**:
   When launching a new chat session on ANY device (Mac AG 2.0, Mac AG IDE, Win AG IDE), start your message with:
   ```text
   Target Branch: feature/02-print-recipes
   Plan File: docs/plans/02_print_recipes.md
   Task: [Describe current milestone, e.g. "Implement service singleton and defensive model"]
   ```

---

## Workflow Step-by-Step

### 1. Starting a New Module Task
1. Checkout target feature branch:
   ```bash
   git checkout -b feature/<module-name> master
   ```
2. Update the Plan Matrix in [docs/plans/README.md](plans/README.md) to record the new branch and assigned surface.
3. Start your AG chat session using the Standard Chat Orientation Prompt Header.

### 2. Multi-Device Operations (Mac ↔ Windows)
- **Mac AG IDE**: Ideal for fast UI coding, refactoring, and model creation.
- **Mac AG 2.0**: Ideal for subagent orchestration, background jobs, and plan design.
- **Windows AG IDE**: Ideal for native Windows desktop builds (`flutter run -d windows`) and PowerShell tasks.

**Hand-off between devices**:
1. Run `./tasks/git_checkpoint.sh` (macOS) or `.\tasks\git_commit.ps1` (Windows) to commit and push changes.
2. On the target machine, run:
   ```bash
   git fetch origin
   git checkout feature/<module-name>
   git pull origin feature/<module-name>
   ```
3. Open chat and attach `@docs/plans/[module].md`.

### 3. Using Git Worktrees (Optional - Single Machine Parallelism)
To run two AG sessions on different modules simultaneously on the same machine:
```bash
# Add a clean worktree in a adjacent folder
git worktree add ../textile_erp-print-recipes feature/02-print-recipes

# Open the new worktree folder in Antigravity IDE or AG 2.0
```

---

## Merge Verification Checklist (Feature Branch → Master)

Before merging any feature branch into `master`:

- [ ] **Static Analyzer**: `flutter analyze` inside `frontend/` reports 0 warnings and 0 errors.
- [ ] **Native Token Check**: Verified zero hardcoded colors (`OrganismTheme.colorsOf(context)` used throughout).
- [ ] **Triple-Key Join Check**: All legacy `BILLS`/`DETAIL` joins include `CNO`, `VNO`, and `TYPE`.
- [ ] **Async Safety Check**: Checked `if (!mounted) return;` after all `await` calls in StatefulWidgets.
- [ ] **Knowledge Graph Sync**: Ran `graphify update .` (or `tasks/graphify_update.ps1`).
- [ ] **Master Rebase & Merge**:
  ```bash
  # PowerShell (Windows):
  .\tasks\merge_feature.ps1 -Branch feature/02-print-recipes

  # Bash (macOS):
  ./tasks/merge_feature.sh feature/02-print-recipes
  ```
