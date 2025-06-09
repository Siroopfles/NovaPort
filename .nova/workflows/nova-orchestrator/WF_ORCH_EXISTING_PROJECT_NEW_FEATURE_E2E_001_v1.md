# Workflow: Existing Project - New Feature End-to-End Cycle (WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1)

**Goal:** To guide the implementation of a new feature within an existing project, from specification through design, development, QA, and integration.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Primary Lead Mode Actors (delegated to by Nova-Orchestrator):** Nova-LeadArchitect, Nova-LeadDeveloper, Nova-LeadQA

**Trigger / Recognition:**
- User requests a new feature for an existing, already initialized project (e.g., "Add a user dashboard to Project X", "Implement payment integration for our app").
- ConPort `ProductContext` (key 'product_context'), `ProjectConfig:ActiveConfig` (key), and `NovaSystemConfig:ActiveSettings` (key) already exist and are reasonably up-to-date.

**Pre-requisites by Nova-Orchestrator (before starting this workflow):**
- Nova-Orchestrator has performed its initial session/ConPort initialization (executing `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md`).
- User has provided a clear description of the new feature, its goals, and ideally, some initial requirements or user stories.
- The existing project in ConPort is in a stable state (e.g., not in the middle of a critical bug fix for an unrelated area).

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase NF.1: Feature Definition & Impact Assessment (Nova-Orchestrator -> Nova-LeadArchitect)**

1.  **Nova-Orchestrator: Delegate Feature Specification & Impact Analysis**
    *   **DoR Check:** User has provided initial feature description. Existing project context is loaded.
    *   **Action:** Log/Update top-level `Progress` (integer `id`) item for "Feature [FeatureName] Delivery for Project [ProjectName]" to "SPECIFICATION_DESIGN_PHASE", using `use_mcp_tool` (`tool_name: 'log_progress'` or `update_progress`).
    *   **Task:** "Delegate the detailed specification of new feature [FeatureName] and an impact analysis of its integration into Project [ProjectName] to Nova-LeadArchitect."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Feature [FeatureName] Definition (LeadArchitect)",
          "Overall_Project_Goal": "Successfully integrate new feature [FeatureName] into Project [ProjectName].",
          "Phase_Goal": "Define detailed specifications for [FeatureName], analyze its impact on the existing architecture of Project [ProjectName], and update relevant ConPort documentation.",
          "Lead_Mode_Specific_Instructions": [
            "Feature to define: [FeatureName] - [UserProvidedFeatureDescription].",
            "1. Work with the user (simulated via your `ask_followup_question` if needed, relayed by me, Nova-Orchestrator) to detail out user stories, acceptance criteria, and non-functional requirements for [FeatureName]. Your Nova-SpecializedConPortSteward or SystemDesigner should log these to ConPort `CustomData FeatureScope:[FeatureName_Scope_Key]` (key) and `CustomData AcceptanceCriteria:[FeatureName_AC_Key]` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`).",
            "2. Execute the workflow `.nova/workflows/nova-leadarchitect/WF_ARCH_IMPACT_ANALYSIS_001_v1.md` to assess the impact of [FeatureName] on existing `SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key), and other relevant ConPort items for Project [ProjectName]. Your team (SystemDesigner, ConPortSteward) should perform the detailed checks as outlined in that workflow.",
            "3. Based on the impact analysis, propose necessary architectural changes or additions. Log these as new/updated `SystemArchitecture` (key) components and related `Decisions` (integer `id`) using `use_mcp_tool`.",
            "4. If new APIs or DB changes are needed, ensure your SystemDesigner defines them in `APIEndpoints` (key) / `DBMigrations` (key) using `use_mcp_tool`.",
            "5. To update `active_context`, instruct your team to first `get_active_context`, modify the `state_of_the_union` field to 'Feature [FeatureName] specified and impact assessed. Ready for development planning', then use `log_custom_data` on the `ActiveContext` category with key `active_context`."
          ],
          "Required_Input_Context": {
            "ProjectName": "[ProjectName]",
            "FeatureName": "[FeatureName]",
            "UserProvidedFeatureDescription": "[UserProvidedFeatureDescription]",
            "Path_To_Impact_Analysis_Workflow": ".nova/workflows/nova-leadarchitect/WF_ARCH_IMPACT_ANALYSIS_001_v1.md",
            "Existing_Project_ProductContext_Ref": { "type": "product_context", "id": "product_context"},
            "Existing_Project_SystemArchitecture_Ref_Pattern": { "type": "custom_data", "category": "SystemArchitecture", "key_pattern": "[ProjectName]_*" }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "ConPort keys for `FeatureScope:[FeatureName_Scope_Key]` and `AcceptanceCriteria:[FeatureName_AC_Key]`.",
            "ConPort key for the `ImpactAnalyses:[FeatureName_ImpactReport_Date_Key]`.",
            "List of ConPort IDs/keys for any new/updated `SystemArchitecture`, `APIEndpoints`, `DBMigrations`, or architectural `Decisions` related to this feature.",
            "Confirmation `active_context.state_of_the_union` is updated."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify key deliverables.
        *   Update top-level `Progress` (integer `id`) to "Specification & Design Complete, Development Pending".

**Phase NF.2: Feature Development & Unit/Integration Testing (Nova-Orchestrator -> Nova-LeadDeveloper)**

2.  **Nova-Orchestrator: Delegate Feature Development**
    *   **DoR Check:** `FeatureScope` (key), `AcceptanceCriteria` (key) for [FeatureName] are in ConPort. Any necessary architectural updates (`SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key)) are logged and approved. User confirms readiness.
    *   **Action:** Update top-level `Progress` (integer `id`) to "DEVELOPMENT_PHASE".
    *   **Task:** "Delegate the development of [FeatureName] to Nova-LeadDeveloper."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Feature [FeatureName] Development (LeadDeveloper)",
          "Overall_Project_Goal": "Successfully integrate new feature [FeatureName] into Project [ProjectName].",
          "Phase_Goal": "Implement [FeatureName] for Project [ProjectName] according to provided specifications, ensuring code quality and comprehensive testing.",
          "Lead_Mode_Specific_Instructions": [
            "Feature to implement: [FeatureName].",
            "Refer to `FeatureScope:[FeatureName_Scope_Key]` (key), `AcceptanceCriteria:[FeatureName_AC_Key]` (key), and relevant `SystemArchitecture` (key)/`APIEndpoints` (key)/`DBMigrations` (key) updates provided by Nova-LeadArchitect's team (retrieve using `use_mcp_tool`).",
            "Execute your standard development lifecycle (e.g., `.nova/workflows/nova-leaddeveloper/WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md`) to manage your team (FeatureImplementer, TestAutomator, CodeDocumenter, Refactorer if needed) for this feature.",
            "Ensure all new code is unit tested and integration tested with existing project components.",
            "Your team should log all technical implementation `Decisions` (integer `id`), `CodeSnippets` (key), `APIUsage` (key), `TechDebtCandidates` (key) with scoring, etc. using `use_mcp_tool`.",
            "Update `active_context.state_of_the_union` to 'Feature [FeatureName] Development Completed, Awaiting QA' (This update will be coordinated via me, Nova-Orchestrator, to Nova-LeadArchitect if you cannot do it directly)."
          ],
          "Required_Input_Context": {
            "ProjectName": "[ProjectName]",
            "FeatureName": "[FeatureName]",
            "ConPort_FeatureScope_Key": "[FeatureName_Scope_Key]",
            "ConPort_AcceptanceCriteria_Key": "[FeatureName_AC_Key]",
            "ConPort_Relevant_Arch_API_DB_Refs": "[Keys/IDs from LeadArchitect's phase output]",
            "ConPort_ProjectConfig_Key": "ProjectConfig:ActiveConfig"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Summary of implemented aspects of [FeatureName].",
            "Confirmation of linting and unit/integration test completion and pass status (or list of critical unresolved test failures).",
            "List of key ConPort items created: implementation `Decision` (integer `id`s), `CodeSnippets` (keys).",
            "Confirmation that `active_context.state_of_the_union` is updated (or request for update sent)."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify deliverables.
        *   Update `Progress` (integer `id`) to "Development Complete, QA Pending".

**Phase NF.3: Feature Quality Assurance & Testing (Nova-Orchestrator -> Nova-LeadQA)**

3.  **Nova-Orchestrator: Delegate Feature QA**
    *   **DoR Check:** Feature development reported as complete. Feature is in a testable state.
    *   **Action:** Update top-level `Progress` (integer `id`) to "QA_PHASE".
    *   **Task:** "Delegate the QA and testing for the newly implemented [FeatureName] to Nova-LeadQA."
    *   **`new_task` message for Nova-LeadQA:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Feature [FeatureName] QA (LeadQA)",
          "Overall_Project_Goal": "Successfully integrate new feature [FeatureName] into Project [ProjectName].",
          "Phase_Goal": "Thoroughly test the new [FeatureName] within Project [ProjectName], including integration with existing functionalities. Identify and track defects, verify fixes.",
          "Lead_Mode_Specific_Instructions": [
            "Feature to test: [FeatureName].",
            "Refer to `FeatureScope:[FeatureName_Scope_Key]` (key) and `AcceptanceCriteria:[FeatureName_AC_Key]` (key) (retrieve using `use_mcp_tool`).",
            "Develop and execute test cases covering functional requirements, AC, and integration points with existing system parts.",
            "Log all defects as structured `CustomData ErrorLogs:[key]` (R20 compliant) using `use_mcp_tool` (`tool_name: 'log_custom_data'`).",
            "Manage bug lifecycle: investigation, coordination for fixes (via me, Nova-Orchestrator, to Nova-LeadDeveloper), verification.",
            "Update `active_context.open_issues` (coordinate update via me to Nova-LeadArchitect/ConPortSteward).",
            "At the end of this phase, update `active_context.state_of_the_union` to 'Feature [FeatureName] QA Completed. Quality Status: [e.g., Ready for Integration, Blocked by X bugs]' (Coordinate update via me to Nova-LeadArchitect)."
          ],
          "Required_Input_Context": {
            "ProjectName": "[ProjectName]",
            "FeatureName": "[FeatureName]",
            "ConPort_FeatureScope_Key": "[FeatureName_Scope_Key]",
            "ConPort_AcceptanceCriteria_Key": "[FeatureName_AC_Key]",
            "Developer_Build_Or_Branch_Info": "[Details from LeadDeveloper phase completion]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "QA Summary Report for [FeatureName]: Test coverage, pass/fail, list of open critical/high `ErrorLogs` (keys).",
            "Confirmation `active_context.state_of_the_union` and `open_issues` are updated (or request for update sent).",
            "Recommendation on feature integration readiness."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Review QA report. If not ready, loop back to Phase NF.2 (Development for fixes) or Phase NF.3 (more QA), logging a `Decision` (integer `id`) for this loop.
        *   Update `Progress` (integer `id`) e.g., "QA Complete, Release Prep Pending" or "QA Found Blockers".

**Phase NF.4: Feature Integration & Documentation Update (Nova-Orchestrator -> relevant Leads)**
    *(This might be folded into the end of QA or become part of a broader release workflow like WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md)*
4.  **Nova-Orchestrator: Coordinate Final Integration & Documentation**
    *   **Action:**
        *   Delegate to Nova-LeadDeveloper: Briefing to ensure feature branch is merged to main (conceptual, no git tools directly), final build checks, and update any developer-facing documentation.
        *   Delegate to Nova-LeadArchitect: Briefing to ensure their team (CodeDocumenter via LeadDev or WorkflowManager/ConPortSteward via LeadArch) updates all project documentation (`SystemArchitecture` (key), user docs, `DefinedWorkflows` (key)) to include the new feature.
    *   **Output:** Feature fully integrated. All documentation updated.

**Phase NF.5: Closure for Feature Cycle (Nova-Orchestrator)**
5.  **Nova-Orchestrator: Finalize Feature Cycle**
    *   **Action:**
        *   Log `Decision` (integer `id`) confirming successful integration of [FeatureName] using `use_mcp_tool` (`tool_name: 'log_decision'`).
        *   Update top-level `Progress` (integer `id`) for "Feature [FeatureName] Delivery" to "COMPLETED" using `use_mcp_tool` (`tool_name: 'update_progress'`).
        *   Update `active_context.state_of_the_union` to "Feature [FeatureName] successfully integrated into Project [ProjectName]" (coordinated via LeadArchitect).
        *   Initiate `WF_ORCH_SYSTEM_RETROSPECTIVE_AND_IMPROVEMENT_PROPOSAL_001_v1.md` if defined, to capture `LessonsLearned`.
    *   **Output:** Feature cycle concluded.

**Key ConPort Items Referenced/Updated by Nova-Orchestrator (overall for this feature):**
- Progress (integer `id`) for the feature delivery.
- Reads/Ensures creation of: FeatureScope (key), AcceptanceCriteria (key), ImpactAnalyses (key).
- Ensures updates to: SystemArchitecture (key), APIEndpoints (key), DBMigrations (key), Decisions (integer `id`), CodeSnippets (key), ErrorLogs (key), LessonsLearned (key), DefinedWorkflows (key).
- Manages overall active_context.state_of_the_union.