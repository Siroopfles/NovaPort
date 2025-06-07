# Workflow: ConPort Schema Proposal (WF_ARCH_CONPORT_SCHEMA_PROPOSAL_001_v1)

**Goal:** To formally propose a new standard `CustomData` category, or significant changes/additions to the structure or usage guidelines of existing ConPort entities, and log this proposal in ConPort for review and potential adoption.

**Primary Actor:** Nova-LeadArchitect (Can be initiated by LeadArchitect based on project needs, `LessonsLearned`, or by Nova-Orchestrator if a system-wide need for schema evolution is identified).
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
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   **If New Category:**
            *   Define `ProposedCategoryName` (e.g., "CIBuildResults", "UserStories").
            *   Write a clear `Description` (purpose, what it stores, why it's needed).
            *   Provide `ExampleKeys` (1-3 typical keys, e.g., "Build_123_Results", "Story_US456_Details").
            *   Describe `ExpectedValueStructure` (e.g., "JSON object with fields: `build_id` (string), `status` (string: success/failure), `test_summary` (object), `artifact_paths` (array of strings)").
            *   List `PotentialBenefits` of adding this category (e.g., "Standardized CI/CD reporting", "Better tracking of user story evolution").
        *   **If Modifying Existing Entity/Category:**
            *   Identify `EntityOrCategoryToModify` (e.g., "Decisions", "CustomData:ErrorLogs").
            *   Describe `ProposedChanges` (e.g., "Add new optional field `review_status` (string: 'pending', 'approved', 'rejected') to Decisions entity schema", "Standardize key naming for APIEndpoints to include version suffix like `_v1`").
            *   Provide `RationaleForChange` and `PotentialBenefitsOrImpacts`.
    *   **ConPort Action:**
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "Develop ConPort Schema Proposal: [ProposalName]". Let this be `[SPProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[SPProgressID]_ArchitectPlan` (key) using `use_mcp_tool`. Main step: Delegate logging to ConPortSteward.
        *   Log a `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`) outlining the intent to propose this schema change, with initial rationale and benefits. Link this Decision to `[SPProgressID]`.
    *   **Output:** Detailed specification of the schema proposal, ready for logging. `[SPProgressID]` known.

**Phase SP.2: Logging Proposal by Nova-SpecializedConPortSteward**

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Schema Proposal**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Log the detailed schema proposal into ConPort `CustomData` category `ConPortSchema`."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (SchemaProposal) -> LogProposal (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Develop and log ConPort Schema Proposal: [ProposalName_From_LeadArchitect].",
          "Specialist_Subtask_Goal": "Log the schema proposal details to ConPort category `ConPortSchema`.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[SPProgressID]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
            "Create a new `CustomData` entry using `use_mcp_tool` (`tool_name: 'log_custom_data'`, `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'category': 'ConPortSchema', ...}`).",
            "  - Key: `ProposedSchemaChange_[YYYYMMDD]_[ProposalNameShort_From_LeadArchitect]` (e.g., `ProposedSchemaChange_20240115_NewCIResultsCategory`).",
            "  - Value (JSON Object): {",
            "      \"proposal_name\": \"[Full_Proposal_Name_From_LeadArchitect]\",",
            "      \"proposal_date\": \"[Current_YYYY-MM-DD]\",",
            "      \"proposed_by_mode\": \"Nova-LeadArchitect\",",
            "      \"change_type\": \"[NewCategory | ModifyEntity | NewField | StandardizeUsage - from LeadArchitect]\",",
            "      \"details\": { /* Structure depends on change_type, content from LeadArchitect */",
            "        // If NewCategory:",
            "        \"proposed_category_name\": \"[Name]\",",
            "        \"description\": \"[...Purpose...]\",",
            "        \"example_keys\": [\"key1\", \"key2\"],",
            "        \"expected_value_structure_desc\": \"JSON object with fields A, B...\",",
            "        // If ModifyEntity or NewField:",
            "        \"target_entity_or_category\": \"[e.g., Decisions, CustomData:ErrorLogs]\",",
            "        \"proposed_modification_details\": \"[Description of change, e.g., Add field 'review_status' (string: 'pending', 'approved', 'rejected') to Decisions entity schema. Default: 'pending'.]\"",
            "       },",
            "      \"rationale_and_benefits\": \"[Rationale_Text_From_LeadArchitect]\",",
            "      \"potential_impacts_or_migration_notes\": \"[Impacts_Text_From_LeadArchitect, e.g., Existing items might need backfill. No direct code impact expected.]\",",
            "      \"status\": \"Proposed\" // Other statuses: UnderReview, Approved, Implemented, Rejected, Deprecated",
            "    }",
            "Ensure all fields in the value object are complete and clearly describe the proposal."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[SPProgressID_as_string]",
            "Proposal_Details_Structured_From_LeadArchitect": "{ /* All details from LeadArchitect's Step 1, matching the value structure above */ }",
            "ProposalNameShort_For_Key_From_LeadArchitect": "[e.g., NewCIResultsCat]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "ConPort key of the created `ConPortSchema` entry (e.g., `ProposedSchemaChange_20240115_NewCIResultsCategory`)."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged proposal using `use_mcp_tool` (`tool_name: 'get_custom_data'`). Update `[SPProgressID]_ArchitectPlan` and specialist `Progress`.

**Phase SP.3: Finalization & Reporting by Nova-LeadArchitect**

3.  **Nova-LeadArchitect: Finalize Proposal Process**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Update main `Progress` (`[SPProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "ConPort Schema Proposal '[ProposalName]' developed and logged as `ConPortSchema:[ProposalKey]`."
        *   (If tasked by Nova-Orchestrator) Prepare to report the proposal completion.
        *   (Internal step for LeadArchitect) If this proposal needs wider discussion or approval from other Leads, Nova-LeadArchitect would typically request Nova-Orchestrator to facilitate this. The `ConPortSchema:[ProposalKey]` status would then be updated by ConPortSteward based on the outcome of such discussions (e.g., to 'UnderReview', 'Approved').
    *   **Output:** Schema proposal logged and ready for review/action.

4.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator (if this was a delegated phase)**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Report completion, providing the ConPort key of the `ConPortSchema` proposal. State that the proposal is logged and its current status (e.g., "Proposed, awaiting wider review if necessary").

**Key ConPort Items Created/Updated:**
- Progress (integer `id`): For the overall task and specialist subtask.
- CustomData LeadPhaseExecutionPlan:[SPProgressID]_ArchitectPlan (key).
- Decisions (integer `id`): To initiate the proposal and document its rationale.
- CustomData ConPortSchema:[Key] (key): The schema proposal itself.