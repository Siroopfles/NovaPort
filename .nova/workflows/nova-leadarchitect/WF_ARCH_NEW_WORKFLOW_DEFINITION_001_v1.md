# Workflow: New Nova Workflow Definition (WF_ARCH_NEW_WORKFLOW_DEFINITION_001_v1)

**Goal:** To define, document, and register a new standardized workflow for use by Nova-Orchestrator or Lead Modes, storing it in the appropriate `.nova/workflows/{mode_slug}/` directory and logging its existence in ConPort.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedWorkflowManager

**Trigger / Recognition:**

- Nova-Orchestrator delegates: "Define a new workflow for [ProcessDescription], to be owned by [TargetModeSlug]."
- LeadArchitect identifies a need to standardize a recurring process.
- User explicitly requests a new standard workflow.

**Reference Milestones for your Single-Step Loop:**

**Milestone NWDef.1: Workflow Design & Drafting**

- **Goal:** Define the core elements and draft the full Markdown content for the new workflow file.
- **Suggested Lead Action:**
  1.  **Define Core Elements:**
      - Determine a clear, versioned **Filename** (e.g., `WF_[MODE]_[NAME]_[ID]_[version].md`).
      - Write the **Goal** of the workflow.
      - Identify the **Primary Actor(s)**.
      - Describe the **Trigger / Recognition** hints.
      - Outline the main **Phases & Steps** (or Milestones), including example `Subtask Briefing Object` structures and key ConPort interactions.
  2.  **Log Intent:** Log a `Decision` to create the new workflow and a main `Progress` item for this entire definition cycle.
  3.  **Draft Content:** Prepare the full, final Markdown content for the new workflow file.

**Milestone NWDef.2: File Creation & ConPort Registration**

- **Goal:** Create the workflow `.md` file on the filesystem and register its metadata in ConPort.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **Delegate to `Nova-SpecializedWorkflowManager`:**
      - **Subtask Goal:** "Create the workflow file `[FileName]` in path `.nova/workflows/[TargetModeSlug]/` and log it to ConPort category `DefinedWorkflows`."
      - **Briefing Details:**
        - Provide the full `Target Path` and `Workflow File Content`.
        - Instruct the specialist to use `write_to_file` to create the file.
        - Instruct the specialist to then use `log_custom_data` to create the `DefinedWorkflows` entry. The briefing must provide all necessary fields for the `value` object: `description`, `path`, `version`, `primary_mode_owner`, and any `tags`.
        - The specialist should return the path to the created file and the key of the new `DefinedWorkflows` entry.

**Milestone NWDef.3: Finalization & Reporting**

- **Goal:** Verify the new workflow and report completion.
- **Suggested Lead Action:**
  1.  **Verify:** Use `read_file` and `get_custom_data` to verify the work of the `WorkflowManager`.
  2.  **Update Progress:** Update the main `Progress` item for the definition cycle to 'DONE'.
  3.  **Update Context:** Update the `active_context.state_of_the_union` to reflect that a new workflow is available.
  4.  **Report:** In your `attempt_completion` to `Nova-Orchestrator`, report the completion, providing the path to the new file and its ConPort key.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData DefinedWorkflows:[Key] (key)
- ActiveContext (`state_of_the_union` update)
