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

---

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase RP.0: Pre-flight Checks by Nova-Orchestrator**

1.  **Nova-Orchestrator: Verify Readiness for Release Cycle**
    *   **Actor:** Nova-Orchestrator
    *   **Action:** Before delegating the first phase, perform these critical pre-flight checks using `use_mcp_tool`.
    *   **Checks:**
        1.  **Check for `ProjectConfig:ActiveConfig`:**
            - Use `use_mcp_tool` (`tool_name: 'get_custom_data'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"ProjectConfig\", \"key\": \"ActiveConfig\"}`).
            - **Failure:** If not found, report to user: "BLOCKER: `ProjectConfig:ActiveConfig` is not defined. Cannot proceed with release. Please run the project configuration setup first." Halt workflow.
        2.  **Check for QA sign-off on major features:**
            - Based on the user-provided release scope, identify the key `FeatureScope` keys or `Progress` IDs.
            - For each, check linked `Progress` items for a status of `QA_COMPLETE` or `DONE`.
            - **Failure:** If key features have not passed QA, report to user: "BLOCKER: Feature '[FeatureName]' has not completed the QA phase. Cannot proceed with release. Please ensure all features for this release are QA-approved." Halt workflow.
        3.  **Check for Open Critical Bugs:**
            - Use `use_mcp_tool` (`tool_name: 'get_active_context'`) to check `open_issues`.
            - Filter for any issues with severity 'CRITICAL' or 'BLOCKER'.
            - **Failure:** If open critical bugs exist that are not explicitly deferred for this release by a `Decision`, report to user: "BLOCKER: Found open critical bugs: [ErrorLog Keys]. Cannot proceed with release until these are resolved or formally deferred." Halt workflow.
    *   **Output:** All pre-flight checks passed. Workflow can proceed.

**Phase RP.1: Release Planning & Scope Finalization (Nova-Orchestrator -> Nova-LeadArchitect)**

2.  **Nova-Orchestrator: Delegate Release Scope Definition & ConPort Setup**
    *   **Action:** Log/Update top-level `Progress` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_progress'` or `update_progress`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Release [ReleaseVersion] Preparation\"}`). Let this be `[ReleasePrepProgressID]`.
    *   **Task:** "Delegate to Nova-LeadArchitect to finalize the scope for release [ReleaseVersion], draft release notes, and set up initial release tracking in ConPort."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Release [ReleaseVersion] -> Scope Definition (LeadArchitect)",
          "Overall_Project_Goal": "Successfully prepare Project [ProjectName] for release [ReleaseVersion].",
          "Phase_Goal": "Finalize scope for release [ReleaseVersion], create initial release artifacts in ConPort (Releases entry, draft release notes).",
          "Lead_Mode_Specific_Instructions": [
            "Target Release Version: [ReleaseVersion].",
            "Your goal is to finalize the release scope. Plan and delegate tasks to your specialists.",
            "Key sub-tasks will include: creating/updating a `Releases:[ReleaseVersion]` item in ConPort; compiling a list of included features/fixes to draft `ReleaseNotesDraft:[ReleaseVersion]_Draft`; and identifying relevant technical changes (`Decisions`, `APIEndpoints`, etc.) for technical release notes."
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

3.  **Nova-Orchestrator: Delegate Final Regression Testing**
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
            "Your goal for this phase is to provide a final quality gate. Create a plan and delegate tasks to your specialists to perform full regression and targeted testing based on the release scope.",
            "You may consult `.nova/workflows/nova-leadqa/WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1.md` for a reference process.",
            "Log all new defects as `ErrorLogs`. Critical/High severity issues are release blockers."
          ],
          "Required_Input_Context": {
            "ReleaseVersion": "[ReleaseVersion]",
            "ConPort_Release_Scope_Ref_Key": "ReleaseNotesDraft:[ReleaseVersion]_Draft",
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["testing"] }
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

4.  **Nova-Orchestrator: Delegate Documentation Finalization**
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
            "Your goal is to ensure all documentation is updated for the release. Plan and delegate tasks to your specialists.",
            "Key sub-tasks will include: updating user-facing docs in `/docs/`, ensuring technical docs in ConPort (`SystemArchitecture`, `APIEndpoints`) are current, and finalizing the release notes based on the draft and QA results, storing the final version in `ReleaseNotesFinal:[ReleaseVersion]`."
          ],
          "Required_Input_Context": {
            "ReleaseVersion": "[ReleaseVersion]",
            "ConPort_Release_Draft_Notes_Key": "ReleaseNotesDraft:[ReleaseVersion]_Draft",
            "List_Of_Minor_Issues_From_QA": "[...]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": ["Confirmation of documentation updates", "Key of `ReleaseNotesFinal` entry"]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:** Verify deliverables. Update `[ReleasePrepProgressID]` status to "DOCS_FINALIZED_TAGGING_PENDING".

**Phase RP.4: Conceptual Version Tagging & ConPort Update (Nova-Orchestrator -> Nova-LeadDeveloper & Nova-LeadArchitect)**

5.  **Nova-Orchestrator: Delegate Conceptual Tagging & Final ConPort Status**
    *   **Task 1 (to Nova-LeadDeveloper):** "Conceptually prepare for version tagging of [ReleaseVersion]."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```json
        {
          "Context_Path": "Project [ProjectName] (Orchestrator) -> Release [ReleaseVersion] -> Conceptual Tagging (LeadDeveloper)",
          "Overall_Project_Goal": "Successfully prepare Project [ProjectName] for release [ReleaseVersion].",
          "Phase_Goal": "Log conceptual version tagging for [ReleaseVersion] in ConPort.",
          "Lead_Mode_Specific_Instructions": [
            "Release Version: [ReleaseVersion].",
            "Identify the current commit hash that represents this release state (this might require user input).",
            "Log a `Decision` in ConPort with the summary 'Commit [hash] designated for release [ReleaseVersion]' and tag it with the release version.",
            "(The user will be instructed to perform the actual git tag command separately based on this decision)."
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
            "Your ConPortSteward should update `CustomData Releases:[ReleaseVersion]` (key) status to 'Shipped' and add `release_date`.",
            "Update `active_context.state_of_the_union` to reflect the new release."
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

6.  **Nova-Orchestrator: `attempt_completion` to User**
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