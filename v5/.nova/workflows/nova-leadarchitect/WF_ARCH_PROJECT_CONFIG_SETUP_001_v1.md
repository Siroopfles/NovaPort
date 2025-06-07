# Workflow: Initial Project & Nova System Configuration Setup (WF_ARCH_PROJECT_CONFIG_SETUP_001_v1)

**Goal:** To establish the initial `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` entries in ConPort for a new project, or when these configurations are found to be missing.

**Primary Orchestrator Actor:** Nova-LeadArchitect (Typically tasked by Nova-Orchestrator during initial project setup, or if Orchestrator detects missing configurations).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Orchestrator Recognition (for Nova-Orchestrator to delegate to Nova-LeadArchitect):**
- During Nova-Orchestrator's session/ConPort initialization, `ProjectConfig:ActiveConfig` or `NovaSystemConfig:ActiveSettings` are not found.
- User explicitly requests to set up or review project/Nova configurations.

**Pre-requisites by Nova-Orchestrator (before delegating this phase to Nova-LeadArchitect):**
- ConPort is `[CONPORT_ACTIVE]` (or if not, this workflow is part of the initial bootstrap delegated by Orchestrator).
- (Optional) User has provided some initial hints about project type or desired settings.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase CFG.1: Planning & User Consultation (Simulated) by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Receive Task & Prepare Default/Proposed Configurations**
    *   **Action:** Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` ("Setup ProjectConfig & NovaSystemConfig").
    *   **ConPort:**
        *   Log main `Progress` (integer `id`) item: "Setup Project & Nova Configurations - [Date]".
        *   Create internal plan (`LeadPhaseExecutionPlan:[CfgProgressID]_ArchitectPlan` (key)) for ConPortSteward's subtasks.
    *   **Logic:**
        *   Based on `standard_conport_categories` for `ProjectConfig` and `NovaSystemConfig` (and any user hints from Orchestrator's briefing), prepare a default set of JSON values for both configurations.
        *   For example, for `ProjectConfig:ActiveConfig`:
            ```json
            {
              "project_type_hint": "generic_application",
              "primary_programming_language": "Python",
              "primary_frameworks": [],
              "code_style_guide_ref": "ConPort SystemPatterns:DefaultPythonStyle_v1", // or URL
              "testing_preferences": {
                "default_test_runner_command": "pytest",
                "min_unit_test_coverage_target_percentage": 70
              },
              "documentation_standards": {"inline_doc_style": "reStructuredText", "technical_docs_location": "docs/"},
              // ... other ProjectConfig fields
            }
            ```
        *   For `NovaSystemConfig:ActiveSettings`:
            ```json
            {
              "mode_behavior": {
                "nova-orchestrator": {"default_dor_strictness": "medium"},
                "nova-leaddeveloper": {"refactoring_aggressiveness": "medium"},
                "nova-leadqa": {"regression_testing_scope_default": "focused_on_changes"}
              },
              "conport_integration": {"auto_link_suggestion_enabled": true},
              // ... other NovaSystemConfig fields
            }
            ```
    *   **User Consultation (Simulated):**
        *   Nova-LeadArchitect (YOU, the LLM playing this role) would typically now use `ask_followup_question` repeatedly to discuss EACH key setting with the user, presenting the default and asking for confirmation or a different value.
        *   **Example Interaction (Simulated):**
            *   LeadArchitect (via `ask_followup_question` to user, relayed by Orchestrator): "For `ProjectConfig`, the default `primary_programming_language` is 'Python'. Is this correct for your project, or would you prefer another (e.g., JavaScript, Java)?"
            *   User responds. LeadArchitect notes the answer.
            *   LeadArchitect: "Default for `testing_preferences.default_test_runner_command` is 'pytest'. Is this suitable?"
            *   ...and so on for all relevant fields in both configs.
    *   **Output:** Finalized JSON objects for `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` based on defaults and user feedback.

**Phase CFG.2: Logging Configurations by Nova-SpecializedConPortSteward**

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Configurations**
    *   **Task:** "Log the finalized ProjectConfig and NovaSystemConfig to ConPort."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Setup Project & Nova Configurations."
          Specialist_Subtask_Goal: "Log ProjectConfig:ActiveConfig and NovaSystemConfig:ActiveSettings to ConPort."
          Specialist_Specific_Instructions:
            - "Log your own `Progress` (integer `id`) for this subtask."
            - "1. Using `log_custom_data` (or `update_custom_data` if an empty/placeholder entry was made by bootstrap):
                  - Category: `ProjectConfig`
                  - Key: `ActiveConfig`
                  - Value: [Final JSON object for ProjectConfig provided by LeadArchitect]"
            - "2. Using `log_custom_data` (or `update_custom_data`):
                  - Category: `NovaSystemConfig`
                  - Key: `ActiveSettings`
                  - Value: [Final JSON object for NovaSystemConfig provided by LeadArchitect]"
            - "Ensure both entries are complete, correctly structured, and meet Definition of Done."
          Required_Input_Context_For_Specialist:
            - Final_ProjectConfig_JSON: "{...}" # From LeadArchitect after simulated user consultation
            - Final_NovaSystemConfig_JSON: "{...}" # From LeadArchitect
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation that `ProjectConfig:ActiveConfig` (key) was logged/updated."
            - "Confirmation that `NovaSystemConfig:ActiveSettings` (key) was logged/updated."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify ConPort entries. Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`).

**Phase CFG.3: Final Reporting by Nova-LeadArchitect**

3.  **Nova-LeadArchitect: Consolidate & Finalize**
    *   **Action:** Once configurations are logged by ConPortSteward:
        *   Update main `Progress` (integer `id`) for "Setup Project & Nova Configurations" to DONE.
        *   Update `active_context.state_of_the_union` (via `use_mcp_tool`) with a note: "Initial ProjectConfig and NovaSystemConfig established."
    *   **Output:** Configurations established in ConPort.

4.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, confirming that `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are now in ConPort. Include a brief summary of key settings if requested by Orchestrator's initial briefing.

**Key ConPort Items Created/Updated by Nova-LeadArchitect's Team:**
-   `Progress` (integer `id`): For overall phase and specialist subtask.
-   `CustomData LeadPhaseExecutionPlan:[CfgProgressID]_ArchitectPlan` (key).
-   `CustomData ProjectConfig:ActiveConfig` (key): The main deliverable.
-   `CustomData NovaSystemConfig:ActiveSettings` (key): The main deliverable.
-   (Potentially) `Decisions` (integer `id`) related to choosing specific configuration values if the discussion was complex.
-   `ActiveContext` (key `state_of_the_union` update).