# Workflow: Bug Investigation to Resolution Cycle (WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1)

**Goal:** To manage the lifecycle of a reported bug from initial investigation, root cause analysis, coordination of fix, and verification of resolution.

**Primary Actor:** Nova-LeadQA
**Primary Specialist Actors:** Nova-SpecializedBugInvestigator, Nova-SpecializedFixVerifier
**Collaborating Lead (via Nova-Orchestrator):** Nova-LeadDeveloper

**Pre-requisites by Nova-LeadQA:**

- A `CustomData ErrorLogs:[BugKey]` entry exists in ConPort.

**Reference Milestones for your Single-Step Loop:**

**Milestone BIR.0: Pre-flight & Readiness Check**

- **Goal:** Verify that the bug report is valid and in a state that requires investigation.
- **Suggested Lead Action:**
  1.  Your first action MUST be a "Definition of Ready" check.
  2.  Use `use_mcp_tool` to retrieve the `ErrorLogs:[BugKey]` item.
  3.  **Gated Check:**
      - **Failure:** If the item does not exist or its status is already 'RESOLVED' or 'CLOSED', immediately `attempt_completion` with a `NOTICE:` or `BLOCKER:` status to `Nova-Orchestrator`. Do not proceed.
      - **Success:** If the bug is open and requires investigation, proceed to the next milestone.

**Milestone BIR.1: Detailed Investigation & Root Cause Analysis (RCA)**

- **Goal:** Perform a detailed investigation to find the bug's root cause.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **LeadQA Action:** Log a main `Progress` item for this bug's lifecycle.
  2.  **Delegate to `Nova-SpecializedBugInvestigator`:**
      - **Subtask Goal:** "Conduct detailed RCA for `ErrorLogs:[BugKey]`."
      - **Briefing Details:**
        - Provide the `ErrorLogs` key to investigate.
        - Instruct the specialist to attempt reproduction, analyze logs/code (read-only), and consult related ConPort items.
        - The primary deliverable is an **updated** `ErrorLogs` item in ConPort containing detailed `investigation_notes`, a clear `root_cause_analysis`, and a new `status` (e.g., `AWAITING_FIX`).
        - The specialist should return confirmation of the update and a summary of the root cause.

**Milestone BIR.2: Fix Coordination**

- **DoR Check:** RCA is complete and the root cause points to a code defect.
- **Goal:** Request a fix from the development team via the Orchestrator.
- **Suggested Lead Action:**
  1.  Update the `ErrorLogs:[BugKey]` status to 'AWAITING_FIX'.
  2.  In your `attempt_completion` (if this is part of a larger phase) or in a direct communication with `Nova-Orchestrator`, report that the RCA is complete and a fix is required from `Nova-LeadDeveloper`. Provide the `ErrorLogs` key as a reference.
  3.  **Pause this workflow.** Await notification from `Nova-Orchestrator` that a fix has been implemented and is ready for verification.

**Milestone BIR.3: Fix Verification**

- **DoR Check:** Notification received from `Nova-Orchestrator` that a fix is deployed to a test environment.
- **Goal:** Verify the deployed fix and check for regressions.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **LeadQA Action:** Update the `ErrorLogs:[BugKey]` status to 'AWAITING_VERIFICATION'.
  2.  **Delegate to `Nova-SpecializedFixVerifier`:**
      - **Subtask Goal:** "Verify the deployed fix for `ErrorLogs:[BugKey]`."
      - **Briefing Details:**
        - Provide the `ErrorLogs` key and details of the fix (e.g., commit ID, deployed build version).
        - Instruct the specialist to execute the original reproduction steps to confirm the fix.
        - Instruct them to perform targeted regression testing around the fix area.
        - Based on the outcome, they must update the `ErrorLogs` item's status to either `RESOLVED` or `FAILED_VERIFICATION`/`REOPENED`, including detailed `verification_notes`.
        - If a new regression is found, they must log a new, separate `ErrorLogs` item for it.
        - The specialist returns the final status and keys of any new bugs logged.

**Milestone BIR.4: Closure & Learning**

- **Goal:** Finalize the bug lifecycle and capture any learnings.
- **Suggested Lead Action & Specialist Sequence:**
  1.  **Process Verification Outcome:**
      - **If RESOLVED:** Update the main `Progress` to 'DONE'. Coordinate with `Nova-Orchestrator` to update `active_context.open_issues`.
      - **Delegate to `Nova-SpecializedBugInvestigator` or `ConPortSteward`:** "Draft a `LessonsLearned` entry for `ErrorLogs:[BugKey]`."
      - **If FAILED_VERIFICATION:** Update `Progress` to 'BLOCKED'. Inform `Nova-Orchestrator` to re-engage `Nova-LeadDeveloper`. Loop back to Milestone BIR.2.
  2.  **Report to Orchestrator:** Use `attempt_completion` to report the final outcome of the bug lifecycle.

**Key ConPort Items Involved:**

- CustomData ErrorLogs:[BugKey] (key)
- Progress (integer `id`)
- CustomData LessonsLearned:[key] (key)
- ActiveContext (`open_issues` list)
