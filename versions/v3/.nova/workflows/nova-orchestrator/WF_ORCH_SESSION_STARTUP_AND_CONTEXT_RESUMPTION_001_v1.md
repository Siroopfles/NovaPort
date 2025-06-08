# Workflow: Session Startup and Context Resumption (WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1)

**Goal:** To correctly initialize Nova-Orchestrator at the start of a new user session by loading all relevant context from ConPort and the last session summary file, establishing a clear operational state.

**Primary Orchestrator Actor:** Nova-Orchestrator (executes this internally)
**Utility Mode Actor (potentially delegated to by Nova-Orchestrator):** Nova-FlowAsk (for summary parsing)

**Trigger / Recognition:**
- A new user session with Nova-Orchestrator begins. This workflow is step 1.b of Nova-Orchestrator's main `task_execution_protocol`.

**Pre-requisites by Nova-Orchestrator:**
- Nova-Orchestrator has access to its own system prompt and tools.
- User has initiated interaction.

**Phases & Steps (executed by Nova-Orchestrator):**

**Phase SSU.1: Determine Workspace & ConPort DB Status**

1.  **Nova-Orchestrator: Identify Workspace**
    *   **Action:** Determine `ACTUAL_WORKSPACE_ID` from `[WORKSPACE_PLACEHOLDER]` in `system_information`.
    *   **Output:** `ACTUAL_WORKSPACE_ID` known.

2.  **Nova-Orchestrator: Check ConPort Database Existence**
    *   **Action:** Use `list_files` tool to check for `context_portal/context.db` within `ACTUAL_WORKSPACE_ID`.
    *   **Output:** Boolean indicating if `context.db` exists.

**Phase SSU.2: Load or Initialize Core ConPort Data & Configurations**

3.  **Nova-Orchestrator: Handle ConPort DB State**
    *   **Condition:** If `context.db` exists (from step 2):
        *   **Action:** Proceed to step 4 (Load Existing Context). Set internal ConPort status to `[CONPORT_ACTIVE]`.
    *   **Condition:** If `context.db` does NOT exist:
        *   **Action:**
            *   Inform user: "No existing ConPort database found for this workspace (`ACTUAL_WORKSPACE_ID`)."
            *   Use `ask_followup_question`: "Would you like to initialize a new ConPort database and project setup now? This involves: 1. Running the New Project Bootstrap workflow, 2. Setting up initial `ProjectConfig:ActiveConfig`, 3. Setting up initial `NovaSystemConfig:ActiveSettings`. I will delegate this entire setup to Nova-LeadArchitect." Suggestions: ["Yes, delegate full setup to Nova-LeadArchitect.", "No, do not use ConPort/Nova configs this session."].
            *   If user selects "Yes":
                *   Delegate to `Nova-LeadArchitect` using `new_task`. The 'Subtask Briefing Object' must instruct Nova-LeadArchitect to execute `WF_PROJ_INIT_001_NewProjectBootstrap.md` (path: `.nova/workflows/nova-orchestrator/WF_PROJ_INIT_001_NewProjectBootstrap.md`), then guide user for `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) creation, and report completion. (This is detailed in `conport_memory_strategy.handle_new_conport_setup`).
                *   Await `attempt_completion` from Nova-LeadArchitect (via user).
                *   If successful, set internal ConPort status to `[CONPORT_ACTIVE]`.
            *   If user selects "No":
                *   Set internal ConPort status to `[CONPORT_INACTIVE]`. Inform user: "[CONPORT_INACTIVE] ConPort will not be used." Proceed to step 6 (skipping ConPort loads).
    *   **Output:** ConPort status (`[CONPORT_ACTIVE]` or `[CONPORT_INACTIVE]`) determined. If new setup was done, basic ConPort items exist.

4.  **Nova-Orchestrator: Load Core ConPort Contexts (if CONPORT_ACTIVE)**
    *   **Action:** If status is `[CONPORT_ACTIVE]`:
        *   Use `use_mcp_tool` to call `get_product_context` (`ACTUAL_WORKSPACE_ID`).
        *   Use `use_mcp_tool` to call `get_active_context` (`ACTUAL_WORKSPACE_ID`).
        *   Use `use_mcp_tool` to call `get_custom_data` for `category: "ProjectConfig", key: "ActiveConfig"`.
        *   Use `use_mcp_tool` to call `get_custom_data` for `category: "NovaSystemConfig", key: "ActiveSettings"`.
        *   Use `use_mcp_tool` to call `get_custom_data` for `category: "DefinedWorkflows"`.
        *   Use `use_mcp_tool` to call `get_recent_activity_summary` (e.g., `hours_ago: 168`).
    *   **Output:** Core ConPort data loaded into Nova-Orchestrator's current session understanding.

5.  **Nova-Orchestrator: Verify/Delegate Missing Configurations (if CONPORT_ACTIVE)**
    *   **Action:** If `ProjectConfig:ActiveConfig` (key) or `NovaSystemConfig:ActiveSettings` (key) were not found in step 4 (e.g., bootstrap created DB but not these specific configs):
        *   Inform user: "Essential configurations (`ProjectConfig:ActiveConfig` or `NovaSystemConfig:ActiveSettings`) are missing from ConPort."
        *   Delegate to `Nova-LeadArchitect` using `new_task` to execute `.nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md` to guide user and log these.
        *   Await `attempt_completion` from Nova-LeadArchitect. Re-load these configs if created.
    *   **Output:** `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are confirmed to be loaded or user is aware if they declined setup.

**Phase SSU.3: Resume Previous Session State (if applicable)**

6.  **Nova-Orchestrator: Load Last Session Summary (if CONPORT_ACTIVE or user desires continuity)**
    *   **Action:**
        *   Use `list_files` to check `.nova/summary/` for `session_summary_*.md` files. Identify the most recent one.
        *   If found, use `read_file` to get its content.
        *   Delegate to `Nova-FlowAsk` using `new_task` to parse and summarize this file:
            ```
            Subtask_Briefing:
              Subtask_Goal: "Extract key status, last active task, and open points from the provided previous session summary text."
              Mode_Specific_Instructions:
                - "Parse the provided Markdown text from the last session summary."
                - "Identify: 1. The main project/workflow that was active. 2. The last major step/phase being worked on. 3. Key ConPort items (IDs/keys) mentioned as recently changed or important. 4. Any explicit 'next steps' or 'open questions' noted."
              Required_Input_Context:
                - File_Content_To_Summarize: "[Content of the .nova/summary/file.md]"
              Expected_Deliverables_In_Attempt_Completion:
                - "Bulleted list summary: {last_active_task: '...', last_status: '...', key_items: ['...'], next_steps_or_open_points: ['...']}"
            ```
        *   Await `attempt_completion` from Nova-FlowAsk.
    *   **Output:** Summary of previous session's state, if available.

**Phase SSU.4: Inform User & Await Instructions**

7.  **Nova-Orchestrator: Present Initial Context and Prompt for Action**
    *   **Action:**
        *   Formulate a message to the user, combining:
            *   ConPort status (`[CONPORT_ACTIVE]` or `[CONPORT_INACTIVE]`).
            *   Brief summary of loaded `ProjectConfig:ActiveConfig.project_type_hint` (key) and `NovaSystemConfig:ActiveSettings.mode_behavior.nova-orchestrator.default_dor_strictness` (key) if available.
            *   Key points from the last session summary (if available and processed).
        *   Use `ask_followup_question` to ask the user how to proceed.
            *   Question: "Session initialized. ConPort is `[Status]`. Project type is configured as `[Type]`. Last session focused on `[Last Task Summary from .nova/summary/ if any]`. What would you like to work on?"
            *   Suggestions: ["Continue with [Last Task]", "Start a new major project", "Implement new feature for existing project [ProjectName]", "Debug issue [ErrorLog Key if known]", "Review project status"].
    *   **Output:** User is informed of the initialized state and provides direction for the current session. This workflow (SSU) concludes; Nova-Orchestrator proceeds with the user's chosen task.

**Key ConPort Items Read by Nova-Orchestrator:**
-   `ProductContext` (key 'product_context')
-   `ActiveContext` (key 'active_context')
-   `CustomData ProjectConfig:ActiveConfig` (key)
-   `CustomData NovaSystemConfig:ActiveSettings` (key)
-   `CustomData DefinedWorkflows` (category)
-   Recent items from various categories via `get_recent_activity_summary`.