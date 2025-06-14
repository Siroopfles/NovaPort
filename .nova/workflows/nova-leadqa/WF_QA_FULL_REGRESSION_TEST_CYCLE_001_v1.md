# Workflow: Full Regression Test Cycle (WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1)

**Goal:** To execute a comprehensive regression test suite for the entire application or a major part of it, typically before a release or after significant refactoring, to ensure existing functionality remains intact.

**Primary Actor:** Nova-LeadQA
**Primary Specialist Actor (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor

**Trigger / Recognition:**
- `Nova-Orchestrator` delegates: "Perform Full Regression Test for Release [Version]".
- A major refactoring phase is completed.

**Pre-requisites by Nova-LeadQA (from Nova-Orchestrator's briefing or ConPort):**
- A stable, deployed build is available in the designated test environment.
- The full regression test suite is available and executable (path/command from `ProjectConfig`).

**Reference Milestones for your Single-Step Loop:**

**Milestone FRT.1: Execution**
*   **Goal:** Execute the full automated regression suite against the target build.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **LeadQA Action:** Log a main `Progress` item for this regression cycle and a `Decision` to commence.
    2.  **Delegate to `Nova-SpecializedTestExecutor`:**
        *   **Subtask Goal:** "Execute the full automated regression test suite against [Target Build/Release]."
        *   **Briefing Details:**
            *   Provide the target build version and the test environment URL from `ProjectConfig`.
            *   Instruct the specialist to verify the environment, prepare test data if necessary, and run the regression suite using the command from `ProjectConfig`.
            *   They should capture all output, save detailed reports to `.nova/reports/qa/`, and return an initial summary (pass/fail counts) and paths to the raw reports.

**Milestone FRT.2: Results Analysis & Defect Logging**
*   **Goal:** Analyze all test failures and log new or reopened defects in ConPort.
*   **Suggested Lead Action:**
    1.  Thoroughly review the test results from the `TestExecutor`.
    2.  For each test failure, determine if it is a new issue or a recurrence of a known bug.
    3.  **Delegate Defect Logging to `Nova-SpecializedTestExecutor` (or perform self):**
        *   **Subtask Goal:** "For each new, unique failure, log a new `ErrorLogs` item in ConPort."
        *   **Briefing Details:** Instruct to create detailed, R20-compliant `ErrorLogs` entries, including precise repro steps, severity, and links to the failed test case.
        *   For recurring bugs, instruct them to update the existing `ErrorLogs` item's status to 'REOPENED'.
    4.  Coordinate with `Nova-Orchestrator` to update `active_context.open_issues`.

**Milestone FRT.3: Reporting & Closure**
*   **Goal:** Compile a final report and provide a quality assessment to the Orchestrator.
*   **Suggested Specialist Sequence & Lead Actions:**
    1.  **Delegate to `Nova-SpecializedTestExecutor` (or ConPortSteward):**
        *   **Subtask Goal:** "Compile a summary report for the full regression cycle."
        *   **Briefing Details:** The report should include test metrics (total, pass, fail), a list of all new/reopened `ErrorLogs` keys with their severity, and an overall assessment of stability. The report should be saved as a `TestExecutionReports` item in ConPort or as a file.
    2.  **LeadQA Action:**
        *   Review the final report.
        *   Update the main `Progress` item for the cycle to 'DONE' or 'DONE_WITH_FAILURES'.
        *   Use `attempt_completion` to report the final summary, the list of critical new bugs, and the key/path to the full report to `Nova-Orchestrator`.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- CustomData ErrorLogs:[key] (key)
- CustomData TestExecutionReports:[Key] (key)
- ActiveContext (`open_issues` update)