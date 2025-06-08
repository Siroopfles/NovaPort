# Workflow: Release Preparation and Conceptual Go-Live (WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1)

**Goal:** To guide all necessary steps to prepare for a software release, including final testing, documentation updates, ConPort updates, and conceptual version tagging.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Primary Lead Mode Actors (delegated to by Nova-Orchestrator):** Nova-LeadQA, Nova-LeadArchitect, Nova-LeadDeveloper

**Trigger / Recognition:**
- User indicates intention to prepare for a new release (e.g., "Let's prepare release v2.1.0").
- All features and critical bugs planned for this release have their main `Progress` (integer `id`) items marked as resolved/done in ConPort.
- Triggered by a higher-level project plan in ConPort `ProjectRoadmap:[key]`.

**Pre-requisites by Nova-Orchestrator (before starting this workflow):**
- Nova-Orchestrator has performed its initial session/ConPort initialization.
- User has provided a target `ReleaseVersion` string (e.g., "v2.1.0").
- (Ideally) A ConPort `CustomData SprintGoals:[key]` or `CustomData ProjectFeatures:[key]` list exists outlining the scope of the release.

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase RP.1: Release Planning & Scope Finalization (Nova-Orchestrator -> Nova-LeadArchitect)**

1.  **Nova-Orchestrator: Delegate Release Scope Definition & ConPort Setup**
    *   **Action:** Log/Update top-level `Progress` (integer `id`) using `use_mcp_tool`: "Release [ReleaseVersion] Preparation", Status: "PLANNING_SCOPE". Let this be `[ReleasePrepProgressID]`.
    *   **Task:** "Delegate to Nova-LeadArchitect to finalize the scope for release [ReleaseVersion], draft release notes, and set up initial release tracking in ConPort."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Release [ReleaseVersion] -> Scope Definition (LeadArchitect)",
          "Overall_Project_Goal": "Successfully prepare Project [ProjectName] for release [ReleaseVersion].",
          "Phase_Goal": "Finalize scope for release [ReleaseVersion], create initial release artifacts in ConPort (Releases entry, draft release notes).",
          "Lead_Mode_Specific_Instructions": [
            "Target Release Version: [ReleaseVersion].",
            "1. Your ConPortSteward should create/update `CustomData Releases:[ReleaseVersion]` (key) with initial data: `{\"status\": \"Planning\", \"target_date\": \"[UserProvidedDate or TBD]\", \"scope_summary_ref_key\": \"ReleaseNotesDraft:[ReleaseVersion]_Draft\"}` using `use_mcp_tool` (`tool_name: 'log_custom_data'`).",
            "2. Review ConPort `Progress` (integer `id`) items (status DONE/RESOLVED since last release) and `CustomData ProjectFeatures:[key]` or `SprintGoals:[key]` to compile a list of features/fixes included in [ReleaseVersion]. Use `use_mcp_tool` (`tool_name: 'get_progress'`, `get_custom_data`).",
            "3. Your ConPortSteward should draft initial release notes content based on this scope. Store as `CustomData ReleaseNotesDraft:[ReleaseVersion]_Draft` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). The value should be structured (e.g., {new_features: [], bug_fixes: [], known_issues: []}).",
            "4. To update `CustomData Releases:[ReleaseVersion]` (key) with a summary of the scope, first `get_custom_data`, then modify the value, then `log_custom_data` to overwrite.",
            "5. Identify key `Decisions` (integer `id`), `SystemPatterns` (integer `id`), `APIEndpoints` (key) changes relevant to this release for inclusion in technical release notes."
          ],
          "Required_Input_Context": {
            "ReleaseVersion": "[ReleaseVersion]",
            "ProjectName": "[ProjectName]",
            "Reference_To_Sprint_Goals_Or_Feature_List_Key": "[Optional ConPort Key]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "ConPort key of the `Releases:[ReleaseVersion]` entry.",
            "ConPort key of the `ReleaseNotesDraft:[ReleaseVersion]_Draft` entry.",
            "Summary of the release scope."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Review scope. Update `[ReleasePrepProgressID]` status to "SCOPE_FINALIZED_QA_PENDING".

**Phase RP.2: Final QA & Regression Testing (Nova-Orchestrator -> Nova-LeadQA)**

2.  **Nova-Orchestrator: Delegate Final Regression Testing**
    *   **DoR Check:** Release scope finalized (`Releases:[ReleaseVersion]` (key) exists). Codebase is feature-complete for the release.
    *   **Action:** Update `[ReleasePrepProgressID]` status to "FINAL_QA_PHASE".
    *   **Task:** "Delegate to Nova-LeadQA to perform final, full regression testing and sanity checks for release [ReleaseVersion]."
    *   **`new_task` message for Nova-LeadQA:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Release [ReleaseVersion] -> Final QA (LeadQA)",
          "Overall_Project_Goal": "Successfully prepare Project [ProjectName] for release [ReleaseVersion].",
          "Phase_Goal": "Execute comprehensive final testing for release [ReleaseVersion] to ensure quality and stability.",
          "Lead_Mode_Specific_Instructions": [
            "Release Version: [ReleaseVersion] (Ref: ConPort `CustomData Releases:[ReleaseVersion]` (key)).",
            "Scope: Features/fixes listed in `CustomData ReleaseNotesDraft:[ReleaseVersion]_Draft` (key).",
            "1. Your TestExecutor should execute the full regression test suite (command from `ProjectConfig:ActiveConfig.testing_preferences.full_regression_command` or as defined in a QA workflow like `.nova/workflows/nova-leadqa/WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1.md`).",
            "2. Perform sanity checks on all key features/areas included in this release.",
            "3. If critical/high severity issues found: Log detailed `CustomData ErrorLogs:[key]` (R20 compliant) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Coordinate with me (Nova-Orchestrator) to update `active_context.open_issues`. Report these immediately in your `attempt_completion` as BLOCKERS.",
            "4. If only minor issues, or all tests pass: Document results."
          ],
          "Required_Input_Context": {
            "ReleaseVersion": "[ReleaseVersion]",
            "ConPort_Release_Scope_Ref_Key": "ReleaseNotesDraft:[ReleaseVersion]_Draft",
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["testing_preferences.full_regression_command"] }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Overall test execution summary (pass/fail, number of tests).",
            "List of any new CRITICAL/HIGH `ErrorLogs` (keys) found (these are blockers).",
            "List of any new MINOR/LOW `ErrorLogs` (keys) found.",
            "Recommendation: 'GO' or 'NO_GO (due to blockers)' for release."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   If 'NO_GO': Halt release. Log `Decision` using `use_mcp_tool`. Delegate bug fixes via `WF_ORCH_CRITICAL_BUG_RESOLUTION_PROCESS_001_v1.md`. Loop back to this phase after fixes. Update `[ReleasePrepProgressID]`.
        *   If 'GO' (or only minor issues acceptable for release with a logged `Decision`): Proceed. Update `[ReleasePrepProgressID]` status to "QA_PASSED_DOCS_PENDING".

**Phase RP.3: Documentation & Release Notes Finalization (Nova-Orchestrator -> Nova-LeadArchitect)**

3.  **Nova-Orchestrator: Delegate Documentation Finalization**
    *   **DoR Check:** QA phase completed with 'GO' recommendation.
    *   **Action:** Update `[ReleasePrepProgressID]` status to "FINAL_DOCS_PHASE".
    *   **Task:** "Delegate to Nova-LeadArchitect to finalize all user-facing and technical documentation, and the official release notes for [ReleaseVersion]."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Release [ReleaseVersion] -> Docs Finalization (LeadArchitect)",
          "Overall_Project_Goal": "Successfully prepare Project [ProjectName] for release [ReleaseVersion].",
          "Phase_Goal": "Finalize all documentation and release notes for [ReleaseVersion].",
          "Lead_Mode_Specific_Instructions": [
            "Release Version: [ReleaseVersion].",
            "1. Your ConPortSteward/WorkflowManager should ensure all user-facing documentation (e.g., in `/docs/` as per `ProjectConfig:ActiveConfig`) and technical documentation (`SystemArchitecture` (key), `APIEndpoints` (key) in ConPort) are updated for features/changes in this release. This may involve your SystemDesigner for technical content.",
            "2. Your ConPortSteward should finalize the release notes based on `CustomData ReleaseNotesDraft:[ReleaseVersion]_Draft` (key) and any last-minute changes or minor issues from QA. Store final version in `CustomData ReleaseNotesFinal:[ReleaseVersion]` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`).",
            "3. To update `ProductContext` (key 'product_context') if it needs to reflect the state of this release (e.g., new major version), use `get_product_context`, modify the object, then use `log_custom_data` on category `ProductContext` and key `product_context` to overwrite."
          ],
          "Required_Input_Context": {
            "ReleaseVersion": "[ReleaseVersion]",
            "ConPort_Release_Draft_Notes_Key": "ReleaseNotesDraft:[ReleaseVersion]_Draft",
            "List_Of_Minor_Issues_From_QA": "[...]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Confirmation of documentation updates (paths or ConPort keys).",
            "ConPort key of the `ReleaseNotesFinal:[ReleaseVersion]` entry.",
            "Confirmation if `ProductContext` (key 'product_context') was updated."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:** Verify deliverables. Update `[ReleasePrepProgressID]` status to "DOCS_FINALIZED_TAGGING_PENDING".

**Phase RP.4: Conceptual Version Tagging & ConPort Update (Nova-Orchestrator -> Nova-LeadDeveloper & Nova-LeadArchitect)**

4.  **Nova-Orchestrator: Delegate Conceptual Tagging & Final ConPort Status**
    *   **Task 1 (to Nova-LeadDeveloper):** "Conceptually prepare for version tagging of [ReleaseVersion]."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Release [ReleaseVersion] -> Conceptual Tagging (LeadDeveloper)",
          "Overall_Project_Goal": "Successfully prepare Project [ProjectName] for release [ReleaseVersion].",
          "Phase_Goal": "Log conceptual version tagging for [ReleaseVersion] in ConPort.",
          "Lead_Mode_Specific_Instructions": [
            "Release Version: [ReleaseVersion].",
            "1. Identify the current commit hash in the main/release branch that represents this release state (this might require user input if no direct VCS tool access).",
            "2. Log a `Decision` (integer `id`) in ConPort using `use_mcp_tool` (`tool_name: 'log_decision'`): 'Decision: Commit `[commit_hash]` is designated for release `[ReleaseVersion]`. All tests passed, documentation finalized.' Rationale: 'Formal marker for release state.' Add tag #[ReleaseVersion].",
            "3. (User will be instructed to perform actual git tag command separately based on this decision)."
          ],
          "Required_Input_Context": {
            "ReleaseVersion": "[ReleaseVersion]",
            "User_Provided_Commit_Hash_If_Any": "[...]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "ConPort integer `id` of the conceptual tagging `Decision`."
          ]
        }
        ```
    *   **Nova-Orchestrator Action:** Await completion. Instruct user about physical git tagging.
    *   **Task 2 (to Nova-LeadArchitect):** "Update ConPort status for released version [ReleaseVersion]."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Release [ReleaseVersion] -> ConPort Status Update (LeadArchitect)",
          "Overall_Project_Goal": "Successfully prepare Project [ProjectName] for release [ReleaseVersion].",
          "Phase_Goal": "Update ConPort to reflect that [ReleaseVersion] is now considered 'Shipped' or 'Released'.",
          "Lead_Mode_Specific_Instructions": [
            "Release Version: [ReleaseVersion].",
            "1. Your ConPortSteward should update `CustomData Releases:[ReleaseVersion]` (key) status to 'Shipped' and add `release_date: [current_date]` by first using `get_custom_data` and then `log_custom_data` to overwrite.",
            "2. Update your main `Progress` (integer `id`) for this entire Release Prep workflow (which I, Nova-Orchestrator, will provide the ID for if you need to link or find it) to DONE.",
            "3. To update `active_context`, instruct your team to first `get_active_context`, modify the `state_of_the_union` field to 'Project [ProjectName] version [ReleaseVersion] released on [Date].', then use `log_custom_data` on the `ActiveContext` category with key `active_context`."
          ],
          "Required_Input_Context": {
            "ReleaseVersion": "[ReleaseVersion]",
            "Orchestrator_Main_Release_Prep_Progress_ID": "[integer_id_of_Orchestrators_Progress_for_this_release_cycle]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Confirmation of `Releases:[ReleaseVersion]` (key) update.",
            "Confirmation of `active_context.state_of_the_union` update."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after both Leads complete:** Update `[ReleasePrepProgressID]` status to "COMPLETED_RELEASED_CONCEPTUALLY".

**Phase RP.5: Notify User (Nova-Orchestrator)**

5.  **Nova-Orchestrator: `attempt_completion` to User**
    *   **Action:** Inform user that release [ReleaseVersion] preparation is complete, all checks passed, documentation is updated, and ConPort reflects the new release status. Summarize key ConPort items.
    *   Result should include ConPort key for `Releases:[ReleaseVersion]` and `ReleaseNotesFinal:[ReleaseVersion]`.

**Key ConPort Items Involved:**
- CustomData Releases:[key]
- CustomData ReleaseNotesDraft:[key], CustomData ReleaseNotesFinal:[key]
- Progress (integer `id`) (Orchestrator's main, Leads' phases, Specialists' subtasks)
- Decisions (integer `id`) (e.g., for conceptual tagging, for accepting minor bugs in release)
- ErrorLogs (key) (from QA phase)
- ProductContext (key 'product_context') (potentially updated)
- SystemArchitecture (key), APIEndpoints (key) (documentation updates)
- ActiveContext (`state_of_the_union`, `open_issues` updates)