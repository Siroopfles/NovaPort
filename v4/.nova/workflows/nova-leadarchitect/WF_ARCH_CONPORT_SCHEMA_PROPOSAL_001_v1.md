# Workflow: ConPort Schema Proposal (WF_ARCH_CONPORT_SCHEMA_PROPOSAL_001_v1)

**Goal:** To formally propose a new standard `CustomData` category, or significant changes/additions to the structure or usage guidelines of existing ConPort entities, and log this proposal in ConPort for review and potential adoption.

**Primary Orchestrator Actor:** Nova-LeadArchitect (Can be initiated by LeadArchitect based on project needs, `LessonsLearned`, or by Nova-Orchestrator if a system-wide need for schema evolution is identified).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- During a project, a recurring type of information is identified that doesn't fit well into existing `standard_conport_categories`.
- `LessonsLearned` (key) suggest that a new structured way of capturing certain information would improve processes.
- Inconsistent use of an existing category highlights the need for clearer schema or guidelines.
- Nova-Orchestrator tasks Nova-LeadArchitect to investigate and propose a schema improvement.

**Pre-requisites by Nova-LeadArchitect:**
- A clear problem statement or need for the schema change/addition.
- Initial ideas about the proposed new category name, its purpose, typical keys, and value structure, or changes to existing entities.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator or self-initiated):**

**Phase SP.1: Proposal Design & Justification by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Define the Schema Proposal**
    *   **Action:**
        *   **If New Category:**
            *   Define `ProposedCategoryName`.
            *   Write a clear `Description` (purpose, what it stores).
            *   Provide `ExampleKeys` (1-3 typical keys).
            *   Describe `ExpectedValueStructure` (e.g., "JSON object with fields X, Y, Z", "Plain text", "List of strings").
            *   List `PotentialBenefits` of adding this category.
        *   **If Modifying Existing Entity/Category:**
            *   Identify `Entity/CategoryToModify`.
            *   Describe `ProposedChanges` (e.g., "Add new field 'urgency' to ErrorLogs value structure", "Standardize key naming for APIEndpoints to include version").
            *   Provide `RationaleForChange` and `PotentialBenefits/Impacts`.
    *   **ConPort:**
        *   Log main `Progress` (integer `id`) item: "Develop ConPort Schema Proposal: [ProposalName]".
        *   Create internal plan (`LeadPhaseExecutionPlan:[SPProgressID]_ArchitectPlan` (key)).
        *   Log a `Decision` (integer `id`) outlining the intent to propose this schema change, with initial rationale.
    *   **Output:** Detailed specification of the schema proposal.

**Phase SP.2: Logging Proposal by Nova-SpecializedConPortSteward**

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Schema Proposal**
    *   **Task:** "Log the detailed schema proposal into ConPort `CustomData` category `ConPortSchema`."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Develop and log ConPort Schema Proposal: [ProposalName]."
          Specialist_Subtask_Goal: "Log the schema proposal details to ConPort category `ConPortSchema`."
          Specialist_Specific_Instructions:
            - "Log your own `Progress` (integer `id`) for this subtask."
            - "Create a new `CustomData` entry with:"
            - "  Category: `ConPortSchema`"
            - "  Key: `ProposedSchemaChange_[YYYYMMDD]_[ProposalNameShort]` (e.g., `ProposedSchemaChange_20240115_NewCIResultsCategory`)"
            - "  Value (JSON Object): 
                {
                  \"proposal_name\": \"[Full Proposal Name]\",
                  \"proposal_date\": \"[Current YYYY-MM-DD]\",
                  \"proposed_by_mode\": \"Nova-LeadArchitect\",
                  \"change_type\": \"NewCategory | ModifyEntity | NewField\",
                  \"details\": { // Structure depends on change_type
                    // If NewCategory:
                    \"proposed_category_name\": \"[Name]\",
                    \"description\": \"[...Purpose...]\",
                    \"example_keys\": [\"key1\", \"key2\"],
                    \"expected_value_structure_desc\": \"JSON object with fields A, B...\",
                    // If ModifyEntity or NewField:
                    \"target_entity_or_category\": \"[e.g., Decisions, CustomData:ErrorLogs]\",
                    \"proposed_modification_details\": \"[Description of change, e.g., Add field 'review_status' to Decisions]\"
                  },
                  \"rationale_and_benefits\": \"[From LeadArchitect]\",
                  \"potential_impacts_or_migration_notes\": \"[From LeadArchitect, e.g., Existing items might need backfill]\",
                  \"status\": \"Proposed\" // Other statuses: UnderReview, Approved, Implemented, Rejected
                }"
            - "Ensure all fields in the value object are complete and clearly describe the proposal."
          Required_Input_Context_For_Specialist:
            - Proposal_Details_Structured: "[All details from LeadArchitect's Step 1]"
            - ProposalNameShort_For_Key: "[...]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "ConPort key of the created `ConPortSchema` entry."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged proposal. Update plan and progress.

**Phase SP.3: Finalization & Reporting by Nova-LeadArchitect**

3.  **Nova-LeadArchitect: Finalize Proposal Process**
    *   **Action:**
        *   Update main `Progress` (integer `id`) for "Develop ConPort Schema Proposal" to DONE.
        *   (If tasked by Nova-Orchestrator) Prepare to report the proposal.
        *   (Internal step) Schedule a (conceptual) review of this proposal if part of a larger ConPort governance process.
    *   **Output:** Schema proposal logged and ready for review/action.

4.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, providing the ConPort key of the `ConPortSchema` proposal. State that the proposal is ready for review or further action by Nova-Orchestrator or relevant stakeholders.

**Key ConPort Items Created/Updated:**
-   `Progress` (integer `id`)
-   `CustomData LeadPhaseExecutionPlan:[SPProgressID]_ArchitectPlan` (key)
-   `Decisions` (integer `id`) (to initiate the proposal)
-   `CustomData ConPortSchema:[Key]` (key) (the proposal itself)