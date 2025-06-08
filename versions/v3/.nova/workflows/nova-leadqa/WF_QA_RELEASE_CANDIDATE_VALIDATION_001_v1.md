# Workflow: Release Candidate Validation (WF_QA_RELEASE_CANDIDATE_VALIDATION_001_v1)

**Goal:** To perform comprehensive Quality Assurance validation on a designated Release Candidate build, including final regression, targeted feature testing, and checks against release criteria, to provide a go/no-go recommendation.

**Primary Orchestrator Actor:** Nova-LeadQA (receives task from Nova-Orchestrator when a release candidate is ready for final validation).
**Primary Specialist Actors (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor, Nova-SpecializedBugInvestigator (if new critical issues arise).

**Trigger / Nova-LeadQA Recognition:**
- Nova-Orchestrator delegates: "Validate Release Candidate [RC_Version] for [TargetReleaseVersion]".
- Part of `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`.

**Pre-requisites by Nova-LeadQA:**
- A specific Release Candidate build/version is deployed to a stable, production-like QA environment (details in `ProjectConfig:ActiveConfig.testing_preferences.rc_validation_env`).
- Scope of the release (`CustomData Releases:[TargetReleaseVersion]` (key) or `ReleaseNotesDraft:[TargetReleaseVersion]_Draft` (key)) is defined in ConPort.
- All planned features/fixes for this release have passed prior development and feature-level QA cycles.

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator):**

**Phase RCV.1: Planning & Setup by Nova-LeadQA**

1.  **Nova-LeadQA: Receive Task & Plan Validation Cycle**
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator.
        *   Log main `Progress` (integer `id`): "RC Validation: [RC_Version] for Release [TargetReleaseVersion]".
        *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[RCValProgressID]_QAPlan` (key)). Plan items:
            1.  Environment & Data Verification (TestExecutor).
            2.  Execute Full Regression Suite (TestExecutor).
            3.  Execute Targeted New Feature/Fix Tests (TestExecutor).
            4.  Execute Key User Scenario / Exploratory Tests (TestExecutor).
            5.  Analyze Results, Log Critical Defects (TestExecutor/BugInvestigator).
            6.  Compile Validation Report & Recommendation (LeadQA).
    *   **ConPort:** Review `Releases:[TargetReleaseVersion]` (key) for scope. Review `ProjectConfig:ActiveConfig` (key) for RC environment details. Log `Decision` (integer `id`) to commence RC validation.
    *   **Output:** Plan ready.

**Phase RCV.2: Test Execution by Nova-SpecializedTestExecutor (Sequentially Managed by Nova-LeadQA)**

2.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Environment & Full Regression**
    *   **Task:** "Verify RC environment and execute the full regression suite against Release Candidate [RC_Version]."
    *   **Briefing for TestExecutor:** Include RC version, environment details, regression suite command (from `ProjectConfig`). Expect raw logs, pass/fail counts. New critical failures are immediate blockers.
    *   **Nova-LeadQA Action:** Monitor. If regression suite has critical failures, this workflow might pause, and `WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1.md` might be triggered for those bugs via Nova-Orchestrator.

3.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Targeted Feature/Fix Tests**
    *   **Task:** "Execute specific tests for all new features and bug fixes included in Release Candidate [RC_Version]."
    *   **Briefing for TestExecutor:** Provide list of features/fixes (from `Releases:[TargetReleaseVersion]` (key) scope). Point to relevant `AcceptanceCriteria` (key) or `ErrorLogs` (key) (original bug report) for test case design/focus.
    *   **Nova-LeadQA Action:** Monitor. New critical failures are blockers.

4.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Key Scenario & Exploratory Testing**
    *   **Task:** "Perform key user scenario walkthroughs and exploratory testing on Release Candidate [RC_Version]."
    *   **Briefing for TestExecutor:** Define 3-5 critical end-to-end user scenarios. Provide charters for exploratory testing around new/changed areas. Emphasize looking for unexpected issues.
    *   **Nova-LeadQA Action:** Monitor.

**Phase RCV.3: Results Analysis, Defect Management, and Reporting by Nova-LeadQA**

5.  **Nova-LeadQA: Consolidate Test Results & Manage Defects**
    *   **Action:**
        *   Collect all results from Nova-SpecializedTestExecutor subtasks.
        *   Ensure all new defects found during RC validation are logged as structured `CustomData ErrorLogs:[key]` with appropriate severity (CRITICAL release blockers vs. others).
        *   If critical blockers are found that were not caught earlier:
            *   Update `ErrorLogs:[key]` status to OPEN/INVESTIGATING.
            *   Immediately prepare information for Nova-Orchestrator (see step 7). This RC cannot pass.
        *   Update `active_context.open_issues`.
    *   **Output:** Consolidated list of test outcomes and all logged defects for this RC.

6.  **Nova-LeadQA: Compile RC Validation Report**
    *   **Action:** Create a comprehensive report summarizing:
        *   RC Version, Test Environment.
        *   Scope of testing.
        *   Summary of regression results, new feature tests, exploratory tests.
        *   List of ALL new `ErrorLogs` (keys) found during RC validation, with severity.
        *   List of any critical pre-existing `ErrorLogs` (keys) that were expected to be fixed in this RC but are still present.
        *   Overall assessment: **Go / No-Go** recommendation for this RC to become the official release. Justify No-Go with specific critical `ErrorLogs` (keys).
    *   **ConPort/File:** Log as `CustomData TestExecutionReports:RC_[RC_Version]_ValidationReport` (key) or save to `.nova/reports/RC_[RC_Version]_ValidationReport.md`.

7.  **Nova-LeadQA: Finalize & Report to Nova-Orchestrator**
    *   **Action:**
        *   Update main `Progress` (integer `id`) for "RC Validation" to DONE (or FAILED_CRITICAL_BUGS_FOUND).
        *   Update `active_context.state_of_the_union` with summary: "RC [RC_Version] validation complete. Recommendation: [Go/No-Go]. Report: [ConPortKey/Path]."
    *   **`attempt_completion` to Nova-Orchestrator:** Provide the Go/No-Go recommendation, summary of critical issues (if any) with their `ErrorLogs` (keys), and reference to the full validation report.

**Key ConPort Items Involved:**
-   `Progress` (integer `id`)
-   `CustomData LeadPhaseExecutionPlan:[RCValProgressID]_QAPlan` (key)
-   `CustomData Releases:[TargetReleaseVersion]` (key) (Read)
-   `CustomData ReleaseNotesDraft:[TargetReleaseVersion]_Draft` (key) (Read for scope)
-   `CustomData ErrorLogs:[key]` (New ones created, existing ones potentially verified)
-   `CustomData TestExecutionReports:[key]` (or file path in `.nova/reports/`)
-   `ActiveContext` (`state_of_the_union`, `open_issues` updates)
-   Reads `ProjectConfig:ActiveConfig` (key) for test environment/commands.
-   Reads `FeatureScope` (key), `AcceptanceCriteria` (key) for targeted testing.