# Workflow: ConPort Health Check & Maintenance (WF_ARCH_CONPORT_HEALTH_CHECK_001_v1)

**Goal:** To periodically review and maintain the quality, consistency, and utility of data within ConPort for the current workspace, executed by Nova-LeadArchitect's team.

**Primary Actor:** Nova-LeadArchitect (receives phase task from Nova-Orchestrator, or can initiate based on `NovaSystemConfig`)
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Run ConPort Maintenance/Health Check for Project [ProjectName]".
- Scheduled review task as per `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadarchitect.conport_health_check_frequency_days` (retrieved via `use_mcp_tool`).
- Nova-Orchestrator or Nova-LeadArchitect detects potential ConPort inconsistencies from Lead reports or direct observation.

**Pre-requisites by Nova-LeadArchitect (from Nova-Orchestrator's briefing or self-initiated):**
- ConPort is `[CONPORT_ACTIVE]`.
- (Optional) Specific areas of concern or focus for the health check provided by user/Orchestrator.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator, or as a self-initiated phase):**

**Phase HC.1: Initial Planning & Delegation**

1.  **Nova-LeadArchitect: Receive Task & Plan Health Check**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator (if applicable). Understand `Phase_Goal` and any specific areas of focus.
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "ConPort Health Check Cycle - [Date]". Let this be `[HCProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[HCProgressID]_ArchitectPlan` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Example plan items:
            1.  Perform Health Scan & Generate Findings Report (Delegate to ConPortSteward).
            2.  Review Findings & Propose Actions (LeadArchitect).
            3.  Execute Approved Corrective Actions (Delegate to ConPortSteward).
            4.  Finalize and Report Health Check Cycle (LeadArchitect).
    *   **Output:** Plan ready. Main `Progress` (`[HCProgressID]`) created. `LeadPhaseExecutionPlan` (key) logged.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Perform Health Scan & Report Findings**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Execute ConPort health scan based on standard checks and specific focus areas, and generate a findings report."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (ConPortHealthCheck) -> Perform Scan (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Complete ConPort Health Check Cycle - [Date].",
          "Specialist_Subtask_Goal": "Perform comprehensive ConPort health scan and generate a structured findings report.",
          "Specialist_Specific_Instructions": [
            "Log your own detailed `Progress` (integer `id`) for this scan, parented to `[HCProgressID]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
            "Using `use_mcp_tool` with appropriate ConPort getter/search tools (`get_decisions`, `get_progress`, `get_custom_data`, `get_linked_items`, `semantic_search_conport`, etc.) and `workspace_id: 'ACTUAL_WORKSPACE_ID'`:",
            "1. **Decision Integrity:** Retrieve recent/all `Decisions` (integer `id`). Check for missing `rationale`/`implications` fields (DoD check). List deficient Decision IDs.",
            "2. **Progress Item Review:** Retrieve `Progress` (integer `id`) items that are BLOCKED or have been IN_PROGRESS for more than [X_days_threshold] (get threshold from `NovaSystemConfig:ActiveSettings` if available, or use a default like 30). Analyze context. List items needing follow-up.",
            "3. **Custom Data Audit:** Review a sample of `CustomData` (key) entries, especially those in non-standard or overly generic categories. Check for consistency in `value` structure for common categories like `APIEndpoints`, `SystemArchitecture`. Identify potentially orphaned or redundant entries. Suggest consolidations or re-categorizations.",
            "4. **Linkage Review:** For a sample of critical `ErrorLogs` (key), `Decisions` (integer `id`), and `SystemArchitecture` (key) components, use `get_linked_items` to verify expected relationships (e.g., `ErrorLogs` linked to `Progress`; `Decisions` linked to implementing `SystemArchitecture` or `CodeSnippets`). Identify items with weak/missing linkage.",
            "5. **Outdated Information Scan:** Check `SystemPatterns` (integer `id`), `CustomData ConfigSettings:[key]`, `CustomData APIEndpoints:[key]` not updated in more than [Y_months_threshold] (get threshold from `NovaSystemConfig:ActiveSettings` or use a default like 6). List potentially outdated items for review.",
            "6. **Schema Adherence (Conceptual):** Review `CustomData` categories and keys against `standard_conport_categories` (provided by LeadArchitect). Note any deviations or suggestions for new standard categories (to be formalized later via `WF_ARCH_CONPORT_SCHEMA_PROPOSAL_001_v1.md`).",
            "Compile a structured Markdown report of ALL findings, categorised by check type, including item IDs/keys and specific issues. Save this report to `.nova/reports/architect/ConPortHealthCheck_[YYYYMMDD].md` using the `write_to_file` tool."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[HCProgressID_as_string]",
            "NovaSystemConfig_Ref_For_Thresholds": { "type": "custom_data", "category": "NovaSystemConfig", "key": "ActiveSettings" },
            "Standard_ConPort_Categories_List": "[List from LeadArchitect, derived from Orchestrator/Architect prompts]",
            "Specific_Focus_Areas_From_LeadArchitect": "[Optional: e.g., 'Focus on Decision linkage for Project X components']"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Path to the generated findings report in `.nova/reports/architect/`.",
            "Summary of major findings (e.g., number of decisions missing rationale, number of stale progress items).",
            "Confirmation that their detailed `Progress` (integer `id`) for the scan is logged."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review the findings report (`read_file`). Update `[HCProgressID]_ArchitectPlan` and specialist `Progress` in ConPort.

3.  **Nova-LeadArchitect: Review Findings & Propose Corrective Actions to User/Orchestrator**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Based on ConPortSteward's report:
        *   Summarize key findings and anomalies (e.g., "Found 5 Decisions missing rationale, 3 stale Progress items over 60 days old, inconsistent use of 'Notes' category in CustomData").
        *   Propose specific corrective actions with justifications (e.g., "Action 1: Update Decision D-10 rationale to include X.", "Action 2: Review Progress P-XYZ with LeadDeveloper to determine status.", "Action 3: Consolidate CustomData 'MiscNotes' and 'GeneralInfo' into 'MeetingNotes' or `LessonsLearned`.").
        *   If the health check was initiated by Nova-Orchestrator, include these proposals in your `attempt_completion` to Orchestrator. If self-initiated, log a `Decision` (integer `id`) for the proposed actions and proceed if within your autonomy, or use `ask_followup_question` to get user/Orchestrator approval for significant changes.
    *   **Output:** User/Orchestrator approval or a clear plan for specific corrective actions.

4.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Execute Approved Corrective Actions**
    *   **Actor:** Nova-LeadArchitect
    *   **DoR Check:** Clear, approved list of corrective actions is available.
    *   **Task:** "Execute approved corrective actions on ConPort items based on the Health Check findings."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (ConPortHealthCheck) -> Execute Actions (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Complete ConPort Health Check Cycle - [Date].",
          "Specialist_Subtask_Goal": "Execute approved ConPort corrective actions and document changes.",
          "Specialist_Specific_Instructions": [
            "Log your own detailed `Progress` (integer `id`) for these updates, parented to `[HCProgressID]`.",
            "For each approved action (provided by LeadArchitect):",
            "  - Action Example 1: For `Decision` (integer `id`) [ID], update `rationale` to '[New Rationale]' using `use_mcp_tool` (`tool_name: 'update_decision'`, `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'decision_id': [ID_as_string], 'rationale': '[New Rationale]'}`).",
            "  - Action Example 2: For `CustomData ErrorLogs:[key]`, update `status` to 'NEEDS_REVIEW_STALE' using `use_mcp_tool` (`tool_name: 'update_custom_data'`, `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'category': 'ErrorLogs', 'key': '[ErrorLogKey]', 'value': { /* entire_updated_R20_object_with_new_status */ }}`).",
            "  - Action Example 3: Link `Decision` (integer `id`) [ID_A_as_string] to `Progress` (integer `id`) [ID_B_as_string] with relationship 'tracked_by' using `use_mcp_tool` (`tool_name: 'link_conport_items'`, `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'source_item_type': 'decision', 'source_item_id': '[ID_A_as_string]', ...}`).",
            "Document all specific changes made in your `Progress` item's description field."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[HCProgressID_as_string]",
            "List_Of_Approved_Actions_With_Details": "[Structured list from LeadArchitect, including item types, IDs/keys, new values, link details]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation of all actions executed.",
            "List of ConPort items (IDs/keys) that were modified or linked."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify actions. Update `[HCProgressID]_ArchitectPlan` and specialist `Progress` in ConPort.

**Phase HC.2: Final Reporting by Nova-LeadArchitect**

5.  **Nova-LeadArchitect: Consolidate & Finalize**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Once all approved actions are DONE by ConPortSteward:
        *   Update main `Progress` (`[HCProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "ConPort Health Check Cycle - [Date] completed. Findings reported and actions taken. Report: `.nova/reports/architect/ConPortHealthCheck_[YYYYMMDD].md`."
        *   Update `active_context.state_of_the_union` (using `use_mcp_tool`, `tool_name: 'update_active_context'`, `patch_content: {'state_of_the_union': 'ConPort health check completed on [Date]. Key improvements implemented.'}`) to reflect completion and key outcomes.
    *   **Output:** Health check cycle completed and documented.

6.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Report completion, summary of findings, actions taken, and path to the detailed report.

**Key ConPort Items Involved:**
- Progress (integer `id`): For overall cycle, scan subtask, action subtask.
- CustomData LeadPhaseExecutionPlan:[HCProgressID]_ArchitectPlan (key).
- Updates to various existing ConPort items (Decisions (integer `id`), Progress (integer `id`), CustomData (key) entries).
- New ContextLinks (integer `id`).
- ActiveContext (`state_of_the_union` update).
- (Potentially) New `ErrorLogs` (key) if health check reveals critical data corruption or process failures.
- (Reads) Many ConPort item types.