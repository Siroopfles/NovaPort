# Workflow: Full Regression Test Cycle (WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1)

**Goal:** To execute a comprehensive regression test suite for the entire application or a major part of it, typically before a release or after significant refactoring, to ensure existing functionality remains intact.

**Primary Orchestrator Actor:** Nova-LeadQA (receives task from Nova-Orchestrator, e.g., as part of `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`).
**Primary Specialist Actor (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor.

**Trigger / Nova-LeadQA Recognition:**
- Nova-Orchestrator delegates "Perform Full Regression Test for Release [Version]".
- A major refactoring phase by Nova-LeadDeveloper is completed.
- Scheduled periodic regression run as per `NovaSystemConfig:ActiveSettings`.

**Pre-requisites by Nova-LeadQA:**
- A stable, deployed build is available in the designated test environment (URL/access from `ProjectConfig:ActiveConfig.testing_preferences.full_regression_env`).
- The full regression test suite (automated scripts) is available and executable.
- (Ideally) A baseline of expected results or previous run's `ErrorLogs` (key) for comparison.

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator):**

**Phase FRT.1: Preparation & Execution by Nova-LeadQA & Nova-SpecializedTestExecutor**

1.  **Nova-LeadQA: Receive Task & Plan Regression Cycle**
    *   **Action:** Parse `Subtask Briefing Object`. Log main `Progress` (integer `id`): "Full Regression Test Cycle - [Date/ReleaseVersion]".
    *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[RegressProgressID]_QAPlan` (key)):
        1.  Setup Test Environment & Data (TestExecutor/LeadQA).
        2.  Execute Full Regression Suite (TestExecutor).
        3.  Analyze Results & Log Defects (TestExecutor/LeadQA).
        4.  Compile Regression Report (TestExecutor/LeadQA).
    *   **ConPort:** Log `Decision` (integer `id`) to start regression cycle, noting scope/version.
    *   **Output:** Plan ready.

2.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Setup & Execute Suite**
    *   **Task:** "Set up the test environment, ensure test data is appropriate, and execute the full automated regression suite."
    *   **`new_task` message for Nova-SpecializedTestExecutor:**
        ```
        Subtask_Briefing:
          Overall_QA_Phase_Goal: "Full Regression Test Cycle for [ReleaseVersion]."
          Specialist_Subtask_Goal: "Execute the full automated regression test suite."
          Specialist_Specific_Instructions:
            - "1. Verify test environment ([URL from ProjectConfig]) is stable and has the correct build deployed."
            - "2. Prepare/reset test data as per regression suite requirements."
            - "3. Execute the full regression suite using the command: [`ProjectConfig:ActiveConfig.testing_preferences.full_regression_command`] in CWD: [`ProjectConfig:ActiveConfig.testing_preferences.regression_suite_path`]."
            - "4. Capture all output, including console logs and any generated test reports (e.g., HTML, XML)."
            - "5. If test execution itself fails catastrophically (e.g., suite cannot start), report this immediately."
          Required_Input_Context_For_Specialist:
            - ProjectConfig_Ref: { type: "custom_data", category: "ProjectConfig", key: "ActiveConfig", fields_needed: ["testing_preferences.full_regression_env", "testing_preferences.full_regression_command", "testing_preferences.regression_suite_path"] }
            - Target_Build_Version_Info: "[From Orchestrator/LeadQA]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation of suite execution (or report of catastrophic failure)."
            - "Raw test execution logs/report files (or paths to them if very large and saved to `.nova/reports/`)."
            - "Initial count of passed/failed/skipped tests."
        ```
    *   **Nova-LeadQA Action:** Monitor. Update plan/progress.

**Phase FRT.2: Results Analysis & Defect Logging by Nova-LeadQA & Nova-SpecializedTestExecutor**

3.  **Nova-LeadQA (can delegate parts to Nova-SpecializedTestExecutor): Analyze Results & Log Defects**
    *   **Task:** "Analyze the regression suite results, investigate all failures, and log new, unique defects as structured `ErrorLogs` (key) in ConPort."
    *   **Logic for Nova-LeadQA/TestExecutor:**
        *   For each test failure:
            *   Determine if it's a known issue (check open `ErrorLogs` (key)).
            *   If new: Attempt to reproduce manually. Gather logs, screenshots.
            *   Log a new `CustomData ErrorLogs:[YYYYMMDD_RegressionFail_ShortDesc]` (key) entry (R20 compliant: repro steps, expected, actual, env, severity CRITICAL/HIGH for regression).
            *   Link new `ErrorLogs` (key) to this regression `Progress` (integer `id`).
        *   Update `active_context.open_issues` (via LeadArchitect/ConPortSteward or directly if capable).
    *   **Output:** All new regression defects logged in ConPort.

**Phase FRT.3: Reporting & Closure by Nova-LeadQA**

4.  **Nova-LeadQA (can delegate report compilation to TestExecutor): Compile Regression Report**
    *   **Task:** "Compile a summary report for the full regression cycle."
    *   **Logic:** Report should include:
        *   Date, Build Version Tested.
        *   Total tests executed, passed, failed, skipped.
        *   List of new `ErrorLogs` (keys) created with their severity.
        *   List of pre-existing `ErrorLogs` (keys) that were re-tested (and their current status).
        *   Overall assessment of stability based on regression results.
    *   **Output:** Regression Test Report (e.g., Markdown in `.nova/reports/RegressionReport_[Date]_[Version].md` or a ConPort `CustomData TestExecutionReports:[Key]` (key) entry).

5.  **Nova-LeadQA: Finalize Cycle & Report**
    *   **Action:**
        *   Update main `Progress` (integer `id`) for "Full Regression Test Cycle" to DONE.
        *   Update `active_context.state_of_the_union` with summary of regression outcome.
    *   **Output:** Regression cycle documented.

6.  **Nova-LeadQA: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, summary of regression (pass/fail, critical new bugs found), path/key to the full report, and updated list of critical `ErrorLogs` (keys).

**Key ConPort Items Involved:**
-   `Progress` (integer `id`)
-   `CustomData LeadPhaseExecutionPlan:[RegressProgressID]_QAPlan` (key)
-   `Decisions` (integer `id`) (e.g., to proceed despite some known non-critical regressions)
-   `CustomData ErrorLogs:[key]` (new ones created, existing ones potentially re-verified)
-   `CustomData TestExecutionReports:[Key]` (key) (optional, for detailed report storage)
-   `ActiveContext` (`state_of_the_union`, `open_issues` updates)
-   Reads `ProjectConfig:ActiveConfig` (key).