# Workflow: Generate Knowledge Graph Visualization (WF_ARCH_GENERATE_KNOWLEDGE_GRAPH_VISUALIZATION_001_v1)

**Goal:** To generate a Mermaid.js diagram representing a slice of the ConPort knowledge graph, centered on a specific item, to help visualize dependencies and relationships.

**Primary Actor:** Nova-LeadArchitect (can be initiated by user/Orchestrator request)
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- A user or Orchestrator requests a visualization of a feature's dependencies: "Show me a diagram of everything related to Feature X."
- An architect or developer needs to understand the impact of changing a specific component.

**Pre-requisites by Nova-LeadArchitect:**
- A central ConPort item (the "root" of the graph) is identified by its type and ID/key.

**Phases & Steps (managed by Nova-LeadArchitect):**

**Phase GV.1: Graph Traversal & Data Gathering**

1.  **Nova-LeadArchitect: Plan Visualization**
    *   **Action:**
        *   Log a main `Progress` (integer `id`) item for this task: "Generate Knowledge Graph for [Item]" using `use_mcp_tool`. Let this be `[GraphProgressID]`.
        *   Delegate the graph data traversal to Nova-SpecializedConPortSteward.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Traverse Links**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Recursively fetch all items linked to the root item up to 2 levels deep."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (GraphVis) -> TraverseLinks (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Generate a knowledge graph visualization.",
          "Specialist_Subtask_Goal": "Fetch all linked ConPort items for a given root item, up to 2 levels deep.",
          "Specialist_Specific_Instructions": [
            "Log your own detailed `Progress` (integer `id`), parented to `[GraphProgressID_as_integer]`, using `use_mcp_tool`.",
            "1. **Start with the Root Item:** Use `get_linked_items` on the provided `root_item_type` and `root_item_id` to get the first level of linked items.",
            "2. **Fetch Level 2 Links:** For each item returned from the first level, perform another `get_linked_items` call to find its direct links.",
            "3. **De-duplicate and Compile:** Consolidate all unique items and the links between them into a single structured list. The list should contain objects representing each link: `{'source_id': '...', 'source_summary': '...', 'target_id': '...', 'target_summary': '...', 'relationship': '...'}`. Fetch item summaries using `get_decisions`, `get_custom_data`, etc., as needed."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[GraphProgressID_as_integer]",
            "root_item_type": "[e.g., custom_data]",
            "root_item_id": "[e.g., FeatureScope:NewCheckoutFlow_v1]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "A structured JSON list of all the links found."
          ]
        }
        ```

**Phase GV.2: Diagram Generation & Output**

3.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Generate Mermaid Diagram**
    *   **DoR Check:** The structured list of links is available from the previous step.
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Convert the structured list of links into Mermaid.js graph syntax and save it to a file."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (GraphVis) -> GenerateDiagram (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Generate a knowledge graph visualization.",
          "Specialist_Subtask_Goal": "Generate a Mermaid.js diagram from the provided link data.",
          "Specialist_Specific_Instructions": [
            "Log your own detailed `Progress` (integer `id`), parented to `[GraphProgressID_as_integer]`, using `use_mcp_tool`.",
            "1. **Start Mermaid Syntax:** Begin the file content with `graph TD`.",
            "2. **Iterate Through Links:** For each link object in the provided list:",
            "   - Sanitize the summaries and IDs to be valid Mermaid node identifiers (e.g., replace spaces and special characters).",
            "   - Create the node definitions: `SourceNode[\"Source Summary\"]`.",
            "   - Create the link definition: `SourceNode -- \"relationship\" --> TargetNode`.",
            "3. **Save to File:** Consolidate the complete Mermaid syntax into a single string and use `write_to_file` to save it to `.nova/reports/graph_visuals/[RootItemName]_graph_[YYYYMMDD].md`."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[GraphProgressID_as_integer]",
            "Structured_Link_List": "[... from previous step ...]",
            "RootItemName": "[For filename]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "The full path to the generated Markdown file containing the Mermaid diagram."
          ]
        }
        ```

**Phase GV.3: Closure**

4.  **Nova-LeadArchitect: Finalize & Report**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Update main `Progress` (`[GraphProgressID]`) to 'DONE'.
        *   Report completion to Nova-Orchestrator, providing the path to the generated diagram file.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Reads many different item types via `get_linked_items`.
- (Writes to file system, not ConPort)
