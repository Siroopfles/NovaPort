# Workflow: Generate Knowledge Graph Visualization (WF_ARCH_GENERATE_KNOWLEDGE_GRAPH_VISUALIZATION_001_v1)

**Goal:** To generate a Mermaid.js diagram representing a slice of the ConPort knowledge graph, centered on a specific item, to help visualize dependencies and relationships.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**

- A user or Orchestrator requests a visualization of a feature's dependencies.
- An architect or developer needs to understand the impact of changing a specific component.

**Reference Milestones for your Single-Step Loop:**

**Milestone GV.1: Graph Traversal & Data Gathering**

- **Goal:** Recursively fetch all items linked to a specified root item.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **LeadArchitect Action:** Log a main `Progress` item for this task.
  2.  **Delegate to `Nova-SpecializedConPortSteward`:**
      - **Subtask Goal:** "Fetch all linked ConPort items for a given root item, up to 2 levels deep."
      - **Briefing Details:**
        - Provide the `root_item_type` and `root_item_id` to start the traversal.
        - Instruct the specialist to use `get_linked_items` recursively (up to 2 levels).
        - They should de-duplicate and compile all unique items and links into a single structured list of link objects: `{'source_id': '...', 'target_id': '...', 'relationship': '...'}`.
        - The specialist should return this structured list of links.

**Milestone GV.2: Diagram Generation & Output**

- **DoR Check:** The structured list of links is available from the previous milestone.
- **Goal:** Convert the link data into a Mermaid.js diagram and save it.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **Delegate to `Nova-SpecializedConPortSteward`:**
      - **Subtask Goal:** "Generate a Mermaid.js diagram from the provided link data and save it to a file."
      - **Briefing Details:**
        - Provide the structured list of links from the previous step.
        - Instruct the specialist to iterate through the links and generate Mermaid `graph TD` syntax.
        - They should use `write_to_file` to save the complete syntax to a file like `.nova/reports/graph_visuals/[RootItemName]_graph_[YYYYMMDD].md`.
        - The specialist should return the path to the generated file.

**Milestone GV.3: Closure**

- **Goal:** Finalize the process and report completion.
- **Suggested Lead Action:**
  1.  Update the main `Progress` item to 'DONE'.
  2.  Report completion to `Nova-Orchestrator`, providing the path to the diagram file.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- Reads many different item types via `get_linked_items`.
