# Workflow: ConPort Data Hygiene Review (WF_ARCH_CONPORT_DATA_HYGIENE_REVIEW_001_v1)

**Goal:** To periodically scan ConPort for stale or outdated information, log these items as archival candidates, and present them to the user for a decision on whether to archive them.

**Primary Actor:** Nova-LeadArchitect (can be initiated by `NovaSystemConfig` schedule or by user/Orchestrator request)
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- A scheduled task as per `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadarchitect.conport_hygiene_check_frequency_days`.
- Nova-Orchestrator delegates a "ConPort data cleanup" or "archive old items" task.
- A ConPort Health Check (`WF_ARCH_CONPORT_HEALTH_CHECK_001_v1.md`) reveals a high volume of outdated items.

**Pre-requisites by Nova-LeadArchitect:**
- ConPort is `[CONPORT_ACTIVE]`.
- (Optional) User or Orchestrator provides specific categories or date cutoffs for the review.

**Phases & Steps (managed by Nova-LeadArchitect):**

**Phase DH.1: Scan for Stale Items**

1.  **Nova-LeadArchitect: Plan Hygiene Review**
    *   **Action:**
        *   Log a main `Progress` (integer `id`) item for this task: "ConPort Data Hygiene Review - [Date]" using `use_mcp_tool`. Let this be `[HygieneProgressID]`.
        *   Delegate the scanning process to Nova-SpecializedConPortSteward.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Scan for Stale Items**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Scan ConPort for items that meet staleness criteria and log them as `ArchivalCandidates`."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (DataHygiene) -> ScanForStaleItems (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Identify and manage stale data in ConPort.",
          "Specialist_Subtask_Goal": "Scan specified ConPort categories for items older than a defined threshold and log them as `ArchivalCandidates`.",
          "Specialist_Specific_Instructions": [
            "Log your own detailed `Progress` (integer `id`), parented to `[HygieneProgressID_as_integer]`, using `use_mcp_tool`.",
            "1. **Retrieve Scan Parameters:** Get staleness criteria (e.g., `staleness_threshold_days: 180`) from `NovaSystemConfig:ActiveSettings.data_hygiene_policy` or use defaults provided by LeadArchitect.",
            "2. **Scan `Decisions`:** Use `use_mcp_tool` (`tool_name: 'get_decisions'`) to retrieve decisions older than the threshold. For each stale decision, log a new `CustomData ArchivalCandidates` entry. The `key` should be `Decision_[ID]` and the `value` should be a JSON object: `{\"original_item_type\": \"decision\", \"original_item_id\": \"[ID]\", \"reason\": \"Decision logged over [X] days ago and has no recent links.\", \"status\": \"candidate\"}`.",
            "3. **Scan `SystemArchitecture`:** Use `use_mcp_tool` (`tool_name: 'get_custom_data'`, `category`: 'SystemArchitecture') to get architecture items. Check their `last_updated_timestamp` (if available in value) against the threshold. For each stale item, log a corresponding `ArchivalCandidates` entry.",
            "4. **Compile List:** Keep a list of all `ArchivalCandidates` keys you have created."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[HygieneProgressID_as_integer]",
            "Staleness_Threshold_Days": 180,
            "Categories_To_Scan": ["Decisions", "SystemArchitecture"]
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "A list of all created `ArchivalCandidates` keys."
          ]
        }
        ```

**Phase DH.2: User Approval for Archival**

3.  **Nova-LeadArchitect: Present Archival Candidates to User**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Retrieve the list of `ArchivalCandidates` keys from the specialist's `attempt_completion`.
        *   Use `ask_followup_question` to present the list to the user (via Nova-Orchestrator) for approval.
        *   **Question:** "The data hygiene scan has identified the following items as potential candidates for archival (they will be marked as [ARCHIVED] but not deleted): `[List of ArchivalCandidate keys]`. Do you approve archiving these items?"
        *   **Suggestions:** ["Yes, archive all approved candidates.", "No, do not archive anything.", "Let me review them first."]

**Phase DH.3: Perform Archival**

4.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Perform Archival**
    *   **DoR Check:** User has approved the archival action.
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "For each approved candidate, update the original ConPort item to mark it as archived."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (DataHygiene) -> PerformArchival (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Identify and manage stale data in ConPort.",
          "Specialist_Subtask_Goal": "Update original ConPort items to mark them as archived.",
          "Specialist_Specific_Instructions": [
            "Log your own detailed `Progress` (integer `id`), parented to `[HygieneProgressID_as_integer]`, using `use_mcp_tool`.",
            "For each approved `ArchivalCandidates` key provided:",
            "  1. Retrieve the `ArchivalCandidates` item to get the original item's type and ID/key.",
            "  2. **Retrieve the original item** (e.g., `get_decisions` for a decision, `get_custom_data` for a SystemArchitecture item).",
            "  3. **Modify the item's summary/description:** Prepend `[ARCHIVED ON YYYY-MM-DD]` to the existing summary or description text.",
            "  4. **Update the original item** using the appropriate tool (`update_decision` or `log_custom_data` to overwrite).",
            "  5. **Update the `ArchivalCandidates` item's status** to 'archived'."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[HygieneProgressID_as_integer]",
            "Approved_Candidate_Keys": ["..."]
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that all approved items have been marked as archived."
          ]
        }
        ```

**Phase DH.4: Closure**

5.  **Nova-LeadArchitect: Finalize & Report**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Update main `Progress` (`[HygieneProgressID]`) to 'DONE'.
        *   Report completion to Nova-Orchestrator.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- CustomData ArchivalCandidates:[Key] (key)
- Updates to various existing ConPort items (`Decisions`, `SystemArchitecture`, etc.)
