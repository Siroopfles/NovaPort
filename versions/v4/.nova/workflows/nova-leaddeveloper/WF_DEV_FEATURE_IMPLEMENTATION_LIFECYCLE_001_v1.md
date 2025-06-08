# Workflow: Feature Implementation Lifecycle (within Development Phase) (WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1)

**Goal:** To manage the complete development lifecycle of a feature or significant component, from receiving specifications to delivering tested, documented, and integrated code, by coordinating a team of development specialists.

**Primary Orchestrator Actor:** Nova-LeadDeveloper (receives phase task from Nova-Orchestrator)
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedFeatureImplementer, Nova-SpecializedTestAutomator, Nova-SpecializedCodeDocumenter, (potentially Nova-SpecializedCodeRefactorer).

**Trigger / Orchestrator Recognition (for Nova-Orchestrator to delegate to Nova-LeadDeveloper):**
- Nova-Orchestrator initiates the "Development Phase" for a new feature or project, providing specifications from Nova-LeadArchitect.
- E.g., as a step in `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md` or `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`.

**Pre-requisites by Nova-Orchestrator (before delegating this phase to Nova-LeadDeveloper):**
- Detailed feature specifications exist in ConPort: `FeatureScope:[key]`, `AcceptanceCriteria:[key]`.
- Relevant architectural designs, API specifications, and DB schemas are finalized and available in ConPort: `SystemArchitecture:[key]`, `APIEndpoints:[key]`, `DBMigrations:[key]`.
- `ProjectConfig:ActiveConfig` (key) is defined, specifying language, frameworks, testing tools, etc.
- User/Nova-Orchestrator confirms readiness to start development.

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator):**

**Phase DEV.1: Initial Planning & Decomposition by Nova-LeadDeveloper**

1.  **Nova-LeadDeveloper: Receive Phase Task & Plan Implementation**
    *   **Action:** Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` (e.g., "Implement User Authentication Feature"), `Required_Input_Context` (refs to specs, designs, configs), and `Expected_Deliverables_In_Attempt_Completion_From_Lead`.
    *   **ConPort:**
        *   Log main `Progress` (integer `id`) item for this "Feature Implementation Phase: [FeatureName]".
        *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[DevPhaseProgressID]_DeveloperPlan` (key)). This plan is a **sequence of small, focused specialist subtasks**. Example subtasks:
            1.  Implement Backend API Endpoint X (FeatureImplementer).
            2.  Write Unit Tests for Endpoint X (TestAutomator or FeatureImplementer).
            3.  Implement Frontend Component Y (FeatureImplementer).
            4.  Write Unit/Component Tests for Component Y (TestAutomator or FeatureImplementer).
            5.  Implement Service Z (FeatureImplementer).
            6.  Write Integration Test for X-Y-Z interaction (TestAutomator).
            7.  Identify & Log Tech Debt for Module M (FeatureImplementer/CodeRefactorer during their work).
            8.  Document Module M Public API (CodeDocumenter).
            9.  Final Linter & Test Suite Run (TestAutomator).
    *   **Logic:**
        *   Review all provided specifications (`FeatureScope`, `AcceptanceCriteria`, `APIEndpoints`, `SystemArchitecture` components relevant to this feature).
        *   Identify key modules/components to be built or modified.
        *   Log any high-level implementation `Decisions` (integer `id`) (e.g., choice of a specific utility library not covered by `ProjectConfig`, overall data flow within the feature if not detailed by architect).
    *   **Output:** Detailed, sequenced plan of specialist subtasks in `LeadPhaseExecutionPlan`. Main `Progress` (integer `id`) created.

**Phase DEV.2: Sequential Execution of Specialist Subtasks by Nova-LeadDeveloper**

*(Nova-LeadDeveloper iterates through its `LeadPhaseExecutionPlan`, delegating one subtask at a time using `new_task` to the appropriate specialist, awaiting their `attempt_completion`, processing results (incl. test/lint status, ConPort items logged by specialist), and then initiating the next subtask.)*

2.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Implement Backend Endpoint**
    *   **Task:** "Implement backend API endpoint [EndpointName] as per specification [APIEndpointKey]."
    *   **`new_task` message for Nova-SpecializedFeatureImplementer:**
        ```
        Subtask_Briefing:
          Overall_Developer_Phase_Goal: "Implement Feature [FeatureName]."
          Specialist_Subtask_Goal: "Implement API endpoint [EndpointName]."
          Specialist_Specific_Instructions:
            - "Refer to API specification: `CustomData APIEndpoints:[APIEndpointKey]` (key)."
            - "Implement in [language/framework from ProjectConfig:ActiveConfig]."
            - "Adhere to coding standards: `SystemPatterns:[CodingStandardPatternID]` (integer `id` or name)."
            - "Write necessary unit tests for your new code using [testing_framework from ProjectConfig]."
            - "Run linter ([linter_command from ProjectConfig]) on your changes."
            - "Log any micro-decisions as a `Decision` (integer `id`). Log useful `CodeSnippets` (key)."
            - "If you identify significant out-of-scope tech debt, log it to `CustomData TechDebtCandidates:[key]` (R23)."
          Required_Input_Context_For_Specialist:
            - API_Spec_ConPort_Ref: { type: "custom_data", category: "APIEndpoints", key: "[APIEndpointKey]" }
            - ProjectConfig_Ref: { type: "custom_data", category: "ProjectConfig", key: "ActiveConfig" }
            - Coding_Standard_Ref: { type: "system_pattern", id: [integer_id_of_pattern] } // or name
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Path to created/modified file(s)."
            - "Confirmation of unit tests written & passing."
            - "Confirmation of linter passing."
            - "List of ConPort `Decision` (integer `id`s), `CodeSnippets` (keys), or `TechDebtCandidates` (keys) logged."
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Review code (conceptually), test results, ConPort logs. Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`). If tests fail or linter errors, re-delegate fix to implementer or a new task to TestAutomator for deeper analysis.

3.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Write Integration Tests**
    *   **Task:** "Write and execute integration tests for the interaction between [ComponentA] and [ComponentB] for [FeatureName]."
    *   **`new_task` message for Nova-SpecializedTestAutomator:**
        ```
        Subtask_Briefing:
          Overall_Developer_Phase_Goal: "Implement Feature [FeatureName]."
          Specialist_Subtask_Goal: "Write and run integration tests for [ComponentA]-[ComponentB] interaction."
          Specialist_Specific_Instructions:
            - "Components involved: [ComponentA details/paths], [ComponentB details/paths]."
            - "Test scenarios based on `CustomData AcceptanceCriteria:[FeatureName_AC_Key]`."
            - "Use testing framework: [from ProjectConfig:ActiveConfig.testing_preferences.integration_test_framework or specific instruction]."
            - "Log `Progress` (integer `id`) for test creation and execution."
            - "Report all test outcomes. If failures, provide details for debugging."
          Required_Input_Context_For_Specialist:
            - Acceptance_Criteria_Ref: { type: "custom_data", category: "AcceptanceCriteria", key: "[FeatureName_AC_Key]" }
            - ComponentA_Code_Ref: "[Path or ConPort CodeSnippet key]"
            - ComponentB_Code_Ref: "[Path or ConPort CodeSnippet key]"
            - ProjectConfig_Ref: { type: "custom_data", category: "ProjectConfig", key: "ActiveConfig" }
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Test execution summary (pass/fail count)."
            - "Paths to new/modified test script files."
            - "Keys of any new `ErrorLogs` logged for test failures."
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Review test results. If failures, create `ErrorLogs` (key) (or ensure specialist did) and delegate fix to FeatureImplementer. Update plan and progress.

*(... Other specialist subtasks for frontend, services, documentation, final lint/test run, etc., would follow a similar pattern of delegation, awaiting completion, and processing results sequentially ...)*

**Phase DEV.3: Final Review & Reporting by Nova-LeadDeveloper**

4.  **Nova-LeadDeveloper: Consolidate & Finalize Feature Implementation**
    *   **Action:** Once all specialist subtasks in `LeadPhaseExecutionPlan` (key) are DONE:
        *   Perform a final conceptual review of the implemented feature against specifications.
        *   Ensure all planned tests passed and documentation is adequate.
        *   Log a final `Decision` (integer `id`) for the development phase completion (e.g., "Feature [FeatureName] implementation complete and meets quality standards").
        *   Update main phase `Progress` (integer `id`) to DONE.
        *   Update `active_context.state_of_the_union` (via `use_mcp_tool` by instructing Nova-SpecializedConPortSteward via Nova-LeadArchitect, or directly if LeadDeveloper has this explicit capability for its own phase closure for `state_of_the_union`) to reflect "Feature [FeatureName] Development Completed (Code Implemented & Unit/Integration Tested), Awaiting QA".
    *   **Output:** Feature developed, tested by dev team, documented. `active_context.state_of_the_union` potentially updated.

5.  **Nova-LeadDeveloper: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Prepare and send `attempt_completion` message including all `Expected_Deliverables_In_Attempt_Completion_From_Lead` specified by Nova-Orchestrator (summary, test status, key ConPort items created/updated with their correct ID/key types, new issues, tech debt, critical outputs).

**Key ConPort Items Created/Updated by Nova-LeadDeveloper's Team:**
-   `Progress` (integer `id`): For the overall phase and each specialist subtask.
-   `CustomData LeadPhaseExecutionPlan:[DevPhaseProgressID]_DeveloperPlan` (key): The LeadDeveloper's internal plan.
-   `Decisions` (integer `id`): Technical implementation choices made by the team.
-   `CustomData CodeSnippets:[key]`: Reusable or important code sections.
-   `CustomData APIUsage:[key]`: If the feature consumes other APIs.
-   `CustomData ConfigSettings:[key]`: If the feature introduces new application configurations.
-   `CustomData TechDebtCandidates:[key]`: Identified during development.
-   (Potentially) `ErrorLogs` (key): If TestAutomator finds new, independent bugs.
-   Reads: `FeatureScope` (key), `AcceptanceCriteria` (key), `SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key), `ProjectConfig` (key), `SystemPatterns` (integer `id`/name).