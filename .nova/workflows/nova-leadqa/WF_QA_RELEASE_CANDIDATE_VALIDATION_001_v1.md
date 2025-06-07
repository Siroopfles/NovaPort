# Workflow: Release Candidate Validation (WF_QA_RELEASE_CANDIDATE_VALIDATION_001_v1)

**Goal:** To perform comprehensive Quality Assurance validation on a designated Release Candidate build, including final regression, targeted feature testing, and checks against release criteria, to provide a go/no-go recommendation for release.

**Primary Actor:** Nova-LeadQA (receives task from Nova-Orchestrator when a release candidate is ready for final validation, often as part of `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`).
**Primary Specialist Actors (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor, Nova-SpecializedBugInvestigator (if new critical issues arise and need immediate, focused RCA).

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Validate Release Candidate [RC_Version] for [TargetReleaseVersion]".
- Part of a parent workflow like `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`.

**Pre-requisites by Nova-LeadQA (from Nova-Orchestrator's briefing or ConPort):**
- A specific Release Candidate build/version (e.g., `Build_Tag_RC_2.1.0-beta3`) is deployed to a stable, production-like QA environment (URL/access details from `CustomData ProjectConfig:ActiveConfig.testing_preferences.rc_validation_env` (key)).
- Scope of the release (`CustomData Releases:[TargetReleaseVersion]` (key) or `CustomData ReleaseNotesDraft:[TargetReleaseVersion]_Draft` (key)) is defined in ConPort, listing features and bug fixes.
- All planned features/fixes for this release have passed prior development and feature-level QA cycles (status reflected in their respective `Progress` (integer `id`) items).
- `CustomData TestPlans:[RelevantTestPlanKey]` (key) covering regression and key features for this release exists.

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator):**

**Phase RCV.1: Planning & Setup by Nova-LeadQA**

1.  **Nova-LeadQA: Receive Task & Plan Validation Cycle**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Identify `RC_Version` and `TargetReleaseVersion`.
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "RC Validation: [RC_Version] for Release [TargetReleaseVersion]". Let this be `[RCValProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[RCValProgressID]_QAPlan` (key) using `use_mcp_tool`. Plan items:
            1.  Environment & Data Verification (Delegate to TestExecutor).
            2.  Execute Full Regression Suite (Delegate to TestExecutor).
            3.  Execute Targeted New Feature & Bug Fix Verification Tests (Delegate to TestExecutor).
            4.  Execute Key User Scenario / Sanity / Exploratory Tests (Delegate to TestExecutor).
            5.  Analyze Results, Triage & Log Critical Defects (LeadQA, delegate investigation to BugInvestigator if needed).
            6.  Compile Validation Report & Formulate Go/No-Go Recommendation (LeadQA, may delegate report drafting to TestExecutor).
    *   **ConPort Action:**
        *   Review `CustomData Releases:[TargetReleaseVersion]` (key) and `CustomData ReleaseNotesDraft:[TargetReleaseVersion]_Draft` (key) using `use_mcp_tool` (`tool_name: 'get_custom_data'`) for release scope.
        *   Review `CustomData ProjectConfig:ActiveConfig` (key) for RC environment details and test commands.
        *   Log `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`): "Commence Release Candidate [RC_Version] validation for Release [TargetReleaseVersion]." Link to `[RCValProgressID]`.
    *   **Output:** Plan ready. `[RCValProgressID]` known.

**Phase RCV.2: Test Execution by Nova-SpecializedTestExecutor (Sequentially Managed by Nova-LeadQA)**

2.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Environment Verification & Full Regression**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "Verify RC environment is correct and stable, then execute the full regression suite against Release Candidate [RC_Version]."
    *   **`new_task` message for Nova-SpecializedTestExecutor (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (RC_Validation_[RC_Version]) -> FullRegression (TestExecutor)",
          "Overall_QA_Phase_Goal": "Validate RC [RC_Version] for Release [TargetReleaseVersion].",
          "Specialist_Subtask_Goal": "Verify environment and execute full regression suite against RC [RC_Version].",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[RCValProgressID]`.",
            "RC Version: [RC_Version_From_LeadQA]. Deployed to Env: [RC_Env_URL_From_ProjectConfig].",
            "1. Verify correct build [RC_Version_From_LeadQA] is deployed and environment is stable.",
            "2. Execute full regression suite using command: [`ProjectConfig:ActiveConfig.testing_preferences.full_regression_command`] in CWD: [`ProjectConfig:ActiveConfig.testing_preferences.regression_suite_path`]. Use `execute_command`.",
            "3. Capture all output. Save detailed logs/reports to `.nova/reports/qa/RC_[RC_Version]_Regression_[Date]/` using `write_to_file` if output is large.",
            "Report initial pass/fail counts and any critical execution failures immediately."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[RCValProgressID_as_string]",
            "RC_Version_From_LeadQA": "[...]",
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["testing_preferences.rc_validation_env", "testing_preferences.full_regression_command", "testing_preferences.regression_suite_path"] }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": ["Execution summary (pass/fail)", "Path to reports/logs if saved", "List of any new critical `ErrorLogs` (keys) found."]
        }
        ```
    *   **Nova-LeadQA Action:** Monitor. If regression suite has critical failures, this workflow might pause. LeadQA will use `WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1.md` for those new critical `ErrorLogs` (key), coordinating with Nova-Orchestrator for fixes.

3.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Targeted Feature/Fix Tests**
    *   **Actor:** Nova-LeadQA
    *   **DoR Check:** Full regression (or critical subset) shows acceptable stability OR critical regression blockers are being addressed.
    *   **Task:** "Execute specific tests for all new features and bug fixes included in Release Candidate [RC_Version] as per `ReleaseNotesDraft`."
    *   **Briefing for TestExecutor:** Provide list of features/fixes (from `ReleaseNotesDraft:[TargetReleaseVersion]_Draft` (key)). Point to relevant `AcceptanceCriteria` (key) or original `ErrorLogs` (key) for test case design/focus. Instruct TestExecutor to log any new bugs found as `ErrorLogs` (key).
    *   **Nova-LeadQA Action:** Monitor. New critical failures are blockers.

4.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Key Scenario & Exploratory Testing**
    *   **Actor:** Nova-LeadQA
    *   **DoR Check:** Targeted tests show reasonable stability.
    *   **Task:** "Perform key user scenario walkthroughs and exploratory testing on Release Candidate [RC_Version]."
    *   **Briefing for TestExecutor:** Define 3-5 critical end-to-end user scenarios (from `TestPlans` (key) or ad-hoc). Provide charters for exploratory testing around new/changed areas. Emphasize looking for unexpected issues. Instruct TestExecutor to log any new bugs found as `ErrorLogs` (key).
    *   **Nova-LeadQA Action:** Monitor.

**Phase RCV.3: Results Analysis, Defect Management, and Reporting**

5.  **Nova-LeadQA: Consolidate Test Results & Manage Defects**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Collect all `attempt_completion` results from Nova-SpecializedTestExecutor subtasks.
        *   Review all newly logged `CustomData ErrorLogs:[key]` entries by TestExecutor. Triage them for severity and ensure they are R20 compliant.
        *   If new critical blockers are found that were not caught earlier:
            *   Ensure their `ErrorLogs:[key]` status is 'OPEN' or 'INVESTIGATING'.
            *   This RC cannot pass. Prepare to report "NO_GO" to Nova-Orchestrator.
            *   (Optional) If quick RCA is needed, delegate to Nova-SpecializedBugInvestigator for a high-priority investigation of the new critical blocker(s).
        *   Coordinate update of `active_context.open_issues` (via Nova-Orchestrator to LeadArchitect/ConPortSteward).
    *   **Output:** Consolidated list of test outcomes and all logged/triaged defects for this RC.

6.  **Nova-LeadQA: Compile RC Validation Report**
    *   **Actor:** Nova-LeadQA (may delegate drafting aspects to TestExecutor or ConPortSteward)
    *   **Action:** Create a comprehensive report summarizing:
        *   RC Version, Test Environment.
        *   Scope of testing (link to `Releases:[TargetReleaseVersion]` (key)).
        *   Summary of regression results, new feature tests, exploratory tests (pass/fail/skipped counts).
        *   List of ALL new `ErrorLogs` (keys) found during RC validation, with severity and current status.
        *   List of any critical pre-existing `ErrorLogs` (keys) that were expected to be fixed in this RC but are still present (status: FAILED_VERIFICATION).
        *   Overall assessment: **Go / No-Go** recommendation for this RC to become the official release. Justify No-Go with specific critical `ErrorLogs` (keys).
    *   **ConPort/File Action:** Log report as `CustomData TestExecutionReports:RC_[RC_Version]_ValidationReport_[Date]` (key) using `use_mcp_tool` or instruct specialist to save to `.nova/reports/qa/RC_[RC_Version]_ValidationReport_[Date].md` using `write_to_file`.

7.  **Nova-LeadQA: Finalize & Report to Nova-Orchestrator**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Update main `Progress` (`[RCValProgressID]`) to 'DONE' (if GO) or 'FAILED_CRITICAL_BUGS_FOUND' (if NO_GO) using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description with summary.
        *   Coordinate update of `active_context.state_of_the_union` (via Nova-Orchestrator to LeadArchitect) with summary: "RC [RC_Version] validation complete. Recommendation: [Go/No-Go]. Report: TestExecutionReports:RC_[Key] or [Path]."
    *   **`attempt_completion` to Nova-Orchestrator:** Provide the Go/No-Go recommendation, summary of critical issues (if any) with their `ErrorLogs` (keys), and reference to the full validation report.

**Key ConPort Items Involved:**
- Progress (integer `id`): For overall cycle and specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[RCValProgressID]_QAPlan (key).
- CustomData Releases:[TargetReleaseVersion]` (key) (Read).
- CustomData ReleaseNotesDraft:[TargetReleaseVersion]_Draft (key) (Read for scope).
- CustomData ErrorLogs:[key] (New ones created, existing ones potentially re-verified).
- CustomData TestExecutionReports:[key] (or file path in `.nova/reports/`).
- ActiveContext (`state_of_the_union`, `open_issues` updates).
- Reads `ProjectConfig:ActiveConfig` (key) for test environment/commands.
- Reads `FeatureScope` (key), `AcceptanceCriteria` (key), `TestPlans` (key) for targeted testing.
- Decisions (integer `id`) (e.g., to accept minor issues for release, or to declare NO_GO).