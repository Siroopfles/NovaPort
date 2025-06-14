# Workflow: ConPort Data Hygiene Review (WF_ARCH_CONPORT_DATA_HYGIENE_REVIEW_001_v1)

**Goal:** To periodically scan ConPort for stale or outdated information, log these items as archival candidates, and present them to the user for a decision on whether to archive them.

**Primary Actor:** Nova-LeadArchitect (can be initiated by `NovaSystemConfig` schedule or by user/Orchestrator request)
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**

- A scheduled task as per `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadarchitect.conport_hygiene_check_frequency_days`.
- Nova-Orchestrator delegates a "ConPort data cleanup" or "archive old items" task.
- A ConPort Health Check (`WF_ARCH_CONPORT_HEALTH_CHECK_001_v1.md`) reveals a high volume of outdated items.

**Reference Milestones for your Single-Step Loop:**

**Milestone DH.1: Scan for Stale Items**

- **Goal:** Identify and log all ConPort items that meet the project's staleness criteria.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **LeadArchitect Action:** Log a main `Progress` item for this entire review cycle.
  2.  **Delegate to `Nova-SpecializedConPortSteward`:**
      - **Subtask Goal:** "Scan ConPort for items that meet staleness criteria and log them as `ArchivalCandidates`."
      - **Briefing Details:** Instruct the specialist to:
        - Log their own `Progress` item, parented to your main review cycle progress item.
        - Retrieve scan parameters (e.g., `staleness_threshold_days`) from `NovaSystemConfig:ActiveSettings.data_hygiene_policy`.
        - Scan specified categories (e.g., `Decisions`, `SystemArchitecture`) for items older than the threshold.
        - For each stale item, log a new `CustomData ArchivalCandidates` entry with details about the original item and reason for candidacy.
        - Return a list of all created `ArchivalCandidates` keys in the `attempt_completion`.

**Milestone DH.2: User Approval for Archival**

- **Goal:** Obtain explicit user approval before archiving any items.
- **Suggested Lead Action:**
  1.  Receive the list of `ArchivalCandidates` from the `ConPortSteward`.
  2.  Use `ask_followup_question` to present this list to the user (via `Nova-Orchestrator`) for approval. The question should be clear: "The data hygiene scan has identified the following items as candidates for archival. Do you approve archiving these items?"
  3.  Provide clear suggestions like ["Yes, archive all approved candidates.", "No, do not archive anything."].

**Milestone DH.3: Perform Archival**

- **DoR Check:** User has approved the archival action.
- **Goal:** Mark all user-approved items as archived in ConPort.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **Delegate to `Nova-SpecializedConPortSteward`:**
      - **Subtask Goal:** "For each user-approved `ArchivalCandidates` key, update the original ConPort item to mark it as archived."
      - **Briefing Details:** Instruct the specialist to:
        - Log their own `Progress` item.
        - For each approved key: retrieve the `ArchivalCandidates` item, then retrieve the original item.
        - Modify the original item's summary or description to prepend `[ARCHIVED ON YYYY-MM-DD]`.
        - Use the appropriate `use_mcp_tool` command (`log_decision` or `log_custom_data`) to update the original item.
        - Update the `ArchivalCandidates` item's status to 'archived'.
        - Return a confirmation of all actions taken.

**Milestone DH.4: Finalize Cycle**

- **Goal:** Close out the review process and report completion.
- **Suggested Lead Action:**
  1.  Update the main `Progress` item for the review cycle to 'DONE'.
  2.  Report completion of the phase to `Nova-Orchestrator` in your `attempt_completion`.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- CustomData ArchivalCandidates:[Key] (key)
- Updates to various existing ConPort items (`Decisions`, `SystemArchitecture`, etc.)
