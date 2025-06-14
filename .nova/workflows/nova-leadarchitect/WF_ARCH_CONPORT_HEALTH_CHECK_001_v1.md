# Workflow: ConPort Health Check & Maintenance (WF_ARCH_CONPORT_HEALTH_CHECK_001_v1)

**Goal:** To periodically review and maintain the quality, consistency, and utility of data within ConPort for the current workspace, executed by Nova-LeadArchitect's team.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**

- Nova-Orchestrator delegates: "Run ConPort Maintenance/Health Check for Project [ProjectName]".
- Scheduled review task as per `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadarchitect.conport_health_check_frequency_days`.
- Nova-Orchestrator or Nova-LeadArchitect detects potential ConPort inconsistencies.

**Reference Milestones for your Single-Step Loop:**

**Milestone HC.1: Perform Health Scan & Report Findings**

- **Goal:** Execute a comprehensive ConPort health scan and generate a structured findings report.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **LeadArchitect Action:** Log a main `Progress` item for this Health Check Cycle.
  2.  **Delegate to `Nova-SpecializedConPortSteward`:**
      - **Subtask Goal:** "Perform comprehensive ConPort health scan and generate a structured findings report."
      - **Briefing Details:** Instruct the specialist to:
        - Log their own `Progress` item, parented to your main cycle progress item.
        - **Perform Standard Checks:**
          - **Decision Integrity:** Check for missing `rationale`/`implications` fields in `Decisions`.
          - **Progress Item Review:** Check for stale `IN_PROGRESS` or `BLOCKED` items.
          - **Custom Data Audit:** Check for consistency in `value` structures for common categories.
          - **Linkage Review:** Use `get_linked_items` on a sample of critical items to verify expected relationships.
          - **Outdated Information Scan:** Check `SystemPatterns`, `ConfigSettings`, etc. for items not updated recently.
          - **Schema Adherence:** Review `CustomData` categories against established standards.
        - Compile all findings into a structured Markdown report and save it to `.nova/reports/architect/ConPortHealthCheck_[YYYYMMDD].md`.
        - Return the path to the report and a summary of major findings.

**Milestone HC.2: Review Findings & Propose Actions**

- **Goal:** Analyze the findings report and decide on a course of action.
- **Suggested Lead Action:**
  1.  Read and analyze the findings report from the `ConPortSteward`.
  2.  Summarize key findings and anomalies.
  3.  Propose specific, actionable corrective measures.
  4.  **Decision Point:**
      - If changes are minor, log a `Decision` to proceed and move to the next milestone.
      - If changes are significant, use `ask_followup_question` to get approval from the user/Orchestrator before proceeding.

**Milestone HC.3: Execute Corrective Actions**

- **DoR Check:** There is a clear, approved list of corrective actions.
- **Goal:** Apply all approved fixes to ConPort to improve its health.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **Delegate to `Nova-SpecializedConPortSteward`:**
      - **Subtask Goal:** "Execute the approved ConPort corrective actions based on the Health Check findings."
      - **Briefing Details:** Provide a clear, itemized list of actions for the specialist to perform. Each action should be a specific `use_mcp_tool` call. Examples:
        - Update a `Decision` with a missing rationale using `log_decision`.
        - Update a `CustomData` item's status using `get_custom_data` then `log_custom_data`.
        - Create a missing link between items using `link_conport_items`.
        - Instruct the specialist to document all specific changes made.
        - Return a list of all modified ConPort items.

**Milestone HC.4: Finalize Cycle**

- **Goal:** Close out the health check process and report completion.
- **Suggested Lead Action:**
  1.  Verify the corrective actions have been completed by the `ConPortSteward`.
  2.  Update the main `Progress` item for the Health Check Cycle to 'DONE'.
  3.  Update the `active_context.state_of_the_union` with a summary of the health check outcome.
  4.  Report completion of the phase to `Nova-Orchestrator` in your `attempt_completion`.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- CustomData (`TestExecutionReports`, `ErrorLogs`, etc.)
- Decisions (integer `id`)
- ContextLinks (integer `id`)
- ActiveContext (`state_of_the_union` update)
