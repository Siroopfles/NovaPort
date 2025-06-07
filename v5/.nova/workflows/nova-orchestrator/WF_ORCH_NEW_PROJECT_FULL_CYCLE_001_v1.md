# Workflow: New Project Full Cycle (WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1)

**Goal:** To guide the end-to-end process of initializing a new project, from initial user request through design, development, QA, and preparation for a first release, coordinating all Lead Modes.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Primary Lead Mode Actors (delegated to by Nova-Orchestrator):** Nova-LeadArchitect, Nova-LeadDeveloper, Nova-LeadQA

**Trigger / Recognition:**
- User expresses a desire to start an entirely new software project (e.g., "Let's build a new application for X", "I want to create a system for Y").
- No existing ConPort `ProductContext` or minimal ConPort data for the `ACTUAL_WORKSPACE_ID`.

**Pre-requisites by Nova-Orchestrator (before starting this workflow):**
- Nova-Orchestrator has performed its initial session/ConPort initialization (TEP Step 1).
- User has provided at least a preliminary project name and a general idea of the project's main goal or type.
- User has confirmed they want to proceed with a full new project setup.

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase 1: Project Initialization & Configuration Setup (Nova-Orchestrator -> Nova-LeadArchitect)**

1.  **Nova-Orchestrator: Delegate Initial Project & ConPort Setup**
    *   **Task:** "Delegate the complete initial setup of the new project's ConPort, directory structure, essential configurations (`ProjectConfig`, `NovaSystemConfig`), and initial `ProductContext` to Nova-LeadArchitect."
    *   **Action:** If ConPort DB did not exist, Nova-Orchestrator already delegated this during its TEP Step 1.b.iv. If DB existed but was minimal, or if `ProjectConfig`/`NovaSystemConfig` are missing, this step ensures they are created.
    *   **`new_task` message for Nova-LeadArchitect:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Successfully set up and launch Project [UserProvided_ProjectName]."
          Phase_Goal: "Initialize ConPort, establish directory structure, define ProjectConfig & NovaSystemConfig, and draft initial ProductContext for Project [UserProvided_ProjectName]."
          Lead_Mode_Specific_Instructions:
            - "This is for a new project: [UserProvided_ProjectName] - [UserProvided_MainGoal]."
            - "1. Execute the workflow defined in `.nova/workflows/nova-orchestrator/WF_PROJ_INIT_001_NewProjectBootstrap.md`. This includes creating basic root directory structure (e.g., `/src`, `/docs`, `/tests`, `.nova/`) if it doesn't exist, and bootstrapping initial ConPort `ProductContext` (key: 'product_context') based on user input/project brief, logging initial `Decisions` (integer `id`), `Progress` (integer `id`), and `CustomData ProjectRoadmap:[key]`."
            - "2. After bootstrap, execute workflow `.nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md` to guide the user through defining and logging `CustomData ProjectConfig:ActiveConfig` (key) and `CustomData NovaSystemConfig:ActiveSettings` (key) in ConPort."
            - "3. Ensure your specialists (SystemDesigner, ConPortSteward, WorkflowManager) are utilized appropriately for these tasks."
            - "4. Update `active_context.state_of_the_union` to reflect 'Project Initialized, Awaiting Design Phase'."
          Required_Input_Context:
            - UserProvided_ProjectName: "[...]"
            - UserProvided_MainGoal: "[...]"
            - Path_To_Bootstrap_Workflow: ".nova/workflows/nova-orchestrator/WF_PROJ_INIT_001_NewProjectBootstrap.md"
            - Path_To_Config_Setup_Workflow: ".nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "Confirmation of ConPort bootstrap completion."
            - "Confirmation that `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are logged."
            - "ConPort key of the initial `ProductContext`."
            - "List of other key ConPort items created (Decision IDs, Progress IDs, CustomData keys)."
            - "Confirmation that `active_context.state_of_the_union` is updated."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify key deliverables are reported.
        *   Log/Update its own top-level `Progress` (integer `id`) for "Project [UserProvided_ProjectName] Cycle" to status "Initialization Complete, Design Pending".

**Phase 2: System Design & Architecture (Nova-Orchestrator -> Nova-LeadArchitect)**

2.  **Nova-Orchestrator: Delegate System Design Phase**
    *   **DoR Check:** `ProductContext` (key), `ProjectConfig:ActiveConfig` (key), `NovaSystemConfig:ActiveSettings` (key) exist in ConPort. User confirms readiness for design.
    *   **Task:** "Delegate the full system design and architecture definition phase to Nova-LeadArchitect."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Successfully set up and launch Project [UserProvided_ProjectName]."
          Phase_Goal: "Define and document the complete system architecture, detailed component designs, API specifications, and database schema for Project [UserProvided_ProjectName]."
          Lead_Mode_Specific_Instructions:
            - "Execute the workflow defined in `.nova/workflows/nova-leadarchitect/WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1.md` to manage your team (SystemDesigner, ConPortSteward) for this entire design phase."
            - "Ensure all architectural `Decisions` (integer `id`), `SystemArchitecture` documents (key), `APIEndpoints` (key), and `DBMigrations` (key) / schemas are thoroughly defined and logged in ConPort with DoD met."
            - "Consider creating project-specific workflows (e.g., for new service onboarding within this project) via your WorkflowManager and log them to `DefinedWorkflows` (key)."
            - "At the end of this phase, update `active_context.state_of_the_union` to 'Design Phase Completed, Awaiting Development'."
          Required_Input_Context:
            - ProjectName: "[UserProvided_ProjectName]"
            - ConPort_ProductContext_Key: "product_context"
            - ConPort_ProjectConfig_Key: "ProjectConfig:ActiveConfig"
            - ConPort_NovaSystemConfig_Key: "NovaSystemConfig:ActiveSettings"
            - Path_To_System_Design_Workflow: ".nova/workflows/nova-leadarchitect/WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1.md"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "Summary of the defined architecture."
            - "List of key ConPort items created: `SystemArchitecture` keys, `APIEndpoints` keys, `DBMigrations` keys, core architectural `Decision` (integer `id`s)."
            - "Confirmation that `active_context.state_of_the_union` is updated."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify key deliverables.
        *   Update top-level `Progress` (integer `id`) to "Design Complete, Development Pending".

**Phase 3: Development & Unit/Integration Testing (Nova-Orchestrator -> Nova-LeadDeveloper)**

3.  **Nova-Orchestrator: Delegate Development Phase**
    *   **DoR Check:** Key `SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key) are in ConPort with status "approved" or "final". User confirms readiness.
    *   **Task:** "Delegate the full development phase, including coding, unit testing, and integration testing, to Nova-LeadDeveloper."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Successfully set up and launch Project [UserProvided_ProjectName]."
          Phase_Goal: "Implement all specified features and components for Project [UserProvided_ProjectName] according to the defined architecture and API specifications, ensuring code quality through linting and comprehensive unit/integration testing."
          Lead_Mode_Specific_Instructions:
            - "Execute the workflow defined in `.nova/workflows/nova-leaddeveloper/WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md` (or a more project-specific one if created by LeadArchitect) to manage your team (FeatureImplementer, TestAutomator, CodeDocumenter, Refactorer if needed) for this entire development phase."
            - "Ensure all code adheres to standards in `ProjectConfig:ActiveConfig` and ConPort `SystemPatterns` (integer `id`/name)."
            - "All new code must have accompanying unit tests. Integration tests for service interactions are crucial."
            - "Ensure your team logs technical implementation `Decisions` (integer `id`), `CodeSnippets` (key), `APIUsage` (key), `TechDebtCandidates` (key), and detailed `Progress` (integer `id`) for modules/features."
            - "At the end of this phase, update `active_context.state_of_the_union` to 'Development Phase Completed (Code Implemented & Unit/Integration Tested), Awaiting QA'."
          Required_Input_Context:
            - ProjectName: "[UserProvided_ProjectName]"
            - ConPort_SystemArchitecture_References: "[Provide keys to relevant SystemArchitecture documents]"
            - ConPort_APIEndpoints_References: "[Provide keys or tag for APIEndpoints]"
            - ConPort_DBMigrations_References: "[Provide keys for DBMigrations]"
            - ConPort_ProjectConfig_Key: "ProjectConfig:ActiveConfig"
            - Path_To_Dev_Lifecycle_Workflow: ".nova/workflows/nova-leaddeveloper/WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "Summary of implemented features/modules."
            - "Confirmation of linting and unit/integration test completion and pass status (or list of critical unresolved test failures)."
            - "List of key ConPort items created: implementation `Decision` (integer `id`s), `CodeSnippets` (keys)."
            - "Confirmation that `active_context.state_of_the_union` is updated."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify deliverables. If critical test failures, may need to re-delegate to LeadDeveloper or involve LeadQA for deeper analysis before proceeding.
        *   Update top-level `Progress` (integer `id`) to "Development Complete, QA Pending".

**Phase 4: Quality Assurance & Testing (Nova-Orchestrator -> Nova-LeadQA)**

4.  **Nova-Orchestrator: Delegate QA Phase**
    *   **DoR Check:** Development phase reported as complete. Code is in a testable state. Test environments (from `ProjectConfig:ActiveConfig`) are ready.
    *   **Task:** "Delegate the full Quality Assurance phase, including test plan execution, bug logging/tracking, and fix verification, to Nova-LeadQA."
    *   **`new_task` message for Nova-LeadQA:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Successfully set up and launch Project [UserProvided_ProjectName]."
          Phase_Goal: "Thoroughly test Project [UserProvided_ProjectName], identify and track defects, verify fixes, and provide a quality assessment for release readiness."
          Lead_Mode_Specific_Instructions:
            - "Execute the workflow defined in `.nova/workflows/nova-leadqa/WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1.md` (or a more project-specific one) to manage your team (TestExecutor, BugInvestigator, FixVerifier) for this QA phase."
            - "Develop/utilize test plans based on `FeatureScope` (key), `AcceptanceCriteria` (key), `APIEndpoints` (key), and `SystemArchitecture` (key)."
            - "Ensure your team meticulously logs all defects as structured `CustomData ErrorLogs:[key]` (R20), updates their status through the lifecycle, and contributes to `LessonsLearned` (key)."
            - "Maintain an accurate list of `active_context.open_issues` (via LeadArchitect/ConPortSteward)."
            - "Coordinate with Nova-Orchestrator for communication with Nova-LeadDeveloper regarding bug fixes."
            - "At the end of this phase, update `active_context.state_of_the_union` to 'QA Phase Completed. Quality Status: [e.g., Ready for Release Candidate, Blocked by X critical bugs]'."
          Required_Input_Context:
            - ProjectName: "[UserProvided_ProjectName]"
            - ConPort_FeatureScope_References: "[Keys or tag]"
            - ConPort_AcceptanceCriteria_References: "[Keys or tag]"
            - ConPort_APIEndpoints_References: "[Keys or tag for testing]"
            - (Optional) List_Of_Known_Issues_From_Dev: "[Any `ErrorLog` keys reported by LeadDeveloper]"
            - Path_To_QA_Cycle_Workflow: ".nova/workflows/nova-leadqa/WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1.md"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "QA Summary Report: Test coverage, pass/fail rates, list of open critical/high `ErrorLogs` (keys)."
            - "List of key `ErrorLogs` (keys) created/resolved during this phase."
            - "List of `LessonsLearned` (keys) logged."
            - "Confirmation that `active_context.state_of_the_union` and `open_issues` are updated."
            - "Recommendation on release readiness."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Review QA report and release readiness recommendation. If not ready, loop back to Phase 3 (Development for fixes) or Phase 4 (more QA), or discuss scope changes with user.
        *   Update top-level `Progress` (integer `id`) e.g., "QA Complete, Release Prep Pending" or "QA Found Blockers".

**Phase 5: Release Preparation (Nova-Orchestrator -> Nova-LeadArchitect / Nova-LeadDeveloper)**

5.  **Nova-Orchestrator: Delegate Release Preparation**
    *   **DoR Check:** QA Lead recommends release readiness or all critical/high bugs are resolved/deferred by a `Decision` (integer `id`).
    *   **Task:** "Delegate final documentation, release notes, and conceptual tagging for release to appropriate Leads."
    *   *(This step might use `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001.md` which would detail sub-delegations for specific release tasks like final documentation to LeadArchitect (CodeDocumenter), release notes to LeadArchitect (ConPortSteward), and conceptual code tagging/branching to LeadDeveloper).*
    *   **Output:** Project is conceptually ready for deployment (actual deployment is out of scope for Nova). `active_context.state_of_the_union` updated to "Release [Version] Prepared".

**Phase 6: Post-Release & Iteration Planning (Nova-Orchestrator)**

6.  **Nova-Orchestrator: Finalize & Plan Next Steps**
    *   **Action:**
        *   Log final `Decision` (integer `id`) about project launch/release.
        *   Update top-level project `Progress` (integer `id`) to "COMPLETED" or "Version 1.0 Released".
        *   Consult user for next steps: new feature cycle (using `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001.md`), maintenance, or project closure.
    *   **Output:** Project cycle concluded.

**Key ConPort Items Created/Referenced by Nova-Orchestrator (overall):**
-   Top-level `Progress` (integer `id`) for the entire project.
-   Reads all types of ConPort items to inform DoR checks and delegation.
-   Ensures `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are established.
-   Relies on `DefinedWorkflows` (key) for its own operational guidance.
-   Acts upon `ErrorLogs` (key) and `LessonsLearned` (key) reported by Lead Modes.