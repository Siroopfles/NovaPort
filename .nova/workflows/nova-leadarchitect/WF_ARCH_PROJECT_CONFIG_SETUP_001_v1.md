# Workflow: Project & Nova System Configuration Setup (Architect-Led) (WF_ARCH_PROJECT_CONFIG_SETUP_001_v1)

**Goal:** To establish or update the `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` entries in ConPort, managed by Nova-LeadArchitect, typically involving user consultation for key values.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- Tasked by `Nova-Orchestrator`, e.g., during initial project setup (`WF_PROJ_INIT_001_NewProjectBootstrap.md`).
- LeadArchitect identifies a need to establish or significantly revise these configurations.

**Reference Milestones for your Single-Step Loop:**

**Milestone CFGA.1: Preparation & User Consultation**
*   **Goal:** Gather all necessary project details from the user to populate the configuration files.
*   **Suggested Specialist Sequence & Lead Actions:**
    1.  **LeadArchitect Action:** Log a main `Progress` item for this configuration setup phase.
    2.  **Delegate to `Nova-SpecializedConPortSteward` (Optional):**
        *   **Subtask Goal:** "Retrieve existing `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` from ConPort, if they exist."
        *   **Briefing Details:** Instruct the specialist to use `get_custom_data` and return the JSON content or a "not found" status.
    3.  **LeadArchitect Action: User Consultation:**
        *   Based on the project type and any existing configs, prepare a list of questions for the user.
        *   For each key setting (e.g., `primary_language`, `testing.framework`, `mode_behavior` settings), use `ask_followup_question` to get user input. Relay these questions via `Nova-Orchestrator`.
        *   **Example Question:** "To Nova-Orchestrator: Please ask the user for ProjectConfig: What is the primary programming language? Suggestions: Python, JavaScript, Java".
        *   Collect all user responses to build the final configuration objects.

**Milestone CFGA.2: Log Final Configurations**
*   **Goal:** Persist the finalized configuration objects to ConPort.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedConPortSteward`:**
        *   **Subtask Goal:** "Log the finalized `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` JSON objects to ConPort."
        *   **Briefing Details:**
            *   Provide the two complete, final JSON objects for the configurations.
            *   Instruct the specialist to use `log_custom_data` twice:
                1.  `category: "ProjectConfig"`, `key: "ActiveConfig"`, `value: {project_config_json}`
                2.  `category: "NovaSystemConfig"`, `key: "ActiveSettings"`, `value: {nova_config_json}`
            *   The specialist should return confirmation for both logging operations.

**Milestone CFGA.3: Finalize & Report**
*   **Goal:** Close out the configuration process and report completion.
*   **Suggested Lead Action:**
    1.  **Verify:** Use `get_custom_data` to verify the work of the `ConPortSteward`.
    2.  **Update Progress:** Update the main `Progress` item for the setup phase to 'DONE'.
    3.  **Report:** In your `attempt_completion` to `Nova-Orchestrator`, confirm that both configurations have been logged and provide their ConPort keys.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- CustomData ProjectConfig:ActiveConfig (key)
- CustomData NovaSystemConfig:ActiveSettings (key)