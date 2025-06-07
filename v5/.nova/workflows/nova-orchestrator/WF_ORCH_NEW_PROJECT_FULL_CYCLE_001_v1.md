# Workflow: New Project Full Cycle (WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1)

**Goal:** To guide the end-to-end process of initializing a new project, from initial user request through design, development, QA, and preparation for a first release, coordinating all Lead Modes.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Primary Lead Mode Actors (delegated to by Nova-Orchestrator):** Nova-LeadArchitect, Nova-LeadDeveloper, Nova-LeadQA

**Trigger / Recognition:**
- User expresses a desire to start an entirely new software project (e.g., "Let's build a new application for X", "I want to create a system for Y").
- No existing ConPort `ProductContext` or minimal ConPort data for the `ACTUAL_WORKSPACE_ID`.

**Pre-requisites by Nova-Orchestrator (before starting this workflow):**
- Nova-Orchestrator has performed its initial session/ConPort initialization (executing `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md`).
- User has provided at least a preliminary project name and a general idea of the project's main goal or type.
- User has confirmed they want to proceed with a full new project setup.

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase 1: Project Initialization & Configuration Setup (Nova-Orchestrator -> Nova-LeadArchitect)**

1.  **Nova-Orchestrator: Delegate Initial Project & ConPort Setup**
    *   **Action:**
        *   Log/Update its own top-level `Progress` (integer `id`) for "Project [UserProvided_ProjectName] Full Cycle" to status "INITIALIZATION_PHASE".
    *   **Task:** "Delegate the complete initial setup of the new project's ConPort, directory structure, essential configurations (`ProjectConfig`, `NovaSystemConfig`), and initial `ProductContext` to Nova-LeadArchitect."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "Project [UserProvided_ProjectName] (Orchestrator) -> Initialization Phase (LeadArchitect)",
          "Overall_Project_Goal": "Successfully set up and launch Project [UserProvided_ProjectName].",
          "Phase_Goal": "Initialize ConPort, establish directory structure (if needed), define ProjectConfig & NovaSystemConfig, and draft initial ProductContext for Project [UserProvided_ProjectName].",
          "Lead_Mode_Specific_Instructions": [
            "This is for a new project: [UserProvided_ProjectName] - [UserProvided_MainGoal].",
            "1. If ConPort DB was not present and you are performing initial bootstrap (as per Orchestrator's startup): Execute the workflow defined in `.nova/workflows/nova-orchestrator/WF_PROJ_INIT_001_NewProjectBootstrap.md`. This includes creating basic root directory structure (e.g., `/src`, `/docs`, `/tests`, `.nova/`) if it doesn't exist, and bootstrapping initial ConPort `ProductContext` (key: 'product_context') based on user input/project brief, logging initial `Decisions` (integer `id`), `Progress` (integer `id`), and `CustomData ProjectRoadmap:[key]`.",
            "2. Execute workflow `.nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md` to guide the user (via Orchestrator relay if needed) through defining and logging `CustomData ProjectConfig:ActiveConfig` (key) and `CustomData NovaSystemConfig:ActiveSettings` (key) in ConPort.",
            "3. Ensure your specialists (SystemDesigner, ConPortSteward, WorkflowManager) are utilized appropriately for these tasks.",
            "4. Update `active_context.state_of_the_union` to reflect 'Project Initialized, Awaiting Design Phase' using `use_mcp_tool` (`tool_name: 'update_active_context'`)."
          ],
          "Required_Input_Context": {
            "UserProvided_ProjectName": "[UserProvided_ProjectName]",
            "UserProvided_MainGoal": "[UserProvided_MainGoal]",
            "Path_To_Bootstrap_Workflow": ".nova/workflows/nova-orchestrator/WF_PROJ_INIT_001_NewProjectBootstrap.md",
            "Path_To_Config_Setup_Workflow": ".nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Confirmation of ConPort bootstrap completion (if performed).",
            "Confirmation that `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are logged.",
            "ConPort key of the initial `ProductContext` (usually 'product_context').",
            "List of other key ConPort items created (Decision IDs, Progress IDs, CustomData keys).",
            "Confirmation that `active_context.state_of_the_union` is updated."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify key deliverables are reported.
        *   Update its own top-level `Progress` (integer `id`) to "Initialization Complete, Design Pending".

**Phase 2: System Design & Architecture (Nova-Orchestrator -> Nova-LeadArchitect)**

2.  **Nova-Orchestrator: Delegate System Design Phase**
    *   **DoR Check:** `ProductContext` (key), `ProjectConfig:ActiveConfig` (key), `NovaSystemConfig:ActiveSettings` (key) exist in ConPort. User confirms readiness for design.
    *   **Task:** "Delegate the full system design and architecture definition phase to Nova-LeadArchitect."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "Project [UserProvided_ProjectName] (Orchestrator) -> Design Phase (LeadArchitect)",
          "Overall_Project_Goal": "Successfully set up and launch Project [UserProvided_ProjectName].",
          "Phase_Goal": "Define and document the complete system architecture, detailed component designs, API specifications, and database schema for Project [UserProvided_ProjectName].",
          "Lead_Mode_Specific_Instructions": [
            "Execute the workflow defined in `.nova/workflows/nova-leadarchitect/WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1.md` to manage your team (SystemDesigner, ConPortSteward) for this entire design phase.",
            "Ensure all architectural `Decisions` (integer `id`), `SystemArchitecture` documents (key), `APIEndpoints` (key), and `DBMigrations` (key) / schemas are thoroughly defined and logged in ConPort with DoD met.",
            "Consider creating project-specific workflows (e.g., for new service onboarding within this project) via your WorkflowManager and log them to `DefinedWorkflows` (key).",
            "At the end of this phase, update `active_context.state_of_the_union` to 'Design Phase Completed, Awaiting Development' using `use_mcp_tool` (`tool_name: 'update_active_context'`)"
          ],
          "Required_Input_Context": {
            "ProjectName": "[UserProvided_ProjectName]",
            "ConPort_ProductContext_Key": "product_context",
            "ConPort_ProjectConfig_Key": "ProjectConfig:ActiveConfig",
            "ConPort_NovaSystemConfig_Key": "NovaSystemConfig:ActiveSettings",
            "Path_To_System_Design_Workflow": ".nova/workflows/nova-leadarchitect/WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1.md"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Summary of the defined architecture.",
            "List of key ConPort items created: `SystemArchitecture` keys, `APIEndpoints` keys, `DBMigrations` keys, core architectural `Decision` (integer `id`s).",
            "Confirmation that `active_context.state_of_the_union` is updated."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify key deliverables.
        *   Update top-level `Progress` (integer `id`) to "Design Complete, Development Pending".

**Phase 3: Development & Unit/Integration Testing (Nova-Orchestrator -> Nova-LeadDeveloper)**

3.  **Nova-Orchestrator: Delegate Development Phase**
    *   **DoR Check:** Key `SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key) are in ConPort with status "approved" or "final". User confirms readiness.
    *   **Task:** "Delegate the full development phase, including coding, unit testing, and integration testing, to Nova-LeadDeveloper."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```json
        {
          "Context_Path": "Project [UserProvided_ProjectName] (Orchestrator) -> Development Phase (LeadDeveloper)",
          "Overall_Project_Goal": "Successfully set up and launch Project [UserProvided_ProjectName].",
          "Phase_Goal": "Implement all specified features and components for Project [UserProvided_ProjectName] according to the defined architecture and API specifications, ensuring code quality through linting and comprehensive unit/integration testing.",
          "Lead_Mode_Specific_Instructions": [
            "Execute the workflow defined in `.nova/workflows/nova-leaddeveloper/WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md` (or a more project-specific one if created by LeadArchitect) to manage your team (FeatureImplementer, TestAutomator, CodeDocumenter, Refactorer if needed) for this entire development phase.",
            "Ensure all code adheres to standards in `ProjectConfig:ActiveConfig` and ConPort `SystemPatterns` (integer `id`/name).",
            "All new code must have accompanying unit tests. Integration tests for service interactions are crucial.",
            "Ensure your team logs technical implementation `Decisions` (integer `id`), `CodeSnippets` (key), `APIUsage` (key), `TechDebtCandidates` (key), and detailed `Progress` (integer `id`) for modules/features.",
            "At the end of this phase, update `active_context.state_of_the_union` to 'Development Phase Completed (Code Implemented & Unit/Integration Tested), Awaiting QA' (This update will be coordinated via Nova-LeadArchitect if you cannot do it directly)."
          ],
          "Required_Input_Context": {
            "ProjectName": "[UserProvided_ProjectName]",
            "ConPort_SystemArchitecture_References": "[Provide keys to relevant SystemArchitecture documents]",
            "ConPort_APIEndpoints_References": "[Provide keys or tag for APIEndpoints]",
            "ConPort_DBMigrations_References": "[Provide keys for DBMigrations]",
            "ConPort_ProjectConfig_Key": "ProjectConfig:ActiveConfig"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Summary of implemented features/modules.",
            "Confirmation of linting and unit/integration test completion and pass status (or list of critical unresolved test failures).",
            "List of key ConPort items created: implementation `Decision` (integer `id`s), `CodeSnippets` (keys).",
            "Confirmation that `active_context.state_of_the_union` is updated (or request for update sent)."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify deliverables. If critical test failures, may need to re-delegate to LeadDeveloper or involve LeadQA for deeper analysis before proceeding.
        *   Update top-level `Progress` (integer `id`) to "Development Complete, QA Pending".

**Phase 4: Quality Assurance & Testing (Nova-Orchestrator -> Nova-LeadQA)**

4.  **Nova-Orchestrator: Delegate QA Phase**
    *   **DoR Check:** Development phase reported as complete. Code is in a testable state. Test environments (from `ProjectConfig:ActiveConfig`) are ready.
    *   **Task:** "Delegate the full Quality Assurance phase, including test plan execution, bug logging/tracking, and fix verification, to Nova-LeadQA."
    *   **`new_task` message for Nova-LeadQA:**
        ```json
        {
          "Context_Path": "Project [UserProvided_ProjectName] (Orchestrator) -> QA Phase (LeadQA)",
          "Overall_Project_Goal": "Successfully set up and launch Project [UserProvided_ProjectName].",
          "Phase_Goal": "Thoroughly test Project [UserProvided_ProjectName], identify and track defects, verify fixes, and provide a quality assessment for release readiness.",
          "Lead_Mode_Specific_Instructions": [
            "Execute the workflow defined in `.nova/workflows/nova-leadqa/WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1.md` (or a more project-specific one like `WF_QA_RELEASE_CANDIDATE_VALIDATION_001_v1.md` if this is a release candidate) to manage your team (TestExecutor, BugInvestigator, FixVerifier) for this QA phase.",
            "Develop/utilize test plans based on `FeatureScope` (key), `AcceptanceCriteria` (key), `APIEndpoints` (key), and `SystemArchitecture` (key).",
            "Ensure your team meticulously logs all defects as structured `CustomData ErrorLogs:[key]` (R20), updates their status through the lifecycle, and contributes to `LessonsLearned` (key).",
            "Maintain an accurate list of `active_context.open_issues` (coordinate update via me to Nova-LeadArchitect/ConPortSteward).",
            "Coordinate with Nova-Orchestrator for communication with Nova-LeadDeveloper regarding bug fixes.",
            "At the end of this phase, update `active_context.state_of_the_union` to 'QA Phase Completed. Quality Status: [e.g., Ready for Release Candidate, Blocked by X critical bugs]' (Coordinate update via me to Nova-LeadArchitect)."
          ],
          "Required_Input_Context": {
            "ProjectName": "[UserProvided_ProjectName]",
            "ConPort_FeatureScope_References": "[Keys or tag]",
            "ConPort_AcceptanceCriteria_References": "[Keys or tag]",
            "ConPort_APIEndpoints_References": "[Keys or tag for testing]",
            "Developer_Build_Or_Branch_Info": "[Details from LeadDeveloper phase completion]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "QA Summary Report for Project [UserProvided_ProjectName]: Test coverage, pass/fail rates, list of open critical/high `ErrorLogs` (keys).",
            "List of key `ErrorLogs` (keys) created/resolved during this phase.",
            "List of `LessonsLearned` (keys) logged.",
            "Confirmation that `active_context.open_issues` and `state_of_the_union` are updated (or request for update sent).",
            "Recommendation on release readiness."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Review QA report and release readiness recommendation. If not ready, loop back to Phase 3 (Development for fixes) or Phase 4 (more QA), or discuss scope changes with user.
        *   Update top-level `Progress` (integer `id`) e.g., "QA Complete, Release Prep Pending" or "QA Found Blockers".

**Phase 5: Release Preparation (Nova-Orchestrator -> Nova-LeadArchitect / Nova-LeadDeveloper)**

5.  **Nova-Orchestrator: Delegate Release Preparation**
    *   **DoR Check:** QA Lead recommends release readiness or all critical/high bugs are resolved/deferred by a `Decision` (integer `id`).
    *   **Task:** "Delegate final documentation, release notes, and conceptual tagging for release [TargetReleaseVersion] to appropriate Leads. This may involve executing parts of `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`."
    *   **`new_task` message for Nova-LeadArchitect (Documentation & Release Notes):**
        ```json
        {
          "Context_Path": "Project [UserProvided_ProjectName] (Orchestrator) -> ReleasePrep_Docs (LeadArchitect)",
          "Overall_Project_Goal": "Prepare Project [UserProvided_ProjectName] for release [TargetReleaseVersion].",
          "Phase_Goal": "Finalize all user-facing and technical documentation, and official release notes for [TargetReleaseVersion].",
          "Lead_Mode_Specific_Instructions": [
            "Ensure your ConPortSteward/WorkflowManager/SystemDesigner update all relevant documentation (`SystemArchitecture` (key), user docs, `APIEndpoints` (key)) and finalize release notes in `CustomData ReleaseNotesFinal:[TargetReleaseVersion]` (key)."
          ],
          "Required_Input_Context": { "TargetReleaseVersion": "[...]", "Release_Scope_Ref_Key": "Releases:[TargetReleaseVersion]" },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": ["Confirmation of documentation updates", "Key of `ReleaseNotesFinal` entry"]
        }
        ```
    *   **`new_task` message for Nova-LeadDeveloper (Conceptual Tagging):**
        ```json
        {
          "Context_Path": "Project [UserProvided_ProjectName] (Orchestrator) -> ReleasePrep_Tagging (LeadDeveloper)",
          "Overall_Project_Goal": "Prepare Project [UserProvided_ProjectName] for release [TargetReleaseVersion].",
          "Phase_Goal": "Log conceptual version tagging for [TargetReleaseVersion] in ConPort.",
          "Lead_Mode_Specific_Instructions": [
            "Identify commit hash for [TargetReleaseVersion] (user to provide if needed).",
            "Log a `Decision` (integer `id`): 'Commit [hash] designated for release [TargetReleaseVersion]. All tests passed, docs final.' Tag with #[TargetReleaseVersion]."
          ],
          "Required_Input_Context": { "TargetReleaseVersion": "[...]" },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": ["Integer ID of the conceptual tagging `Decision`"]
        }
        ```
    *   **Nova-Orchestrator Action after Leads complete:** Inform user about physical git tagging. Delegate to Nova-LeadArchitect to update `CustomData Releases:[TargetReleaseVersion]` (key) status to 'Shipped' and update `active_context.state_of_the_union`.
    *   **Output:** Project is conceptually ready for deployment. `active_context.state_of_the_union` updated to "Release [Version] Prepared".

**Phase 6: Post-Release & Iteration Planning (Nova-Orchestrator)**

6.  **Nova-Orchestrator: Finalize & Plan Next Steps**
    *   **Action:**
        *   Log final `Decision` (integer `id`) about project launch/release using `use_mcp_tool` (`tool_name: 'log_decision'`).
        *   Update top-level project `Progress` (integer `id`) to "COMPLETED" or "Version 1.0 Released" using `use_mcp_tool` (`tool_name: 'update_progress'`).
        *   Consult user for next steps: new feature cycle (using `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`), maintenance, or project closure.
    *   **Output:** Project cycle concluded.

**Key ConPort Items Created/Referenced by Nova-Orchestrator (overall for this workflow):**
- Top-level `Progress` (integer `id`) for the entire project.
- Reads all types of ConPort items to inform DoR checks and delegation.
- Ensures `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are established.
- Relies on `DefinedWorkflows` (key) for its own operational guidance.
- Acts upon `ErrorLogs` (key) and `LessonsLearned` (key) reported by Lead Modes.