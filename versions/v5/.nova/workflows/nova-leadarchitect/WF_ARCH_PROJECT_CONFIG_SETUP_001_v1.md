# Workflow: Project & Nova System Configuration Setup (Architect-Led) (WF_ARCH_PROJECT_CONFIG_SETUP_001_v1)

**Goal:** To establish or update the `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` entries in ConPort, managed by Nova-LeadArchitect, typically involving user consultation for key values.

**Primary Actor:** Nova-LeadArchitect (Tasked by Nova-Orchestrator, e.g., during initial project setup or when configs are missing/need review).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- Nova-Orchestrator delegates this task to Nova-LeadArchitect (e.g., as part of `WF_ORCH_PROJECT_CONFIG_NOVA_CONFIG_SETUP_001_v1.md` or `WF_PROJ_INIT_001_NewProjectBootstrap.md`).
- Nova-LeadArchitect identifies a need to establish or significantly revise these configurations.

**Pre-requisites by Nova-LeadArchitect (from Nova-Orchestrator's briefing or self-assessment):**
- ConPort is `[CONPORT_ACTIVE]`.
- Understanding of the project type or desired Nova operational parameters.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase CFGA.1: Preparation & User Consultation (Simulated by LeadArchitect)**

1.  **Nova-LeadArchitect: Receive Task & Prepare Default/Proposed Configurations**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` ("Setup/Update ProjectConfig & NovaSystemConfig").
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "Setup/Update Project & Nova Configurations - [Date]". Let this be `[CfgSetupProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[CfgSetupProgressID]_ArchitectPlan` (key) using `use_mcp_tool`. Plan items:
            1.  Retrieve Existing Configs (if any) (ConPortSteward).
            2.  Prepare Default/Proposed Config Values (LeadArchitect).
            3.  Consult User for Key Values (LeadArchitect, via Orchestrator relay).
            4.  Log Finalized Configurations (ConPortSteward).
    *   **Delegate to Nova-SpecializedConPortSteward: Retrieve Existing Configs (if any)**
        *   Briefing for ConPortSteward: Use `use_mcp_tool` (`tool_name: 'get_custom_data'`) to fetch current `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key). Report back the JSON content or indicate if not found.
    *   **Nova-LeadArchitect Action after ConPortSteward's `attempt_completion`:**
        *   Based on existing configs (if any) and `standard_conport_categories` (for `ProjectConfig` and `NovaSystemConfig` fields), prepare a default or proposed set of JSON values for both.
        *   **User Consultation (Simulated via Orchestrator):**
            *   Identify key fields requiring user input or confirmation (e.g., `project_type_hint`, `primary_programming_language`, `testing_preferences.default_test_runner_command` for `ProjectConfig`; `mode_behavior` settings for `NovaSystemConfig`).
            *   For each such field, formulate a question and suggested options.
            *   Use `ask_followup_question` directed TO NOVA-ORCHESTRATOR, requesting it to relay the question TO THE USER.
                *   Example: `<ask_followup_question><question>To Nova-Orchestrator: Please ask user for ProjectConfig: What is the 'primary_programming_language' for this project?</question><follow_up><suggest>Python</suggest><suggest>JavaScript</suggest><suggest>Java</suggest></follow_up></ask_followup_question>`
            *   Acknowledge Orchestrator will relay. Await user responses (via Orchestrator).
            *   Repeat for all necessary fields, collecting user preferences.
    *   **Output:** Finalized JSON objects for `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` based on defaults, existing values, and user feedback.

**Phase CFGA.2: Logging Configurations by Nova-SpecializedConPortSteward**

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Configurations**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Log the finalized ProjectConfig and NovaSystemConfig to ConPort."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (ConfigSetup) -> Log Configs (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Setup/Update Project & Nova Configurations.",
          "Specialist_Subtask_Goal": "Log/Update ProjectConfig:ActiveConfig and NovaSystemConfig:ActiveSettings to ConPort.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`) for this subtask, parented to `[CfgSetupProgressID]`.",
            "1. For `ProjectConfig:ActiveConfig` (key):",
            "   - Value: [Final JSON object for ProjectConfig provided by LeadArchitect].",
            "   - Use `use_mcp_tool` (`server_name: 'conport'`, `tool_name: 'update_custom_data'` (if updating) or `log_custom_data` (if new), `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'category': 'ProjectConfig', 'key': 'ActiveConfig', 'value': { /* ProjectConfig_JSON */ }}`).",
            "2. For `NovaSystemConfig:ActiveSettings` (key):",
            "   - Value: [Final JSON object for NovaSystemConfig provided by LeadArchitect].",
            "   - Use `use_mcp_tool` (`server_name: 'conport'`, `tool_name: 'update_custom_data'` (if updating) or `log_custom_data` (if new), `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'category': 'NovaSystemConfig', 'key': 'ActiveSettings', 'value': { /* NovaSystemConfig_JSON */ }}`).",
            "Ensure both entries are complete, correctly structured, and meet Definition of Done."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[CfgSetupProgressID_as_string]",
            "Final_ProjectConfig_JSON": "{/* JSON from LeadArchitect */}",
            "Final_NovaSystemConfig_JSON": "{/* JSON from LeadArchitect */}"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that `ProjectConfig:ActiveConfig` (key) was logged/updated.",
            "Confirmation that `NovaSystemConfig:ActiveSettings` (key) was logged/updated."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify ConPort entries (e.g., by using `use_mcp_tool` `get_custom_data`). Update `[CfgSetupProgressID]_ArchitectPlan` and specialist `Progress`.

**Phase CFGA.3: Final Reporting by Nova-LeadArchitect**

3.  **Nova-LeadArchitect: Consolidate & Finalize**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Once configurations are logged by ConPortSteward:
        *   Update main `Progress` (`[CfgSetupProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "ProjectConfig:ActiveConfig and NovaSystemConfig:ActiveSettings established/updated."
        *   If this phase was part of a larger Orchestrator-delegated task, prepare the `attempt_completion` for Orchestrator.
    *   **Output:** Configurations established/updated in ConPort.

4.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Report completion, confirming that `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are now in ConPort. Include a brief summary of key settings if requested by Orchestrator's initial briefing.

**Key ConPort Items Created/Updated by Nova-LeadArchitect's Team:**
- Progress (integer `id`): For overall phase and specialist subtask.
- CustomData LeadPhaseExecutionPlan:[CfgSetupProgressID]_ArchitectPlan (key).
- CustomData ProjectConfig:ActiveConfig (key): The main deliverable.
- CustomData NovaSystemConfig:ActiveSettings (key): The main deliverable.
- (Potentially) Decisions (integer `id`) related to choosing specific configuration values if the discussion was complex.