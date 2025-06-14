# Workflow: Create Module Template (WF_ARCH_CREATE_MODULE_TEMPLATE_001_v1)

**Goal:** To design and create a standardized, reusable module/service template and store it in the `.nova/templates/` directory for future use.

**Primary Actor:** Nova-LeadArchitect
**Delegated Specialist Actors:** Nova-SpecializedSystemDesigner, Nova-SpecializedWorkflowManager, Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- The project frequently requires the creation of similar modules or services.
- A `LessonsLearned` item suggests that standardizing module scaffolding would improve consistency.
- A strategic decision is made to enforce a standard structure for new components.

**Reference Milestones for your Single-Step Loop:**

**Milestone MT.1: Template Design**
*   **Goal:** Define the full directory structure and boilerplate file content for the new template.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **LeadArchitect Action:** Log a main `Progress` item and a `Decision` to create the template.
    2.  **Delegate to `Nova-SpecializedSystemDesigner`:**
        *   **Subtask Goal:** "Design the directory structure and boilerplate file content for the new '[TemplateName]' template."
        *   **Briefing Details:**
            *   Instruct the specialist to define a standard directory structure (e.g., `/src`, `/tests`).
            *   Instruct them to specify boilerplate files for each directory (e.g., `main.py`, `README.md`).
            *   Request minimal, high-quality, reusable content for each file, including placeholders.
            *   The specialist should return a single structured object containing the full template design (`{'directories': [...], 'files': [...]}`).

**Milestone MT.2: File System Implementation**
*   **DoR Check:** The full template design from the `SystemDesigner` is available.
*   **Goal:** Create the template's directory structure and files on the file system.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedWorkflowManager`:**
        *   **Subtask Goal:** "Create all directories and files for the '[TemplateName]' template under `.nova/templates/[TemplateName]/`."
        *   **Briefing Details:**
            *   Provide the full template design object from the previous milestone.
            *   Instruct the specialist to use `execute_command` (`mkdir -p`) to create the directory structure.
            *   Instruct them to use `write_to_file` to create each boilerplate file with its content.
            *   The specialist should return a list of all created file paths.

**Milestone MT.3: ConPort Registration & Closure**
*   **DoR Check:** All template files have been created on the filesystem.
*   **Goal:** Log the new template in ConPort for discoverability and finalize the process.
*   **Suggested Specialist Sequence & Lead Actions:**
    1.  **Delegate to `Nova-SpecializedConPortSteward`:**
        *   **Subtask Goal:** "Log the newly created module template in ConPort for discoverability."
        *   **Briefing Details:**
            *   Instruct the specialist to use `log_custom_data` to create a new entry in the `Templates` category.
            *   The `value` object should include the template's `description`, `path` on the filesystem, `primary_language`, and `tags`.
            *   The specialist should return the key of the new ConPort entry.
    2.  **LeadArchitect Action:**
        *   Verify all steps are complete.
        *   Update the main `Progress` item to 'DONE'.
        *   Report completion to `Nova-Orchestrator`.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData Templates:[TemplateName]_v1 (key)