# Workflow: Dependency Update and Audit (WF_DEV_DEPENDENCY_UPDATE_AND_AUDIT_001_v1)

**Goal:** To systematically check for outdated dependencies, audit for known vulnerabilities, and safely apply updates.

**Primary Actor:** Nova-LeadDeveloper
**Delegated Specialist Actors:** Nova-SpecializedTestAutomator (to run audit tools), Nova-SpecializedFeatureImplementer (to apply updates)

**Trigger / Recognition:**
- A scheduled task from `NovaSystemConfig:ActiveSettings` (e.g., `dependency_audit_frequency_days`).
- Before a major release, as part of the `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md` process.
- A user or Lead raises concerns about outdated or vulnerable dependencies.

**Phases & Steps (managed by Nova-LeadDeveloper):**

**Phase DU.1: Audit & Analysis**

1.  **Nova-LeadDeveloper: Plan Audit**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Log a main `Progress` (integer `id`): "Dependency Audit & Update Cycle - [Date]".
        *   Identify dependency management files (e.g., `requirements.txt`, `package.json`) and audit commands from `ProjectConfig:ActiveConfig`.

2.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Run Audit Tools**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Run dependency audit tools and report all findings."
    *   **`new_task` message for Nova-SpecializedTestAutomator:**
        ```json
        {
          "Context_Path": "[ProjectName] (DepAudit) -> RunAudit (TestAutomator)",
          "Overall_Developer_Phase_Goal": "Audit and update project dependencies.",
          "Specialist_Subtask_Goal": "Execute dependency vulnerability and outdated-check commands and report the full output.",
          "Specialist_Specific_Instructions": [
            "1. **Run Vulnerability Audit:** Use `execute_command` to run the project's vulnerability audit tool (e.g., `npm audit`, `pip-audit`). Command from `ProjectConfig:ActiveConfig.dependency_management_commands.audit`.",
            "2. **Check for Outdated Packages:** Use `execute_command` to run the outdated-check tool (e.g., `npm outdated`, `pip list --outdated`). Command from `ProjectConfig:ActiveConfig.dependency_management_commands.check_outdated`.",
            "3. **Compile Report:** Consolidate the full, raw output from both commands into your `attempt_completion` result."
          ],
          "Required_Input_Context_For_Specialist": {
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["dependency_management_commands"] }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Full, raw output from the audit command.",
            "Full, raw output from the outdated-check command."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Analyze the reports.

3.  **Nova-LeadDeveloper: Triage Findings**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Review the audit results.
        *   For each critical/high vulnerability or significantly outdated package, log a `Decision` (integer `id`) to update it.
        *   If an update has major breaking changes, delegate an `ImpactAnalyses` (key) task to Nova-LeadArchitect (via Orchestrator).
        *   Log severe vulnerabilities as `RiskAssessment` (key) items.
        *   Create a plan of which packages to update.

**Phase DU.2: Update & Verification**

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Apply Updates**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Update the following dependencies to their specified versions: [List of packages and versions]."
    *   **Briefing for FeatureImplementer:** Provide a precise list of packages and target versions. Instruct them to update dependency files (`requirements.txt`, etc.), run the update command (e.g., `npm install`), and then run the full test suite to catch immediate breakages.

5.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Full Regression Test**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** Updates have been applied and basic tests passed.
    *   **Task:** "Perform a full regression test cycle to ensure dependency updates have not introduced subtle regressions."
    *   **Briefing for TestAutomator:** Instruct to run the full regression suite as defined in `ProjectConfig:ActiveConfig.testing_preferences.full_regression_command`. Report all failures.

**Phase DU.3: Closure**

6.  **Nova-LeadDeveloper: Finalize Cycle**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Ensure all new issues from regression tests are logged as `ErrorLogs` (key).
        *   Update main `Progress` item to 'DONE'.
        *   Report summary of updates and new risk/status to Nova-Orchestrator.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- RiskAssessment (key)
- ErrorLogs (key)