# Workflow: Project & Nova System Configuration Management (WF_ARCH_PROJECT_CONFIG_MANAGEMENT_001_v1)

**Goal:** To manage and update existing `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) entries in ConPort, based on user requests or evolving project needs.

**Primary Orchestrator Actor:** Nova-LeadArchitect (Typically tasked by Nova-Orchestrator if user requests config changes, or can initiate if architectural changes necessitate config updates).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Orchestrator Recognition (for Nova-Orchestrator to delegate to Nova-LeadArchitect):**
- User requests to change specific project settings (e.g., "Change primary language to JavaScript", "Update default test runner command").
- User requests to modify Nova system behavior for the current project (e.g., "Make refactoring by Nova-LeadDeveloper less aggressive").
- Nova-LeadArchitect determines that architectural decisions require updates to `ProjectConfig` or `NovaSystemConfig`.

**Pre-requisites by Nova-Orchestrator (before delegating this phase to Nova-LeadArchitect):**
- ConPort is `[CONPORT_ACTIVE]`.
- `CustomData ProjectConfig:ActiveConfig` (key) and `CustomData NovaSystemConfig:ActiveSettings` (key) exist in ConPort.
- A clear description of the desired change(s) is available.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase CFM.1: Change Analysis & User Consultation by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Receive Task & Analyze Requested Change**
    *   **Action:** Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` (e.g., "Update `ProjectConfig:ActiveConfig` field X to value Y") and `Required_Input_Context` (details of requested change).
    *   **ConPort:**
        *   Log main `Progress` (integer `id`) item: "Manage Project/Nova Configurations - Update [FieldX] - [Date]".
        *   Create internal plan (`LeadPhaseExecutionPlan:[CfgMgtProgressID]_ArchitectPlan` (key)) for ConPortSteward's subtask.
        *   Use `get_custom_data` to retrieve current `ProjectConfig:ActiveConfig` (key) and/or `NovaSystemConfig:ActiveSettings` (key).
    *   **Logic:**
        *   Analyze the impact of the requested change.
        *   If the change is simple and clear, prepare the updated JSON patch.
        *   If the change is complex or has wide implications (e.g., changing `primary_programming_language`), use `ask_followup_question` (relayed by Orchestrator) to discuss implications with the user and confirm. Consider if an `ImpactAnalysis` is needed first.
    *   **Output:** Finalized JSON patch object(s) for `ProjectConfig:ActiveConfig` (key) and/or `NovaSystemConfig:ActiveSettings` (key). A `Decision` (integer `id`) logged for significant config changes.

**Phase CFM.2: Logging Configuration Updates by Nova-SpecializedConPortSteward**

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Configuration Updates**
    *   **Task:** "Update the specified configuration entries in ConPort with the approved changes."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Manage Project/Nova Configurations - Update [FieldX]."
          Specialist_Subtask_Goal: "Update specified fields in `ProjectConfig:ActiveConfig` and/or `NovaSystemConfig:ActiveSettings` in ConPort."
          Specialist_Specific_Instructions:
            - "Log your own `Progress` (integer `id`) for this subtask."
            - "1. For `CustomData ProjectConfig:ActiveConfig` (key):
                  - Retrieve the current entry using `get_custom_data`.
                  - Apply the following patch (or merge these changes): [JSON patch object for ProjectConfig provided by LeadArchitect].
                  - Use `update_custom_data` to save the *entire modified* `ProjectConfig:ActiveConfig` (key) object."
            - "2. For `CustomData NovaSystemConfig:ActiveSettings` (key) (if changes are specified):
                  - Retrieve current entry.
                  - Apply patch: [JSON patch object for NovaSystemConfig provided by LeadArchitect].
                  - Use `update_custom_data` to save the *entire modified* `NovaSystemConfig:ActiveSettings` (key) object."
            - "Ensure entries are correctly updated and meet Definition of Done."
          Required_Input_Context_For_Specialist:
            - ProjectConfig_Patch_JSON: "{...}" // Can be null if no changes to this one
            - NovaSystemConfig_Patch_JSON: "{...}" // Can be null if no changes to this one
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation that `ProjectConfig:ActiveConfig` (key) was updated (if applicable)."
            - "Confirmation that `NovaSystemConfig:ActiveSettings` (key) was updated (if applicable)."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify ConPort entries. Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`).

**Phase CFM.3: Final Reporting by Nova-LeadArchitect**

3.  **Nova-LeadArchitect: Consolidate & Finalize**
    *   **Action:** Once configurations are updated by ConPortSteward:
        *   Update main `Progress` (integer `id`) for "Manage Project/Nova Configurations" to DONE.
        *   Update `active_context.state_of_the_union` (via `use_mcp_tool`) with a note: "Project/Nova configurations updated: [Brief summary of change]."
    *   **Output:** Configurations updated in ConPort.

4.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, confirming which configurations were updated and a brief summary of changes.

**Key ConPort Items Created/Updated by Nova-LeadArchitect's Team:**
-   `Progress` (integer `id`): For overall phase and specialist subtask.
-   `CustomData LeadPhaseExecutionPlan:[CfgMgtProgressID]_ArchitectPlan` (key).
-   `CustomData ProjectConfig:ActiveConfig` (key) (updated).
-   `CustomData NovaSystemConfig:ActiveSettings` (key) (updated).
-   `Decisions` (integer `id`): For significant configuration changes and their rationale.
-   `ActiveContext` (key `state_of_the_union` update).