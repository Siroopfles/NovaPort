# Workflow: Dependency Update and Audit (WF_DEV_DEPENDENCY_UPDATE_AND_AUDIT_001_v1)

**Goal:** To systematically check for outdated dependencies, audit for known vulnerabilities, and safely apply updates.

**Primary Actor:** Nova-LeadDeveloper
**Delegated Specialist Actors:** Nova-SpecializedTestAutomator, Nova-SpecializedFeatureImplementer

**Trigger / Recognition:**

- A scheduled task from `NovaSystemConfig`.
- Part of a pre-release workflow (`WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`).
- A user or Lead raises concerns about outdated or vulnerable dependencies.

**Reference Milestones for your Single-Step Loop:**

**Milestone DU.1: Audit & Analysis**

- **Goal:** Run audit tools to identify outdated and vulnerable dependencies and triage the findings.
- **Suggested Specialist Sequence & Lead Actions:**
  1.  **LeadDeveloper Action:** Log a main `Progress` item for this audit cycle.
  2.  **Delegate to `Nova-SpecializedTestAutomator`:**
      - **Subtask Goal:** "Run dependency vulnerability and outdated-check commands and report the full output."
      - **Briefing Details:**
        - Instruct the specialist to use `execute_command` to run the audit tools defined in `ProjectConfig:ActiveConfig.security.tools.dependency_scanner` and `ProjectConfig.dependency_management.commands`.
        - They should return the full, raw output from all commands.
  3.  **LeadDeveloper Action: Triage Findings:**
      - Analyze the audit reports from the specialist.
      - For each critical vulnerability or major outdated package, log a `Decision` to update it.
      - If an update has significant breaking changes, coordinate an `ImpactAnalysis` with `Nova-LeadArchitect` via the `Orchestrator`.
      - Create a final, prioritized list of packages to update.

**Milestone DU.2: Update & Verification**

- **DoR Check:** A clear, prioritized list of packages to update is available.
- **Goal:** Apply the dependency updates and verify that the application remains stable.
- **Suggested Specialist Sequence & Lead Actions:**
  1.  **Delegate to `Nova-SpecializedFeatureImplementer`:**
      - **Subtask Goal:** "Update the following dependencies to their specified versions: [List of packages]."
      - **Briefing Details:**
        - Provide the precise list of packages and target versions.
        - Instruct the specialist to use the project's package manager command (from `ProjectConfig`) to update the dependency files.
        - After updating, they must run the local unit test suite to catch immediate breakages.
  2.  **Delegate to `Nova-SpecializedTestAutomator`:**
      - **Subtask Goal:** "Perform a full regression test cycle to ensure dependency updates have not introduced subtle regressions."
      - **Briefing Details:**
        - Instruct the specialist to run the full regression suite as defined in `ProjectConfig`.
        - They must report all failures. If new, independent bugs are found, they should be logged as new `ErrorLogs`.

**Milestone DU.3: Closure**

- **Goal:** Finalize the audit cycle and report the outcome.
- **Suggested Lead Action:**
  1.  Ensure any new regressions found during verification are logged as `ErrorLogs`.
  2.  Update the main `Progress` item for the audit cycle to 'DONE'.
  3.  Report a summary of the updates, the new risk posture, and any new `ErrorLogs` to `Nova-Orchestrator`.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- Decisions (integer `id`)
- RiskAssessment (key)
- ErrorLogs (key)
