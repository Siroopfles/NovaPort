# Workflow: New Nova Workflow Definition (WF_ARCH_NEW_WORKFLOW_DEFINITION_001_v1)

**Goal:** To define, document, and register a new standardized workflow for use by Nova-Orchestrator or Lead Modes, storing it in the appropriate `.nova/workflows/{mode_slug}/` directory and logging its existence in ConPort.

**Primary Actor:** Nova-LeadArchitect (can be tasked by Nova-Orchestrator to create a workflow, or can initiate this based on identified needs or `LessonsLearned`).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedWorkflowManager

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Define a new workflow for [ProcessDescription], to be owned by [TargetModeSlug]."
- Nova-LeadArchitect (based on `LessonsLearned` (key) or project reviews) sees an opportunity to standardize a process for their team or another.
- User explicitly requests a new standard workflow for a specific type of operation.

**Pre-requisites by Nova-LeadArchitect:**
- A clear understanding of the goal and scope of the new workflow to be defined.
- Identification of the `primary_mode_owner` (mode_slug) that will own/execute this new workflow.
- (Optional) Draft notes or bullet points for the workflow steps, filename convention (e.g., `WF_[MODE_PREFIX]_[ShortName]_[Version].md`).

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator, or self-initiated):**

**Phase NWDef.1: Workflow Design & Drafting by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Define Workflow Core Elements**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Determine Workflow Filename (e.g., `WF_LEADDEV_NEW_COMPONENT_SETUP_001_v1.0.md`). This includes Mode Prefix and Version.
        *   Clearly state the `Goal` of the new workflow.
        *   Identify `Primary Orchestrator/Lead Actor(s)` for the workflow.
        *   Describe `Trigger / Recognition` hints for when this workflow applies.
        *   List `Pre-requisites` for starting the workflow.
        *   Outline main `Phases & Steps`, including delegation patterns (Orchestrator->Lead, Lead->Specialist), example `Subtask Briefing Object` structures/content for key steps, expected ConPort interactions (with correct ID/key types), and DoD for steps.
        *   List `Key ConPort Items` typically affected.
        *   Prepare the full Markdown content for the workflow file.
    *   **ConPort Action:**
        *   Log a `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"summary\": \"Decision to create new workflow: [Workflow Filename]\", \"rationale\": \"[Rationale, e.g., 'Standardize component setup for LeadDeveloper']\", \"implications\": \"...\", \"tags\": [\"#workflow\", \"#process_improvement\"]}`).
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Define New Workflow: [Workflow Filename]\"}`). Let this be `[NWDefProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[NWDefProgressID]_ArchitectPlan` (key) using `use_mcp_tool`. Main step: Delegate file creation and ConPort registration to WorkflowManager.
    *   **Output:** Detailed specification and full Markdown content for the new workflow file. `[NWDefProgressID]` known.

**Phase NWDef.2: File Creation & ConPort Logging by Nova-SpecializedWorkflowManager**

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedWorkflowManager: Create Workflow File & ConPort Entry**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Create the Markdown workflow definition file `[WorkflowFileName]` in path `.nova/workflows/[TargetModeSlug]/` and log its existence in ConPort `DefinedWorkflows`."
    *   **`new_task` message for Nova-SpecializedWorkflowManager:**
        ```json
        {
          "Context_Path": "[ProjectName] (NewWorkflowDef) -> Create File & Log (WorkflowManager)",
          "Overall_Architect_Phase_Goal": "Define and register new workflow: [Workflow Filename].",
          "Specialist_Subtask_Goal": "Create workflow file '[WorkflowFileName]' in path '.nova/workflows/[TargetModeSlug]/' and log to ConPort DefinedWorkflows.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[NWDefProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Subtask: Create workflow file [WorkflowFileName]\", \"parent_id\": [NWDefProgressID_as_integer]} `).",
            "1. Use `write_to_file` to create the workflow file at the specified target path with the provided content.",
            "   `Target Path`: `.nova/workflows/[TargetModeSlug_From_LeadArchitect]/[WorkflowFileName_From_LeadArchitect]`.",
            "   `Workflow File Content`: [Full_Workflow_Markdown_Content_From_LeadArchitect].",
            "2. After successful file creation, log its metadata to ConPort using `use_mcp_tool`. The arguments for this call must be:",
            "   `tool_name`: 'log_custom_data'",
            "   `arguments`: {",
            "     \"workspace_id\": \"ACTUAL_WORKSPACE_ID\",",
            "     \"category\": \"DefinedWorkflows\",",
            "     \"key\": \"[WorkflowFileBasenameWithoutExtension]_SumAndPath\",",
            "     \"value\": {",
            "       \"description\": \"[Brief_Description_From_LeadArchitect]\",",
            "       \"path\": \".nova/workflows/[TargetModeSlug_From_LeadArchitect]/[WorkflowFileName_From_LeadArchitect]\",",
            "       \"version\": \"[Version_From_Filename_e.g., 1.0]\",",
            "       \"primary_mode_owner\": \"[TargetModeSlug_From_LeadArchitect]\",",
            "       \"tags\": [\"#[tag1]\", \"#[tag2]\"]",
            "     }",
            "   }",
            "Ensure the ConPort entry is complete and accurate."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[NWDefProgressID_as_integer]",
            "TargetModeSlug_From_LeadArchitect": "[e.g., nova-leaddeveloper]",
            "WorkflowFileName_From_LeadArchitect": "[e.g., WF_DEV_LIB_UPGRADE_001_v1.0.md]",
            "Full_Workflow_Markdown_Content_From_LeadArchitect": "[Full Markdown text]",
            "Brief_Description_For_ConPort_From_LeadArchitect": "[e.g., 'Standard process for upgrading a project dependency.']",
            "Optional_Tags_For_ConPort_From_LeadArchitect": "[\"dependency_management\", \"upgrade\"]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Full path to the created workflow Markdown file.",
            "ConPort key of the created `DefinedWorkflows` entry."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify file creation (`list_files` then `read_file`) and ConPort entry (`use_mcp_tool` `get_custom_data`). Update `[NWDefProgressID]_ArchitectPlan` and specialist `Progress`.

**Phase NWDef.3: Finalization by Nova-LeadArchitect**

3.  **Nova-LeadArchitect: Review & Finalize**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Review the created workflow file and ConPort entry for accuracy and completeness.
        *   (Optional) If this workflow is intended for another Lead Mode (e.g., Nova-LeadDeveloper), inform Nova-Orchestrator so it can notify that Lead Mode of the new available workflow.
        *   Update main `Progress` (`[NWDefProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"progress_id\": [NWDefProgressID_as_integer], \"status\": \"DONE\", \"description\": \"New workflow '[Workflow Filename]' defined and registered in ConPort: `DefinedWorkflows:[Key]`.\"}`).
        *   To update `active_context`, first `get_active_context` with `use_mcp_tool`, then construct a new value object with the modified `state_of_the_union`, and finally use `log_custom_data` with category `ActiveContext` and key `active_context` to overwrite.
    *   **Output:** New workflow defined, documented, and registered.

4.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator (if this was a delegated phase)**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Report completion of the workflow definition task, providing path to the new file and its ConPort `DefinedWorkflows` (key).

**Key ConPort Items Created/Updated:**
- Progress (integer `id`): For the overall task and specialist subtask.
- CustomData LeadPhaseExecutionPlan:[NWDefProgressID]_ArchitectPlan (key).
- Decisions (integer `id`): Rationale for creating the new workflow.
- CustomData DefinedWorkflows:[WorkflowFileBasename]_SumAndPath (key): The new entry linking to the `.md` file.
- (Potentially) Updates to `active_context.state_of_the_union`.