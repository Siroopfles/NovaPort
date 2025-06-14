# Workflow: Nova System Prompt Update Proposal (WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1)

**Goal:** To manage a proposed change to a Nova system prompt file (in `.roo/`) with the same rigor as application code, including rationale, user approval, and formal implementation.

**Primary Actor:** Nova-LeadArchitect
**Delegated Specialist Actor:** Nova-SpecializedWorkflowManager

**Trigger / Recognition:**
- A `LessonsLearned` item suggests a mode's behavior could be improved with a prompt change.
- A user or Lead Mode identifies a recurring issue that can be traced back to a specific rule in a system prompt.
- A strategic decision is made to alter the capabilities or constraints of a Nova mode.

**Reference Milestones for your Single-Step Loop:**

**Milestone SPU.1: Proposal & Approval**
*   **Goal:** Formally document the proposed prompt change and obtain user approval.
*   **Suggested Lead Action:**
    1.  **Log Intent:** Log a main `Progress` item for this update task.
    2.  **Define Proposal:** Log a formal `Decision` in ConPort. The `Decision` must contain:
        *   A `summary` describing the change and the problem it solves.
        *   A `rationale` explaining why the change is needed.
        *   An `implementation_details` section with a diff-like representation of the exact change.
    3.  **Request Approval:** Use `ask_followup_question` to present the proposal (referencing the `Decision` ID) to the user via `Nova-Orchestrator` for explicit approval.
    4.  **Gated Check:** Do not proceed to the next milestone without user approval. If rejected, update the `Decision` status and close the `Progress` item.

**Milestone SPU.2: Implementation**
*   **DoR Check:** User approval has been received.
*   **Goal:** Apply the approved changes to the target system prompt file.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedWorkflowManager`:**
        *   **Subtask Goal:** "Implement the approved changes to the system prompt file `.roo/system-prompt-nova-[mode_slug].md`."
        *   **Briefing Details:**
            *   Reference the `Decision` ID containing the approval and exact change details.
            *   Specify the target file path in the `.roo/` directory.
            *   Instruct the specialist to use `read_file` to get the current content and then `apply_diff` to make the precise change.
            *   Instruct for a final `read_file` self-verification step after the `apply_diff`.
            *   The specialist should return confirmation and the path to the modified file.

**Milestone SPU.3: Closure**
*   **Goal:** Finalize the update process and report completion.
*   **Suggested Lead Action:**
    1.  **Verify:** Use `read_file` to verify the specialist's file change.
    2.  **Delegate Status Update:** Instruct `Nova-SpecializedConPortSteward` to update the status of the approval `Decision` to 'IMPLEMENTED'.
    3.  **Update Progress:** Update the main `Progress` item for the update cycle to 'DONE'.
    4.  **Report:** In your `attempt_completion` to `Nova-Orchestrator`, confirm the successful implementation of the prompt update, referencing the `Decision` ID.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)