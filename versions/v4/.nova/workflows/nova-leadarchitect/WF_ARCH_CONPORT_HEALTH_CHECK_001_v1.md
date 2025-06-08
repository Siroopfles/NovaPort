# Workflow: ConPort Health Check & Maintenance (WF_ARCH_CONPORT_HEALTH_CHECK_001_v1)

**Goal:** To periodically review and maintain the quality, consistency, and utility of data within ConPort for the current workspace.

**Primary Orchestrator Actor:** Nova-LeadArchitect (receives phase task from Nova-Orchestrator, or can initiate based on `NovaSystemConfig`)
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Orchestrator Recognition (for Nova-Orchestrator to delegate to Nova-LeadArchitect):**
- User requests "Run ConPort Maintenance/Health Check".
- Scheduled review task (as per `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadarchitect.conport_health_check_frequency_days`).
- Nova-Orchestrator detects potential ConPort inconsistencies from Lead reports.

**Pre-requisites by Nova-Orchestrator (before delegating this phase to Nova-LeadArchitect):**
- ConPort is `[CONPORT_ACTIVE]`.
- (Optional) Specific areas of concern or focus for the health check provided by user/Orchestrator.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase HC.1: Initial Planning & Delegation by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Receive Task & Plan Health Check**
    *   **Action:** Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` and any specific areas of focus.
    *   **ConPort:**
        *   Log main `Progress` (integer `id`) item: "ConPort Health Check Cycle - [Date]".
        *   Create internal plan (`LeadPhaseExecutionPlan:[HCProgressID]_ArchitectPlan` (key)) for ConPortSteward's subtasks (e.g., Decision Integrity, Progress Review, Custom Data Audit, Linkage Review, Outdated Info Scan, Report Generation, Action Execution).
    *   **Output:** Plan ready. Main `Progress` (integer `id`) created.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Perform Health Scan**
    *   **Task:** "Execute ConPort health scan based on standard checks and specific focus areas."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Complete ConPort Health Check Cycle - [Date]."
          Specialist_Subtask_Goal: "Perform comprehensive ConPort health scan and report findings."
          Specialist_Specific_Instructions:
            - "Log your own detailed `Progress` (integer `id`) item for this scan, parented to [LeadArchitect_HC_Progress_ID]."
            - "1. **Decision Integrity:** Retrieve recent/all `Decisions` (integer `id`). Check for missing `rationale`/`implications` (DoD). List deficient Decision IDs."
            - "2. **Progress Item Review:** Retrieve `Progress` (integer `id`) items: BLOCKED or IN_PROGRESS for >[X days, from NovaSystemConfig]). Analyze context. List items needing follow-up."
            - "3. **Custom Data Audit:** Review sample `CustomData` (key) entries against `standard_conport_categories`. Identify non-standard/inconsistent usage. Suggest consolidations."
            - "4. **Linkage Review:** For recent critical `ErrorLogs` (key) or high-impact `Decisions` (integer `id`), check `get_linked_items`. Identify items with weak/missing linkage."
            - "5. **Outdated Info Scan:** Check `SystemPatterns` (integer `id`), `ConfigSettings` (key), `APIEndpoints` (key) not updated in >[Y months, from NovaSystemConfig]. List potentially outdated items."
            - "6. **Anomaly Detection:** Scan for `Decisions` (integer `id`) with no linked `Progress` (integer `id`); `ErrorLogs` (key) OPEN too long without `Progress` updates; unreferenced `SystemPatterns` (integer `id`)."
            - "Compile a structured Markdown report of ALL findings, categorised by check type, including item IDs/keys. Save this report to `.nova/reports/conport_health_YYYYMMDD.md` using `write_to_file`."
          Required_Input_Context_For_Specialist:
            - Parent_Progress_ID: [LeadArchitect_HC_Progress_Integer_ID]
            - NovaSystemConfig_Ref: { type: "custom_data", category: "NovaSystemConfig", key: "ActiveSettings", fields_needed: ["mode_behavior.nova-leadarchitect.conport_health_check_frequency_days", "other_thresholds_for_stale_items"] } # (Conceptual fields)
            - Specific_Focus_Areas: "[From Orchestrator/LeadArchitect's initial plan, if any]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Path to the generated findings report in `.nova/reports/`."
            - "Summary of major findings."
            - "Confirmation that their detailed `Progress` (integer `id`) for the scan is logged."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review the findings report. Update plan and progress.

3.  **Nova-LeadArchitect: Review Findings & Propose Actions to User/Orchestrator**
    *   **Action:** Based on ConPortSteward's report:
        *   Summarize key findings and anomalies.
        *   Propose specific corrective actions (e.g., "Update Decision D-10 rationale", "Link ErrorLog EL-ABC to Progress P-XYZ", "Standardize CustomData category 'Misc'").
        *   Use `ask_followup_question` (if interacting directly with user via Orchestrator relay) or prepare these proposals for your `attempt_completion` if Orchestrator expects a plan.
        *   "Findings report at `.nova/reports/conport_health_YYYYMMDD.md`. Key issues: [X, Y]. Proposed actions: [1. Fix X, 2. Investigate Y]. Please confirm/prioritize."
    *   **Output:** User/Orchestrator approval for specific actions.

4.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Execute Approved Actions**
    *   **Task:** "Execute approved corrective actions on ConPort items."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Complete ConPort Health Check Cycle - [Date]."
          Specialist_Subtask_Goal: "Execute approved ConPort corrective actions."
          Specialist_Specific_Instructions:
            - "Log your own detailed `Progress` (integer `id`) for these updates."
            - "Action 1: For `Decision` (integer `id`) [ID], update `rationale` to '[New Rationale]' using `update_decision`."
            - "Action 2: For `CustomData ErrorLogs:[key]`, update `status` to 'NEEDS_REVIEW_STALE' using `update_custom_data`."
            - "Action 3: Link `Decision` (integer `id`) [ID_A] to `Progress` (integer `id`) [ID_B] with relationship 'tracked_by' using `link_conport_items`."
            - "(Provide a list of such specific, atomic actions based on approval)."
            - "Document all changes made in your `Progress` (integer `id`) item notes."
          Required_Input_Context_For_Specialist:
            - List_Of_Approved_Actions_With_Details: "[From LeadArchitect's interaction with user/Orchestrator]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation of all actions executed."
            - "List of ConPort items (IDs/keys) that were modified."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify actions. Update plan and progress.

**Phase HC.2: Final Reporting by Nova-LeadArchitect**

5.  **Nova-LeadArchitect: Consolidate & Finalize**
    *   **Action:** Once all approved actions are DONE by ConPortSteward:
        *   Update main `Progress` (integer `id`) for "ConPort Health Check Cycle" to DONE.
        *   Update `active_context.state_of_the_union` (via `use_mcp_tool`) with a note about health check completion and key outcomes.
    *   **Output:** Health check cycle completed.

6.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, summary of findings, actions taken, and path to the detailed report.

**Key ConPort Items Created/Updated by Nova-LeadArchitect's Team:**
-   `Progress` (integer `id`): For overall cycle, scan subtask, action subtask.
-   `CustomData LeadPhaseExecutionPlan:[HCProgressID]_ArchitectPlan` (key).
-   Updates to various existing ConPort items (`Decisions` (integer `id`), `Progress` (integer `id`), `CustomData` (key) entries).
-   New `ContextLinks` (integer `id`).
-   `ActiveContext` (key `state_of_the_union` update).
-   (Potentially) New `ErrorLogs` (key) if health check reveals critical data corruption.