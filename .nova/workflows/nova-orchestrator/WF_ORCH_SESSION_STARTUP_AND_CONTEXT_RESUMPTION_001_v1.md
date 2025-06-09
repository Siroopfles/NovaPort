# Workflow: Session Startup and Context Resumption (WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1)

**Goal:** To correctly initialize Nova-Orchestrator at the start of a new user session by loading all relevant context from ConPort and the last session summary file, establishing a clear operational state.

**Primary Orchestrator Actor:** Nova-Orchestrator (executes this internally as its first set of actions)
**Utility Mode Actor (potentially delegated to by Nova-Orchestrator):** Nova-FlowAsk (for summary parsing)

**Trigger / Recognition:**
- A new user session with Nova-Orchestrator begins. This workflow is effectively Step 1.b of Nova-Orchestrator's main `task_execution_protocol`.

**Pre-requisites by Nova-Orchestrator:**
- Nova-Orchestrator has access to its own system prompt and tools.
- User has initiated interaction.

**Phases & Steps (executed by Nova-Orchestrator):**

**Phase SSU.1: Determine Workspace & ConPort DB Status**

1.  **Nova-Orchestrator: Identify Workspace**
    *   **Actor:** Nova-Orchestrator
    *   **Action:** Determine `ACTUAL_WORKSPACE_ID` from `[WORKSPACE_PLACEHOLDER]` in `system_information`.
    *   **Output:** `ACTUAL_WORKSPACE_ID` known.

2.  **Nova-Orchestrator: Check ConPort Database Existence**
    *   **Actor:** Nova-Orchestrator
    *   **Action:** Use `list_files` tool to check for `context_portal/context.db` within `ACTUAL_WORKSPACE_ID`.
        *   Tool Call: `<list_files><path>context_portal/</path></list_files>` (Relative to `ACTUAL_WORKSPACE_ID`)
    *   **Output:** Boolean indicating if `context.db` exists.

**Phase SSU.2: Load or Initialize Core ConPort Data & Configurations**

3.  **Nova-Orchestrator: Handle ConPort DB State**
    *   **Actor:** Nova-Orchestrator
    *   **Logic:**
        *   **Condition:** If `context.db` exists (from step 2):
            *   **Action:** Proceed to step 4 (Load Existing Context). Set internal ConPort status to `[CONPORT_ACTIVE]`.
        *   **Condition:** If `context.db` does NOT exist:
            *   **Action:**
                *   Inform user: "No existing ConPort database found for this workspace (`ACTUAL_WORKSPACE_ID`)."
                *   Use `ask_followup_question`:
                    *   Question: "Would you like to initialize a new ConPort database and project setup now? This involves: 1. Running the New Project Bootstrap workflow (`.nova/workflows/nova-orchestrator/WF_PROJ_INIT_001_NewProjectBootstrap.md`). 2. Setting up initial `ProjectConfig:ActiveConfig`. 3. Setting up initial `NovaSystemConfig:ActiveSettings`. I will delegate this entire setup to Nova-LeadArchitect."
                    *   Suggestions: ["Yes, delegate full setup to Nova-LeadArchitect.", "No, do not use ConPort/Nova configs this session."].
                *   If user selects "Yes":
                    *   Delegate to `Nova-LeadArchitect` using `new_task`.
                    *   **Subtask Briefing Object for Nova-LeadArchitect (schematic):**
                        ```json
                        {
                          "Context_Path": "SessionStartup -> NewConPortSetup (LeadArchitect)",
                          "Overall_Project_Goal": "Initialize new project in workspace.",
                          "Phase_Goal": "Execute full ConPort and project initialization: Bootstrap, ProjectConfig, NovaSystemConfig.",
                          "Lead_Mode_Specific_Instructions": [
                            "Execute WF_PROJ_INIT_001_NewProjectBootstrap.md (path: .nova/workflows/nova-orchestrator/WF_PROJ_INIT_001_NewProjectBootstrap.md).",
                            "After bootstrap, guide user (via Orchestrator relay) to define and log CustomData ProjectConfig:ActiveConfig.",
                            "Then, define and log default CustomData NovaSystemConfig:ActiveSettings.",
                            "Report completion of all three parts."
                          ],
                          "Required_Input_Context": {
                            "Path_To_Bootstrap_Workflow": ".nova/workflows/nova-orchestrator/WF_PROJ_INIT_001_NewProjectBootstrap.md",
                            "Path_To_Config_Setup_Workflow": ".nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md"
                           },
                          "Expected_Deliverables_In_Attempt_Completion_From_Lead": ["Confirmation of bootstrap", "Confirmation of ProjectConfig logging", "Confirmation of NovaSystemConfig logging"]
                        }
                        ```
                    *   Acknowledge to user: "Delegating full ConPort and project initialization to Nova-LeadArchitect..."
                    *   Await `attempt_completion` from Nova-LeadArchitect (via user).
                    *   If successful, set internal ConPort status to `[CONPORT_ACTIVE]`.
                *   If user selects "No":
                    *   Set internal ConPort status to `[CONPORT_INACTIVE]`. Inform user: "[CONPORT_INACTIVE] ConPort will not be used." Proceed to step 6 (skipping ConPort loads).
    *   **Output:** ConPort status (`[CONPORT_ACTIVE]` or `[CONPORT_INACTIVE]`) determined. If new setup was done, basic ConPort items exist.

4.  **Nova-Orchestrator: Load Core ConPort Contexts (if CONPORT_ACTIVE)**
    *   **Actor:** Nova-Orchestrator
    *   **Action:** If status is `[CONPORT_ACTIVE]`, use `use_mcp_tool` (`server_name: 'conport'`, `arguments` incl. `workspace_id: 'ACTUAL_WORKSPACE_ID'`) for:
        *   `tool_name: 'get_product_context'`
        *   `tool_name: 'get_active_context'`
        *   `tool_name: 'get_custom_data'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"ProjectConfig\", \"key\": \"ActiveConfig\"}`
        *   `tool_name: 'get_custom_data'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"NovaSystemConfig\", \"key\": \"ActiveSettings\"}`
        *   `tool_name: 'get_custom_data'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"DefinedWorkflows\"}`
        *   `tool_name: 'get_recent_activity_summary'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"hours_ago\": 168, \"limit_per_type\": 3}`
    *   **Output:** Core ConPort data loaded into Nova-Orchestrator's current session understanding.

5.  **Nova-Orchestrator: Verify/Delegate Missing Configurations (if CONPORT_ACTIVE)**
    *   **Actor:** Nova-Orchestrator
    *   **Action:** If `ProjectConfig:ActiveConfig` (key) or `NovaSystemConfig:ActiveSettings` (key) were not found or are incomplete after step 4:
        *   Inform user: "Essential configurations (`ProjectConfig:ActiveConfig` or `NovaSystemConfig:ActiveSettings`) are missing or incomplete from ConPort."
        *   Delegate to `Nova-LeadArchitect` using `new_task` to execute workflow `.nova/workflows/nova-orchestrator/WF_ORCH_PROJECT_CONFIG_NOVA_CONFIG_SETUP_001_v1.md`.
        *   **Subtask Briefing Object for Nova-LeadArchitect (schematic):**
            ```json
            {
              "Context_Path": "SessionStartup -> SetupMissingConfigs (LeadArchitect)",
              "Overall_Project_Goal": "Ensure workspace is fully configured.",
              "Phase_Goal": "Define and log missing ProjectConfig:ActiveConfig and/or NovaSystemConfig:ActiveSettings.",
              "Lead_Mode_Specific_Instructions": ["Execute WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md to guide user and log these configurations."],
              "Required_Input_Context": {"Path_To_Architect_Config_Workflow": ".nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md"},
              "Expected_Deliverables_In_Attempt_Completion_From_Lead": ["Confirmation of logging"]
            }
            ```
        *   Await `attempt_completion` from Nova-LeadArchitect. Re-load these configs if created using `use_mcp_tool`.
    *   **Output:** `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are confirmed to be loaded or setup.

**Phase SSU.3: Resume Previous Session State (if applicable)**

6.  **Nova-Orchestrator: Load Last Session Summary (if CONPORT_ACTIVE or user desires continuity)**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Use `list_files` to check `.nova/summary/` for `session_summary_*.md` files. Identify the most recent one.
        *   If found, use `read_file` to get its content.
        *   Delegate to `Nova-FlowAsk` using `new_task`:
            *   **Subtask Briefing Object for Nova-FlowAsk (schematic):**
                ```json
                {
                  "Context_Path": "SessionStartup -> SummarizePreviousSession (FlowAsk)",
                  "Subtask_Goal": "Extract key status, last active task, and open points from the provided previous session summary text.",
                  "Mode_Specific_Instructions": ["Parse Markdown. Identify: 1. Main project/workflow active. 2. Last major step/phase. 3. Key ConPort items changed. 4. Next steps/open questions."],
                  "Required_Input_Context": { "File_Content_To_Summarize": "[Content of the .nova/summary/file.md]" },
                  "Expected_Deliverables_In_Attempt_Completion": ["Bulleted list summary: {last_active_task: '...', last_status: '...', key_items: ['...'], next_steps_or_open_points: ['...']}"]
                }
                ```
        *   Await `attempt_completion` from Nova-FlowAsk.
    *   **Output:** Summary of previous session's state, if available.

**Phase SSU.4: Inform User & Await Instructions**

7.  **Nova-Orchestrator: Present Initial Context and Prompt for Action**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Formulate a message to the user, combining:
            *   ConPort status (`[CONPORT_ACTIVE]` or `[CONPORT_INACTIVE]`).
            *   Brief summary of loaded `ProjectConfig:ActiveConfig.project_type_hint` (key) and `NovaSystemConfig:ActiveSettings.mode_behavior.nova-orchestrator.default_dor_strictness` (key) if available.
            *   Key points from the last session summary (if available and processed).
        *   Use `ask_followup_question` to ask the user how to proceed.
            *   Question: "Session initialized. ConPort is `[Status]`. Project type hint: `[Type_from_ProjectConfig]`. Default DoR Strictness: `[DoR_from_NovaSystemConfig]`. Last session focused on `[Last Task Summary from .nova/summary/ if any]`. What would you like to work on?"
            *   Suggestions: ["Continue with [Last Task]", "Start a new major project", "Implement new feature for existing project [ProjectName]", "Debug issue [ErrorLog Key if known]", "Review project status"].
    *   **Output:** User is informed of the initialized state and provides direction for the current session. This workflow (SSU) concludes; Nova-Orchestrator proceeds with the user's chosen task.

**Key ConPort Items Read by Nova-Orchestrator (or via delegation in this workflow):**
- ProductContext (key 'product_context')
- ActiveContext (key 'active_context')
- CustomData ProjectConfig:ActiveConfig (key)
- CustomData NovaSystemConfig:ActiveSettings (key)
- CustomData DefinedWorkflows (category)
- Recent items from various categories via `get_recent_activity_summary`.