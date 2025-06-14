# Workflow: New Project Bootstrap (WF_PROJ_INIT_001_NewProjectBootstrap.md)

**Goal:** To establish the foundational ConPort entries and basic directory structure for an entirely new project, guided by Nova-LeadArchitect based on initial user input.

**Primary Orchestrator Actor:** Nova-LeadArchitect (Tasked by Nova-Orchestrator, typically during `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md` if no ConPort DB exists and user agrees to initialize).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward, Nova-SpecializedSystemDesigner (for initial dir structure thoughts).

**Trigger / Recognition:**

- Nova-Orchestrator delegates this task to Nova-LeadArchitect when initializing a brand-new workspace where `context_portal/context.db` does not exist, and the user has agreed to proceed with a new project setup.

**Pre-requisites by Nova-LeadArchitect (from Nova-Orchestrator's briefing):**

- `ACTUAL_WORKSPACE_ID` is known.
- User has provided a `UserProvided_ProjectName` and `UserProvided_MainGoal`.
- ConPort DB has just been (or is about to be) created by the ConPort server itself upon first tool use.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase BS.1: Initial ConPort Entry Creation & Standardization**

1.  **Nova-LeadArchitect: Plan Bootstrap & Log Initial Progress**

    - **Action:**
      - Parse `Subtask Briefing Object` from Nova-Orchestrator.
      - Log main `Progress` (integer `id`) for this bootstrap phase: "Project Bootstrap: [ProjectName]" using `use_mcp_tool` (`tool_name: 'log_progress'`). Let this be `[BootstrapProgressID]`.
      - Create internal plan (`CustomData LeadPhaseExecutionPlan:[BootstrapProgressID]_ArchitectPlan` (key)). Plan items:
        1.  Create Initial ProductContext (Delegate to ConPortSteward).
        2.  Create Initial ActiveContext (Delegate to ConPortSteward).
        3.  Log Initial High-Level Decisions (LeadArchitect self-action).
        4.  Log Initial Project Standards (DoD/DoR) (Delegate to ConPortSteward).
        5.  Log Item Templates (ErrorLog, LessonsLearned, Decision) (Delegate to ConPortSteward).
        6.  Log System Retrospective Heuristics (Delegate to ConPortSteward).
        7.  Draft Initial ProjectRoadmap (Delegate to SystemDesigner).
        8.  Trigger Project & Nova System Configuration Setup (This step will execute the WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md workflow).
    - **Output:** Plan ready. `[BootstrapProgressID]` known.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Create Initial `ProductContext`**

    - **Actor:** Nova-LeadArchitect
    - **Task:** "Create the initial `ProductContext` entry in ConPort for [ProjectName]."
    - **`new_task` message for Nova-SpecializedConPortSteward:**
      ```json
      {
        "Context_Path": "[ProjectName] (Bootstrap) -> Create ProductContext (ConPortSteward)",
        "Overall_Architect_Phase_Goal": "Bootstrap new project [ProjectName] in ConPort.",
        "Specialist_Subtask_Goal": "Create and log the initial ProductContext for Project [ProjectName].",
        "Specialist_Specific_Instructions": [
          "Log your own detailed `Progress` (integer `id`) for this subtask, parented to `[BootstrapProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
          "Based on 'UserProvided_MainGoal' and 'UserProvided_ProjectName' from LeadArchitect's context, formulate a basic ProductContext JSON object.",
          "Use `use_mcp_tool` (`tool_name: 'update_product_context'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"content\": { /* your_json_object */ }}`) to log this. The object should contain keys like `project_name`, `main_goal`, `high_level_features_envisioned`, `target_audience_profile_hint`."
        ],
        "Required_Input_Context_For_Specialist": {
          "Parent_Progress_ID_as_integer": "[BootstrapProgressID_as_integer]",
          "UserProvided_ProjectName": "[...]",
          "UserProvided_MainGoal": "[...]"
        },
        "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
          "Confirmation that ProductContext was created/updated."
        ]
      }
      ```
    - **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify. Update plan/progress.

3.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Create Initial `ActiveContext`**

    - **Actor:** Nova-LeadArchitect
    - **Task:** "Create the initial `ActiveContext` entry in ConPort."
    - **`new_task` message for Nova-SpecializedConPortSteward:**
      ```json
      {
        "Context_Path": "[ProjectName] (Bootstrap) -> Create ActiveContext (ConPortSteward)",
        "Overall_Architect_Phase_Goal": "Bootstrap new project [ProjectName] in ConPort.",
        "Specialist_Subtask_Goal": "Create and log the initial ActiveContext.",
        "Specialist_Specific_Instructions": [
          "Log your own detailed `Progress` (integer `id`) for this subtask, parented to `[BootstrapProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
          "Use `use_mcp_tool` (`tool_name: 'update_active_context'`) with `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"patch_content\": {\"state_of_the_union\": \"Project [ProjectName] initialized. Awaiting initial configurations and detailed design.\", \"open_issues\": []}}`."
        ],
        "Required_Input_Context_For_Specialist": {
          "Parent_Progress_ID_as_integer": "[BootstrapProgressID_as_integer]",
          "ProjectName": "[ProjectName]"
        },
        "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
          "Confirmation that ActiveContext was created/updated."
        ]
      }
      ```
    - **Nova-LeadArchitect Action:** Verify. Update plan/progress.

4.  **Nova-LeadArchitect: Log Initial High-Level Decisions**

    - **Actor:** Nova-LeadArchitect
    - **Action:** Log 1-2 very high-level `Decisions` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`).
      - Example Decision 1: `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"summary\": \"Adopt Nova Standard Project Lifecycle\", \"rationale\": \"Leverage defined best practices.\"}`
      - Example Decision 2: `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"summary\": \"Prioritize Core Feature X for MVP\", \"rationale\": \"Based on user's stated main goal.\"}`
    - **Output:** Initial `Decision` (integer `id`s) logged.

5.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Initial Project Standards**

    - **Actor:** Nova-LeadArchitect
    - **Task:** "Create the initial `ProjectStandards` entries for DoD and DoR."
    - **`new_task` message for Nova-SpecializedConPortSteward:**
      ```json
      {
        "Context_Path": "[ProjectName] (Bootstrap) -> Create ProjectStandards (ConPortSteward)",
        "Overall_Architect_Phase_Goal": "Bootstrap new project [ProjectName] in ConPort.",
        "Specialist_Subtask_Goal": "Create and log initial ProjectStandards for DoD and DoR.",
        "Specialist_Specific_Instructions": [
          "Log your own detailed `Progress` (integer `id`) for this subtask, parented to `[BootstrapProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
          "Refer to `.nova/docs/conport_standards.md` for the formal definitions.",
          "1. **Log Default DoD:** Use `use_mcp_tool` (`tool_name: 'log_custom_data'`) with `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"ProjectStandards\", \"key\": \"DefaultDoD\", \"value\": { /* JSON from conport_standards.md */ }}`",
          "2. **Log Default DoR:** Use `use_mcp_tool` (`tool_name: 'log_custom_data'`) with `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"ProjectStandards\", \"key\": \"DefaultDoR\", \"value\": { /* JSON for DoR from conport_standards.md or similar */ }}`"
        ],
        "Required_Input_Context_For_Specialist": {
          "Parent_Progress_ID_as_integer": "[BootstrapProgressID_as_integer]",
          "Path_To_Standards_Doc": ".nova/docs/conport_standards.md"
        },
        "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
          "Confirmation that `ProjectStandards:DefaultDoD` and `ProjectStandards:DefaultDoR` were created."
        ]
      }
      ```
    - **Nova-LeadArchitect Action:** Verify. Update plan/progress.

6.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Item Templates**

    - **Actor:** Nova-LeadArchitect
    - **Task:** "Create standard item templates in ConPort."
    - **`new_task` message for Nova-SpecializedConPortSteward:**
      ```json
      {
        "Context_Path": "[ProjectName] (Bootstrap) -> LogItemTemplates (ConPortSteward)",
        "Overall_Architect_Phase_Goal": "Bootstrap new project [ProjectName] in ConPort.",
        "Specialist_Subtask_Goal": "Log standard JSON object templates for common ConPort items.",
        "Specialist_Specific_Instructions": [
          "Log your own detailed `Progress` (integer `id`) for this subtask, parented to `[BootstrapProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
          "Create a new `CustomData` category named `Templates`. Log the following items into this category using `use_mcp_tool` (`tool_name: 'log_custom_data'`). The structures MUST match those in `.nova/docs/conport_standards.md`.",
          "1. **Log ErrorLog Template:** `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"Templates\", \"key\": \"ErrorLog_v1\", \"value\": { /* JSON from conport_standards.md */ }}`",
          "2. **Log LessonsLearned Template:** `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"Templates\", \"key\": \"LessonsLearned_v1\", \"value\": { /* JSON from conport_standards.md */ }}`"
        ],
        "Required_Input_Context_For_Specialist": {
          "Parent_Progress_ID_as_integer": "[BootstrapProgressID_as_integer]",
          "Path_To_Standards_Doc": ".nova/docs/conport_standards.md"
        },
        "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
          "Confirmation that `Templates:ErrorLog_v1` and `Templates:LessonsLearned_v1` were created."
        ]
      }
      ```
    - **Nova-LeadArchitect Action:** Verify. Update plan/progress.

7.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log System Retrospective Heuristics**

    - **Actor:** Nova-LeadArchitect
    - **Task:** "Create the initial `ProcessFrictionHeuristics_v1` entry in ConPort."
    - **`new_task` message for Nova-SpecializedConPortSteward:**
      ```json
      {
        "Context_Path": "[ProjectName] (Bootstrap) -> LogRetrospectiveConfig (ConPortSteward)",
        "Overall_Architect_Phase_Goal": "Bootstrap new project [ProjectName] in ConPort.",
        "Specialist_Subtask_Goal": "Log the default configuration for process friction analysis.",
        "Specialist_Specific_Instructions": [
          "Log your own detailed `Progress` (integer `id`) for this subtask, parented to `[BootstrapProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
          "Log a new CustomData entry using `use_mcp_tool` (`tool_name: 'log_custom_data'`). The arguments MUST contain: `category: 'NovaSystemConfig'`, `key: 'ProcessFrictionHeuristics_v1'`, and the full JSON value object for the heuristics.",
          "The JSON `value` must be copied exactly from the established definition."
        ],
        "Required_Input_Context_For_Specialist": {
          "Parent_Progress_ID_as_integer": "[BootstrapProgressID_as_integer]",
          "Full_Heuristics_JSON_Value": {
            /* The full JSON object for ProcessFrictionHeuristics_v1 */
          }
        },
        "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
          "Confirmation that `NovaSystemConfig:ProcessFrictionHeuristics_v1` was created."
        ]
      }
      ```
    - **Nova-LeadArchitect Action:** Verify. Update plan/progress.

8.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedSystemDesigner: Draft Initial `ProjectRoadmap`**
    - **Actor:** Nova-LeadArchitect
    - **Task:** "Draft a very high-level `ProjectRoadmap`."
    - **`new_task` message for Nova-SpecializedSystemDesigner:**
      ```json
      {
        "Context_Path": "[ProjectName] (Bootstrap) -> DraftRoadmap (SystemDesigner)",
        "Overall_Architect_Phase_Goal": "Bootstrap new project [ProjectName] in ConPort.",
        "Specialist_Subtask_Goal": "Create a high-level, initial Project Roadmap in ConPort.",
        "Specialist_Specific_Instructions": [
          "Log your own detailed `Progress` (integer `id`) for this subtask, parented to `[BootstrapProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
          "Based on the `ProductContext` (main goal, envisioned features), create a simple roadmap.",
          "Log this as `CustomData ProjectRoadmap:[ProjectName]_InitialRoadmap_v0.1` using `use_mcp_tool` (`tool_name: 'log_custom_data'`). The `value` should be a JSON object like: `{\"roadmap_name\": \"Initial MVP Roadmap\", \"phases\": [{\"name\": \"Phase 1: Core Functionality\", \"goals\": [\"User Auth\", \"Product Display\"]}, {\"name\": \"Phase 2: E-commerce\", \"goals\": [\"Shopping Cart\", \"Checkout\"]}]}`."
        ],
        "Required_Input_Context_For_Specialist": {
          "Parent_Progress_ID_as_integer": "[BootstrapProgressID_as_integer]",
          "ProductContext_Ref": { "type": "product_context", "id": "product_context" },
          "ProjectName": "[ProjectName]"
        },
        "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
          "The key of the created `ProjectRoadmap` entry."
        ]
      }
      ```
    - **Nova-LeadArchitect Action:** Review. Update plan/progress.

**Phase BS.2: Basic Configuration Setup**

9.  **Nova-LeadArchitect: Trigger Project & Nova System Configuration Setup**
    - **Action:** Now that the bootstrap is done, the LeadArchitect executes the full process detailed in `WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md`. This involves creating a new internal plan for that specific workflow, delegating to `Nova-SpecializedConPortSteward`, and potentially asking the user for input via `Nova-Orchestrator`. This is a self-contained process within this larger bootstrap phase.
    - **Output:** `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are created in ConPort.

**Phase BS.3: Finalize Bootstrap & Report to Orchestrator**

10. **Nova-LeadArchitect: Finalize Bootstrap**

    - **Action:** Update main `Progress` (`[BootstrapProgressID]`) to DONE.
    - **Output:** Bootstrap phase complete.

11. **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**

    - **Action:** Report completion of the entire bootstrap phase to the Nova-Orchestrator. The result must be a structured summary of all created artifacts.
    - **`attempt_completion` format:**

      ```xml
      <attempt_completion>
      <result>
      Phase 'Project Bootstrap: [ProjectName]' completed.
      - Initial ConPort entries for ProductContext, ActiveContext, high-level Decisions, and ProjectRoadmap have been created.
      - Foundational project standards (DoD/DoR) and item templates (ErrorLog, LessonsLearned, Decision) have been logged.
      - The default configuration for the System Retrospective Cycle has been logged.
      - The process for setting up `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` has been completed via the sub-workflow.

      Key ConPort Items Created:
      - ProductContext: product_context (key)
      - ActiveContext: active_context (key)
      - Decisions: [List of initial integer IDs, e.g., '1', '2']
      - Progress: [BootstrapProgressID_as_integer] (integer ID)
      - CustomData LeadPhaseExecutionPlan: [BootstrapProgressID]_ArchitectPlan (key)
      - CustomData ProjectRoadmap: [ProjectName]_InitialRoadmap_v0.1 (key)
      - CustomData ProjectConfig: ActiveConfig (key)
      - CustomData NovaSystemConfig: ActiveSettings (key)
      - CustomData NovaSystemConfig: ProcessFrictionHeuristics_v1 (key)
      - CustomData ProjectStandards: DefaultDoD (key)
      - CustomData ProjectStandards: DefaultDoR (key)
      - CustomData Templates: ErrorLog_v1 (key)
      - CustomData Templates: LessonsLearned_v1 (key)
      </result>
      </attempt_completion>
      ```
