# Workflow: Bug Investigation to Resolution Cycle (WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1)

**Goal:** To manage the lifecycle of a reported bug from initial investigation, root cause analysis, coordination of fix, and verification of resolution, primarily driven by Nova-LeadQA.

**Primary Actor:** Nova-LeadQA (receives task from Nova-Orchestrator for a specific `ErrorLogs:[key]`, or initiates for a new bug found by TestExecutor).
**Primary Specialist Actors (delegated to by Nova-LeadQA):** Nova-SpecializedBugInvestigator, Nova-SpecializedFixVerifier.
**Collaborating Lead (via Nova-Orchestrator):** Nova-LeadDeveloper (for implementing fixes).

**Pre-requisites by Nova-LeadQA:**
- A `CustomData ErrorLogs:[BugKey]` (key) entry exists in ConPort with initial details (symptoms, repro steps if known, environment). If not, Nova-LeadQA instructs Nova-SpecializedTestExecutor or Nova-SpecializedConPortSteward (via LeadArchitect) to create it first using `use_mcp_tool` (`tool_name: 'log_custom_data'`, `category: 'ErrorLogs'`).

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator for a specific bug, or self-initiated for new bugs from its team):**

**Phase BIR.1: Detailed Investigation & Root Cause Analysis (RCA)**

1.  **Nova-LeadQA: Plan Investigation & Delegate to Nova-SpecializedBugInvestigator**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Log/Update main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'` or `update_progress`): "Bug Lifecycle: `ErrorLogs:[BugKey]`", Status: "INVESTIGATION_ACTIVE". Let this be `[BugProgressID]`.
        *   Create/Update `CustomData LeadPhaseExecutionPlan:[BugProgressID]_QAPlan` (key) using `use_mcp_tool`. Initial plan items:
            1.  Detailed RCA by BugInvestigator.
            2.  Review RCA and Request Fix (LeadQA).
            3.  Fix Verification by FixVerifier.
            4.  Closure & Lessons Learned.
        *   Review existing `ErrorLogs:[BugKey]` (key) entry using `use_mcp_tool` (`tool_name: 'get_custom_data'`).
    *   **Task:** "Perform detailed investigation and Root Cause Analysis for `ErrorLogs:[BugKey]`."
    *   **`new_task` message for Nova-SpecializedBugInvestigator:**
        ```json
        {
          "Context_Path": "[ProjectName] (BugLifecycle_[BugKey]) -> RCA (BugInvestigator)",
          "Overall_QA_Phase_Goal": "Investigate, facilitate fix, and verify `ErrorLogs:[BugKey]`.",
          "Specialist_Subtask_Goal": "Conduct detailed RCA for `ErrorLogs:[BugKey]` ([Symptom_From_ErrorLog]).",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[BugProgressID]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
            "Target ErrorLog: `CustomData ErrorLogs:[BugKey]` (key). Review all current details using `use_mcp_tool` (`tool_name: 'get_custom_data'`).",
            "1. Attempt to reproduce the bug consistently in the environment specified in the ErrorLog or `ProjectConfig:ActiveConfig.testing_preferences.default_test_env`. Document exact steps if different from ErrorLog.",
            "2. Analyze relevant application logs (`read_file` - paths from `ProjectConfig:ActiveConfig.logging_paths` or ErrorLog), system logs, and if necessary, inspect related source code (read-only using `search_files`, `list_code_definition_names`) to identify failure points.",
            "3. Consult related ConPort items using `use_mcp_tool`: `Decisions` (integer `id`), `SystemArchitecture` (key), `APIEndpoints` (key), recent `Progress` (integer `id`) on related features that might have introduced the bug (use `get_linked_items` on ErrorLog or related features if links exist).",
            "4. Formulate a clear Root Cause Hypothesis / Confirmed Root Cause.",
            "5. To update the `CustomData ErrorLogs:[BugKey]` (key) entry: First use `get_custom_data` to retrieve the current object. Then, create a new JSON object by modifying the retrieved value. Finally, use `log_custom_data` to overwrite the entry with your updated object, which MUST include:",
            "   - Confirmed/refined `reproduction_steps`.",
            "   - Detailed `investigation_notes` (what was checked, tools used, findings).",
            "   - A `root_cause_analysis` section in the value object.",
            "   - Updated `initial_hypothesis` or a new `confirmed_root_cause` field in the value object.",
            "   - An updated `status` field, e.g., 'INVESTIGATION_COMPLETE_RCA_FOUND' or 'INVESTIGATION_BLOCKED_NEED_MORE_INFO'."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[BugProgressID_as_string]",
            "ErrorLog_To_Investigate_Key": "[BugKey]",
            "ProjectConfig_Ref_For_Logs_Env": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["logging_paths", "testing_preferences.default_test_env"] },
            "Relevant_Code_Module_Hints_From_LeadQA": "[Optional]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that `ErrorLogs:[BugKey]` (key) is updated with RCA.",
            "Summary of the Root Cause.",
            "Any suggestions for fix approach (optional)."
          ]
        }
        ```
    *   **Nova-LeadQA Action after Specialist's `attempt_completion`:** Review RCA. To update `ErrorLogs:[BugKey]` status to 'AWAITING_FIX_COORDINATION', use the `get`/`log` pattern.

**Phase BIR.2: Fix Coordination & Implementation (Involves Nova-Orchestrator & Nova-LeadDeveloper)**

2.  **Nova-LeadQA: Request Fix from Development via Nova-Orchestrator**
    *   **DoR Check:** RCA complete in `ErrorLogs:[BugKey]` (key), root cause points to a code defect.
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Update `ErrorLogs:[BugKey]` (key) status to "AWAITING_FIX" using `use_mcp_tool` (`get_custom_data` then `log_custom_data`).
        *   In its `attempt_completion` to Nova-Orchestrator (if this bug investigation was a delegated phase), or in a new direct communication if LeadQA initiated this workflow for a newly found bug:
            *   Report: "`ErrorLogs:[BugKey]` RCA complete. Root Cause: [Summary from ErrorLog]. Requesting fix implementation by Nova-LeadDeveloper."
            *   Provide `ErrorLogs:[BugKey]` (key) as reference.
    *   **Nova-Orchestrator then delegates fix to Nova-LeadDeveloper** (using a process similar to `WF_ORCH_CRITICAL_BUG_RESOLUTION_PROCESS_001.md` Phase CB.2, but for any severity). Nova-LeadDeveloper's team implements and unit tests the fix, then reports completion back to Nova-Orchestrator.

**Phase BIR.3: Fix Verification**

3.  **Nova-LeadQA: Receive Fix Confirmation & Delegate Verification to Nova-SpecializedFixVerifier**
    *   **Actor:** Nova-LeadQA
    *   **Action:** Nova-Orchestrator informs Nova-LeadQA that a fix for `ErrorLogs:[BugKey]` (key) is ready for verification (providing commit details/PR link if available from Nova-LeadDeveloper).
    *   Update `ErrorLogs:[BugKey]` (key) status to "AWAITING_VERIFICATION" using `use_mcp_tool` (`get_custom_data` then `log_custom_data`).
    *   Update `[BugProgressID]_QAPlan`.
    *   **Task:** "Verify the deployed fix for `ErrorLogs:[BugKey]`."
    *   **`new_task` message for Nova-SpecializedFixVerifier:**
        ```json
        {
          "Context_Path": "[ProjectName] (BugLifecycle_[BugKey]) -> FixVerification (FixVerifier)",
          "Overall_QA_Phase_Goal": "Verify fix for `ErrorLogs:[BugKey]`.",
          "Specialist_Subtask_Goal": "Verify fix for `ErrorLogs:[BugKey]` ([Symptom_From_ErrorLog]).",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[BugProgressID]`.",
            "Target ErrorLog: `CustomData ErrorLogs:[BugKey]` (key). Review original issue and RCA using `use_mcp_tool` (`tool_name: 'get_custom_data'`).",
            "Fix Details from Dev (provided by LeadQA): [Summary of fix, commit ID, deployed environment info].",
            "1. Execute original reproduction steps from `ErrorLogs:[BugKey]`. Confirm issue is GONE.",
            "2. Execute any specific verification test cases defined in the `ErrorLogs` (key) or related `TestPlans` (key).",
            "3. Perform targeted regression testing around the fix area to check for new issues.",
            "4. If fix confirmed AND no regressions: Update `ErrorLogs:[BugKey]` (key). First `get_custom_data`, then `log_custom_data` with a new value object where `status` is `RESOLVED` and you've added detailed `verification_notes` (what was tested, build version).",
            "5. If fix NOT confirmed (bug still present): Update `ErrorLogs:[BugKey]` (key) status to `FAILED_VERIFICATION` (or `REOPENED`) using the `get`/`log` pattern, adding detailed failure notes.",
            "6. If fix confirmed BUT a NEW regression is found: Update original `ErrorLogs:[BugKey]` status to `RESOLVED` with notes about the regression. Then, log the NEW regression as a separate `CustomData ErrorLogs:[new_key]` entry (R20 compliant, including `source_task_id` as your current `Progress` ID string) using `use_mcp_tool` (`tool_name: 'log_custom_data'`)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[BugProgressID_as_string]",
            "ErrorLog_To_Verify_Key": "[BugKey]",
            "Fix_Details_And_Deployed_Env_From_LeadQA": "[...]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Final status of `ErrorLogs:[BugKey]` (RESOLVED or FAILED_VERIFICATION/REOPENED).",
            "Key(s) of any NEW regression `ErrorLogs` logged.",
            "Summary of verification steps and outcome."
          ]
        }
        ```
    *   **Nova-LeadQA Action after Specialist's `attempt_completion`:** Review verification. Update `[BugProgressID]_QAPlan` and specialist `Progress`.

**Phase BIR.4: Closure & Learning**

4.  **Nova-LeadQA: Process Verification Outcome**
    *   **Actor:** Nova-LeadQA
    *   **Condition:** If `ErrorLogs:[BugKey]` (key) status is `RESOLVED`:
        *   Update main `Progress` (`[BugProgressID]`) to DONE using `use_mcp_tool`.
        *   Coordinate update of `active_context.open_issues` with Nova-Orchestrator.
        *   **Delegate to Nova-SpecializedBugInvestigator (or self, or ConPortSteward):** "Draft `LessonsLearned` (key) entry for `ErrorLogs:[BugKey]` (R21 compliant) using `use_mcp_tool` (`tool_name: 'log_custom_data'`, `category: 'LessonsLearned'`). Link it to the `ErrorLogs:[BugKey]`."
        *   Inform Nova-Orchestrator of successful resolution.
    *   **Condition:** If `ErrorLogs:[BugKey]` (key) status is `FAILED_VERIFICATION` or `REOPENED`:
        *   Update main `Progress` (`[BugProgressID]`) to "BLOCKED_FIX_FAILED_VERIFICATION" using `use_mcp_tool`.
        *   Inform Nova-Orchestrator, providing details from FixVerifier. Orchestrator will re-engage Nova-LeadDeveloper. Loop back to Phase BIR.2 of this workflow.
    *   **Output:** Bug resolved or re-routed for further fixing.

5.  **Nova-LeadQA: `attempt_completion` to Nova-Orchestrator (if this was a delegated phase)**
    *   **Actor:** Nova-LeadQA
    *   **Action:** Report final outcome for `ErrorLogs:[BugKey]` (key).

**Key ConPort Items Involved:**
- CustomData ErrorLogs:[BugKey] (key): Heavily used and updated throughout.
- Progress (integer `id`): For LeadQA's overall management of this bug, and for specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[BugProgressID]_QAPlan (key).
- Decisions (integer `id`): (Read) Related to feature that bugged. (Write) For triage or complex fix strategies.
- CustomData LessonsLearned:[key]: Created upon successful resolution of significant bugs.
- ActiveContext (`open_issues` list is updated).