# Workflow: Create Module Template (WF_ARCH_CREATE_MODULE_TEMPLATE_001_v1)

**Goal:** To design and create a standardized, reusable module/service template and store it in the `.nova/templates/` directory for future use.

**Primary Actor:** Nova-LeadArchitect
**Delegated Specialist Actors:** Nova-SpecializedSystemDesigner, Nova-SpecializedWorkflowManager (for file ops)

**Trigger / Recognition:**
- The project frequently requires the creation of similar modules or services (e.g., RESTful APIs, background workers).
- A `LessonsLearned` (key) item suggests that standardizing module scaffolding would reduce errors and improve consistency.
- A strategic decision is made to enforce a standard structure for new components.

**Phases & Steps (managed by Nova-LeadArchitect):**

**Phase MT.1: Template Design & Definition**

1.  **Nova-LeadArchitect: Define Template Scope & Structure**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Log a main `Progress` (integer `id`): "Design and Create Module Template: [TemplateName]". Let this be `[TemplateProgressID]`.
        *   Log a `Decision` (integer `id`) to create the template, outlining its purpose and key technologies.
        *   Delegate the detailed design to Nova-SpecializedSystemDesigner.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedSystemDesigner: Design Template Content**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Design the directory structure and boilerplate file content for the new '[TemplateName]' template."
    *   **`new_task` message for Nova-SpecializedSystemDesigner:**
        ```json
        {
          "Context_Path": "[ProjectName] (ModuleTemplate) -> DesignTemplate (SystemDesigner)",
          "Overall_Architect_Phase_Goal": "Create the '[TemplateName]' module template.",
          "Specialist_Subtask_Goal": "Design the directory and file content for a reusable '[TemplateName]' template.",
          "Specialist_Specific_Instructions": [
            "1. **Define Directory Structure:** Propose a standard directory structure for this type of module (e.g., `/src`, `/tests`, `/config`, `/docs`).",
            "2. **Define Boilerplate Files:** For each directory, specify the essential boilerplate files to include (e.g., `main.py`, `Dockerfile`, `README.md`, `requirements.txt`, `test_main.py`).",
            "3. **Create Boilerplate Content:** For each file, create minimal, high-quality, reusable content. This should include placeholder comments (e.g., `# TODO: Add service-specific logic here`), basic function/class definitions, and standard configuration stubs.",
            "4. **Compile Output:** Consolidate the entire design (directory list, and a list of objects where each object has a `file_path` and `file_content`) into a single structured output."
          ],
          "Required_Input_Context_For_Specialist": {
            "Template_Name": "[e.g., PythonAPIServiceTemplate]",
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig" }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "A structured JSON or YAML object containing the full template design: `{'directories': ['...'], 'files': [{'path': '...', 'content': '...'}]}`."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review the complete template design.

**Phase MT.2: File System Implementation**

3.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedWorkflowManager: Create Template Files**
    *   **DoR Check:** The full template design is available from the SystemDesigner.
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Create the directory structure and all boilerplate files for the '[TemplateName]' template in `.nova/templates/`."
    *   **`new_task` message for Nova-SpecializedWorkflowManager:**
        ```json
        {
          "Context_Path": "[ProjectName] (ModuleTemplate) -> CreateFiles (WorkflowManager)",
          "Overall_Architect_Phase_Goal": "Create the '[TemplateName]' module template.",
          "Specialist_Subtask_Goal": "Create all directories and files for the '[TemplateName]' template under `.nova/templates/[TemplateName]/`.",
          "Specialist_Specific_Instructions": [
            "1. **Create Root Directory:** Use `execute_command` (`mkdir -p`) to create the root directory for the template: `.nova/templates/[TemplateName]/`.",
            "2. **Create Subdirectories:** For each directory specified in the design, use `execute_command` (`mkdir -p`) to create it within the root directory.",
            "3. **Create Files:** For each file specified in the design, use `write_to_file` to create it at the correct path with the provided content."
          ],
          "Required_Input_Context_For_Specialist": {
            "Template_Name": "[TemplateName]",
            "Full_Template_Design_Object": "{... from SystemDesigner ...}"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that all directories and files have been created.",
            "A list of all created file paths."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify file creation using `list_files`.

**Phase MT.3: ConPort Registration & Closure**

4.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Template in ConPort**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Log the newly created module template in ConPort for discoverability."
    *   **Briefing for ConPortSteward:** Instruct them to log a new `CustomData` entry with `category: 'Templates'`, `key: '[TemplateName]_v1'`, and a `value` object containing `{ "description": "...", "path": ".nova/templates/[TemplateName]/", "primary_language": "..." }`.
    *   **Nova-LeadArchitect Action:** Verify ConPort entry.

5.  **Nova-LeadArchitect: Finalize**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Update `[TemplateProgressID]` to 'DONE' and report completion to Nova-Orchestrator.
    *   **Output:** A new, reusable module template is available for the project.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData Templates:[TemplateName]_v1 (key)