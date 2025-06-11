# Workflow: Nova System Prompt Update Proposal (WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1)

**Goal:** To manage a proposed change to a Nova system prompt file (in `.roo/`) with the same rigor as application code, including rationale, user approval, and formal implementation.

**Primary Actor:** Nova-LeadArchitect
**Delegated Specialist Actor:** Nova-SpecializedWorkflowManager (role expanded to include managing `.roo/` files)

**Trigger / Recognition:**
- A `LessonsLearned` (key) item suggests a mode's behavior could be improved with a prompt change.
- A user or Lead Mode identifies a recurring issue or inefficiency that can be traced back to a specific rule or instruction in a system prompt.
- A strategic decision is made to alter the capabilities or constraints of a Nova mode.

**Pre-requisites by Nova-LeadArchitect:**
- A clear problem statement and a proposed solution in the form of a change to a specific `system-prompt-nova-*.md` file.

**Phases & Steps (managed by Nova-LeadArchitect):**

**Phase SPU.1: Proposal & Approval**

1.  **Nova-LeadArchitect: Define Prompt Change Proposal**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Log a main `Progress` (integer `id`) for this task using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"System Prompt Update Proposal: [ModeSlug]\"}`). Let this be `[PromptUpdateProgressID]`.
        *   Log a formal `Decision` (integer `id`) in ConPort outlining the proposed change. The `arguments` for the `use_mcp_tool` (`tool_name: 'log_decision'`) call MUST include:
            *   `workspace_id`: "ACTUAL_WORKSPACE_ID"
            *   `summary`: "Propose update to `system-prompt-nova-[mode_slug].md` to address [problem]."
            *   `rationale`: "The current prompt leads to [describe negative behavior]. The proposed change is expected to [describe positive outcome]."
            *   `implementation_details`: A diff-like representation of the exact change (what to remove, what to add).
            *   `tags`: ["#system_prompt", "#governance", "#[mode_slug]"]
        *   Link this `Decision` to `[PromptUpdateProgressID]` using `use_mcp_tool` (`tool_name: 'link_conport_items'`).
    *   **Output:** Proposal is formally documented in ConPort.

2.  **Nova-LeadArchitect: Request User Approval**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Present the proposal to Nova-Orchestrator to relay to the user.
        *   Use `ask_followup_question`:
            *   Question: "I propose an update to the system prompt for `[ModeSlug]` to address [problem]. The details and rationale are in `Decision:[DecisionID]`. Do you approve this change?"
            *   Suggestions: ["Yes, I approve the change.", "No, I reject the change.", "I have questions about the implications."]
    *   **DoR Check for next step:** Await explicit user approval. If rejected, update the `Decision` (integer `id`) status to 'REJECTED' (using `log_decision` with the existing `decision_id`) and close the `Progress` item.

**Phase SPU.2: Implementation**

3.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedWorkflowManager: Implement Prompt Change**
    *   **DoR Check:** User approval has been received.
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Implement the approved changes to the system prompt file `.roo/system-prompt-nova-[mode_slug].md`."
    *   **`new_task` message for Nova-SpecializedWorkflowManager:**
        ```json
        {
          "Context_Path": "[ProjectName] (SystemPromptUpdate) -> ImplementChange (WorkflowManager)",
          "Overall_Architect_Phase_Goal": "Update system prompt for `[ModeSlug]` as per Decision `[DecisionID]`.",
          "Specialist_Subtask_Goal": "Apply approved changes to the file `.roo/system-prompt-nova-[mode_slug].md`.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[PromptUpdateProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Subtask: Implement prompt change for `[ModeSlug]`\", \"parent_id\": [PromptUpdateProgressID_as_integer]} `).",
            "1. **Reference `Decision:[DecisionID_as_integer]`** using `use_mcp_tool` (`tool_name: 'get_decisions'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"id_filter\": [DecisionID_as_integer]}`) to get the exact change details from the `implementation_details` field.",
            "2. **Target File:** `.roo/system-prompt-nova-[mode_slug].md`",
            "3. **Use `read_file`** to get the current content of the target prompt file to ensure accuracy before applying changes.",
            "4. **Use `apply_diff`** to apply the changes as specified in the Decision's `implementation_details`. Ensure the `diff` block is correctly formatted.",
            "5. **Final Self-Verification:** After applying the diff, use `read_file` again on the modified section to confirm the change was applied correctly."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[PromptUpdateProgressID_as_integer]",
            "Target_Mode_Slug": "[mode_slug]",
            "Decision_ID_as_integer": "[DecisionID_as_integer]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that the file `.roo/system-prompt-nova-[mode_slug].md` has been successfully modified.",
            "The path to the modified file."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:**
        *   Verify the file change using `read_file`.
        *   Update the `Decision:[DecisionID]` status to 'IMPLEMENTED' using `use_mcp_tool` (`tool_name: 'log_decision'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"decision_id\": [DecisionID_as_integer], \"status\": \"IMPLEMENTED\"}`).

**Phase SPU.3: Closure**

4.  **Nova-LeadArchitect: Finalize & Report**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Update main `Progress` (`[PromptUpdateProgressID]`) to 'DONE' using `use_mcp_tool` (`tool_name: 'update_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"progress_id\": [PromptUpdateProgressID_as_integer], \"status\": \"DONE\"}`).
        *   Report completion to Nova-Orchestrator.
    *   **`attempt_completion` to Nova-Orchestrator:**
        *   `result`: "System prompt update for `[ModeSlug]` has been successfully implemented as per `Decision:[DecisionID]`. The change is now active for future sessions."

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)