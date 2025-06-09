# Workflow: Component Refactoring for Technical Debt (WF_DEV_TECHDEBT_REFACTOR_COMPONENT_001_v1)

**Goal:** To refactor a specific code component to address identified technical debt, improving its quality attributes (e.g., performance, maintainability, readability) while ensuring no regressions, managed by Nova-LeadDeveloper.

**Primary Actor:** Nova-LeadDeveloper (receives refactoring task from Nova-Orchestrator, often based on a `TechDebtCandidates` item).
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedCodeRefactorer, Nova-SpecializedTestAutomator, (potentially Nova-SpecializedCodeDocumenter).

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Refactor component [ComponentName] to address `TechDebtCandidates:[TechDebtKey]`."
- User or another Lead Mode requests refactoring of a specific problematic component, and Orchestrator delegates to LeadDeveloper.
- Part of a planned code quality improvement sprint.

**Pre-requisites by Nova-LeadDeveloper (from Nova-Orchestrator's briefing):**
- The component to be refactored is clearly identified (e.g., file path, class/module name).
- The reason for refactoring and the desired outcome/improvement are understood (e.g., from `CustomData TechDebtCandidates:[TechDebtKey]` (key) - "Improve performance of `OrderProcessor` by 20%", "Reduce complexity of `AuthValidationModule`").
- (Ideally) Existing test coverage for the component exists or can be established first. This should be checked by LeadDeveloper.

---

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator):**

**Phase TDR.0: Pre-flight Checks by Nova-LeadDeveloper**

1.  **Nova-LeadDeveloper: Verify Tech Debt Definition is Ready**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Before creating a refactoring plan or delegating any sub-tasks, perform this critical pre-flight check using `use_mcp_tool`.
    *   **Checks:**
        1.  **Retrieve `TechDebtCandidates` Item:** Use `use_mcp_tool` (`tool_name: 'get_custom_data'`) to retrieve the `CustomData TechDebtCandidates:[TechDebtKey]` entry referenced in your briefing.
        2.  **Check for Existence and Completeness:**
            - Verify that the retrieval did not return `null` or `not found`.
            - Check that the `value` object of the item contains essential fields like `description`, `impact`, and `effort`.
            - **Failure:** If the item is missing or key fields are empty, report to Nova-Orchestrator in your `attempt_completion`: "BLOCKER: The required artifact `TechDebtCandidates:[TechDebtKey]` is missing or incomplete in ConPort. The description of the debt or its impact/effort is not defined. Cannot proceed with refactoring planning." Halt this workflow.
    *   **Output:** The `TechDebtCandidates` item is confirmed to exist and be sufficiently detailed to plan the refactoring work.

**Phase TDR.1: Planning & Preparation by Nova-LeadDeveloper**

2.  **Nova-LeadDeveloper: Receive Task & Analyze Refactoring Scope**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` (e.g., "Refactor [ComponentName] to address [TechDebtReason]"), `Required_Input_Context` (ref to `TechDebtCandidates:[TechDebtKey]`, specific component path).
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "Refactor Component: [ComponentName] - [Date]". Let this be `[RefactorProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[RefactorProgressID]_DeveloperPlan` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Plan items:
            1.  Analyze Current Code & Tests, Define Refactor Strategy (LeadDeveloper).
            2.  (If needed) Enhance Test Coverage Pre-Refactor (Delegate to TestAutomator).
            3.  Execute Refactoring - Iteration 1 (Delegate to CodeRefactorer).
            4.  Run Tests & Linters - Iteration 1 (Delegate to TestAutomator).
            5.  (If more iterations needed, repeat 3 & 4).
            6.  Final Verification & Benchmarking (if applicable) (Delegate to TestAutomator).
            7.  Update Documentation (Delegate to CodeDocumenter).
            8.  Propose Update for `TechDebtCandidates` status (LeadDeveloper, in `attempt_completion`).
    *   **ConPort Action:**
        *   Use `read_file` to analyze current code of `[ComponentName]`.
        *   Define a specific refactoring strategy (e.g., "Extract class X", "Simplify method Y by applying Strategy Pattern", "Replace algorithm Z with library L").
        *   Log this strategy as a `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`, `summary: "Refactoring strategy for [ComponentName]: [Strategy]"`, `rationale: "Addresses [TechDebtKey] by..."`).
        *   Identify key metrics or tests to verify success (from `ProjectConfig:ActiveConfig.testing_preferences` or define new ones). Log these as `CustomData RefactorCriteria:[ComponentName_RefactorCriteriaKey]` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`).
    *   **Output:** Detailed refactoring plan in `LeadPhaseExecutionPlan`. Main `Progress` (integer `id`) and `Decision` (integer `id`) created. `RefactorCriteria` (key) logged.

**Phase TDR.2: Iterative Refactoring & Testing by Specialists**

3.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Enhance Test Coverage (If Needed)**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** Analysis in Step 2 shows inadequate test coverage for safe refactoring.
    *   **Task:** "Before refactoring [ComponentName], ensure sufficient test coverage exists to detect regressions. Add characterization/unit tests as needed."
    *   **`new_task` message for Nova-SpecializedTestAutomator (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (Refactor_[ComponentName]) -> Enhance Pre-Refactor Tests (TestAutomator)",
          "Overall_Developer_Phase_Goal": "Refactor Component [ComponentName].",
          "Specialist_Subtask_Goal": "Enhance test coverage for [ComponentName] before refactoring.",
          "Specialist_Specific_Instructions": [
            "Target Component: [ComponentName] (Path: [path/to/component]).",
            "Review existing tests. Add new tests to cover [Specific_Areas_Identified_By_LeadDeveloper] to ensure behavior is captured before changes.",
            "Ensure all tests (existing and new) pass against the current code.",
            "Commit new/updated test files."
          ],
          "Required_Input_Context_For_Specialist": { "Component_Path": "[...]", "Areas_For_Improved_Coverage": "[...]" },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": ["Paths to new/updated test script files.", "Confirmation all pre-refactor tests pass."]
        }
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Review. Update plan/progress.

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeRefactorer: Execute Refactoring Iteration**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Implement refactoring iteration [N] for [ComponentName] as per strategy in `Decision:[RefactorStrategyDecisionID]` and specific instructions for this iteration."
    *   **`new_task` message for Nova-SpecializedCodeRefactorer:**
        ```json
        {
          "Context_Path": "[ProjectName] (Refactor_[ComponentName]) -> Refactor Iteration [N] (CodeRefactorer)",
          "Overall_Developer_Phase_Goal": "Refactor Component [ComponentName].",
          "Specialist_Subtask_Goal": "Implement refactoring iteration [N]: [Specific Refactoring Action for this iteration, e.g., 'Extract PriceCalculation logic into new class OrderItemPricer'].",
          "Specialist_Specific_Instructions": [
            "Target Component: [ComponentName] (Path: [path/to/component]).",
            "Refactoring Strategy Reference: `Decision:[RefactorStrategyDecisionID]` (integer `id`).",
            "Specific action for this iteration: [Detailed instruction, e.g., 'Create OrderItemPricer.java in src/order/pricing/. Move price calculation methods from Order.java to OrderItemPricer. Update Order.java to use OrderItemPricer.']",
            "Ensure code adheres to standards (`SystemPatterns:[CodingStd_ID]` (integer `id`/name)).",
            "Update/add unit tests for the modified/new code. Tests for `Order.java` might need significant updates.",
            "Run linter on changed files."
          ],
          "Required_Input_Context_For_Specialist": {
            "Component_Path": "[...]",
            "Refactor_Strategy_Decision_ID_String": "[Integer_id_as_string]",
            "Specific_Iteration_Goal_And_Changes": "[...]",
            "Coding_Standards_Ref": { "type": "system_pattern", "id_or_name": "[ID or Name of pattern]" }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Paths to modified/created file(s).",
            "Confirmation of unit tests updated/passed for this iteration.",
            "Confirmation of linter passing for this iteration.",
            "List of ConPort `Decision` (integer `id`s) logged for micro-choices made during this iteration."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Review changes. Update plan/progress.

5.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Run Tests & Linters Post-Iteration**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Run all relevant tests (unit, integration) and linters after refactoring iteration [N] for [ComponentName]."
    *   **Briefing for TestAutomator:** Specify scope of tests to run (module-specific, plus any designated integration tests). Command from `ProjectConfig:ActiveConfig.testing_preferences`. Expect detailed pass/fail report.
    *   **Nova-LeadDeveloper Action:** If failures, log `ErrorLogs` (key) (or instruct specialist) and delegate fixes back to CodeRefactorer (looping steps 4 & 5 for that part of refactoring). Update plan/progress.

*(... Repeat steps 4 & 5 for further refactoring iterations if the plan involves multiple distinct refactoring steps on the component ...)*

6.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Final Verification & Benchmarking (if applicable)**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** All planned refactoring iterations complete, all tests pass.
    *   **Task:** "Perform final verification of refactored [ComponentName] against criteria in `CustomData RefactorCriteria:[Key]` and run full regression tests potentially impacting this component."
    *   **Briefing for TestAutomator:** Include `RefactorCriteria` (key) (e.g., performance targets, cyclomatic complexity reduction target if measurable by a tool). Command for full relevant regression suite. Expect benchmark results and regression test suite outcomes.
    *   **Nova-LeadDeveloper Action:** Review. If criteria not met or regressions found, further refactoring/fixing needed (loop back). Update plan/progress. If performance was a goal, ensure `PerformanceNotes` (key) are logged by TestAutomator.

**Phase TDR.3: Documentation & Closure**

7.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter: Update Documentation**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** Refactoring complete and verified.
    *   **Task:** "Update all inline (docstrings) and technical documentation (e.g., in `/docs/`) for the refactored [ComponentName] to reflect changes in structure, API, or behavior."
    *   **Briefing for CodeDocumenter:** Point to refactored code, highlight key changes from the original `TechDebtCandidates` item and refactoring `Decisions`.
    *   **Nova-LeadDeveloper Action:** Review. Update plan/progress.

8.  **Nova-LeadDeveloper: Propose Update for `TechDebtCandidates` Item & Log Final Decision**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Based on the outcome, prepare a proposal for updating the original `CustomData TechDebtCandidates:[TechDebtKey]` (key) entry. This is NOT a direct update by LeadDeveloper, but a proposal. LeadDeveloper will state in its `attempt_completion` to Orchestrator: "Refactoring for `TechDebtCandidates:[TechDebtKey]` is complete. Suggest updating its status to 'RESOLVED' and adding notes: '[Summary of improvements]'." Nova-Orchestrator might then delegate the actual update to Nova-LeadArchitect/ConPortSteward if ConPort governance rules dictate.
        *   Log a final `Decision` (integer `id`) for the refactoring phase using `use_mcp_tool` (`tool_name: 'log_decision'`, `summary: "[ComponentName] refactoring completed. Addressed TechDebtCandidates:[TechDebtKey]. Outcome: [e.g., Performance improved by X%, Complexity reduced by Y points]."`). Link this decision to `[RefactorProgressID]`.
    *   **Output:** Proposal for `TechDebtCandidates` (key) update ready. Final refactoring `Decision` (integer `id`) logged.

9.  **Nova-LeadDeveloper: Finalize Refactoring Phase**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Update main phase `Progress` (`[RefactorProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description.
    *   **Output:** Refactoring phase documented and closed for LeadDeveloper.

10. **Nova-LeadDeveloper: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Report completion, summary of improvements, verification status, key ConPort items (Decisions, new TechDebt if any), and the proposed update/status for the original `TechDebtCandidates:[TechDebtKey]`.

**Key ConPort Items Involved:**
- Progress (integer `id`): Overall phase, specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[RefactorProgressID]_DeveloperPlan (key).
- Decisions (integer `id`): Refactoring strategy, completion confirmation, micro-choices by specialists.
- CustomData RefactorCriteria:[Key] (key).
- CustomData TechDebtCandidates:[Key] (key) (Read, and propose update to its status/notes). Potentially new TechDebtCandidates logged.
- (Potentially) Updated `SystemPatterns` (integer `id`/name) or new `CodeSnippets` (key).
- (Potentially) `ErrorLogs` (key) if tests fail during refactoring and represent new issues.
- (Potentially) `PerformanceNotes` (key) if benchmarking was done.