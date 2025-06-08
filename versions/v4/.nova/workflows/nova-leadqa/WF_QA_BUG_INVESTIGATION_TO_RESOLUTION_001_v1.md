# Workflow: Bug Investigation to Resolution Cycle (WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1)

**Goal:** To manage the lifecycle of a reported bug from initial investigation, root cause analysis, coordination of fix, and verification of resolution, primarily driven by Nova-LeadQA.

**Primary Orchestrator Actor:** Nova-LeadQA (receives task from Nova-Orchestrator for a specific `ErrorLogs:[key]`, or initiates for a new bug found by TestExecutor).
**Primary Specialist Actors (delegated to by Nova-LeadQA):** Nova-SpecializedBugInvestigator, Nova-SpecializedFixVerifier.
**Collaborating Lead (via Nova-Orchestrator):** Nova-LeadDeveloper (for implementing fixes).

**Trigger / Nova-LeadQA Recognition:**
- Nova-Orchestrator delegates: "Investigate and manage `ErrorLogs:[ReportedBugKey]`."
- Nova-SpecializedTestExecutor reports a new bug (and logs initial `ErrorLogs:[key]`); Nova-LeadQA starts this workflow for it.

**Pre-requisites by Nova-LeadQA:**
- A `CustomData ErrorLogs:[BugKey]` (key) entry exists in ConPort with initial details (symptoms, repro steps if known, environment). If not, Nova-LeadQA instructs Nova-SpecializedTestExecutor or Nova-SpecializedConPortSteward (via LA) to create it first.

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator for a specific bug, or self-initiated for new bugs from its team):**

**Phase BIR.1: Detailed Investigation & Root Cause Analysis (RCA)**

1.  **Nova-LeadQA: Plan Investigation & Delegate to Nova-SpecializedBugInvestigator**
    *   **Action:**
        *   Log/Update main `Progress` (integer `id`) item: "Bug Lifecycle: `ErrorLogs:[BugKey]`", Status: "INVESTIGATION_ACTIVE".
        *   Create/Update `LeadPhaseExecutionPlan:[BugProgressID]_QAPlan` (key) with steps for this bug.
        *   Review existing `ErrorLogs:[BugKey]` (key) entry.
    *   **Task:** "Perform detailed investigation and Root Cause Analysis for `ErrorLogs:[BugKey]`."
    *   **`new_task` message for Nova-SpecializedBugInvestigator:**
        ```
        Subtask_Briefing:
          Overall_QA_Phase_Goal: "Investigate, facilitate fix, and verify `ErrorLogs:[BugKey]`."
          Specialist_Subtask_Goal: "Conduct detailed RCA for `ErrorLogs:[BugKey]` ([Symptom])."
          Specialist_Specific_Instructions:
            - "Target ErrorLog: `CustomData ErrorLogs:[BugKey]` (key). Review all current details."
            - "1. Attempt to reproduce the bug consistently. Document exact steps if different from ErrorLog."
            - "2. Analyze relevant application logs (`read_file`), system logs, and if necessary, inspect related source code (read-only using `search_files`, `list_code_definition_names`) to identify failure points."
            - "3. Consult related ConPort items: `Decisions` (integer `id`), `SystemArchitecture` (key), `APIEndpoints` (key), recent `Progress` (integer `id`) on related features that might have introduced the bug."
            - "4. Formulate a clear Root Cause Hypothesis / Confirmed Root Cause."
            - "5. Meticulously update the `CustomData ErrorLogs:[BugKey]` (key) entry using `update_custom_data` with:
                - Confirmed/refined reproduction steps.
                - Detailed investigation notes (what was checked, tools used, findings).
                - Root Cause Analysis section.
                - Updated `initial_hypothesis` or a new `confirmed_root_cause` field.
                - Change `status` to 'INVESTIGATION_COMPLETE_RCA_FOUND' or 'INVESTIGATION_BLOCKED_NEED_MORE_INFO'."
          Required_Input_Context_For_Specialist:
            - ErrorLog_To_Investigate_Key: "[BugKey]"
            - (Optional) ProjectConfig_Logging_Paths_Ref: { type: "custom_data", category: "ProjectConfig", key: "ActiveConfig", fields_needed: ["logging_paths"] }
            - (Optional) Relevant_Code_Module_Hints: "[From initial triage by LeadQA]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation that `ErrorLogs:[BugKey]` (key) is updated with RCA."
            - "Summary of the Root Cause."
            - "Any suggestions for fix approach (optional)."
        ```
    *   **Nova-LeadQA Action after Specialist's `attempt_completion`:** Review RCA. Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`). Update `ErrorLogs:[BugKey]` status if further action from LeadQA needed before dev.

**Phase BIR.2: Fix Coordination & Implementation (Involves Nova-Orchestrator & Nova-LeadDeveloper)**

2.  **Nova-LeadQA: Request Fix from Development via Nova-Orchestrator**
    *   **DoR Check:** RCA complete in `ErrorLogs:[BugKey]` (key), root cause points to a code defect.
    *   **Action:**
        *   Update `ErrorLogs:[BugKey]` (key) status to "AWAITING_FIX".
        *   In its `attempt_completion` to Nova-Orchestrator (if this bug investigation was a delegated phase), or in a new direct communication if LeadQA initiated this workflow:
            *   Report: "`ErrorLogs:[BugKey]` RCA complete. Root Cause: [Summary]. Requesting fix implementation by Nova-LeadDeveloper."
            *   Provide `ErrorLogs:[BugKey]` (key) as reference.
    *   **Nova-Orchestrator then delegates fix to Nova-LeadDeveloper** (using a process similar to `WF_ORCH_CRITICAL_BUG_RESOLUTION_PROCESS_001.md` Phase CB.2, but for any severity). Nova-LeadDeveloper's team implements and unit tests the fix, then reports completion back to Nova-Orchestrator.

**Phase BIR.3: Fix Verification**

3.  **Nova-LeadQA: Receive Fix Confirmation & Delegate Verification to Nova-SpecializedFixVerifier**
    *   **Action:** Nova-Orchestrator informs Nova-LeadQA that a fix for `ErrorLogs:[BugKey]` (key) is ready for verification (providing commit details/PR link if available from Nova-LeadDeveloper).
    *   Update `ErrorLogs:[BugKey]` (key) status to "AWAITING_VERIFICATION".
    *   Update `LeadPhaseExecutionPlan` (key) for this bug.
    *   **Task:** "Verify the deployed fix for `ErrorLogs:[BugKey]`."
    *   **`new_task` message for Nova-SpecializedFixVerifier:**
        ```
        Subtask_Briefing:
          Overall_QA_Phase_Goal: "Verify fix for `ErrorLogs:[BugKey]`."
          Specialist_Subtask_Goal: "Verify fix for `ErrorLogs:[BugKey]` ([Symptom])."
          Specialist_Specific_Instructions:
            - "Target ErrorLog: `CustomData ErrorLogs:[BugKey]` (key). Review original issue and RCA."
            - "Fix Details from Dev: [Summary of fix, commit ID, deployed environment info from LeadQA]."
            - "1. Execute original reproduction steps. Confirm issue is GONE."
            - "2. Execute any specific verification tests defined in the `ErrorLogs` (key) or related test plans."
            - "3. Perform targeted regression testing around the fix area to check for new issues."
            - "4. If fix confirmed: Update `ErrorLogs:[BugKey]` (key) status to `RESOLVED`. Add detailed verification notes (what was tested, build version)."
            - "5. If fix NOT confirmed (bug still present or new regression): Update `ErrorLogs:[BugKey]` (key) status to `FAILED_VERIFICATION` (or `REOPENED`). Add detailed notes on what failed and how."
          Required_Input_Context_For_Specialist:
            - ErrorLog_To_Verify_Key: "[BugKey]"
            - Fix_Details_And_Deployed_Env: "[...]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Final status of `ErrorLogs:[BugKey]` (RESOLVED or FAILED_VERIFICATION/REOPENED)."
            - "Summary of verification steps and outcome."
        ```
    *   **Nova-LeadQA Action after Specialist's `attempt_completion`:** Review verification. Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`).

**Phase BIR.4: Closure & Learning**

4.  **Nova-LeadQA: Process Verification Outcome**
    *   **Condition:** If `ErrorLogs:[BugKey]` (key) status is `RESOLVED`:
        *   Update main `Progress` (integer `id`) for "Bug Lifecycle: `ErrorLogs:[BugKey]`" to DONE.
        *   Update `active_context.open_issues` (coordinate with Nova-LeadArchitect/ConPortSteward via Nova-Orchestrator).
        *   **Delegate to Nova-SpecializedBugInvestigator or self:** "Draft `LessonsLearned` (key) entry for `ErrorLogs:[BugKey]` (R21)."
        *   Inform Nova-Orchestrator of successful resolution.
    *   **Condition:** If `ErrorLogs:[BugKey]` (key) status is `FAILED_VERIFICATION` or `REOPENED`:
        *   Update main `Progress` (integer `id`) to "BLOCKED_FIX_FAILED_VERIFICATION".
        *   Inform Nova-Orchestrator, providing details from FixVerifier. Orchestrator will re-engage Nova-LeadDeveloper. Loop back to BIR.2.
    *   **Output:** Bug resolved or re-routed for further fixing.

5.  **Nova-LeadQA: `attempt_completion` to Nova-Orchestrator (if this was a delegated phase)**
    *   **Action:** Report final outcome for `ErrorLogs:[BugKey]` (key).

**Key ConPort Items Involved:**
-   `CustomData ErrorLogs:[BugKey]` (key): Heavily used and updated throughout.
-   `Progress` (integer `id`): For LeadQA's overall management of this bug, and for specialist subtasks.
-   `CustomData LeadPhaseExecutionPlan:[BugProgressID]_QAPlan` (key).
-   `Decisions` (integer `id`): (Read) Related to feature that bugged. (Write) For triage or complex fix strategies.
-   `CustomData LessonsLearned:[key]`: Created upon successful resolution of significant bugs.
-   `ActiveContext` (`open_issues` list is updated).