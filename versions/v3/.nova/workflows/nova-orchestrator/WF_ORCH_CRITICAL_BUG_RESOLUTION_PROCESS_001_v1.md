# Workflow: Critical Bug Resolution Process (WF_ORCH_CRITICAL_BUG_RESOLUTION_PROCESS_001_v1)

**Goal:** To manage the expedited investigation, fix, and verification of a critical bug that significantly impacts project functionality or stability.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Primary Lead Mode Actors (delegated to by Nova-Orchestrator):** Nova-LeadQA, Nova-LeadDeveloper, (potentially Nova-LeadArchitect if architectural implications)

**Trigger / Recognition:**
- User reports a critical bug: "Critical Issue: System crashes when X happens!"
- Nova-LeadQA escalates an existing `CustomData ErrorLogs:[key]` to CRITICAL severity.
- Automated monitoring (conceptual) flags a severe production issue.

**Pre-requisites by Nova-Orchestrator (before starting this workflow):**
- Nova-Orchestrator has performed its initial session/ConPort initialization.
- A ConPort `CustomData ErrorLogs:[key]` entry exists or is immediately created for the critical bug, containing as much initial detail as possible.
- User/Stakeholder confirms the criticality and the need for an expedited process.

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase CB.1: Initial Triage & Investigation Delegation (Nova-Orchestrator -> Nova-LeadQA)**

1.  **Nova-Orchestrator: Acknowledge Criticality & Delegate Investigation**
    *   **Action:**
        *   Log/Update a main `Progress` (integer `id`) item: "CRITICAL BUG Resolution: [ErrorLog Key/Symptom]", Status: "TRIAGE_INVESTIGATION_PENDING".
        *   Update `active_context.state_of_the_union` to reflect "CRITICAL BUG [ErrorLog Key] under active investigation. Potential impact on current sprint goals."
    *   **Task:** "Delegate immediate and thorough investigation of critical `ErrorLogs:[ErrorLogKey]` to Nova-LeadQA."
    *   **`new_task` message for Nova-LeadQA:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Resolve critical bug [ErrorLogKey] ASAP."
          Phase_Goal: "Perform rapid root cause analysis for `ErrorLogs:[ErrorLogKey]`, document findings, and propose an immediate mitigation or investigation path."
          Lead_Mode_Specific_Instructions:
            - "CRITICAL BUG: `ErrorLogs:[ErrorLogKey]` - [Symptom from ErrorLog]."
            - "1. Assign Nova-SpecializedBugInvestigator to perform immediate, prioritized root cause analysis. They should leverage all available ConPort data (code links, related decisions, past errors) and system logs."
            - "2. Goal for BugInvestigator: Identify root cause or narrow down possibilities significantly within [e.g., 2-4 hours, from NovaSystemConfig if available, otherwise your best estimate]."
            - "3. Ensure BugInvestigator meticulously updates `ErrorLogs:[ErrorLogKey]` (key) with all findings, reproduction steps, environment details, and evolving hypothesis."
            - "4. If a temporary workaround/mitigation is identifiable, document it clearly in the `ErrorLogs:[ErrorLogKey]` notes."
            - "5. Update your LeadQA phase `Progress` (integer `id`) frequently."
            - "6. Update `active_context.open_issues` to reflect this critical bug."
          Required_Input_Context:
            - ConPort_ErrorLog_Key_To_Investigate: "[ErrorLogKey]"
            - (Optional) Any_Initial_User_Or_Orchestrator_Observations: "[...]"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "Updated `ErrorLogs:[ErrorLogKey]` (key) with detailed investigation findings and root cause hypothesis/confirmation."
            - "Proposed next steps (e.g., 'Ready for fix by LeadDeveloper', 'Needs deeper architectural review by LeadArchitect', 'Workaround X can be applied')."
            - "Confirmation `active_context.open_issues` is updated."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Review findings. Update main `Progress` (integer `id`) for the critical bug.

**Phase CB.2: Fix Implementation (Nova-Orchestrator -> Nova-LeadDeveloper)**

2.  **Nova-Orchestrator: Delegate Expedited Fix**
    *   **DoR Check:** Nova-LeadQA has provided a clear root cause hypothesis or confirmed cause in `ErrorLogs:[ErrorLogKey]`. The issue is determined to be a code fix (not purely architectural or config requiring LeadArchitect first).
    *   **Task:** "Delegate the development of an expedited fix for `ErrorLogs:[ErrorLogKey]` to Nova-LeadDeveloper."
    *   **`new_task` message for Nova-LeadDeveloper:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Resolve critical bug [ErrorLogKey] ASAP."
          Phase_Goal: "Develop, unit test, and document a robust fix for `ErrorLogs:[ErrorLogKey]`."
          Lead_Mode_Specific_Instructions:
            - "CRITICAL FIX REQUIRED for `ErrorLogs:[ErrorLogKey]`. Root cause identified by Nova-LeadQA: [Summary from ErrorLog]."
            - "1. Assign Nova-SpecializedFeatureImplementer or Nova-SpecializedCodeRefactorer to implement the fix with highest priority."
            - "2. Ensure the fix is as targeted as possible to minimize regression risk."
            - "3. CRITICAL: Comprehensive unit tests MUST accompany the fix."
            - "4. Code must pass all linters as per `ProjectConfig:ActiveConfig`."
            - "5. Log any technical `Decisions` (integer `id`) made for the fix (e.g., specific algorithm change, library patch usage)."
            - "6. Update your LeadDeveloper phase `Progress` (integer `id`) frequently."
            - "7. If fix requires minor, safe, related refactoring for stability, perform it and document in `TechDebtCandidates` (key) if larger refactoring is out of scope."
          Required_Input_Context:
            - ConPort_ErrorLog_To_Fix_Key: "[ErrorLogKey]"
            - ConPort_Root_Cause_Analysis_Ref: { type: "custom_data", category: "ErrorLogs", key: "[ErrorLogKey]", field_hint: "investigation_notes_or_root_cause_summary" }
            - (Optional) Suggested_Fix_Approach_From_LeadQA: "[...]"
            - (Optional) Relevant_Code_Paths_From_LeadQA: "[...]"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "Confirmation that fix is implemented and unit tested (with pass status)."
            - "Paths to modified files / Pull Request ID (conceptual)."
            - "ConPort integer `id` of any `Decision` made for the fix."
            - "Confirmation that code is ready for verification by Nova-LeadQA."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify deliverables. Update main `Progress` (integer `id`) to "Fix Implemented, Verification Pending".

**Phase CB.3: Fix Verification & Closure (Nova-Orchestrator -> Nova-LeadQA)**

3.  **Nova-Orchestrator: Delegate Fix Verification**
    *   **DoR Check:** Nova-LeadDeveloper reports fix implemented and unit tested.
    *   **Task:** "Delegate verification of the fix for `ErrorLogs:[ErrorLogKey]` to Nova-LeadQA."
    *   **`new_task` message for Nova-LeadQA:**
        ```
        Subtask_Briefing:
          Overall_Project_Goal: "Resolve critical bug [ErrorLogKey] ASAP."
          Phase_Goal: "Verify that the fix implemented by Nova-LeadDeveloper for `ErrorLogs:[ErrorLogKey]` effectively resolves the issue without regressions."
          Lead_Mode_Specific_Instructions:
            - "VERIFY FIX for `ErrorLogs:[ErrorLogKey]`. Fix details from Nova-LeadDeveloper: [Summary of fix, modified files/PR]."
            - "1. Assign Nova-SpecializedFixVerifier."
            - "2. Verifier must execute original reproduction steps from `ErrorLogs:[ErrorLogKey]`."
            - "3. Verifier must execute any specific verification test cases defined for this bug or feature area."
            - "4. Perform targeted regression testing around the fix area."
            - "5. If fix confirmed: Update `ErrorLogs:[ErrorLogKey]` status to RESOLVED. Add verification notes. Consider logging a `LessonsLearned` (key) entry with your team for this critical bug."
            - "6. If fix NOT confirmed: Update `ErrorLogs:[ErrorLogKey]` status back to OPEN (or FAILED_VERIFICATION), add detailed failure notes, and specify what still fails."
            - "7. Update `active_context.open_issues` accordingly."
          Required_Input_Context:
            - ConPort_ErrorLog_To_Verify_Key: "[ErrorLogKey]"
            - Fix_Implementation_Details_From_Dev: "[...]"
          Expected_Deliverables_In_Attempt_Completion_From_Lead:
            - "Final status of `ErrorLogs:[ErrorLogKey]` (RESOLVED or FAILED_VERIFICATION/REOPENED)."
            - "ConPort key of `LessonsLearned` if one was logged."
            - "Confirmation `active_context.open_issues` is updated."
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   If RESOLVED: Proceed to Phase CB.4.
        *   If FAILED_VERIFICATION: Loop back to Phase CB.2 (Nova-LeadDeveloper for re-fix) or Phase CB.1 (Nova-LeadQA for deeper investigation if cause was misunderstood). Log this loop as a `Decision` (integer `id`).

**Phase CB.4: Post-Resolution & Communication (Nova-Orchestrator)**

4.  **Nova-Orchestrator: Finalize Critical Bug Resolution**
    *   **Action:**
        *   Log `Decision` (integer `id`) confirming critical bug `ErrorLogs:[ErrorLogKey]` resolution and any deployment/hotfix strategy.
        *   Update main `Progress` (integer `id`) for "CRITICAL BUG Resolution: [ErrorLogKey]" to "COMPLETED_RESOLVED".
        *   Update `active_context.state_of_the_union` to "Critical bug [ErrorLogKey] resolved. System stable."
        *   Communicate resolution to user/stakeholders.
    *   **Output:** Critical bug resolved and stakeholders informed.

**Key ConPort Items Involved:**
-   `CustomData ErrorLogs:[key]` (central item, status updates are critical)
-   `Progress` (integer `id`) (for Orchestrator's overall tracking, and for each Lead's phase)
-   `Decisions` (integer `id`) (for investigation strategy, fix strategy, deferral, resolution confirmation)
-   `CustomData LessonsLearned:[key]` (logged by Nova-LeadQA team)
-   `ActiveContext` (`state_of_the_union`, `open_issues` updates)
-   (Potentially) `CodeSnippets` (key) or updated `SystemPatterns` (integer `id`) if fix is complex or reveals pattern flaws.