# Workflow: Triage New Issue Reported by Lead (WF_ORCH_TRIAGE_NEW_ISSUE_REPORTED_BY_LEAD_001_v1)

**Goal:** To systematically process a "New Issue Discovered (Out of Scope)" that a Lead Mode has reported in their `attempt_completion`, by ensuring it's tracked in ConPort and discussed with the user for prioritization.

**Primary Orchestrator Actor:** Nova-Orchestrator (executes this internally)
**Delegated Lead Mode Actor:** Nova-LeadArchitect (for logging `Progress` for the new issue)

**Trigger / Recognition:**
- A Lead Mode's `attempt_completion` message includes a "New Issues Discovered (Out of Scope)" section with one or more ConPort `CustomData ErrorLogs:[key]` references.
- This workflow is executed by Nova-Orchestrator for each such reported new issue.

**Pre-requisites by Nova-Orchestrator:**
- The Lead Mode has already created the initial `ErrorLogs:[key]` entry in ConPort (as per their prompt's rules).
- Nova-Orchestrator has the `ErrorLogs:[key]` and a brief summary of the issue from the Lead's report.

**Phases & Steps (executed by Nova-Orchestrator):**

**Phase TI.1: Log Tracking Progress for New Issue**

1.  **Nova-Orchestrator: Delegate `Progress` Item Creation for the New ErrorLog**
    *   **Actor:** Nova-Orchestrator
    *   **Context:** A Lead (e.g., Nova-LeadDeveloper) reported `ErrorLogs:EL-KEY123` (key) (Symptom: "XYZ").
    *   **Task:** "Delegate to Nova-LeadArchitect to log a new `Progress` item to track the investigation/resolution of the newly reported `ErrorLogs:[key]`."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "IssueTriage (Orchestrator) -> LogTrackingProgress (LeadArchitect)",
          "Overall_Project_Goal": "Ensure all discovered issues are tracked.",
          "Phase_Goal": "Create a ConPort `Progress` item for the new `ErrorLogs:[ErrorLogKeyFromLead]`.",
          "Lead_Mode_Specific_Instructions": [
            "A new out-of-scope issue was reported by another Lead: `ErrorLogs:[ErrorLogKeyFromLead]` (key) - Summary: '[IssueSummaryFromLead]'.",
            "Your Nova-SpecializedConPortSteward needs to log a new `Progress` (integer `id`) item in ConPort using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"TODO\", \"description\": \"Triage & Investigate New Issue: [IssueSummaryFromLead] (ref: ErrorLogs:[ErrorLogKeyFromLead])\"}`).",
            "After logging the `Progress` item and getting its ID, link it to `CustomData ErrorLogs:[ErrorLogKeyFromLead]` (key) with relationship type 'tracks_errorlog' using `use_mcp_tool` (`tool_name: 'link_conport_items'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"source_item_type\": \"progress_entry\", \"source_item_id\": \"[NewProgressID_as_string]\", \"target_item_type\": \"custom_data\", \"target_item_id\": \"ErrorLogs:[ErrorLogKeyFromLead]\", \"relationship_type\": \"tracks_errorlog\"}`)."
          ],
          "Required_Input_Context": {
            "ErrorLogKeyFromLead": "[The key of the ErrorLog, e.g., EL-KEY123]",
            "IssueSummaryFromLead": "[Brief summary of the issue]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "The integer `id` of the newly created `Progress` item.",
            "Confirmation that the link to the `ErrorLogs` item was created."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Note the new `Progress` (integer `id`). Let this be `[NewIssueProgressID]`.

**Phase TI.2: Inform User & Determine Priority**

2.  **Nova-Orchestrator: Discuss New Issue with User**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Inform the user: "During [PreviousLeadMode]'s work on [PreviousPhaseGoal], they discovered a new potential issue: '[IssueSummaryFromLead]', logged as `ErrorLogs:[ErrorLogKeyFromLead]` (key). I've created `Progress:[NewIssueProgressID]` (integer `id`) to track this."
        *   Use `ask_followup_question`:
            *   Question: "Should we prioritize investigating `ErrorLogs:[ErrorLogKeyFromLead]` now (this might pause the current main task), add it to the backlog for later review, or defer the decision?"
            *   Suggestions: ["Investigate now", "Add to backlog", "Defer decision for now"].
    *   **Output:** User decision on how to handle the new issue.

**Phase TI.3: Action Based on User Prioritization**

3.  **Nova-Orchestrator: Delegate or Tag Based on User Decision**
    *   **Actor:** Nova-Orchestrator
    *   **Condition:** If user chose "Investigate now":
        *   **Action:**
            *   Update `Progress:[NewIssueProgressID]` (integer `id`) status to "INVESTIGATION_PENDING" using `use_mcp_tool` (`tool_name: 'update_progress'`).
            *   Delegate investigation to `Nova-LeadQA` using `WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1.md` (or similar). The `Subtask Briefing Object` will reference `ErrorLogs:[ErrorLogKeyFromLead]` (key) and `Progress:[NewIssueProgressID]` (integer `id`).
            *   Inform user: "Okay, I've tasked Nova-LeadQA with investigating `ErrorLogs:[ErrorLogKeyFromLead]`."
    *   **Condition:** If user chose "Add to backlog":
        *   **Action:**
            *   Delegate to `Nova-LeadArchitect` (via Nova-SpecializedConPortSteward): "Update `Progress:[NewIssueProgressID]` (integer `id`) by setting its status to 'BACKLOGGED' and ensure its `description` field appropriately reflects it's a backlogged item."
            *   Inform user: "Okay, `ErrorLogs:[ErrorLogKeyFromLead]` (key) (tracked by `Progress:[NewIssueProgressID]` (integer `id`)) is added to backlog."
    *   **Condition:** If user chose "Defer decision for now":
        *   **Action:**
            *   Ensure `Progress:[NewIssueProgressID]` (integer `id`) status is 'TODO' or 'NEEDS_TRIAGE'.
            *   Inform user: "Okay, `ErrorLogs:[ErrorLogKeyFromLead]` (key) (tracked by `Progress:[NewIssueProgressID]` (integer `id`)) remains as TODO/NEEDS_TRIAGE for now. We can revisit its priority later."
    *   **Output:** New issue is either actively being investigated, backlogged, or noted for later triage.

**Key ConPort Items Involved:**
- CustomData ErrorLogs:[key] (created by the reporting Lead's team, read by Orchestrator)
- Progress (integer `id`) (new item created by Nova-LeadArchitect's team, status/description updated)
- (Potentially) Decisions (integer `id`) (if deferring the issue is a formal decision)