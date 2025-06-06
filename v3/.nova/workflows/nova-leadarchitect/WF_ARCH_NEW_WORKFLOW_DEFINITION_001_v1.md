# Workflow: New Nova Workflow Definition (WF_ARCH_NEW_WORKFLOW_DEFINITION_001_v1)

**Goal:** To define, document, and register a new standardized workflow for use by Nova-Orchestrator or Lead Modes, storing it in the appropriate `.nova/workflows/{mode_slug}/` directory and logging its existence in ConPort.

**Primary Orchestrator Actor:** Nova-LeadArchitect (can be tasked by Nova-Orchestrator to create a workflow, or can initiate this based on identified needs or `LessonsLearned`).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedWorkflowManager

**Trigger / Orchestrator Recognition:**
- Nova-Orchestrator identifies a recurring complex task pattern that would benefit from a standard workflow.
- Nova-LeadArchitect (based on `LessonsLearned` (key) or project reviews) sees an opportunity to standardize a process.
- User explicitly requests a new standard workflow for a specific type of operation.

**Pre-requisites by Nova-LeadArchitect (before starting this workflow internally):**
- A clear understanding of the goal and scope of the new workflow to be defined.
- Identification of the primary mode (`mode_slug`) that will own/execute this new workflow.
- (Optional) Draft notes or bullet points for the workflow steps.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator, or self-initiated):**

**Phase NW.1: Workflow Design & Drafting by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Define Workflow Core Elements**
    *   **Action:**
        *   Determine Workflow ID (e.g., `WF_[MODE_PREFIX]_[ShortName]_[Version]`).
        *   Clearly state the `Goal` of the new workflow.
        *   Identify `Primary Orchestrator/Lead Actor(s)` for the workflow.
        *   Describe `Trigger / Recognition` hints for when this workflow applies.
        *   List `Pre-requisites` for starting the workflow.
        *   Outline main `Phases & Steps`, including delegation patterns (Orchestrator->Lead, Lead->Specialist), example `Subtask Briefing Object` structures/content for key steps, expected ConPort interactions (with correct ID/key types), and DoD for steps.
        *   List `Key ConPort Items` typically affected.
    *   **ConPort:**
        *   Log a `Decision` (integer `id`) for creating this new workflow, including its rationale and intended benefits.
        *   Log a main `Progress` (integer `id`) item: "Define New Workflow: [Workflow Name]".
        *   Create an internal plan (`LeadPhaseExecutionPlan:[NWProgressID]_ArchitectPlan` (key)) for WorkflowManager's subtasks.
    *   **Output:** Detailed draft/specification for the new workflow content.

**Phase NW.2: File Creation & ConPort Logging by Nova-SpecializedWorkflowManager**

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedWorkflowManager: Create Workflow File & ConPort Entry**
    *   **Task:** "Create the Markdown workflow definition file in the correct `.nova/workflows/{mode_slug}/` path and log its existence in ConPort `DefinedWorkflows`."
    *   **`new_task` message for Nova-SpecializedWorkflowManager:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Define and register new workflow: [Workflow Name]."
          Specialist_Subtask_Goal: "Create workflow file '[FileName.md]' in path '[TargetPath]' and log to ConPort DefinedWorkflows."
          Specialist_Specific_Instructions:
            - "Target Path for file: `.nova/workflows/[target_mode_slug]/[FileName.md]` (e.g., `.nova/workflows/nova-leaddeveloper/WF_DEV_LIB_UPGRADE_001_v1.md`)."
            - "Workflow File Content (Markdown): [Full Markdown content provided by Nova-LeadArchitect, following the standard template]."
            - "1. Use `write_to_file` to create the workflow file at the specified target path with the provided content."
            - "2. After successful file creation, log its metadata to ConPort using `log_custom_data`:
                - Category: `DefinedWorkflows`
                - Key: `[FileNameWithoutExtension]_SumAndPath` (e.g., `WF_DEV_LIB_UPGRADE_001_v1_SumAndPath`)
                - Value (JSON Object): 
                  {
                    \"description\": \"[Brief description from LeadArchitect, e.g., 'Standard process for upgrading a project dependency.']\",
                    \"path\": \".nova/workflows/[target_mode_slug]/[FileName.md]\",
                    \"version\": \"1.0\",
                    \"primary_mode_owner\": \"[target_mode_slug]\",
                    \"tags\": [\"#[tag1]\", \"#[tag2]\"] // Optional relevant tags
                  }"
            - "Ensure the ConPort entry is complete and accurate."
          Required_Input_Context_For_Specialist:
            - Target_Mode_Slug: "[e.g., nova-leaddeveloper]"
            - Workflow_FileName_With_Version: "[e.g., WF_DEV_LIB_UPGRADE_001_v1.md]"
            - Full_Workflow_Markdown_Content: "[Provided by LeadArchitect]"
            - Brief_Description_For_ConPort: "[Provided by LeadArchitect]"
            - Optional_Tags_For_ConPort: ["[tag1]", "[tag2]"]
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Full path to the created workflow Markdown file."
            - "ConPort key of the created `DefinedWorkflows` entry."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify file creation and ConPort entry. Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`).

**Phase NW.3: Finalization by Nova-LeadArchitect**

3.  **Nova-LeadArchitect: Review & Finalize**
    *   **Action:**
        *   Review the created workflow file and ConPort entry for accuracy and completeness.
        *   (Optional) Delegate a task to another Lead (e.g., Nova-LeadDeveloper if it's a dev workflow) via Nova-Orchestrator for a peer review of the new workflow.
        *   Update main `Progress` (integer `id`) for "Define New Workflow" to DONE.
        *   Update `active_context.state_of_the_union` if this new workflow represents a significant process addition.
    *   **Output:** New workflow defined, documented, and registered.

4.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion of the workflow definition task, providing path to the new file and its ConPort `DefinedWorkflows` (key).

**Key ConPort Items Created/Updated by Nova-LeadArchitect's Team:**
-   `Progress` (integer `id`): For the overall task and specialist subtask.
-   `CustomData LeadPhaseExecutionPlan:[NWProgressID]_ArchitectPlan` (key).
-   `Decisions` (integer `id`): Rationale for creating the new workflow.
-   `CustomData DefinedWorkflows:[WorkflowFileBasename]_SumAndPath` (key): The new entry linking to the `.md` file.
-   (Potentially) Updates to `active_context.state_of_the_union`.