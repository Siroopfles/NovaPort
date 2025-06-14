# Workflow: ConPort Schema Proposal (WF_ARCH_CONPORT_SCHEMA_PROPOSAL_001_v1)

**Goal:** To formally propose a new standard `CustomData` category, or significant changes/additions to the structure or usage guidelines of existing ConPort entities, and log this proposal in ConPort for review and potential adoption.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- A recurring type of information is identified that doesn't fit well into existing ConPort categories.
- `LessonsLearned` suggest a new structured way of capturing information would improve processes.
- Inconsistent use of a category highlights the need for a clearer schema.

**Reference Milestones for your Single-Step Loop:**

**Milestone SP.1: Proposal Design & Justification**
*   **Goal:** Define all elements of the schema proposal.
*   **Suggested Lead Action:**
    1.  **Define Core Elements:**
        *   If proposing a new category, define its name, description, example keys, and expected value structure.
        *   If modifying an existing entity, specify the target and the exact proposed changes.
        *   Write a clear rationale and list the potential benefits.
    2.  **Log Intent:** Log a main `Progress` item for this proposal cycle and a `Decision` to formally initiate the proposal, linking the two.

**Milestone SP.2: Logging Proposal**
*   **Goal:** Log the detailed schema proposal into the ConPort `ConPortSchema` category.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedConPortSteward`:**
        *   **Subtask Goal:** "Log the detailed schema proposal to the ConPort `ConPortSchema` category."
        *   **Briefing Details:**
            *   Provide all proposal details in a structured format.
            *   Instruct the specialist to use `log_custom_data` with `category: "ConPortSchema"` and a descriptive key (e.g., `ProposedSchemaChange_[YYYYMMDD]_[ProposalName]`).
            *   The `value` object must be a structured JSON containing all details of the proposal, with an initial `status` of "Proposed".
            *   The specialist should return the key of the created `ConPortSchema` entry.

**Milestone SP.3: Finalization & Reporting**
*   **Goal:** Close out the proposal process and report completion.
*   **Suggested Lead Action:**
    1.  **Verify:** Use `get_custom_data` to verify the specialist's work.
    2.  **Update Progress:** Update the main `Progress` item for the proposal cycle to 'DONE'.
    3.  **Report:** If this was a delegated task, use `attempt_completion` to report to `Nova-Orchestrator`, providing the key of the new `ConPortSchema` proposal. The proposal is now ready for wider review.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData ConPortSchema:[Key] (key)