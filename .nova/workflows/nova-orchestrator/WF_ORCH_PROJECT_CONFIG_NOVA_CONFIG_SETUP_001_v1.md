# Workflow: Project & Nova System Configuration Setup Orchestration (WF_ORCH_PROJECT_CONFIG_NOVA_CONFIG_SETUP_001_v1)

**Goal:** To ensure that essential project-specific configurations (`ProjectConfig:ActiveConfig`) and Nova system behavior configurations (`NovaSystemConfig:ActiveSettings`) are established in ConPort, orchestrated by Nova-Orchestrator by delegating to Nova-LeadArchitect.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Delegated Lead Mode Actor:** Nova-LeadArchitect

**Trigger / Recognition:**
- Executed by Nova-Orchestrator as part of its `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md` if `ProjectConfig:ActiveConfig` (key) or `NovaSystemConfig:ActiveSettings` (key) are not found in ConPort.
- Can also be triggered if user explicitly requests to review/setup these configurations.

**Pre-requisites by Nova-Orchestrator:**
- ConPort is `[CONPORT_ACTIVE]`.
- If part of a new project, `WF_PROJ_INIT_001_NewProjectBootstrap.md` (or similar) should ideally have been completed to establish basic `ProductContext` (key 'product_context').

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase CFGS.1: Delegation to Nova-LeadArchitect**

1.  **Nova-Orchestrator: Identify Missing Configs & Delegate Setup**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Nova-Orchestrator uses `use_mcp_tool` (`tool_name: 'get_custom_data'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"ProjectConfig\", \"key\": \"ActiveConfig\"}`) to check for `ProjectConfig:ActiveConfig` (key).
        *   Nova-Orchestrator uses `use_mcp_tool` (`tool_name: 'get_custom_data'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"NovaSystemConfig\", \"key\": \"ActiveSettings\"}`) to check for `NovaSystemConfig:ActiveSettings` (key).
        *   If either or both are missing, or if user explicitly requested setup:
            *   Log a `Progress` (integer `id`) item for this overall orchestration task: "Setup Project/Nova Configurations (Orchestrated)" using `use_mcp_tool` (`tool_name: 'log_progress'`). Let this be `[OrchCfgProgressID]`.
    *   **Task:** "Delegate the definition and logging of `ProjectConfig:ActiveConfig` and/or `NovaSystemConfig:ActiveSettings` to Nova-LeadArchitect."
    *   **`new_task` message for Nova-LeadArchitect:**
        ```json
        {
          "Context_Path": "ProjectSetup (Orchestrator) -> ConfigSetup (LeadArchitect)",
          "Overall_Project_Goal": "Ensure Project [ProjectName] has necessary ConPort configurations.",
          "Phase_Goal": "Define and log [missing/requested configs: ProjectConfig:ActiveConfig and/or NovaSystemConfig:ActiveSettings] in ConPort.",
          "Lead_Mode_Specific_Instructions": [
            "Project: [ProjectName].",
            "The following configurations need to be established/reviewed in ConPort: [List missing, e.g., 'ProjectConfig:ActiveConfig', 'NovaSystemConfig:ActiveSettings'].",
            "1. Execute the workflow detailed in `.nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md`.",
            "   This workflow will guide your team (Nova-SpecializedConPortSteward) to:",
            "   a. Prepare default values for all fields within `ProjectConfig:ActiveConfig` (e.g., `project_type_hint`, `primary_language`, `testing`, etc.).",
            "   b. Prepare default values for all fields within `NovaSystemConfig:ActiveSettings` (e.g., `mode_behavior` overrides, `conport_integration` settings).",
            "   c. Guide the user (simulated by you, LeadArchitect, asking me, Orchestrator, to relay `ask_followup_question` to user) through each key setting, presenting the default and allowing them to confirm or provide a project-specific value.",
            "   d. Your Nova-SpecializedConPortSteward will then log the finalized JSON objects to `CustomData ProjectConfig:ActiveConfig` (key) and `CustomData NovaSystemConfig:ActiveSettings` (key) respectively, using `use_mcp_tool` (`tool_name: 'log_custom_data'`)."
          ],
          "Required_Input_Context": {
            "ProjectName": "[ProjectName]",
            "Missing_Configs_List": "['ProjectConfig:ActiveConfig', 'NovaSystemConfig:ActiveSettings']",
            "Path_To_Architect_Config_Workflow": ".nova/workflows/nova-leadarchitect/WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md",
            "User_Project_Type_Hint_From_Orchestrator": "[e.g., 'web_api_project']"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
            "Confirmation that `ProjectConfig:ActiveConfig` (key) has been created/updated, with a summary of key values.",
            "Confirmation that `NovaSystemConfig:ActiveSettings` (key) has been created/updated, with a summary of key values.",
            "ConPort keys for both logged configuration items."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Lead's `attempt_completion`:**
        *   Verify configurations are reported as logged by LeadArchitect.
        *   Use `use_mcp_tool` (`tool_name: 'get_custom_data'`) to re-load `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) into its own session understanding.
        *   Update its `Progress` (`[OrchCfgProgressID]`) for "Setup Project/Nova Configurations (Orchestrated)" to "DONE" using `use_mcp_tool` (`tool_name: 'update_progress'`).
        *   Inform user: "Project and Nova system configurations have been established in ConPort."

**Key ConPort Items Involved:**
- CustomData ProjectConfig:ActiveConfig (key) (created/updated by LeadArchitect's team)
- CustomData NovaSystemConfig:ActiveSettings (key) (created/updated by LeadArchitect's team)
- Progress (integer `id`) (for Orchestrator's tracking of this delegation)
- (Reads) other context like ProductContext (key 'product_context') if providing hints to LeadArchitect.