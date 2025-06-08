# Workflow: Manage Prioritized Technical Debt Item (WF_ORCH_MANAGE_TECH_DEBT_ITEM_001_v1)

**Goal:** To orchestrate the analysis, planning, and resolution of a prioritized technical debt item logged in ConPort.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Primary Lead Mode Actors (delegated to by Nova-Orchestrator):** Nova-LeadDeveloper (for refactoring), Nova-LeadArchitect (for impact/design if TD is architectural), Nova-LeadQA (for verifying fix).

**Trigger / Recognition:**
- User explicitly requests to address a specific `CustomData TechDebtCandidates:[TechDebtKey]` (key).
- During project planning or sprint review, a `TechDebtCandidates` item is prioritized for resolution (e.g., based on its impact/effort score).
- `NovaSystemConfig:ActiveSettings.mode_behavior.nova-orchestrator.tech_debt_review_trigger` (e.g., "if_impact_score_above_X") flags an item.

**Pre-requisites by Nova-Orchestrator:**
- ConPort is `[CONPORT_ACTIVE]`.
- A specific `CustomData TechDebtCandidates:[TechDebtKey]` (key) has been identified and prioritized.
- The `TechDebtCandidates` item contains a reasonable description of the debt, its location, and potential impact.

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase TD.1: Initial Assessment & Refactoring Planning**

1.  **Nova-Orchestrator: Retrieve Tech Debt Details & Assess Architectural Impact**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Log a main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "Manage Tech Debt: [TechDebtKey]". Let this be `[TechDebtProgressID]`.
        *   Use `use_mcp_tool` (`tool_name: 'get_custom_data'`, `category: 'TechDebtCandidates'`, `key: '[TechDebtKey_From_User]'`) to retrieve the full details of the tech debt item.
    *   **Condition:** If the tech debt description suggests significant architectural impact or requires design changes before refactoring:
        *   **Delegate to Nova-LeadArchitect:**
            *   **Task:** "Analyze `TechDebtCandidates:[TechDebtKey]` for architectural impact and propose design changes or refactoring approach."
            *   **Briefing for LeadArchitect (schematic):**
                ```json
                {
                  "Context_Path": "TechDebt_[TechDebtKey] (Orchestrator) -> ArchAnalysis (LeadArchitect)",
                  "Overall_Project_Goal": "Resolve prioritized tech debt item [TechDebtKey].",
                  "Phase_Goal": "Assess architectural impact of [TechDebtKey] and define/refine refactoring design if needed.",
                  "Lead_Mode_Specific_Instructions": [
                    "Review `TechDebtCandidates:[TechDebtKey]` and related code/ConPort items.",
                    "Determine if fixing this requires architectural changes or a specific design pattern for refactoring.",
                    "If so, your SystemDesigner should document these changes in `SystemArchitecture` (key) or as a `Decision` (integer `id`).",
                    "Provide an updated refactoring approach/specification for LeadDeveloper."
                  ],
                  "Required_Input_Context": { "TechDebtCandidate_Ref": { "type": "custom_data", "category": "TechDebtCandidates", "key": "[TechDebtKey]" } },
                  "Expected_Deliverables_In_Attempt_Completion_From_Lead": ["Refined refactoring specification", "Keys/IDs of any new/updated Arch/Decision items."]
                }
                ```
            *   Await LeadArchitect's `attempt_completion`. The output (refined spec) becomes input for LeadDeveloper.
    *   **Output:** Full tech debt details and (if applicable) architectural guidance/refined spec ready. Update `[TechDebtProgressID]`.

**Phase TD.2: Refactoring Implementation (Nova-Orchestrator -> Nova-LeadDeveloper)**

2.  **Nova-Orchestrator: Delegate Refactoring to Nova-LeadDeveloper**
    *   **DoR Check:** Tech debt details are clear. Architectural input (if needed) is available.
    *   **Action:** Update `[TechDebtProgressID]` status to "REFACTORING_IN_PROGRESS".
    *   **Task:** "Delegate the refactoring of code related to `TechDebtCandidates:[TechDebtKey]` to Nova-LeadDeveloper."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```json
        {
          "Context_Path": "TechDebt_[TechDebtKey] (Orchestrator) -> Refactor (LeadDeveloper)",
          "Overall_Project_Goal": "Resolve prioritized tech debt item [TechDebtKey].",
          "Phase_Goal": "Implement code refactoring to address `TechDebtCandidates:[TechDebtKey]`, ensuring all tests pass and quality standards are met.",
          "Lead_Mode_Specific_Instructions": [
            "Target Tech Debt: `CustomData TechDebtCandidates:[TechDebtKey]` (key). Review its details and any architectural guidance from LeadArchitect (see `Refined_Refactoring_Spec_From_LeadArch`).",
            "Execute your standard refactoring workflow (e.g., `.nova/workflows/nova-leaddeveloper/WF_DEV_TECHDEBT_REFACTOR_COMPONENT_001_v1.md`) to manage your team (CodeRefactorer, TestAutomator) for this task.",
            "Key goals: Address the described debt, improve code quality/performance as specified, ensure no regressions by running all relevant tests.",
            "Log any significant refactoring `Decisions` (integer `id`) or new `CodeSnippets` (key).",
            "In your `attempt_completion`, provide a summary of changes and confirm test/linter status. Also indicate the new suggested status for `TechDebtCandidates:[TechDebtKey]` (e.g., 'RESOLVED', 'PARTIALLY_ADDRESSED')."
          ],
          "Required_Input_Context": {
            "TechDebtCandidate_Ref": { "type": "custom_data", "category": "TechDebtCandidates", "key": "[TechDebtKey]" },
            "Refined_Refactoring_Spec_From_LeadArch_If_Any": "[Output from LeadArchitect in TD.1, or null]",
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig" }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Summary of refactoring performed.",
            "Confirmation of all relevant tests passing and linters clean.",
            "List of key ConPort items created (Decisions, CodeSnippets).",
            "Suggested new status and outcome notes for `TechDebtCandidates:[TechDebtKey]`."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after LeadDeveloper's `attempt_completion`:** Review. Update `[TechDebtProgressID]`.

**Phase TD.3: Verification & Closure**

3.  **Nova-Orchestrator: Delegate Verification of Refactoring to Nova-LeadQA**
    *   **DoR Check:** LeadDeveloper reports refactoring complete, all their tests pass.
    *   **Action:** Update `[TechDebtProgressID]` status to "VERIFICATION_PENDING".
    *   **Task:** "Delegate QA verification for the refactored code related to `TechDebtCandidates:[TechDebtKey]` to Nova-LeadQA."
    *   **`new_task` message for Nova-LeadQA (schematic):**
        ```json
        {
          "Context_Path": "TechDebt_[TechDebtKey] (Orchestrator) -> VerifyRefactor (LeadQA)",
          "Overall_Project_Goal": "Resolve prioritized tech debt item [TechDebtKey].",
          "Phase_Goal": "Verify that the refactoring for `TechDebtCandidates:[TechDebtKey]` was successful, introduced no regressions, and achieved its quality goals.",
          "Lead_Mode_Specific_Instructions": [
            "Target: Refactored code related to `TechDebtCandidates:[TechDebtKey]`. Dev changes summary: [From LeadDev's output].",
            "1. Your TestExecutor should run targeted regression tests on areas affected by the refactoring.",
            "2. If performance was a goal, execute relevant performance tests (`WF_QA_PERFORMANCE_TEST_EXECUTION_001_v1.md` for guidance).",
            "3. If complexity reduction was a goal, review code (or delegate to FlowAsk for metrics if possible) for clarity improvements.",
            "4. Log any new `ErrorLogs` (key) if regressions are found.",
            "Report on whether the refactoring goals (from `TechDebtCandidates` item or `RefactorCriteria`) were met and if system stability is maintained."
          ],
          "Required_Input_Context": {
            "TechDebtCandidate_Ref": { "type": "custom_data", "category": "TechDebtCandidates", "key": "[TechDebtKey]" },
            "Refactor_Criteria_Ref_If_Any": { "type": "custom_data", "category": "RefactorCriteria", "key": "[ComponentName_RefactorCriteriaKey]" },
            "Summary_Of_Dev_Changes": "[...]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": ["Verification summary", "Pass/fail status", "List of any new `ErrorLogs` (keys)."]
        }
        ```
    *   **Nova-Orchestrator Action:** If QA finds issues, loop back to TD.2 (LeadDeveloper for fixes). Update `[TechDebtProgressID]`.

4.  **Nova-Orchestrator: Finalize Tech Debt Item**
    *   **DoR Check:** LeadQA confirms successful verification.
    *   **Action:**
        *   Delegate to `Nova-LeadArchitect` (ConPortSteward) to update the `CustomData TechDebtCandidates:[TechDebtKey]` (key) entry. Briefing: "Update TD item `[TechDebtKey]`. First `get_custom_data`, then modify the `value` to set status to 'RESOLVED' and add resolution date and summary of outcome (from LeadDeveloper/LeadQA reports). Then use `log_custom_data` to save the updated object."
        *   Update `[TechDebtProgressID]` to "COMPLETED_RESOLVED" using `use_mcp_tool`.
        *   Update `active_context.state_of_the_union` if the resolution was significant.
        *   Inform user of resolution.
    *   **Output:** Tech debt item formally closed.

**Key ConPort Items Involved:**
- CustomData TechDebtCandidates:[key] (Read, and its status eventually updated).
- Progress (integer `id`) (Overall orchestration, Lead phases, Specialist subtasks).
- Decisions (integer `id`) (Refactoring strategy, specific implementation choices, closure decision).
- CodeSnippets (key) (If refactored code is a good example).
- ErrorLogs (key) (If QA finds regressions).
- PerformanceNotes (key) (If performance was tested).
- (Reads) SystemArchitecture (key), ProjectConfig (key), SystemPatterns (integer `id`/name).