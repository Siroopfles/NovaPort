# Workflow: Feature Implementation Lifecycle (within Development Phase) (WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1)

**Goal:** To manage the complete development lifecycle of a feature or significant component, from receiving specifications to delivering tested, documented, and integrated code, by coordinating a team of development specialists.

**Primary Actor:** Nova-LeadDeveloper
**Primary Specialist Actors:** Nova-SpecializedFeatureImplementer, Nova-SpecializedTestAutomator, Nova-SpecializedCodeDocumenter, (potentially Nova-SpecializedCodeRefactorer).

**Trigger / Recognition:**
- `Nova-Orchestrator` initiates the "Development Phase" for a new feature.
- Part of `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md` or `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`.

**Pre-requisites by Nova-LeadDeveloper:**
- Detailed feature specifications (`FeatureScope`, `AcceptanceCriteria`) and architectural designs (`SystemArchitecture`, `APIEndpoints`) are finalized and approved in ConPort.
- `ProjectConfig:ActiveConfig` is defined.

**Reference Milestones for your Single-Step Loop:**

**Milestone DEV.0: Pre-flight & Readiness Check**
*   **Goal:** Verify all specifications and designs are approved before starting development.
*   **Suggested Lead Action:**
    1.  Your first action MUST be a "Definition of Ready" check.
    2.  Use `use_mcp_tool` to retrieve all prerequisite ConPort items from your briefing (`FeatureScope`, `SystemArchitecture`, `APIEndpoints`, etc.).
    3.  **Gated Check:** If any required spec is missing or not 'APPROVED'/'FINAL', immediately `attempt_completion` with a `BLOCKER:` status to `Nova-Orchestrator`. Do not proceed.

**Milestone DEV.1: Planning & Implementation Breakdown**
*   **Goal:** Analyze requirements and create a high-level plan of development components.
*   **Suggested Lead Action:**
    1.  Log a main `Progress` item for the feature implementation phase.
    2.  Review all specifications from ConPort. Log any high-level implementation `Decisions`.
    3.  Create and log your `LeadPhaseExecutionPlan`. This plan should be a sequence of the milestones below, broken down into logical components (e.g., "Implement Backend API Endpoint X", "Implement Frontend Component Y").

**Milestone DEV.2: Component Implementation & Testing (Iterative)**
*   **Goal:** Implement and test each component of the feature sequentially.
*   **Suggested Specialist Sequence & Briefing Guidance (run this loop for each component):**
    1.  **Delegate to `Nova-SpecializedFeatureImplementer`:**
        *   **Subtask Goal:** "Implement [Specific Component/API Endpoint]."
        *   **Briefing Details:** Provide the relevant `APIEndpoints` or `SystemArchitecture` spec. Instruct to write code, necessary unit tests, and run linters. They should log any micro-`Decisions` or `TechDebtCandidates` found.
    2.  **Delegate to `Nova-SpecializedTestAutomator` (for integration):**
        *   **Subtask Goal:** "Write and execute integration tests for the interaction between [ComponentA] and [ComponentB]."
        *   **Briefing Details:** Provide the `AcceptanceCriteria` for the interaction. Instruct to report pass/fail and log any new, independent bugs as `ErrorLogs`.

**Milestone DEV.3: Documentation & Final Quality Gate**
*   **DoR Check:** All code implemented and integration tests are passing.
*   **Goal:** Document the new feature's code and perform a final quality check.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedCodeDocumenter`:**
        *   **Subtask Goal:** "Ensure all new/modified code for [FeatureName] is adequately documented (inline and module-level)."
        *   **Briefing Details:** Point to all new/modified source files and specify documentation standards from `ProjectConfig`.
    2.  **Delegate to `Nova-SpecializedTestAutomator`:**
        *   **Subtask Goal:** "Perform a final linter run and execute the full test suite relevant to [FeatureName]."
        *   **Briefing Details:** Instruct to run all relevant tests and linters. This is the final gate. If issues are found, loop back to the relevant specialist for fixes.

**Milestone DEV.4: Finalize & Report**
*   **Goal:** Close out the development phase and report completion.
*   **Suggested Lead Action:**
    1.  Log a final `Decision` confirming development phase completion.
    2.  Update the main phase `Progress` item to 'DONE'.
    3.  Coordinate with `Nova-Orchestrator` to update `active_context.state_of_the_union`.
    4.  In your `attempt_completion` to `Nova-Orchestrator`, summarize the work, confirm test status, and list all critical ConPort items created.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData (`CodeSnippets`, `APIUsage`, `ConfigSettings`, `TechDebtCandidates`, `ErrorLogs`)