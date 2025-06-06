# Workflow: Session End and Summary Generation (WF_ORCH_SESSION_END_AND_SUMMARY_001_v1)

**Goal:** To gracefully end the current user session by ensuring critical ConPort state is updated and a session summary file is generated and saved in `.nova/summary/`.

**Primary Orchestrator Actor:** Nova-Orchestrator (executes this internally)
**Delegated Actors:** Nova-LeadArchitect (for `active_context` update), Nova-FlowAsk (for summary generation & file write)

**Trigger / Recognition:**
- User explicitly states they want to end the current session (e.g., "Stop for today", "End session", "We're done for now").
- This is typically the final workflow executed by Nova-Orchestrator in a session.

**Pre-requisites by Nova-Orchestrator:**
- Current session is active.
- Any acutely active Lead Mode task has reached a logical conclusion or a safe pause point (Orchestrator should ensure this before starting this workflow).

**Phases & Steps (executed by Nova-Orchestrator):**

**Phase SE.1: Finalize ConPort State**

1.  **Nova-Orchestrator: Ensure Lead Mode Task Completion/Pause**
    *   **Action:** If a Lead Mode was actively processing a phase, confirm with the user if that Lead should complete its current *smallest logical unit of work* (e.g., current specialist subtask) or if the work should pause immediately.
    *   If Lead needs to complete a small step, await that `attempt_completion`.
    *   **Output:** Current primary delegated phase is at a stable point.

2.  **Nova-Orchestrator: Delegate `active_context.state_of_the_union` Update**
    *   **Task:** "Delegate to Nova-LeadArchitect to ensure `active_context.state_of_the_union` accurately reflects the project's status at the end of this session."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Gracefully end current Nova session."
          Phase_Goal: "Update ConPort `active_context.state_of_the_union` with final session status."
          Lead_Mode_Specific_Instructions:
            - "The user is ending the current session."
            - "Review the overall project progress based on information from Nova-Orchestrator (see context below) and your knowledge of recent architectural/ConPort changes."
            - "Formulate a concise `state_of_the_union` string (e.g., 'Development of Feature X 50% complete, awaiting API integration. QA blocked on Test Environment Setup.')."
            - "Instruct your Nova-SpecializedConPortSteward to update `active_context.state_of_the_union` in ConPort with this string using `update_active_context` (patch)."
          Required_Input_Context:
            - Orchestrator_Current_Project_Status_View: "[Nova-Orchestrator's summary of ongoing main tasks and Lead Mode statuses]"
            - Key_Recent_ConPort_Progress_IDs: ["[ID1]", "[ID2]"] // Optional, if Orchestrator has them handy
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "Confirmation that `active_context.state_of_the_union` has been updated."
            - "The final `state_of_the_union` string that was logged."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:** Note the final state of the union.

**Phase SE.2: Generate and Save Session Summary**

3.  **Nova-Orchestrator: Delegate Session Summary Generation and File Write**
    *   **Task:** "Delegate to Nova-FlowAsk to generate a Markdown summary of the current session and save it to `.nova/summary/`."
    *   **`new_task` message for Nova-FlowAsk:**
        ```
        Subtask_Briefing:
          Subtask_Goal: "Generate a Markdown session summary and save it to a timestamped file in `.nova/summary/`."
          Mode_Specific_Instructions:
            - "Generate a concise Markdown summary of the user session that is now ending."
            - "Include the following sections if information is available from `Required_Input_Context`:
                - Date and Time of Session End.
                - Main Project/Workflow Active: ([Orchestrator_Active_Workflow_Name])
                - Last Major Task/Phase Delegated by Orchestrator: (To [LeadMode], Goal: [PhaseGoal])
                - Status of that Delegation: ([Status from Lead or Orchestrator's tracking])
                - Key ConPort Items Created/Updated This Session (provide Type and ID/Key if known): [List provided by Orchestrator]
                - Key Decisions Made This Session (provide Decision integer IDs if known): [List]
                - Open Issues/Blockers Noted (`active_context.open_issues` or critical `ErrorLog` keys): [List]
                - Agreed Next Steps (if any discussed for next session): [Details]
                - Final `active_context.state_of_the_union` (as updated by Nova-LeadArchitect): [State of Union string]"
            - "Filename should be: `session_summary_[CurrentYYYYMMDD]_[CurrentHHMMSS].md` (e.g., `session_summary_20240115_183000.md`)."
            - "Target Path: `.nova/summary/[TIMESTAMPED_FILENAME].md`."
            - "Use the `write_to_file` tool to save the generated Markdown content to this path."
          Required_Input_Context:
            - Orchestrator_Active_Workflow_Name: "[Name of current overarching workflow, if any]"
            - Orchestrator_Last_Delegation_Info: "{ lead_mode: '...', phase_goal: '...', status: '...' }"
            - Orchestrator_Key_ConPort_Changes_This_Session: "[Summary or list of IDs/keys]"
            - Orchestrator_Key_Decisions_This_Session: "[Summary or list of IDs]"
            - ConPort_State_Of_Union: "[String from Nova-LeadArchitect's update]"
            - Current_Timestamp_YYYYMMDD_HHMMSS: "[Provided by Orchestrator]"
          Expected_Deliverables_In_Attempt_Completion:
            - "Confirmation that the summary file was written."
            - "The full path to the saved summary file (should be in the `command` attribute)."
        ```
    *   **Nova-Orchestrator Action after Nova-FlowAsk's `attempt_completion`:** Note the path of the saved summary.

**Phase SE.3: Conclude Session**

4.  **Nova-Orchestrator: Inform User and Final `attempt_completion`**
    *   **Action:**
        *   Inform user: "Session ending. Current project status has been updated in ConPort, and a summary of this session has been saved to `[.nova/summary/FILENAME.md]`."
        *   Provide a very brief sign-off.
    *   **Output:** Nova-Orchestrator uses `attempt_completion` with the final message. The overall Nova session for the user is now concluded.

**Key ConPort Items Involved:**
-   `ActiveContext` (`state_of_the_union` is updated).
-   (Read-only by Nova-FlowAsk for summary): `Progress` (integer `id`), `Decisions` (integer `id`), other recent items.