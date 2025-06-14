# Workflow: Component Refactoring for Technical Debt (WF_DEV_TECHDEBT_REFACTOR_COMPONENT_001_v1)

**Goal:** To refactor a specific code component to address identified technical debt, improving its quality attributes while ensuring no regressions.

**Primary Actor:** Nova-LeadDeveloper
**Primary Specialist Actors:** Nova-SpecializedCodeRefactorer, Nova-SpecializedTestAutomator, Nova-SpecializedCodeDocumenter

**Trigger / Recognition:**
- Tasked by `Nova-Orchestrator` to address a prioritized `TechDebtCandidates` item.
- User or another Lead requests refactoring of a problematic component.

**Pre-requisites by Nova-LeadDeveloper (from Nova-Orchestrator's briefing):**
- The component to be refactored and the reason/goal are clearly defined, typically in a `CustomData TechDebtCandidates:[TechDebtKey]` item.

**Reference Milestones for your Single-Step Loop:**

**Milestone TDR.0: Pre-flight & Readiness Check**
*   **Goal:** Verify the technical debt item is clearly defined and ready to be worked on.
*   **Suggested Lead Action:**
    1.  Your first action MUST be a "Definition of Ready" check.
    2.  Use `use_mcp_tool` to retrieve the `TechDebtCandidates` item from your briefing.
    3.  **Gated Check:** If the item is missing or lacks essential fields (`description`, `impact`), `attempt_completion` with a `BLOCKER:` status. Do not proceed.

**Milestone TDR.1: Planning & Preparation**
*   **Goal:** Analyze the code, define a specific refactoring strategy, and ensure adequate test coverage.
*   **Suggested Lead Action & Specialist Sequence:**
    1.  **LeadDeveloper Action:** Log a main `Progress` item for this refactoring cycle.
    2.  **LeadDeveloper Action:** Analyze the current code. Define a specific refactoring strategy (e.g., "Extract class X", "Apply Strategy Pattern") and log it as a `Decision`.
    3.  **LeadDeveloper Action:** Assess existing test coverage. If it's inadequate for a safe refactor, this becomes the first task.
    4.  **Delegate to `Nova-SpecializedTestAutomator` (if needed):**
        *   **Subtask Goal:** "Enhance test coverage for [ComponentName] before refactoring."
        *   **Briefing Details:** Instruct to add characterization tests to capture the current behavior and ensure all tests pass against the original code.

**Milestone TDR.2: Iterative Refactoring & Verification**
*   **Goal:** Apply the refactoring changes and continuously verify that no regressions are introduced.
*   **Suggested Specialist Sequence & Briefing Guidance (this can be a loop of several delegations):**
    1.  **Delegate to `Nova-SpecializedCodeRefactorer`:**
        *   **Subtask Goal:** "Implement refactoring iteration [N] for [ComponentName] as per the strategy in `Decision:[ID]`."
        *   **Briefing Details:** Provide a very specific, atomic action (e.g., "Extract method Y into new class Z"). Instruct to update/add unit tests for the modified code and run linters.
    2.  **Delegate to `Nova-SpecializedTestAutomator`:**
        *   **Subtask Goal:** "Run all relevant tests (unit, integration) and linters after refactoring iteration [N]."
        *   **Briefing Details:** Specify the test scope. Expect a detailed pass/fail report. If failures occur, loop back to the `CodeRefactorer` for fixes.

**Milestone TDR.3: Final Verification & Documentation**
*   **DoR Check:** All planned refactoring iterations are complete and all tests pass.
*   **Goal:** Perform final verification against refactoring goals and update documentation.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedTestAutomator` (if performance was a goal):**
        *   **Subtask Goal:** "Perform final verification and benchmarking against criteria in `RefactorCriteria:[Key]`."
        *   **Briefing Details:** Provide the ConPort key for the success criteria. Request benchmark results and a full regression run.
    2.  **Delegate to `Nova-SpecializedCodeDocumenter`:**
        *   **Subtask Goal:** "Update all inline and technical documentation for the refactored [ComponentName]."
        *   **Briefing Details:** Point to the refactored code and highlight the key changes.

**Milestone TDR.4: Closure**
*   **Goal:** Finalize the refactoring cycle and report the outcome.
*   **Suggested Lead Action:**
    1.  **Log Final Decision:** Log a `Decision` summarizing the completion and outcome of the refactoring.
    2.  **Propose TechDebt Update:** Prepare the text for updating the original `TechDebtCandidates` item (e.g., status 'RESOLVED', resolution notes).
    3.  **Update Progress:** Update the main `Progress` item to 'DONE'.
    4.  **Report to Orchestrator:** In your `attempt_completion`, report the summary of improvements, verification status, and the proposed update for the `TechDebtCandidates` item.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData (`TechDebtCandidates`, `RefactorCriteria`, `CodeSnippets`, `ErrorLogs`)