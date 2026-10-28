---
description: "Execute a read-only 3-dimensional code audit against OpenSpec boundaries and contracts"
---

Execute an independent, read-only code audit against OpenSpec specifications.

**Purpose**: Validate implemented code against OpenSpec planning artifacts (`proposal.md`, `specs/`, `design.md`, `tasks.md`) using an isolated, zero-memory Subagent with **strictly disabled write tools** (`EnableWriteTools: false`). This guarantees the auditor cannot modify code to endorse its own findings.

**Input**: Optionally specify a change name (e.g., `/opsx-audit add-auth`). If omitted, auto-select if only one active change exists, or prompt user.

---

### Audit Steps

1. **Select the change**
   - Run `openspec list --json` to identify active changes.
   - Resolve change path: `openspec/changes/<change-name>/`.
   - Identify modified and newly created code files for this change (via `git status --porcelain` or task logs).

2. **Extract Precise Audit Anchors (Prevent Context Overflow)**
   Extract ONLY the critical boundary criteria from the change artifacts:
   - **From `proposal.md`**: Extract `Scope` (what is allowed) and `Non-Goals / Out-of-Scope` (strict red lines).
   - **From `specs/**/spec.md`**: Extract behavioral requirements, input/output schemas, and error scenarios.
   - **From `design.md`**: Extract architectural decisions, data flow, exception handling strategies, and environment constraints.
   - **From `tasks.md`**: Extract acceptance criteria and verification commands.

3. **Deploy Read-Only Zero-Memory Auditor Subagent**
   Define and invoke an auditor subagent with write permissions explicitly denied:
   ```json
   {
     "Name": "spec-auditor",
     "Description": "Zero-memory, read-only auditor for code verification against OpenSpec contracts.",
     "EnableWriteTools": false,
     "EnableMCPTools": false,
     "EnableSubagentTools": false,
     "SystemPrompt": "You are a strict, adversarial, read-only code auditor. You have NO permission to edit files or run commands. Your sole responsibility is to evaluate code against the provided OpenSpec boundary criteria across 3 distinct dimensions. Be rigorous, fact-based, and objective. Never hallucinate passes."
   }
   ```

4. **Execute 3-Dimensional Audit**
   The auditor reads the code files and the extracted anchors, evaluating across 3 dimensions:
   - **Dimension 1: Functional & Contract Accuracy (`audit_functional.md`)**
     - Does the implementation satisfy all requirements in `spec.md`?
     - Are edge cases and expected error states handled per contract?
     - Have all tasks in `tasks.md` been genuinely fulfilled?
     - *Verdict: PASS | REJECT*
   - **Dimension 2: Runtime Robustness & Engineering Standards (`audit_runtime.md`)**
     - Does the code adhere to virtual environment isolation (`.\.venv\Scripts\python.exe`)?
     - Does the code adhere to the Config-Driven principle (zero script bloat; parameters/paths must be externalized in `configs/` or flags, not duplicated script copies)?
     - Are exceptions caught specifically without bare `except:`?
     - Are resource handles (files, database connections, sessions) properly closed?
     - Are file and variable namings 100% in English with zero Chinese logging?
     - *Verdict: PASS | REJECT*
   - **Dimension 3: Scope Boundary & Security Compliance (`audit_security.md`)**
     - Did the code touch anything defined as `Out-of-Scope` or `Non-Goals` in `proposal.md`?
     - Are credentials, API keys, or private paths hardcoded?
     - Is there potential for command injection, path traversal, or unvalidated input?
     - *Verdict: PASS | REJECT*

5. **Persist Multi-Document Audit Reports**
   Ensure the directory exists: `openspec/changes/<change-name>/audits/`.
   Write the 3 distinct audit documents:
   - `openspec/changes/<change-name>/audits/audit_functional.md`
   - `openspec/changes/<change-name>/audits/audit_runtime.md`
   - `openspec/changes/<change-name>/audits/audit_security.md`

6. **Present Final Verdict to Human**
   - If ALL 3 dimensions **PASS**:
     - State that the code audit passed all gates.
     - Inform the user that the change is cleared for `/opsx-archive`.
   - If ANY dimension is **REJECT**:
     - Detail the specific blocking items and file locations.
     - Block archiving until remediations are made and re-audited.
