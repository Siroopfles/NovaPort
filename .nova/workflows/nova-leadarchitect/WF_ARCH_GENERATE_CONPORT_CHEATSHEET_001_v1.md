# Workflow: Generate ConPort Cheatsheet (WF_ARCH_GENERATE_CONPORT_CHEATSHEET_001_v1)

**Goal:** To scan the current ConPort instance and generate a helpful Markdown "cheatsheet" that summarizes key data categories and workflows for user reference.

**Primary Actor:** Nova-LeadArchitect (can be initiated by user/Orchestrator request for project overview)
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- A user asks "What can I store in ConPort?" or "What are the main workflows?"
- As part of new developer onboarding (`WF_ORCH_ONBOARD_NEW_DEVELOPER_001_v1.md`).
- A periodic task to keep project documentation current.

**Pre-requisites by Nova-LeadArchitect:**
- ConPort is `[CONPORT_ACTIVE]` and contains some data (especially `DefinedWorkflows`).

**Phases & Steps (managed by Nova-LeadArchitect):**

**Phase CS.1: Data Gathering**

1.  **Nova-LeadArchitect: Plan Cheatsheet Generation**
    *   **Action:**
        *   Log a main `Progress` (integer `id`) item for this task: "Generate ConPort Cheatsheet - [Date]" using `use_mcp_tool`. Let this be `[CheatsheetProgressID]`.
        *   Delegate the data gathering and file generation to Nova-SpecializedConPortSteward.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Scan ConPort & Generate File**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Scan ConPort for all `CustomData` categories and `DefinedWorkflows`. Generate a Markdown cheatsheet and save it to `.nova/docs/`."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (Cheatsheet) -> ScanAndGenerate (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Generate a ConPort cheatsheet for the user.",
          "Specialist_Subtask_Goal": "Scan ConPort, generate a Markdown cheatsheet, and save it to `.nova/docs/conport_cheatsheet.md`.",
          "Specialist_Specific_Instructions": [
            "Log your own detailed `Progress` (integer `id`), parented to `[CheatsheetProgressID_as_integer]`, using `use_mcp_tool`.",
            "1. **Get Schema:** Use `use_mcp_tool` (`tool_name: 'get_conport_schema'`) to get a list of all tables. From this, extract the `CustomData` category names.",
            "2. **Get Workflows:** Use `use_mcp_tool` (`tool_name: 'get_custom_data'`, `category`: 'DefinedWorkflows') to retrieve all workflow definitions.",
            "3. **Draft Markdown Content - Categories:** Create a section '## ConPort CustomData Categories'. For each unique category found in the schema, create a bullet point with the category name and a placeholder for its purpose (e.g., `- **APIEndpoints**: Stores detailed API specifications.`).",
            "4. **Draft Markdown Content - Workflows:** Create a section '## Key Workflows'. For each workflow retrieved, create a table row with its name, primary owner, and description.",
            "5. **Combine and Save:** Combine all generated Markdown into a single string. Use `write_to_file` to save this content to the path `.nova/docs/conport_cheatsheet.md`, overwriting any existing file."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[CheatsheetProgressID_as_integer]",
            "Target_File_Path": ".nova/docs/conport_cheatsheet.md"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that the cheatsheet file was written.",
            "The full path to the generated file."
          ]
        }
        ```

**Phase CS.2: Closure**

3.  **Nova-LeadArchitect: Finalize & Report**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Update main `Progress` (`[CheatsheetProgressID]`) to 'DONE'.
        *   Report completion to Nova-Orchestrator, providing the path to the generated cheatsheet file.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Reads from `DefinedWorkflows` category.
- Uses `get_conport_schema` tool.
- (Writes to file system, not ConPort)
