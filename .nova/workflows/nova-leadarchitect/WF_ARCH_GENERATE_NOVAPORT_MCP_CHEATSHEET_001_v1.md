# Workflow: Generate NovaPort-MCP Cheatsheet (WF_ARCH_GENERATE_NOVAPORT_MCP_CHEATSHEET_001_v1)

**Goal:** To scan the current NovaPort-MCP instance and generate a helpful Markdown "cheatsheet" that summarizes key data categories and workflows for user reference.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedNovaPortSteward

**Trigger / Recognition:**

- A user asks "What can I store in the database?" or "What are the main workflows?"
- As part of new developer onboarding (`WF_ORCH_ONBOARD_NEW_DEVELOPER_001_v1.md`).
- A periodic task to keep project documentation current.

**Reference Milestones for your Single-Step Loop:**

**Milestone CS.1: Data Gathering & File Generation**

- **Goal:** Scan NovaPort-MCP for relevant data and generate the cheatsheet file.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **LeadArchitect Action:** Log a main `Progress` item for this task.
  2.  **Delegate to `Nova-SpecializedNovaPortSteward`:**
      - **Subtask Goal:** "Scan NovaPort-MCP, generate a Markdown cheatsheet, and save it to `.nova/docs/novaport_mcp_cheatsheet.md`."
      - **Briefing Details:**
        - Instruct the specialist to use `get_conport_schema` to get a list of all tables and `get_custom_data` on category `DefinedWorkflows` to get all workflows.
        - They should then draft Markdown content with a section for "NovaPort-MCP CustomData Categories" and "Key Workflows".
        - Finally, instruct them to use `write_to_file` to save the complete Markdown content to `.nova/docs/novaport_mcp_cheatsheet.md`.
        - The specialist should return the path to the generated file.

**Milestone CS.2: Closure**

- **Goal:** Finalize the process and report completion.
- **Suggested Lead Action:**
  1.  Update the main `Progress` item to 'DONE'.
  2.  Report completion to `Nova-Orchestrator`, providing the path to the generated cheatsheet file.

**Key NovaPort-MCP Items Involved:**

- Progress (integer `id`)
- Reads from `DefinedWorkflows` category.
- Uses `get_conport_schema` tool.
