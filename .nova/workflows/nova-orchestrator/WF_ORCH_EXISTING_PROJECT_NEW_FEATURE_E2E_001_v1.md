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
            "5. To update `active_context`, instruct your team to use `use_mcp_tool` with `tool_name: 'update_active_context'` and provide a `patch_content` argument to set the `state_of_the_union` field to 'Feature [FeatureName] specified and impact assessed. Ready for development planning'."
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

**Phase NF.1.5: Definition of Ready (DoR) Check for Development Phase**

2.  **Nova-Orchestrator: Verify DoR for Development**
    *   **Trigger:** Activated after Design Phase (NF.1) and before delegating the Development phase (NF.2).
    *   **Step 1: Get DoR Criteria**
        *   **Action:** Use `use_mcp_tool` (`tool_name: 'get_custom_data'`) to retrieve `CustomData ProjectStandards:DefaultDoR`. If not found, use a default list: ["Approved Architecture Document", "Finalized API Specifications", "Feature Scope Defined", "Acceptance Criteria Defined"].
        *   **Output:** `DoR_Criteria_List`.
    *   **Step 2: Verify Criteria**
        *   **Action:** For each criterion in `DoR_Criteria_List`:
            *   Verify `FeatureScope` and `AcceptanceCriteria` (from Phase NF.1 output) exist.
            *   Verify key `SystemArchitecture` and `APIEndpoints` items (from NF.1 output) exist and have `status: "APPROVED"` or `status: "FINAL"`.
        *   **Output:** `Verification_Results` (list of pass/fail for each criterion).
    *   **Step 3: Conditional Gateway**
        *   **Condition:** Are all criteria in `Verification_Results` marked as 'pass'?
        *   **Path A (YES - Success):**
            *   **Action:** Log a `Decision`: "DoR check for Development of Feature [FeatureName] passed."
            *   **Next Step:** Proceed to Phase NF.2.
        *   **Path B (NO - Failure):**
            *   **Action:** Pause this workflow. Identify and list the `Failed_Criteria`.
            *   **Action:** Delegate a new preparatory subtask to `Nova-LeadArchitect`.
            *   **`new_task` message for Nova-LeadArchitect:**
                ```json
                {
                  "Context_Path": "Feature [FeatureName] (Orchestrator) -> DoR Remediation for Development (LeadArchitect)",
                  "Phase_Goal": "Remediate failing DoR criteria for the Development Phase of Feature [FeatureName].",
                  "Lead_Mode_Specific_Instructions": [
                    "The 'Definition of Ready' for the Development Phase has failed. The following criteria are not met: [List of Failed_Criteria].",
                    "Your team must take action to meet these criteria. This may involve finalizing designs, securing approvals (simulated via user interaction if needed), or updating ConPort statuses.",
                    "Report back via `attempt_completion` when all listed criteria are now met."
                  ],
                  "Required_Input_Context": { "Failed_Criteria_List": "[...]" },
                  "Expected_Deliverables_In_Attempt_Completion_From_Lead": ["Confirmation that all failed DoR criteria are now met."]
                }
                ```
            *   **Action:** Await `attempt_completion` from Nova-LeadArchitect.
            *   **Next Step:** Upon completion, loop back to the beginning of this Phase NF.1.5 to re-run the DoR check.


**Phase NF.2: Feature Development & Unit/Integration Testing (Nova-Orchestrator -> Nova-LeadDeveloper)**

3.  **Nova-Orchestrator: Delegate Feature Development**
    *   **DoR Check:** DoR for Development (Phase NF.1.5) has passed. User confirms readiness.
    *   **Action:** Update top-level `Progress` (integer `id`) to "DEVELOPMENT_PHASE".
    *   **Task:** "Delegate the development of [FeatureName] to Nova-LeadDeveloper."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Feature [FeatureName] Development (LeadDeveloper)",
          "Overall_Project_Goal": "Successfully integrate new feature [FeatureName] into Project [ProjectName].",
          "Phase_Goal": "Implement [FeatureName] for Project [ProjectName] according to provided specifications, ensuring code quality and comprehensive testing.",
          "Lead_Mode_Specific_Instructions": [
            "Your goal for this phase is to implement the feature '[FeatureName]'. Create a high-level plan for this phase, log it to ConPort, and then use your standard single-step execution loop to delegate atomic tasks to your specialists. You may consult `.nova/workflows/nova-leaddeveloper/WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md` for a reference process. Ensure all code is tested and quality standards are met."
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

**Phase NF.2.5: Definition of Ready (DoR) Check for QA Phase**
4.  **Nova-Orchestrator: Verify DoR for QA**
    *   **Trigger:** Activated before delegating the QA phase.
    *   **Step 1 & 2: Get & Verify DoR Criteria**
        *   **Action:** Retrieve `CustomData ProjectStandards:DefaultDoR`. Check criteria like "Development Complete (All planned features implemented and unit/integration tested)", "Code merged to test branch", "Test Environment Ready".
        *   Verify by checking `Progress` from development phase is "DONE", and `ProjectConfig` specifies a ready test environment.
    *   **Step 3: Conditional Gateway**
        *   **Path A (YES - Success):** Log success, proceed to Phase NF.3.
        *   **Path B (NO - Failure):** Pause workflow. Delegate remediation task to `Nova-LeadDeveloper` (e.g., "Complete unfinished components", "Fix failing integration tests") or `Nova-LeadArchitect` (e.g., "Ensure test environment in `ProjectConfig` is correctly defined and available"). Await completion, then loop back to start of Phase NF.2.5.

**Phase NF.3: Feature Quality Assurance & Testing (Nova-Orchestrator -> Nova-LeadQA)**

5.  **Nova-Orchestrator: Delegate Feature QA**
    *   **DoR Check:** DoR for QA (Phase NF.2.5) has passed.
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
            "Coordinate with me to ensure `active_context.open_issues` is updated.",
            "At the end of this phase, coordinate with me to update `active_context.state_of_the_union` to 'Feature [FeatureName] QA Completed. Quality Status: [e.g., Ready for Integration, Blocked by X bugs]'."
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
6.  **Nova-Orchestrator: Coordinate Final Integration & Documentation**
    *   **Action:**
        *   Delegate to Nova-LeadDeveloper: Briefing to ensure feature branch is merged to main (conceptual, no git tools directly), final build checks, and update any developer-facing documentation.
        *   Delegate to Nova-LeadArchitect: Briefing to ensure their team (CodeDocumenter via LeadDev or WorkflowManager/ConPortSteward via LeadArch) updates all project documentation (`SystemArchitecture` (key), user docs, `DefinedWorkflows` (key)) to include the new feature.
    *   **Output:** Feature fully integrated. All documentation updated.

**Phase NF.5: Closure for Feature Cycle (Nova-Orchestrator)**
7.  **Nova-Orchestrator: Finalize Feature Cycle**
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