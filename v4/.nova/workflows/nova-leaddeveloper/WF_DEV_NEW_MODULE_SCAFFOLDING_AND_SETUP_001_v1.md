# Workflow: New Code Module Scaffolding and Initial Setup (WF_DEV_NEW_MODULE_SCAFFOLDING_AND_SETUP_001_v1)

**Goal:** To create the basic directory structure, boilerplate files, initial configuration, and basic tests for a new, independent code module or microservice within the project, managed by Nova-LeadDeveloper.

**Primary Orchestrator Actor:** Nova-LeadDeveloper (receives task from Nova-Orchestrator, or initiates if a new major component defined by Nova-LeadArchitect needs its own module).
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedFeatureImplementer (for boilerplate code), Nova-SpecializedTestAutomator (for initial test setup), Nova-SpecializedCodeDocumenter (for initial README/docs).

**Trigger / Nova-LeadDeveloper Recognition:**
- Nova-LeadArchitect defines a new major system component or service that requires its own isolated directory structure and setup.
- A new feature requires a new, largely independent module/service.
- Refactoring efforts identify a need to extract functionality into a new, separate module.

**Pre-requisites by Nova-LeadDeveloper:**
- A clear name and purpose for the new module/service.
- Basic architectural guidance from Nova-LeadArchitect (e.g., primary language/framework from `ProjectConfig:ActiveConfig` (key), interaction patterns with other modules via `SystemArchitecture:[key]`).
- (Optional) A relevant module template might exist in `.nova/templates/`.

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator, or as a self-contained sub-process):**

**Phase NMS.1: Planning & Boilerplate Generation by Nova-LeadDeveloper & Specialists**

1.  **Nova-LeadDeveloper: Define Module Scope & Initial Structure**
    *   **Action:**
        *   Parse `Subtask Briefing Object` if from Nova-Orchestrator, or define scope internally.
        *   Log main `Progress` (integer `id`) item: "Scaffold New Module: [ModuleName]".
        *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[ScaffoldProgressID]_DeveloperPlan` (key)). Plan items:
            1.  Create Directory Structure & Basic Files (FeatureImplementer).
            2.  Setup Initial Test Harness (TestAutomator).
            3.  Create Initial README & Doc Stubs (CodeDocumenter).
            4.  Log Module in ConPort SystemArchitecture (LeadDeveloper or ConPortSteward via LeadArchitect).
    *   **Logic:**
        *   Determine the root path for the new module (e.g., `src/modules/[module_name]/`, `services/[service_name]/`).
        *   Define basic subdirectory structure (e.g., `tests/`, `docs/`, `config/`, main source folders).
        *   Identify core boilerplate files needed (e.g., `__init__.py`, `main.go`, `package.json`, `Dockerfile`, basic config file, entry point file).
    *   **ConPort:** Log a `Decision` (integer `id`) for creating this module, its purpose, and chosen root path.
    *   **Output:** Module structure and boilerplate file list defined.

2.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Create Directory Structure & Boilerplate Files**
    *   **Task:** "Create the defined directory structure and essential boilerplate files for the new module [ModuleName], potentially using a template from `.nova/templates/`."
    *   **`new_task` message for Nova-SpecializedFeatureImplementer:**
        ```
        Subtask_Briefing:
          Overall_Developer_Phase_Goal: "Scaffold New Module: [ModuleName]."
          Specialist_Subtask_Goal: "Create directory structure and boilerplate files for [ModuleName]."
          Specialist_Specific_Instructions:
            - "Module Name: [ModuleName]."
            - "Target Root Path: [path/to/module_root]."
            - "Required Subdirectories: [List: e.g., 'src', 'tests', 'docs']."
            - "Boilerplate Files to Create (with minimal functional content or comments):"
            - "  - `[path/to/module_root]/src/main.[ext]` (e.g., basic hello world or module entry)."
            - "  - `[path/to/module_root]/tests/test_basic.[ext]` (e.g., a single passing placeholder test)."
            - "  - `[path/to/module_root]/README.md` (basic title and purpose)."
            - "  - `[path/to/module_root]/config/default.json` (empty JSON object or basic structure)."
            - "(Optional) If a template exists at `.nova/templates/[template_name]/`, copy its structure and files as a starting point instead of creating from scratch. Then adapt as needed."
            - "Use `execute_command` for `mkdir`. Use `write_to_file` for new boilerplate files."
          Required_Input_Context_For_Specialist:
            - ModuleName: "[ModuleName]"
            - TargetBasePathForModule: "[e.g., src/modules/]"
            - ListOfSubdirectories: "['src', 'tests', 'docs', 'config']"
            - ListOfBoilerplateFilesAndContentHints: "[{path: 'src/main.py', hint: '# Main entry point'}, ...]"
            - (Optional) Template_Path_If_Applicable: ".nova/templates/python_service_template/"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation that directory structure is created."
            - "List of paths for all created boilerplate files."
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Verify structure. Update plan and progress.

3.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Setup Initial Test Harness**
    *   **Task:** "Initialize the testing framework and a basic passing test for the new module [ModuleName]."
    *   **`new_task` message for Nova-SpecializedTestAutomator:**
        ```
        Subtask_Briefing:
          Overall_Developer_Phase_Goal: "Scaffold New Module: [ModuleName]."
          Specialist_Subtask_Goal: "Setup initial test harness for [ModuleName]."
          Specialist_Specific_Instructions:
            - "Module Path: [path/to/module_root]."
            - "Testing Framework (from `ProjectConfig:ActiveConfig.testing_preferences`): [e.g., Pytest, Jest]."
            - "1. If needed, create/update test configuration files (e.g., `pytest.ini`, `jest.config.js`) in the module's test directory."
            - "2. Ensure the placeholder test created by FeatureImplementer (e.g., `tests/test_basic.[ext]`) can be discovered and run by the test runner."
            - "3. Execute the test runner command (from `ProjectConfig`) scoped to this new module to confirm the placeholder test passes."
            - "Report the command used and its output."
          Required_Input_Context_For_Specialist:
            - Module_Path: "[path/to/module_root]"
            - ProjectConfig_Ref: { type: "custom_data", category: "ProjectConfig", key: "ActiveConfig", fields_needed: ["testing_preferences"] }
            - Placeholder_Test_File_Path: "[path/to/module_root]/tests/test_basic.[ext]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation of test harness setup."
            - "Output of the initial test run (showing placeholder test passing)."
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Verify test setup. Update plan and progress.

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter: Create Initial README & Doc Stubs**
    *   **Task:** "Create an initial README.md for [ModuleName] and stub documentation files."
    *   **Briefing for CodeDocumenter:** Provide module name, purpose. Instruct to create a basic README in the module root and placeholder files in its `docs/` subfolder (e.g., `introduction.md`, `api_guide.md`).
    *   **Nova-LeadDeveloper Action:** Verify files. Update plan/progress.

**Phase NMS.2: ConPort Registration & Finalization by Nova-LeadDeveloper**

5.  **Nova-LeadDeveloper: Register Module in ConPort SystemArchitecture**
    *   **Action:**
        *   Log a new `CustomData SystemArchitecture:[ModuleName]_ModuleOverview_v1` (key) entry in ConPort.
        *   Value should include:
            *   `description`: Purpose of the module.
            *   `path`: File path to the module's root.
            *   `key_files`: List of important entry points or config files created.
            *   `interface_status`: "Scaffolded - Awaiting Detailed Design/Implementation".
            *   `dependencies`: (Initially empty or high-level).
        *   Link this new `SystemArchitecture` (key) entry to the main `Progress` (integer `id`) for scaffolding this module.
    *   **Output:** Module architecturally registered in ConPort.

6.  **Nova-LeadDeveloper: Finalize Scaffolding**
    *   **Action:**
        *   Update main `Progress` (integer `id`) for "Scaffold New Module" to DONE.
        *   If this was a major addition, consider if `active_context.state_of_the_union` needs an update (coordinate with Nova-Orchestrator if so).
    *   **Output:** Module scaffolding process documented and closed.

7.  **Nova-LeadDeveloper: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, path to the new module, and key ConPort `SystemArchitecture:[ModuleName]_ModuleOverview_v1` (key) for the new module.

**Key ConPort Items Created/Updated:**
-   `Progress` (integer `id`): Overall phase, specialist subtasks.
-   `CustomData LeadPhaseExecutionPlan:[ScaffoldProgressID]_DeveloperPlan` (key).
-   `Decisions` (integer `id`): For creating the module and its chosen path/structure.
-   `CustomData SystemArchitecture:[ModuleName]_ModuleOverview_v1` (key): Registering the new module.
-   (Potentially) Links between the new module's `SystemArchitecture` (key) entry and other related architectural components or features.