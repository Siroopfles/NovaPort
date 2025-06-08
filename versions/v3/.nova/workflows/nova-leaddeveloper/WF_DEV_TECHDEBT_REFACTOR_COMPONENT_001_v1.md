# Workflow: Component Refactoring for Technical Debt (WF_DEV_TECHDEBT_REFACTOR_COMPONENT_001_v1)

**Goal:** To refactor a specific code component to address identified technical debt, improving its quality attributes (e.g., performance, maintainability, readability) while ensuring no regressions, managed by Nova-LeadDeveloper.

**Primary Orchestrator Actor:** Nova-LeadDeveloper (receives refactoring task from Nova-Orchestrator, often based on a `TechDebtCandidates` item).
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedCodeRefactorer, Nova-SpecializedTestAutomator, (potentially Nova-SpecializedCodeDocumenter).

**Trigger / Orchestrator Recognition (for Nova-Orchestrator to delegate to Nova-LeadDeveloper):**
- A `CustomData TechDebtCandidates:[key]` item is prioritized for action.
- User or another Lead Mode requests refactoring of a specific problematic component.
- Part of a planned code quality improvement sprint.

**Pre-requisites by Nova-Orchestrator (before delegating this phase to Nova-LeadDeveloper):**
- The component to be refactored is clearly identified (e.g., file path, class/module name).
- The reason for refactoring and the desired outcome/improvement are understood (e.g., "Improve performance of `OrderProcessor` by 20%", "Reduce complexity of `AuthValidationModule`").
- (Ideally) Existing test coverage for the component exists or can be established first.

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator):**

**Phase TDR.1: Planning & Preparation by Nova-LeadDeveloper**

1.  **Nova-LeadDeveloper: Receive Task & Analyze Refactoring Scope**
    *   **Action:** Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` (e.g., "Refactor [ComponentName] to address [TechDebtReason]"), `Required_Input_Context` (ref to `TechDebtCandidates:[key]`, specific component path).
    *   **ConPort:**
        *   Log main `Progress` (integer `id`) item: "Refactor Component: [ComponentName] - [Date]".
        *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[RefactorProgressID]_DeveloperPlan` (key)). Plan items:
            1.  Analyze Current State & Define Refactor Strategy (LeadDeveloper, CodeRefactorer).
            2.  (If needed) Enhance Test Coverage Pre-Refactor (TestAutomator).
            3.  Execute Refactoring - Step 1 (CodeRefactorer).
            4.  Run Tests & Linters - Step 1 (TestAutomator).
            5.  Execute Refactoring - Step N (CodeRefactorer).
            6.  Run Tests & Linters - Step N (TestAutomator).
            7.  Final Verification & Benchmarking (TestAutomator/LeadDeveloper).
            8.  Update Documentation (CodeDocumenter).
            9.  Update `TechDebtCandidates` status (LeadDeveloper/CodeRefactorer).
    *   **Logic:**
        *   Review the `TechDebtCandidates:[key]` entry and the current code of `[ComponentName]`.
        *   Define a specific refactoring strategy (e.g., "Extract class X", "Simplify method Y", "Replace algorithm Z").
        *   Log this strategy as a `Decision` (integer `id`).
        *   Identify key metrics or tests to verify success (from `ProjectConfig:ActiveConfig.testing_preferences` or define new ones). Log these as `CustomData RefactorCriteria:[ComponentName_RefactorCriteriaKey]` (key).
    *   **Output:** Detailed refactoring plan in `LeadPhaseExecutionPlan`. Main `Progress` (integer `id`) and `Decision` (integer `id`) created. `RefactorCriteria` (key) logged.

**Phase TDR.2: Sequential Execution of Refactoring & Testing by Specialists**

2.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Enhance Test Coverage (If Needed)**
    *   **Task:** "Before refactoring [ComponentName], ensure sufficient test coverage exists to detect regressions. Add tests if needed."
    *   **Briefing for TestAutomator:** Detail component, existing tests, areas needing more coverage based on refactoring plan. Expect path to new/updated test files and test run confirmation.
    *   **Nova-LeadDeveloper Action:** Review, update plan/progress.

3.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeRefactorer: Execute Refactoring Step**
    *   **Task:** "Implement refactoring step [StepDescription] for [ComponentName] as per strategy in `Decision:[RefactorStrategyDecisionID]`."
    *   **`new_task` message for Nova-SpecializedCodeRefactorer:**
        ```
        Subtask_Briefing:
          Overall_Developer_Phase_Goal: "Refactor Component [ComponentName]."
          Specialist_Subtask_Goal: "Implement refactoring step: [Specific Refactoring Action, e.g., 'Extract PriceCalculation logic into new class']."
          Specialist_Specific_Instructions:
            - "Target Component: [ComponentName] (Path: [path/to/component])."
            - "Refactoring Strategy Reference: `Decision:[RefactorStrategyDecisionID]` (integer `id`)."
            - "Implement the specific change: [Detailed instruction for this step]."
            - "Ensure code adheres to standards (`SystemPatterns:[CodingStd_ID]` (integer `id`/name))."
            - "Update/add unit tests for the modified code."
            - "Run linter."
            - "Log any micro-decisions as a `Decision` (integer `id`)."
          Required_Input_Context_For_Specialist:
            - Component_Path: "[...]"
            - Refactor_Strategy_Decision_ID: [Integer `id`]
            - Coding_Standards_Ref: { type: "system_pattern", id: [integer_id_of_pattern] } // or name
            - Pre_Refactor_Test_Coverage_Report_Ref: "[ConPort key or path if applicable]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Paths to modified file(s)."
            - "Confirmation of unit tests updated/passed."
            - "Confirmation of linter passing."
            - "List of ConPort `Decision` (integer `id`s) logged for this step."
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Review changes. Update plan and progress.

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Run Tests & Linters**
    *   **Task:** "Run all relevant tests (unit, integration) and linters after refactoring step for [ComponentName]."
    *   **Briefing for TestAutomator:** Specify scope of tests to run. Expect detailed pass/fail report.
    *   **Nova-LeadDeveloper Action:** If failures, delegate fixes back to CodeRefactorer (looping steps 3 & 4 for that part of refactoring). Update plan/progress.

*(... Repeat steps 3 & 4 for iterative refactoring if the plan involves multiple distinct refactoring steps on the component ...)*

5.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Final Verification & Benchmarking**
    *   **Task:** "Perform final verification of refactored [ComponentName] against criteria in `RefactorCriteria:[Key]` and run full regression tests."
    *   **Briefing for TestAutomator:** Include `RefactorCriteria` (key) (e.g., performance targets). Expect benchmark results and regression test suite outcomes.
    *   **Nova-LeadDeveloper Action:** Review. If criteria not met or regressions, further refactoring/fixing needed (loop back).

**Phase TDR.3: Documentation & Closure by Nova-LeadDeveloper & Specialists**

6.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter: Update Documentation**
    *   **Task:** "Update all inline and technical documentation for the refactored [ComponentName]."
    *   **Briefing for CodeDocumenter:** Point to refactored code, highlight key changes. Expect confirmation of doc updates.
    *   **Nova-LeadDeveloper Action:** Review. Update plan/progress.

7.  **Nova-LeadDeveloper (or delegate to Nova-SpecializedCodeRefactorer): Update TechDebtCandidates Item**
    *   **Action:** Update the original `CustomData TechDebtCandidates:[TechDebtKey]` (key) entry in ConPort:
        *   Set status to `RESOLVED` or `PARTIALLY_ADDRESSED`.
        *   Add `actual_outcome` field summarizing improvements made.
        *   Link to the `Progress` (integer `id`) item for this refactoring effort.
    *   **Output:** `TechDebtCandidates` (key) item updated.

8.  **Nova-LeadDeveloper: Consolidate & Finalize Refactoring**
    *   **Action:**
        *   Log final `Decision` (integer `id`) for refactoring completion (e.g., "[ComponentName] refactoring completed, meeting all criteria. Quality improved.").
        *   Update main phase `Progress` (integer `id`) to DONE.
        *   If significant, update `active_context.state_of_the_union` (via appropriate mechanism).
    *   **Output:** Refactoring phase documented and closed.

9.  **Nova-LeadDeveloper: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, summary of improvements, verification status, key ConPort items.

**Key ConPort Items Created/Updated:**
-   `Progress` (integer `id`): Overall phase, specialist subtasks.
-   `CustomData LeadPhaseExecutionPlan:[RefactorProgressID]_DeveloperPlan` (key).
-   `Decisions` (integer `id`): Refactoring strategy, completion confirmation.
-   `CustomData RefactorCriteria:[Key]` (key).
-   `CustomData TechDebtCandidates:[Key]` (key) (status updated).
-   (Potentially) Updated `SystemPatterns` (integer `id`/name) or new `CodeSnippets` (key).
-   (Potentially) `ErrorLogs` (key) if tests fail during refactoring.
-   (Potentially) `PerformanceNotes` (key) if benchmarking was done.