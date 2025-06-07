# Workflow: Existing Project - New Feature End-to-End Cycle (WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1)

**Goal:** To guide the implementation of a new feature within an existing project, from specification through design, development, QA, and integration.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Primary Lead Mode Actors (delegated to by Nova-Orchestrator):** Nova-LeadArchitect, Nova-LeadDeveloper, Nova-LeadQA

**Trigger / Recognition:**
- User requests a new feature for an existing, already initialized project (e.g., "Add a user dashboard to Project X", "Implement payment integration for our app").
- ConPort `ProductContext` (key 'product_context'), `ProjectConfig:ActiveConfig` (key), and `NovaSystemConfig:ActiveSettings` (key) already exist and are reasonably up-to-date.

**Pre-requisites by Nova-Orchestrator (before starting this workflow):**
- Nova-Orchestrator has performed its initial session/ConPort initialization.
- User has provided a clear description of the new feature, its goals, and ideally, some initial requirements or user stories.
- The existing project in ConPort is in a stable state (e.g., not in the middle of a critical bug fix for an unrelated area).

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase NF.1: Feature Definition & Impact Assessment (Nova-Orchestrator -> Nova-LeadArchitect)**

1.  **Nova-Orchestrator: Delegate Feature Specification & Impact Analysis**
    *   **DoR Check:** User has provided initial feature description.
    *   **Task:** "Delegate the detailed specification of the new feature [FeatureName] and an impact analysis of its integration into the existing project [ProjectName] to Nova-LeadArchitect."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Successfully integrate new feature [FeatureName] into Project [ProjectName]."
          Phase_Goal: "Define detailed specifications for [FeatureName], analyze its impact on the existing architecture of Project [ProjectName], and update relevant ConPort documentation."
          Lead_Mode_Specific_Instructions:
            - "Feature to define: [FeatureName] - [UserProvidedFeatureDescription]."
            - "1. Work with the user (simulated via your `ask_followup_question` if needed, relayed by me) to detail out user stories, acceptance criteria, and non-functional requirements for [FeatureName]. Log these to ConPort `CustomData FeatureScope:[FeatureName_Scope]` (key) and `CustomData AcceptanceCriteria:[FeatureName_AC]` (key)."
            - "2. Execute the workflow `.nova/workflows/nova-leadarchitect/WF_ARCH_IMPACT_ANALYSIS_001_v1.md` to assess the impact of [FeatureName] on existing `SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key), and other relevant ConPort items for Project [ProjectName]. Your team (SystemDesigner, ConPortSteward) should perform the detailed checks."
            - "3. Based on the impact analysis, propose necessary architectural changes or additions. Log these as new/updated `SystemArchitecture` (key) components and related `Decisions` (integer `id`)."
            - "4. If new APIs or DB changes are needed, ensure your SystemDesigner defines them in `APIEndpoints` (key) / `DBMigrations` (key)."
            - "5. Update `active_context.state_of_the_union` to reflect 'Feature [FeatureName] specified and impact assessed. Ready for development planning'."
          Required_Input_Context:
            - ProjectName: "[ProjectName]"
            - FeatureName: "[FeatureName]"
            - UserProvidedFeatureDescription: "[...]"
            - Path_To_Impact_Analysis_Workflow: ".nova/workflows/nova-leadarchitect/WF_ARCH_IMPACT_ANALYSIS_001_v1.md"
            - Existing_Project_ProductContext_Ref: { type: "product_context", id: "product_context"}
            - Existing_Project_SystemArchitecture_Ref: { type: "custom_data", category: "SystemArchitecture", key_pattern: "[ProjectName]_*" }
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "ConPort keys for `FeatureScope:[FeatureName_Scope]` and `AcceptanceCriteria:[FeatureName_AC]`."
            - "ConPort key for the `ImpactAnalyses:[FeatureName_ImpactReport_Date]`."
            - "List of ConPort IDs/keys for any new/updated `SystemArchitecture`, `APIEndpoints`, `DBMigrations`, or architectural `Decisions` related to this feature."
            - "Confirmation `active_context.state_of_the_union` is updated."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify key deliverables.
        *   Log/Update top-level `Progress` (integer `id`) for "Feature [FeatureName] Delivery" to "Specification & Design Complete, Development Pending".

**Phase NF.2: Feature Development & Unit/Integration Testing (Nova-Orchestrator -> Nova-LeadDeveloper)**

2.  **Nova-Orchestrator: Delegate Feature Development**
    *   **DoR Check:** `FeatureScope` (key), `AcceptanceCriteria` (key) for [FeatureName] are in ConPort. Any necessary architectural updates (`SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key)) are logged and approved. User confirms readiness.
    *   **Task:** "Delegate the development of [FeatureName] to Nova-LeadDeveloper."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Successfully integrate new feature [FeatureName] into Project [ProjectName]."
          Phase_Goal: "Implement [FeatureName] for Project [ProjectName] according to provided specifications, ensuring code quality and comprehensive testing."
          Lead_Mode_Specific_Instructions:
            - "Feature to implement: [FeatureName]."
            - "Refer to `FeatureScope:[FeatureName_Scope]` (key), `AcceptanceCriteria:[FeatureName_AC]` (key), and relevant `SystemArchitecture` (key)/`APIEndpoints` (key)/`DBMigrations` (key) updates provided by Nova-LeadArchitect's team."
            - "Execute your standard development lifecycle (e.g., `.nova/workflows/nova-leaddeveloper/WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md`) to manage your team for this feature."
            - "Ensure all new code is unit tested and integration tested with existing project components."
            - "Your team should log all technical implementation `Decisions` (integer `id`), `CodeSnippets` (key), `APIUsage` (key), etc."
            - "Update `active_context.state_of_the_union` to 'Feature [FeatureName] Development Completed, Awaiting QA'."
          Required_Input_Context:
            - ProjectName: "[ProjectName]"
            - FeatureName: "[FeatureName]"
            - ConPort_FeatureScope_Key: "[FeatureName_Scope]"
            - ConPort_AcceptanceCriteria_Key: "[FeatureName_AC]"
            - ConPort_Relevant_Arch_API_DB_Refs: "[Keys/IDs from LeadArchitect's phase output]"
            - ConPort_ProjectConfig_Key: "ProjectConfig:ActiveConfig"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "Summary of implemented aspects of [FeatureName]."
            - "Confirmation of linting and unit/integration test completion and pass status."
            - "List of key ConPort items created: implementation `Decision` (integer `id`s), `CodeSnippets` (keys)."
            - "Confirmation `active_context.state_of_the_union` is updated."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify deliverables.
        *   Update `Progress` (integer `id`) for "Feature [FeatureName] Delivery" to "Development Complete, QA Pending".

**Phase NF.3: Feature Quality Assurance & Testing (Nova-Orchestrator -> Nova-LeadQA)**

3.  **Nova-Orchestrator: Delegate Feature QA**
    *   **DoR Check:** Feature development reported as complete. Feature is in a testable state.
    *   **Task:** "Delegate the QA and testing for the newly implemented [FeatureName] to Nova-LeadQA."
    *   **`new_task` message for Nova-LeadQA:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Successfully integrate new feature [FeatureName] into Project [ProjectName]."
          Phase_Goal: "Thoroughly test the new [FeatureName] within Project [ProjectName], including integration with existing functionalities. Identify and track defects, verify fixes."
          Lead_Mode_Specific_Instructions:
            - "Feature to test: [FeatureName]."
            - "Refer to `FeatureScope:[FeatureName_Scope]` (key) and `AcceptanceCriteria:[FeatureName_AC]` (key)."
            - "Develop and execute test cases covering functional requirements, AC, and integration points with existing system parts."
            - "Log all defects as structured `CustomData ErrorLogs:[key]` (R20)."
            - "Manage bug lifecycle: investigation, coordination for fixes (via me, Nova-Orchestrator, to Nova-LeadDeveloper), verification."
            - "Update `active_context.state_of_the_union` to 'Feature [FeatureName] QA Completed. Quality Status: [e.g., Ready for Integration, Blocked by X bugs]'."
          Required_Input_Context:
            - ProjectName: "[ProjectName]"
            - FeatureName: "[FeatureName]"
            - ConPort_FeatureScope_Key: "[FeatureName_Scope]"
            - ConPort_AcceptanceCriteria_Key: "[FeatureName_AC]"
            - (Optional) Developer_Unit_Integration_Test_Results_Ref: "[Path or ConPort key if available]"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "QA Summary Report for [FeatureName]: Test coverage, pass/fail, list of open critical/high `ErrorLogs` (keys)."
            - "Confirmation `active_context.state_of_the_union` and `open_issues` are updated."
            - "Recommendation on feature integration readiness."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Review QA report. If not ready, loop back to Phase NF.2 (Development for fixes) or Phase NF.3 (more QA).
        *   Update `Progress` (integer `id`) for "Feature [FeatureName] Delivery" e.g., "QA Complete, Ready for Release" or "QA Found Blockers".

**Phase NF.4: Feature Integration & Documentation Update (Nova-Orchestrator -> relevant Leads)**
    *(This might be folded into the end of QA or become part of a broader release workflow)*
4.  **Nova-Orchestrator: Coordinate Final Integration & Documentation**
    *   **Action:**
        *   Delegate to Nova-LeadDeveloper: Ensure feature branch is merged to main, final build checks.
        *   Delegate to Nova-LeadArchitect: Ensure all project documentation (`SystemArchitecture` (key), user docs via CodeDocumenter/WorkflowManager) is updated to include the new feature. Ensure `DefinedWorkflows` (key) that might be affected are reviewed.
    *   **Output:** Feature fully integrated. All documentation updated.

**Phase NF.5: Closure for Feature Cycle (Nova-Orchestrator)**
5.  **Nova-Orchestrator: Finalize Feature Cycle**
    *   **Action:**
        *   Log `Decision` (integer `id`) confirming successful integration of [FeatureName].
        *   Update `Progress` (integer `id`) for "Feature [FeatureName] Delivery" to "COMPLETED".
        *   Update `active_context.state_of_the_union` to "Feature [FeatureName] successfully integrated into Project [ProjectName]".
    *   **Output:** Feature cycle concluded.

**Key ConPort Items Referenced/Updated by Nova-Orchestrator (overall for this feature):**
-   `Progress` (integer `id`) for the feature delivery.
-   Reads/Ensures creation of: `FeatureScope:[key]`, `AcceptanceCriteria:[key]`, `ImpactAnalyses:[key]`.
-   Ensures updates to: `SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key), `Decisions` (integer `id`), `CodeSnippets` (key), `ErrorLogs` (key), `LessonsLearned` (key), `DefinedWorkflows` (key).
-   Manages overall `active_context.state_of_the_union`.