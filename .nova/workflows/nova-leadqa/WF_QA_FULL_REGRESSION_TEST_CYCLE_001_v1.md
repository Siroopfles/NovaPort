# Workflow: Full Regression Test Cycle (WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1)

**Goal:** To execute a comprehensive regression test suite for the entire application or a major part of it, typically before a release or after significant refactoring, to ensure existing functionality remains intact.

**Primary Actor:** Nova-LeadQA (receives task from Nova-Orchestrator, e.g., as part of `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`).
**Primary Specialist Actor (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor.

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Perform Full Regression Test for Release [Version] on Project [ProjectName]".
- A major refactoring phase by Nova-LeadDeveloper is completed, and LeadDeveloper requests full regression via Orchestrator.
- Scheduled periodic regression run as per `CustomData NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadqa.regression_run_schedule`.

**Pre-requisites by Nova-LeadQA (from Nova-Orchestrator's briefing or ConPort):**
- A stable, deployed build is available in the designated test environment (URL/access from `CustomData ProjectConfig:ActiveConfig.testing.regression_env_url`).
- The full regression test suite (automated scripts) is available and executable (path and command from `ProjectConfig:ActiveConfig.testing.commands.run_regression` and `.testing.paths.regression_suite_root`).
- (Ideally) A baseline of expected results or previous run's `ErrorLogs` (key) for comparison (from `CustomData TestExecutionReports:[PreviousRunKey]` (key)).

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator):**

**Phase FRT.1: Preparation & Execution**

1.  **Nova-LeadQA: Receive Task & Plan Regression Cycle**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Identify Target Build/Release Version.
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Full Regression Test Cycle - [Date/ReleaseVersion]\"}`). Let this be `[RegressProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[RegressProgressID]_QAPlan` (key) using `use_mcp_tool`. Plan items:
            1.  Verify Environment & Test Data Setup (Delegate to TestExecutor).
            2.  Execute Full Regression Suite (Delegate to TestExecutor).
            3.  Analyze Results & Log New/Reopened Defects (LeadQA, with TestExecutor input).
            4.  Compile Regression Report (Delegate report drafting to TestExecutor or ConPortSteward).
    *   **ConPort Action:** Log `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"summary\": \"Start regression cycle for [Version]\", \"rationale\": \"Ensure stability before release/after major change.\"}`) to start regression cycle. Link to `[RegressProgressID]`.
    *   **Output:** Plan ready. `[RegressProgressID]` known.

2.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Setup & Execute Suite**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "Set up the test environment, ensure test data is appropriate, and execute the full automated regression suite for [Target Build/Release]."
    *   **`new_task` message for Nova-SpecializedTestExecutor:**
        ```json
        {
          "Context_Path": "[ProjectName] (RegressionCycle_[Date/Version]) -> ExecuteSuite (TestExecutor)",
          "Overall_QA_Phase_Goal": "Full Regression Test Cycle for [ReleaseVersion/TargetBuild].",
          "Specialist_Subtask_Goal": "Execute the full automated regression test suite against [Target Build/Release].",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[RegressProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Subtask: Execute full regression suite\", \"parent_id\": [RegressProgressID_as_integer]} `).",
            "Target Build/Release: [Version_From_LeadQA]. Deployed to Env: [Regression_Env_URL_From_ProjectConfig].",
            "1. Verify correct build [Version_From_LeadQA] is deployed and environment ([Regression_Env_URL_From_ProjectConfig]) is stable and accessible.",
            "2. Prepare/reset test data as per regression suite requirements (scripts might be in `ProjectConfig:ActiveConfig.testing.test_data_setup_scripts`). Execute data setup if needed.",
            "3. Execute the full regression suite using the command from `ProjectConfig:ActiveConfig.testing.commands.run_regression` in the CWD from `ProjectConfig:ActiveConfig.testing.paths.regression_suite_root`. Use `execute_command`.",
            "4. Capture all output, including console logs and any generated test reports (e.g., HTML, XML).",
            "5. If test execution itself fails catastrophically (e.g., suite cannot start, environment down), report this immediately with relevant error messages.",
            "6. If instructed by LeadQA to save detailed raw logs/reports, use `write_to_file` to path like `.nova/reports/qa/FullRegression_[Date/Version]_[timestamp]/`."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[RegressProgressID_as_integer]",
            "Target_Build_Or_Release_Version": "[...]",
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["testing"] }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation of suite execution (or report of catastrophic failure).",
            "Raw test execution logs/report files (or paths to them if saved to `.nova/reports/qa/`).",
            "Initial count of passed/failed/skipped tests from the test runner output."
          ]
        }
        ```
    *   **Nova-LeadQA Action after Specialist's `attempt_completion`:** Review execution status. Update plan/progress.

**Phase FRT.2: Results Analysis & Defect Logging**

3.  **Nova-LeadQA (can delegate parts of detailed failure analysis to Nova-SpecializedTestExecutor or initial RCA to Nova-SpecializedBugInvestigator): Analyze Results & Log Defects**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Retrieve and thoroughly analyze the test results (logs, reports from TestExecutor).
        *   For each test failure:
            *   Determine if it's a known issue (check open `CustomData ErrorLogs:[key]` in ConPort using `use_mcp_tool` (`tool_name: 'get_custom_data'` or `search_custom_data_value_fts`)).
            *   If new and unique:
                *   Log a new `CustomData ErrorLogs:[YYYYMMDD_RegressionFail_ShortDesc]` (key) entry (R20 compliant) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Include: precise repro steps (from test case), expected vs actual, environment (build, env URL), severity (regressions are often HIGH or CRITICAL), link to test case in `TestPlans` (key) if applicable, `source_task_id` (TestExecutor's Progress ID string).
            *   If it's a recurrence of a previously "RESOLVED" bug, retrieve the existing `ErrorLogs` (key) with `get_custom_data`, update its status to "REOPENED" with new details, and re-log it with `log_custom_data`.
        *   Coordinate update of `active_context.open_issues` (via Nova-Orchestrator to LeadArchitect/ConPortSteward).
    *   **Output:** All new/reopened regression defects logged in ConPort. List of corresponding `ErrorLogs` keys. Update `[RegressProgressID]_QAPlan`.

**Phase FRT.3: Reporting & Closure**

4.  **Nova-LeadQA (can delegate report compilation to Nova-SpecializedTestExecutor or Nova-SpecializedConPortSteward): Compile Regression Report**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "Compile a summary report for the full regression cycle."
    *   **Action:** Report should include:
        *   Date, Build Version Tested, Test Environment.
        *   Total tests executed, passed, failed, skipped (from TestExecutor's output).
        *   List of new `ErrorLogs` (keys) created with their severity.
        *   List of pre-existing `ErrorLogs` (keys) that were re-tested and their current status (PASSED verification or REOPENED).
        *   Overall assessment of stability based on regression results.
    *   **ConPort/File Action:** Log report as `CustomData TestExecutionReports:FullRegression_[Date]_[Version]` (key) using `use_mcp_tool` or instruct specialist to save to `.nova/reports/qa/FullRegressionReport_[Date]_[Version].md` using `write_to_file`. Link this report to `[RegressProgressID]`.

5.  **Nova-LeadQA: Finalize Cycle & Report**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Update main `Progress` (`[RegressProgressID]`) to DONE (or DONE_WITH_FAILURES if significant issues remain) using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description with outcome summary.
        *   To update `active_context`, first `get_active_context` with `use_mcp_tool`, then construct a new value object with the modified `state_of_the_union`, and finally use `log_custom_data` with category `ActiveContext` and key `active_context` to overwrite.
    *   **Output:** Regression cycle documented.

6.  **Nova-LeadQA: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadQA
    *   **Action:** Report completion, summary of regression (pass/fail, critical new bugs found with their `ErrorLogs` keys), path/key to the full report, and request for triage/prioritization of new critical/high bugs.

**Key ConPort Items Involved:**
- Progress (integer `id`): Overall cycle, specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[RegressProgressID]_QAPlan (key).
- Decisions (integer `id`) (e.g., to proceed despite some known non-critical regressions).
- CustomData ErrorLogs:[key] (new ones created, existing ones potentially re-verified).
- CustomData TestExecutionReports:[Key] (key) (optional, for detailed report storage).
- ActiveContext (`state_of_the_union`, `open_issues` updates).
- Reads `ProjectConfig:ActiveConfig` (key), `NovaSystemConfig:ActiveSettings` (key).
- Reads `TestPlans` (key) (implicitly, as regression suite is based on them).