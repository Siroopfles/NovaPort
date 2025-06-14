# Workflow: New Code Module Scaffolding and Initial Setup (WF_DEV_NEW_MODULE_SCAFFOLDING_AND_SETUP_001_v1)

**Goal:** To create the basic directory structure, boilerplate files, initial configuration, and basic tests for a new, independent code module or microservice.

**Primary Actor:** Nova-LeadDeveloper
**Primary Specialist Actors:** Nova-SpecializedFeatureImplementer, Nova-SpecializedTestAutomator, Nova-SpecializedCodeDocumenter

**Trigger / Recognition:**
- A new major system component defined by `Nova-LeadArchitect` requires its own isolated module.
- A new feature requires a new, largely independent module.

**Reference Milestones for your Single-Step Loop:**

**Milestone NMS.1: Boilerplate Generation**
*   **Goal:** Create the basic directory structure and essential boilerplate files for the new module.
*   **Suggested Specialist Sequence & Lead Actions:**
    1.  **LeadDeveloper Action:** Log a main `Progress` item and a `Decision` to create the new module. Define the module's root path and basic subdirectory structure.
    2.  **Delegate to `Nova-SpecializedFeatureImplementer`:**
        *   **Subtask Goal:** "Create the directory structure and boilerplate files for [ModuleName]."
        *   **Briefing Details:**
            *   Provide the target root path and list of subdirectories.
            *   Provide a list of boilerplate files to create (e.g., `main.py`, `README.md`, `Dockerfile`, `.env.example`).
            *   Instruct to use `execute_command` (`mkdir -p`) for directories and `write_to_file` for files.
            *   If a relevant template exists in `.nova/templates/`, instruct the specialist to use it as a starting point.

**Milestone NMS.2: Initial Test & Documentation Setup**
*   **Goal:** Set up a basic, passing test and initial documentation stubs.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedTestAutomator`:**
        *   **Subtask Goal:** "Set up the initial test harness and confirm the placeholder test for [ModuleName] runs and passes."
        *   **Briefing Details:**
            *   Specify the testing framework and runner command from `ProjectConfig`.
            *   Instruct to run the test scoped to the new module to confirm the harness is working.
    2.  **Delegate to `Nova-SpecializedCodeDocumenter`:**
        *   **Subtask Goal:** "Create an initial `README.md` and documentation stubs for [ModuleName]."
        *   **Briefing Details:**
            *   Provide the module's purpose.
            *   Instruct to update the module's `README.md` with a title, purpose, and placeholder sections for Usage and Setup.
            *   Instruct to create placeholder `.md` files in the module's `docs/` directory (e.g., `introduction.md`, `api_reference.md`).

**Milestone NMS.3: ConPort Registration & Finalization**
*   **Goal:** Register the new module in ConPort and close out the scaffolding process.
*   **Suggested Lead Action:**
    1.  **Register Module:** Log a new `CustomData SystemArchitecture:[ModuleName]_ModuleOverview_v1` item to ConPort. The `value` should include the module's description, root path, primary language, and an initial version hint (e.g., "0.1.0-alpha").
    2.  **Finalize:** Update the main `Progress` item for the scaffolding task to 'DONE'.
    3.  **Report:** Use `attempt_completion` to report to `Nova-Orchestrator`, providing the path to the new module and the key of its `SystemArchitecture` entry in ConPort.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData SystemArchitecture:[ModuleName]_ModuleOverview_v1 (key)