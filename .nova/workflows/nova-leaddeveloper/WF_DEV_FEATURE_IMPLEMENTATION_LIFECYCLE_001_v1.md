# Workflow: Feature Implementation Lifecycle (within Development Phase) (WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1)

**Goal:** To manage the complete development lifecycle of a feature or significant component, from receiving specifications to delivering tested, documented, and integrated code, by coordinating a team of development specialists.

**Primary Actor:** Nova-LeadDeveloper (receives phase task from Nova-Orchestrator)
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedFeatureImplementer, Nova-SpecializedTestAutomator, Nova-SpecializedCodeDocumenter, (potentially Nova-SpecializedCodeRefactorer).

**Trigger / Recognition:**
- Nova-Orchestrator initiates the "Development Phase" for a new feature or project, providing specifications from Nova-LeadArchitect.
- E.g., as a step in `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md` or `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`.

**Pre-requisites by Nova-LeadDeveloper (from Nova-Orchestrator's briefing):**
- Detailed feature specifications exist in ConPort: `CustomData FeatureScope:[key]`, `CustomData AcceptanceCriteria:[key]`.
- Relevant architectural designs, API specifications, and DB schemas are finalized and available in ConPort: `CustomData SystemArchitecture:[key]`, `CustomData APIEndpoints:[key]`, `CustomData DBMigrations:[key]`.
- `CustomData ProjectConfig:ActiveConfig` (key) is defined, specifying language, frameworks, testing tools, etc.
- User/Nova-Orchestrator confirms readiness to start development.

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator):**

**Phase DEV.1: Initial Planning & Decomposition by Nova-LeadDeveloper**

1.  **Nova-LeadDeveloper: Receive Phase Task & Plan Implementation**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` (e.g., "Implement User Authentication Feature"), `Required_Input_Context` (refs to specs, designs, configs using correct ConPort ID/key types), and `Expected_Deliverables_In_Attempt_Completion_From_Lead`.
        *   Log main `Progress` (integer `id`) item for this "Feature Implementation Phase: [FeatureName]" using `use_mcp_tool` (`tool_name: 'log_progress'`). Let this be `[DevPhaseProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[DevPhaseProgressID]_DeveloperPlan` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). This plan is a **sequence of small, focused specialist subtasks**. Example subtasks:
            1.  Implement Backend API Endpoint X (Delegate to FeatureImplementer).
            2.  Write Unit Tests for Endpoint X (Delegate to TestAutomator or instruct FeatureImplementer).
            3.  Implement Frontend Component Y (Delegate to FeatureImplementer).
            4.  Write Unit/Component Tests for Component Y (Delegate to TestAutomator or instruct FeatureImplementer).
            5.  Implement Business Logic Service Z (Delegate to FeatureImplementer).
            6.  Write Integration Test for X-Y-Z interaction (Delegate to TestAutomator).
            7.  Identify & Log Tech Debt for Module M (Instruct FeatureImplementer/CodeRefactorer during their work, R23).
            8.  Document Module M Public API (Delegate to CodeDocumenter).
            9.  Final Linter & Full Test Suite Run for Feature (Delegate to TestAutomator).
    *   **Logic:**
        *   Review all provided specifications (`FeatureScope` (key), `AcceptanceCriteria` (key), `APIEndpoints` (key), `SystemArchitecture` (key) components relevant to this feature) using `use_mcp_tool` (`tool_name: 'get_custom_data'`).
        *   Identify key modules/components to be built or modified.
        *   Log any high-level implementation `Decisions` (integer `id`) (e.g., choice of a specific utility library not covered by `ProjectConfig`, overall data flow within the feature if not detailed by architect) using `use_mcp_tool` (`tool_name: 'log_decision'`).
    *   **Output:** Detailed, sequenced plan of specialist subtasks in `LeadPhaseExecutionPlan`. Main `Progress` (`[DevPhaseProgressID]`) created.

**Phase DEV.2: Sequential Execution of Specialist Subtasks by Nova-LeadDeveloper**

*(Nova-LeadDeveloper iterates through its `LeadPhaseExecutionPlan`, delegating one subtask at a time using `new_task` to the appropriate specialist, awaiting their `attempt_completion`, processing results (incl. test/lint status, ConPort items logged by specialist), and then initiating the next subtask.)*

2.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Implement Component/Endpoint**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Implement [Specific Component/Backend API EndpointName] as per specification [APIEndpointKey/SystemArchitectureKey]."
    *   **`new_task` message for Nova-SpecializedFeatureImplementer (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (DevPhase_[FeatureName]) -> Implement [Component/Endpoint] (FeatureImplementer)",
          "Overall_Developer_Phase_Goal": "Implement Feature [FeatureName].",
          "Specialist_Subtask_Goal": "Implement [Component/API endpoint Name].",
          "Specialist_Specific_Instructions": [
            "Refer to specification: `CustomData APIEndpoints:[APIEndpointKey]` or `CustomData SystemArchitecture:[ComponentArchKey]` (key).",
            "Implement in [language/framework from ProjectConfig:ActiveConfig].",
            "Adhere to coding standards: `SystemPatterns:[CodingStandardPatternID_or_Name]` (integer `id` or name).",
            "Write necessary unit tests for your new code using [testing_framework from ProjectConfig]. Ensure they cover critical paths and edge cases.",
            "Run linter ([linter_command from ProjectConfig]) on your changes and fix all issues.",
            "Log any micro-decisions as a `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`). Log useful `CodeSnippets` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`, `category: 'CodeSnippets'`).",
            "If you identify significant out-of-scope tech debt, log it to `CustomData TechDebtCandidates:[key]` (R23 compliant) using `use_mcp_tool` (`tool_name: 'log_custom_data'`, `category: 'TechDebtCandidates'`).",
            "Log your `Progress` (integer `id`) for this subtask, parented to `[DevPhaseProgressID]`."
          ],
          "Required_Input_Context_For_Specialist": {
            "Spec_ConPort_Ref": { "type": "custom_data", "category": "APIEndpoints", "key": "[APIEndpointKey]" }, // Or SystemArchitecture
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig" },
            "Coding_Standard_Ref": { "type": "system_pattern", "id_or_name": "[ID or Name of pattern]" },
            "Parent_Progress_ID_String": "[DevPhaseProgressID_as_string]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Path to created/modified file(s).",
            "Confirmation of unit tests written & passing (mention coverage if measured).",
            "Confirmation of linter passing.",
            "List of ConPort `Decision` (integer `id`s), `CodeSnippets` (keys), or `TechDebtCandidates` (keys) logged."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Review code (conceptually), test results, ConPort logs. Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`). If tests fail or linter errors, re-delegate fix to implementer or a new task to TestAutomator for deeper analysis.

3.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Write/Run Integration Tests**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** Component(s) implemented and unit tested by FeatureImplementer.
    *   **Task:** "Write and execute integration tests for the interaction between [ComponentA] and [ComponentB] for [FeatureName]."
    *   **`new_task` message for Nova-SpecializedTestAutomator (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (DevPhase_[FeatureName]) -> IntegrationTest [ComponentA-B] (TestAutomator)",
          "Overall_Developer_Phase_Goal": "Implement Feature [FeatureName].",
          "Specialist_Subtask_Goal": "Write and run integration tests for [ComponentA]-[ComponentB] interaction.",
          "Specialist_Specific_Instructions": [
            "Components involved: [ComponentA details/paths], [ComponentB details/paths].",
            "Test scenarios based on `CustomData AcceptanceCriteria:[FeatureName_AC_Key]` (key).",
            "Use testing framework: [from ProjectConfig:ActiveConfig.testing_preferences.integration_test_framework or specific instruction].",
            "Log `Progress` (integer `id`) for test creation and execution, parented to `[DevPhaseProgressID]`.",
            "Report all test outcomes. If failures, log new, independent bugs as `CustomData ErrorLogs:[key]` (R20 compliant)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Acceptance_Criteria_Ref": { "type": "custom_data", "category": "AcceptanceCriteria", "key": "[FeatureName_AC_Key]" },
            "ComponentA_Code_Ref": "[Path or ConPort CodeSnippet key]",
            "ComponentB_Code_Ref": "[Path or ConPort CodeSnippet key]",
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig" },
            "Parent_Progress_ID_String": "[DevPhaseProgressID_as_string]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Test execution summary (pass/fail count).",
            "Paths to new/modified test script files.",
            "Keys of any new `ErrorLogs` logged for test failures."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Review test results. If failures (new `ErrorLogs` (key) logged by TestAutomator), coordinate fix with FeatureImplementer. Update plan and progress.

*(... Other specialist subtasks for frontend, services, documentation, final lint/test run, etc., would follow a similar pattern of delegation, awaiting completion, and processing results sequentially ...)*

**Phase DEV.3: Final Review & Reporting by Nova-LeadDeveloper**

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter: Final Documentation**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** All code implemented and tested (unit/integration).
    *   **Task:** "Ensure all new/modified code for [FeatureName] is adequately documented (inline and module-level technical docs)."
    *   **Briefing for CodeDocumenter:** Point to all new/modified source files, relevant `APIEndpoints` (key), `SystemArchitecture` (key). Specify documentation standards from `ProjectConfig:ActiveConfig.documentation_standards`.
    *   **Nova-LeadDeveloper Action:** Review documentation. Update plan/progress.

5.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Final Linter & Full Feature Test Suite Run**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** Code implemented, initial tests passed, documentation updated.
    *   **Task:** "Perform a final linter run on all changed code for [FeatureName] and execute the full test suite relevant to this feature."
    *   **Briefing for TestAutomator:** Specify all relevant source and test directories. Command from `ProjectConfig:ActiveConfig`. Expect clean linter output and all tests passing.
    *   **Nova-LeadDeveloper Action:** If issues, loop back to relevant specialist for fixes. This is the final gate before reporting phase completion.

6.  **Nova-LeadDeveloper: Consolidate & Finalize Feature Implementation**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Once all specialist subtasks in `LeadPhaseExecutionPlan` (key) are DONE and final checks passed:
        *   Log a final `Decision` (integer `id`) for the development phase completion using `use_mcp_tool` (`tool_name: 'log_decision'`, e.g., "Feature [FeatureName] implementation complete, unit/integration tested, and meets quality standards"). Link to `[DevPhaseProgressID]`.
        *   Update main phase `Progress` (`[DevPhaseProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description to summarize completion.
        *   Coordinate with Nova-Orchestrator to update `active_context.state_of_the_union` to "Feature [FeatureName] Development Completed, Awaiting QA".
    *   **Output:** Feature developed, tested by dev team, documented.

7.  **Nova-LeadDeveloper: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Prepare and send `attempt_completion` message including all `Expected_Deliverables_In_Attempt_Completion_From_Lead` specified by Nova-Orchestrator (summary, test status, key ConPort items created/updated with their correct ID/key types, new issues, tech debt, critical outputs).

**Key ConPort Items Created/Updated by Nova-LeadDeveloper's Team:**
- Progress (integer `id`): For the overall phase and each specialist subtask.
- CustomData LeadPhaseExecutionPlan:[DevPhaseProgressID]_DeveloperPlan (key).
- Decisions (integer `id`): Technical implementation choices made by the team.
- CustomData CodeSnippets:[key]: Reusable or important code sections.
- CustomData APIUsage:[key]: If the feature consumes other APIs.
- CustomData ConfigSettings:[key]: If the feature introduces new application configurations.
- CustomData TechDebtCandidates:[key]: Identified during development.
- (Potentially) ErrorLogs (key): If TestAutomator finds new, independent bugs.
- Reads: FeatureScope (key), AcceptanceCriteria (key), SystemArchitecture (key), APIEndpoints (key), DBMigrations (key), ProjectConfig (key), SystemPatterns (integer `id`/name).