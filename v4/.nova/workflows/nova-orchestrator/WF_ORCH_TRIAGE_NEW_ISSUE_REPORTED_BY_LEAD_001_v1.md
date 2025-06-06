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
    *   **Context:** A Lead (e.g., Nova-LeadDeveloper) reported `ErrorLogs:EL-KEY123` (key) (Symptom: "XYZ").
    *   **Task:** "Delegate to Nova-LeadArchitect to log a new `Progress` item to track the investigation/resolution of the newly reported `ErrorLogs:[key]`."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Ensure all discovered issues are tracked."
          Phase_Goal: "Create a ConPort `Progress` item for the new `ErrorLogs:[ErrorLogKeyFromLead]`."
          Lead_Mode_Specific_Instructions:
            - "A new out-of-scope issue was reported by another Lead: `ErrorLogs:[ErrorLogKeyFromLead]` (key) - Summary: '[IssueSummaryFromLead]'."
            - "Your Nova-SpecializedConPortSteward needs to log a new `Progress` (integer `id`) item in ConPort with:"
            - "  Description: 'Triage & Investigate New Issue: [IssueSummaryFromLead] (ref: ErrorLogs:[ErrorLogKeyFromLead])'"
            - "  Status: 'TODO' or 'NEEDS_TRIAGE'"
            - "  Linked Item: Link this new `Progress` (integer `id`) item to `CustomData ErrorLogs:[ErrorLogKeyFromLead]` (key) with relationship type 'tracks_errorlog'."
          Required_Input_Context:
            - ErrorLogKeyFromLead: "[The key of the ErrorLog, e.g., EL-KEY123]"
            - IssueSummaryFromLead: "[Brief summary of the issue]"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "The integer `id` of the newly created `Progress` item."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Note the new `Progress` (integer `id`).

**Phase TI.2: Inform User & Determine Priority**

2.  **Nova-Orchestrator: Discuss New Issue with User**
    *   **Action:**
        *   Inform the user: "During [PreviousLeadMode]'s work on [PreviousPhaseGoal], they discovered a new potential issue: '[IssueSummaryFromLead]', logged as `ErrorLogs:[ErrorLogKeyFromLead]` (key). I've created `Progress:[NewProgressID]` (integer `id`) to track this."
        *   Use `ask_followup_question`: "Should we:
            1. Prioritize investigating `ErrorLogs:[ErrorLogKeyFromLead]` now (potentially pausing current main task)?
            2. Add it to the backlog for later review (will tag `Progress:[NewProgressID]` with #backlog)?
            3. Defer decision (will leave `Progress:[NewProgressID]` as TODO)?"
        *   Suggestions: ["Investigate now", "Add to backlog", "Defer decision"].
    *   **Output:** User decision on how to handle the new issue.

**Phase TI.3: Action Based on User Prioritization**

3.  **Nova-Orchestrator: Delegate or Tag Based on User Decision**
    *   **Condition:** If user chose "Investigate now":
        *   **Action:**
            *   Update `Progress:[NewProgressID]` (integer `id`) status to "INVESTIGATION_PENDING".
            *   Delegate investigation to `Nova-LeadQA` (or other appropriate Lead) using a standard bug investigation workflow (e.g., `WF_ORCH_CRITICAL_BUG_RESOLUTION_PROCESS_001.md` adapted for non-critical, or a new `WF_ORCH_STANDARD_BUG_INVESTIGATION_001.md`). The `Subtask Briefing Object` will reference `ErrorLogs:[ErrorLogKeyFromLead]` (key) and `Progress:[NewProgressID]` (integer `id`).
            *   Inform user: "Okay, I've tasked Nova-LeadQA with investigating `ErrorLogs:[ErrorLogKeyFromLead]`."
    *   **Condition:** If user chose "Add to backlog":
        *   **Action:**
            *   Delegate to `Nova-LeadArchitect` (via Nova-SpecializedConPortSteward): "Update `Progress:[NewProgressID]` (integer `id`) by adding tag '#backlog' and set status to 'BACKLOGGED'."
            *   Inform user: "Okay, `ErrorLogs:[ErrorLogKeyFromLead]` (key) (tracked by `Progress:[NewProgressID]` (integer `id`)) is added to backlog."
    *   **Condition:** If user chose "Defer decision":
        *   **Action:** Inform user: "Okay, `ErrorLogs:[ErrorLogKeyFromLead]` (key) (tracked by `Progress:[NewProgressID]` (integer `id`)) remains as TODO for now. We can revisit its priority later."
    *   **Output:** New issue is either actively being investigated, backlogged, or noted for later triage.

**Key ConPort Items Involved:**
-   `CustomData ErrorLogs:[key]` (created by the reporting Lead's team, read by Orchestrator)
-   `Progress` (integer `id`) (new item created by Nova-LeadArchitect's team, status/tags updated)
-   (Potentially) `Decisions` (integer `id`) (if deferring the issue is a formal decision)