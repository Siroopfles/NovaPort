# Workflow: ConPort Schema Migration (WF_ARCH_CONPORT_SCHEMA_MIGRATION_001_v1)

**Goal:** To migrate all ConPort `CustomData` items within a specific category from an old schema version to a new one, ensuring data integrity and consistency.

**Primary Actor:** Nova-LeadArchitect (initiates this after a `ConPortSchema` (key) proposal has been approved and a migration is needed)
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- A `CustomData ConPortSchema:[key]` entry proposing a schema change (e.g., adding a new required field, renaming a key, changing data types) has its status updated to `Approved`.
- Nova-LeadArchitect determines that existing data in the affected category needs to be back-filled or transformed to conform to the new schema.

**Pre-requisites by Nova-LeadArchitect:**
- The new schema is formally defined and approved (e.g., in a `ConPortSchema` (key) entry).
- The `CustomData` category to be migrated is clearly identified.
- The transformation logic (how to map old fields to new fields, what default values to use for new fields) is clearly defined.

**Phases & Steps (managed by Nova-LeadArchitect):**

**Phase SM.1: Planning & Delegation**

1.  **Nova-LeadArchitect: Define Migration Task**
    *   **Action:**
        *   Log a main `Progress` (integer `id`) item for this task: "ConPort Schema Migration for Category: [CategoryName]" using `use_mcp_tool`. Let this be `[MigrationProgressID]`.
        *   Log a `Decision` (integer `id`) to formally start the migration, referencing the approved `ConPortSchema` (key) proposal.
        *   Clearly define the transformation logic. For example: "For all items in `ErrorLogs` category: 1. Rename `bug_summary` field to `summary`. 2. Add new required field `priority` with a default value of 'Medium'. 3. Convert `timestamp` from string to ISO 8601 format."
        *   Delegate the migration execution to Nova-SpecializedConPortSteward.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Execute Migration**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Execute the schema migration for `CustomData` category '[CategoryName]' based on the provided transformation logic."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (SchemaMigration) -> Execute for [CategoryName] (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Migrate ConPort category '[CategoryName]' to new schema.",
          "Specialist_Subtask_Goal": "Retrieve all items from category '[CategoryName]', apply the transformation logic, and use `batch_log_items` to update them.",
          "Specialist_Specific_Instructions": [
            "Log your own detailed `Progress` (integer `id`), parented to `[MigrationProgressID_as_integer]`, using `use_mcp_tool`.",
            "1. **Retrieve All Items:** Use `use_mcp_tool` (`tool_name: 'get_custom_data'`, `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'category': '[CategoryName]'}`) to fetch all items from the target category.",
            "2. **Transform Data:** In your internal logic (without using external tools), iterate through the list of retrieved items. For each item, apply the `Transformation_Logic` provided by LeadArchitect to its `value` object. Create a new list of transformed item objects. Each object in the new list must have the 'category', 'key', and transformed 'value' fields required by the `batch_log_items` tool.",
            "3. **Batch Update Items:** Use `use_mcp_tool` (`tool_name: 'batch_log_items'`, `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'item_type': 'custom_data', 'items': [/* your list of transformed item objects */]}`). This will efficiently overwrite all the old items with their new, transformed versions.",
            "4. **Verification (Optional but Recommended):** After the batch update, retrieve a small sample (2-3 items) from the category using `get_custom_data` to verify that the new schema has been correctly applied."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[MigrationProgressID_as_integer]",
            "Category_To_Migrate": "[CategoryName]",
            "Transformation_Logic_From_LeadArchitect": [
              "Rename field 'old_field' to 'new_field'.",
              "Add new field 'added_field' with default value 'default'.",
              "For field 'timestamp', convert value from epoch seconds to ISO 8601 string."
            ]
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that the `batch_log_items` operation was executed.",
            "The number of items that were migrated.",
            "Confirmation of the optional verification step, if performed."
          ]
        }
        ```

**Phase SM.2: Closure**

3.  **Nova-LeadArchitect: Finalize & Report**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Review the specialist's report.
        *   Update the status of the original `ConPortSchema` (key) proposal item to 'Implemented'.
        *   Update main `Progress` (`[MigrationProgressID]`) to 'DONE'.
        *   Report completion to Nova-Orchestrator.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- ConPortSchema (key) (read for schema, update status)
- CustomData items within the target category (read and batch updated)


================================================
FILE: .nova/workflows/nova-orchestrator/WF_ORCH_ANALYTICAL_GRAPH_QUERY_001_v1.md
================================================
# Workflow: Analytical Graph Query (WF_ORCH_ANALYTICAL_GRAPH_QUERY_001_v1)

**Goal:** To answer a complex user question that requires traversing the ConPort knowledge graph (i.e., following links between items) and synthesizing the results.

**Primary Actor:** Nova-Orchestrator
**Delegated Utility Mode Actor:** Nova-FlowAsk

**Trigger / Recognition:**
- User asks a multi-hop question, e.g., "Show me the architectural decisions that influenced the code that fixed bug XYZ," or "What features were impacted by the decision to switch to the new payment gateway?"
- Nova-Orchestrator recognizes that a single ConPort query is insufficient and a sequence of related queries is needed.

**Pre-requisites by Nova-Orchestrator:**
- ConPort is `[CONPORT_ACTIVE]` and contains linked data.
- The user's question identifies a starting point (e.g., a bug ID, a feature name, a decision).

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase AQ.1: Query Strategy & Delegation**

1.  **Nova-Orchestrator: Plan Multi-Hop Query**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Log a `Progress` (integer `id`) item: "Analytical Graph Query: [Topic]" using `use_mcp_tool`.
        *   Deconstruct the user's question into a sequence of ConPort queries. For example, for "Show me decisions that influenced the code that fixed bug `ErrorLogs:EL-123`":
            1.  Find the `Progress` item that `tracks_fix_for` `ErrorLogs:EL-123`.
            2.  Find the `CodeSnippets` that were `implemented_by` that `Progress` item.
            3.  Find the `Decisions` that `influenced` those `CodeSnippets`.
        *   Formulate this sequence as a series of steps for `Nova-FlowAsk`.

2.  **Nova-Orchestrator -> Delegate to Nova-FlowAsk: Execute Query Sequence**
    *   **Actor:** Nova-Orchestrator
    *   **Task:** "Execute a sequence of linked ConPort queries to answer the user's question and summarize the final result."
    *   **`new_task` message for Nova-FlowAsk:**
        ```json
        {
          "Context_Path": "UserQuery (Orchestrator) -> AnalyticalQuery (FlowAsk)",
          "Subtask_Goal": "Answer user question: '[User_Question]' by executing a sequence of ConPort queries.",
          "Mode_Specific_Instructions": [
            "User's full question: '[Full_User_Question]'.",
            "You are capable of executing a sequence of `use_mcp_tool` calls. The result of one step can be used as input for the next.",
            "Execute the steps defined in `ConPort_Query_Strategy` sequentially. Use `workspace_id: 'ACTUAL_WORKSPACE_ID'` for all calls.",
            "After completing all steps, synthesize the final results into a concise, human-readable answer. Reference key ConPort items by their full identifiers.",
            "Your final answer should directly address the user's original question."
          ],
          "Required_Input_Context": {
            "Full_User_Question": "Show me decisions that influenced the code that fixed bug ErrorLogs:EL-123",
            "ConPort_Query_Strategy": [
              {
                "step": 1,
                "description": "Find the `Progress` item tracking the fix for `ErrorLogs:EL-123`.",
                "tool_name": "get_linked_items",
                "arguments": { "item_type": "custom_data", "item_id": "ErrorLogs:EL-123", "relationship_type_filter": "tracked_by_progress" }
              },
              {
                "step": 2,
                "description": "Using the Progress ID from step 1, find the `CodeSnippets` implemented by that progress.",
                "tool_name": "get_linked_items",
                "arguments": { "item_type": "progress_entry", "item_id": "{{result_of_step_1[0].target_item_id}}", "relationship_type_filter": "implements_progress" }
              },
              {
                "step": 3,
                "description": "Using the CodeSnippet keys from step 2, find the `Decisions` that influenced them.",
                "tool_name": "get_linked_items",
                "arguments": { "item_type": "custom_data", "item_id": "{{result_of_step_2[0].source_item_id}}", "relationship_type_filter": "influenced_by_decision" }
              }
            ]
          },
          "Expected_Deliverables_In_Attempt_Completion": [
            "A concise answer summarizing the findings from the query sequence.",
            "A list of the final ConPort items found (e.g., the Decision IDs)."
          ]
        }
        ```

**Phase AQ.2: Presentation**

3.  **Nova-Orchestrator: Relay Answer to User**
    *   **Actor:** Nova-Orchestrator
    *   **Action:** Present the synthesized answer from `Nova-FlowAsk`'s `attempt_completion` to the user.
    *   Ask if the answer is satisfactory or if further analysis is needed.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Reads various item types through a chain of `get_linked_items` calls.
