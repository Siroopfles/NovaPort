# Workflow: Release Candidate Validation (WF_QA_RELEASE_CANDIDATE_VALIDATION_001_v1)

**Goal:** To perform comprehensive QA validation on a Release Candidate build to provide a go/no-go recommendation for release.

**Primary Actor:** Nova-LeadQA
**Primary Specialist Actors:** Nova-SpecializedTestExecutor, Nova-SpecializedBugInvestigator

**Trigger / Recognition:**
- `Nova-Orchestrator` delegates: "Validate Release Candidate [RC_Version]".
- Part of a parent workflow like `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`.

**Pre-requisites by Nova-LeadQA (from Nova-Orchestrator's briefing or ConPort):**
- A specific RC build is deployed to a stable, production-like QA environment.
- The scope of the release is defined (e.g., in `ReleaseNotesDraft`).
- All planned features/fixes have passed prior development and feature-level QA cycles.

**Reference Milestones for your Single-Step Loop:**

**Milestone RCV.0: Pre-flight & Readiness Check**
*   **Goal:** Verify that the release scope is defined and the test environment is accessible and ready.
*   **Suggested Lead Action:**
    1.  Your first action MUST be a "Definition of Ready" check.
    2.  Use `use_mcp_tool` to retrieve the `ReleaseNotesDraft` and `ProjectConfig` (for `rc_validation_env_url`).
    3.  Use `execute_command` (e.g., `curl -I [url]`) to verify the test environment is accessible.
    4.  Use `use_mcp_tool` (`get_active_context`) to check for open critical bugs that should have been fixed in this RC.
    5.  **Gated Check:** If any check fails, immediately `attempt_completion` with a `BLOCKER:` status to `Nova-Orchestrator`. Do not proceed.

**Milestone RCV.1: Test Execution (Iterative)**
*   **Goal:** Execute a comprehensive set of tests to validate the release candidate's quality.
*   **Suggested Specialist Sequence & Briefing Guidance (delegate these as sequential, atomic subtasks):**
    1.  **Delegate to `Nova-SpecializedTestExecutor`:**
        *   **Subtask Goal:** "Execute the full regression suite against RC [RC_Version]."
        *   **Briefing Details:** Provide RC version, environment URL, and the regression command from `ProjectConfig`. Instruct to save detailed logs and report pass/fail counts.
    2.  **LeadQA Action:** Analyze regression results. If critical blockers are found, this workflow may need to pause to allow for hotfixes.
    3.  **Delegate to `Nova-SpecializedTestExecutor`:**
        *   **Subtask Goal:** "Execute targeted tests for all new features and bug fixes included in this release."
        *   **Briefing Details:** Provide the list of features/fixes from the `ReleaseNotesDraft`. Point to relevant `AcceptanceCriteria` or original `ErrorLogs` for test focus. Instruct to log any new bugs found as new `ErrorLogs`.
    4.  **Delegate to `Nova-SpecializedTestExecutor`:**
        *   **Subtask Goal:** "Perform key user scenario walkthroughs and exploratory testing on the RC."
        *   **Briefing Details:** Provide 3-5 critical end-to-end scenarios and charters for exploratory testing around new/changed areas.

**Milestone RCV.2: Results Analysis & Reporting**
*   **Goal:** Consolidate all test results, manage defects, and formulate a go/no-go recommendation.
*   **Suggested Lead Action:**
    1.  **Consolidate & Triage:** Collect all results and new `ErrorLogs` from the `TestExecutor`. Triage new bugs for severity.
    2.  **Check for Blockers:** If new critical/high severity bugs ("blockers") were found, the RC cannot pass. Prepare a 'NO_GO' recommendation.
    3.  **Compile Report:** Create a comprehensive validation report summarizing the test scope, metrics (pass/fail counts), a list of all new `ErrorLogs` found, and the final go/no-go recommendation with clear justification. Log this as a `TestExecutionReports` item in ConPort.
    4.  **Update Progress:** Update the main `Progress` item to 'DONE' (if GO) or 'FAILED_CRITICAL_BUGS_FOUND' (if NO_GO).
    5.  **Report to Orchestrator:** Use `attempt_completion` to provide the go/no-go recommendation, a summary of any blocking `ErrorLogs` keys, and the key to the full validation report.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- CustomData (`ReleaseNotesDraft`, `ErrorLogs`, `TestExecutionReports`)
- ActiveContext (`open_issues`, `state_of_the_union` updates)
- Reads `ProjectConfig`, `FeatureScope`, `AcceptanceCriteria`, `TestPlans`.