# Workflow: New Code Module Scaffolding and Initial Setup (WF_DEV_NEW_MODULE_SCAFFOLDING_AND_SETUP_001_v1)

**Goal:** To create the basic directory structure, boilerplate files, initial configuration, and basic tests for a new, independent code module or microservice within the project, managed by Nova-LeadDeveloper.

**Primary Actor:** Nova-LeadDeveloper (receives task from Nova-Orchestrator, or initiates if a new major component defined by Nova-LeadArchitect needs its own module).
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedFeatureImplementer (for boilerplate code & dir structure), Nova-SpecializedTestAutomator (for initial test setup), Nova-SpecializedCodeDocumenter (for initial README/docs).

**Trigger / Nova-LeadDeveloper Recognition:**
- Nova-LeadArchitect, via Nova-Orchestrator, defines a new major system component or service (e.g., in `SystemArchitecture:[key]`) that requires its own isolated directory structure and setup. Orchestrator delegates this scaffolding task to LeadDeveloper.
- A new feature requires a new, largely independent module/service, and LeadDeveloper decides to scaffold it.
- Refactoring efforts identify a need to extract functionality into a new, separate module.

**Pre-requisites by Nova-LeadDeveloper:**
- A clear name and purpose for the new module/service (from LeadArchitect or defined by LeadDeveloper).
- Basic architectural guidance (e.g., primary language/framework from `ProjectConfig:ActiveConfig` (key), interaction patterns with other modules from `SystemArchitecture:[key]`).
- (Optional) A relevant module template might exist in `.nova/templates/` (LeadDeveloper to check or instruct specialist).

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator, or as a self-contained sub-process):**

**Phase NMS.1: Planning & Boilerplate Generation**

1.  **Nova-LeadDeveloper: Define Module Scope & Initial Structure**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Parse `Subtask Briefing Object` if from Nova-Orchestrator, or define scope internally based on architectural input.
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Scaffold New Module: [ModuleName]\"}`). Let this be `[ScaffoldProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[ScaffoldProgressID]_DeveloperPlan` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Plan items:
            1.  Create Directory Structure & Basic Boilerplate Files (Delegate to FeatureImplementer).
            2.  Setup Initial Test Harness & Placeholder Test (Delegate to TestAutomator).
            3.  Create Initial README & Basic Doc Stubs (Delegate to CodeDocumenter).
            4.  Register Module in ConPort `SystemArchitecture` (LeadDeveloper or delegate to FeatureImplementer/CodeDocumenter).
    *   **Logic:**
        *   Determine the root path for the new module (e.g., `src/modules/[module_name]/`, `services/[service_name]/`).
        *   Define basic subdirectory structure (e.g., `tests/`, `docs/`, `config/`, main source folders like `src/` within module).
        *   Identify core boilerplate files needed (e.g., `__init__.py` for Python, `main.go`, `package.json`, `Dockerfile`, basic config file like `config.yaml.example`, an entry point file like `app.py` or `server.js`).
    *   **ConPort Action:** Log a `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"summary\": \"Decision to create new module: [ModuleName]\", \"rationale\": \"[Purpose of the module]\"}`) for creating this module. Link to `[ScaffoldProgressID]`.
    *   **Output:** Module structure and boilerplate file list defined. `[ScaffoldProgressID]` known.

2.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Create Directory Structure & Boilerplate Files**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Create the defined directory structure and essential boilerplate files for the new module [ModuleName], potentially using a template from `.nova/templates/`."
    *   **`new_task` message for Nova-SpecializedFeatureImplementer:**
        ```json
        {
          "Context_Path": "[ProjectName] (ScaffoldModule_[ModuleName]) -> CreateDirsAndFiles (FeatureImplementer)",
          "Overall_Developer_Phase_Goal": "Scaffold New Module: [ModuleName].",
          "Specialist_Subtask_Goal": "Create directory structure and boilerplate files for [ModuleName].",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[ScaffoldProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Subtask: Create directory structure and boilerplate files for [ModuleName]\", \"parent_id\": [ScaffoldProgressID_as_integer]} `).",
            "Module Name: [ModuleName].",
            "Target Root Path for Module: [path/to/module_root_from_LeadDeveloper].",
            "Required Subdirectories within Module Root: [List: e.g., 'src', 'tests', 'docs', 'config']. Create these using `execute_command` (`mkdir -p ...`).",
            "Boilerplate Files to Create using `write_to_file` (with minimal functional content or comments):",
            "  - `[path/to/module_root]/src/main.[ext]` (e.g., basic hello world or module entry point).",
            "  - `[path/to/module_root]/tests/test_basic.[ext]` (e.g., a single passing placeholder unit test).",
            "  - `[path/to/module_root]/README.md` (Title: Module [ModuleName], Purpose: [From LeadDeveloper]).",
            "  - `[path/to/module_root]/config/default.yaml.example` (Empty or with placeholder keys).",
            "(Optional) If LeadDeveloper specified a template path in `.nova/templates/[template_name]/`, first check if it exists (`list_files`). If yes, copy its structure and files as a starting point."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[ScaffoldProgressID_as_integer]",
            "ModuleName": "[ModuleName]",
            "Target_Module_Root_Path_From_LeadDeveloper": "[...]",
            "List_Of_Subdirectories_To_Create": "['src', 'tests', 'docs', 'config']",
            "List_Of_Boilerplate_Files_And_Content_Hints": "[{path: 'src/main.py', content_hint: '# Main entry point for [ModuleName]'}, ...]",
            "Optional_Template_Path_From_LeadDeveloper": "[e.g., .nova/templates/python_service_template/]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that directory structure is created.",
            "List of paths for all created boilerplate files."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Verify structure (`list_files`). Update plan/progress.

3.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Setup Initial Test Harness**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Initialize the testing framework and a basic passing test for the new module [ModuleName]."
    *   **`new_task` message for Nova-SpecializedTestAutomator:**
        ```json
        {
          "Context_Path": "[ProjectName] (ScaffoldModule_[ModuleName]) -> SetupTestHarness (TestAutomator)",
          "Overall_Developer_Phase_Goal": "Scaffold New Module: [ModuleName].",
          "Specialist_Subtask_Goal": "Setup initial test harness and confirm placeholder test runs for [ModuleName].",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[ScaffoldProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
            "Module Path: [path/to/module_root_from_LeadDeveloper].",
            "Testing Framework (from `ProjectConfig:ActiveConfig.testing.framework`): [e.g., Pytest, Jest].",
            "Test Runner Command (from `ProjectConfig:ActiveConfig.testing.commands.run_all`): [e.g., 'pytest', 'npm test --'].",
            "1. If needed, create/update test configuration files (e.g., `pytest.ini`, `jest.config.js`) in the module's test directory (`[ModulePath]/tests/`).",
            "2. Ensure the placeholder test created by FeatureImplementer (e.g., `[ModulePath]/tests/test_basic.[ext]`) can be discovered and run by the test runner.",
            "3. Execute the test runner command (e.g., `pytest [ModulePath]/tests/` or `npm test -- [ModulePath]/tests/test_basic.js`) scoped to this new module to confirm the placeholder test passes. Use `execute_command`.",
            "Report the exact command used and its full output."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[ScaffoldProgressID_as_integer]",
            "Module_Path": "[path/to/module_root_from_LeadDeveloper]",
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["testing"] },
            "Placeholder_Test_File_Path": "[path/to/module_root]/tests/test_basic.[ext]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation of test harness setup (any config files created/modified).",
            "Full output of the initial test run (showing placeholder test passing)."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action after Specialist's `attempt_completion`:** Verify test setup and pass status. Update plan/progress.

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter: Create Initial README & Doc Stubs**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Create an initial README.md for [ModuleName] and stub documentation files in its `docs/` directory."
    *   **`new_task` message for Nova-SpecializedCodeDocumenter (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (ScaffoldModule_[ModuleName]) -> CreateInitialDocs (CodeDocumenter)",
          "Overall_Developer_Phase_Goal": "Scaffold New Module: [ModuleName].",
          "Specialist_Subtask_Goal": "Create initial README.md and documentation stubs for [ModuleName].",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[ScaffoldProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`).",
            "Module Path: [path/to/module_root_from_LeadDeveloper].",
            "Module Purpose: [Purpose_From_LeadDeveloper_Or_Decision].",
            "1. Update/Ensure `[ModulePath]/README.md` contains: Title (`# Module: [ModuleName]`), Purpose (`## Purpose\n[ModulePurpose]`), Basic Usage (placeholder: `## Basic Usage\nTODO`), Setup (placeholder: `## Setup\nTODO`). Use `apply_diff` or `write_to_file`.",
            "2. In `[ModulePath]/docs/`, create placeholder files using `write_to_file`:",
            "   - `introduction.md` (Content: `# Introduction to [ModuleName]\n\nTODO: Overview of the module...`)",
            "   - `api_reference.md` (Content: `# API Reference for [ModuleName]\n\nTODO: Detailed API documentation...`) (if applicable)",
            "   - `configuration.md` (Content: `# Configuration for [ModuleName]\n\nTODO: Details on configuring the module...`)"
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[ScaffoldProgressID_as_integer]",
            "Module_Path": "[...]", "Module_Name": "[...]", "Module_Purpose": "[...]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": ["List of paths for all created/updated documentation files."]
        }
        ```
    *   **Nova-LeadDeveloper Action:** Verify files. Update plan/progress.

**Phase NMS.2: ConPort Registration & Finalization**

5.  **Nova-LeadDeveloper: Register Module in ConPort `SystemArchitecture`**
    *   **Actor:** Nova-LeadDeveloper (or delegate to Nova-SpecializedCodeDocumenter or FeatureImplementer if appropriate for their last step)
    *   **Action:**
        *   Log a new `CustomData SystemArchitecture:[ModuleName]_ModuleOverview_v1` (key) entry in ConPort using `use_mcp_tool` (`tool_name: 'log_custom_data'`).
        *   Value (JSON object) should include:
            *   `description`: Purpose of the module (from initial Decision/briefing).
            *   `module_root_path`: File path to the module's root (e.g., `src/modules/[module_name]/`).
            *   `primary_language_framework`: "[Language/Framework from ProjectConfig]".
            *   `key_files_created`: List of important entry points or config files created by FeatureImplementer.
            *   `interface_status`: "Scaffolded - Awaiting Detailed Design/Implementation".
            *   `dependencies_internal`: [] (Initially empty).
            *   `dependencies_external`: [] (Initially empty).
            *   `version`: "0.1.0-alpha" (or similar initial).
        *   Link this new `SystemArchitecture` (key) entry to the main `Progress` item (`[ScaffoldProgressID]`) using `use_mcp_tool` (`tool_name: 'link_conport_items'`).
    *   **Output:** Module architecturally registered in ConPort.

6.  **Nova-LeadDeveloper: Finalize Scaffolding**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Update main `Progress` (`[ScaffoldProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "Scaffolding for module [ModuleName] complete. Initial files, tests, docs, and ConPort entry created."
        *   If this was a major addition, coordinate with Nova-Orchestrator to update `active_context.state_of_the_union`.
    *   **Output:** Module scaffolding process documented and closed.

7.  **Nova-LeadDeveloper: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Report completion, path to the new module, and key ConPort `SystemArchitecture:[ModuleName]_ModuleOverview_v1` (key) for the new module.

**Key ConPort Items Involved:**
- Progress (integer `id`): Overall phase, specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[ScaffoldProgressID]_DeveloperPlan (key).
- Decisions (integer `id`): For creating the module and its chosen path/structure.
- CustomData SystemArchitecture:[ModuleName]_ModuleOverview_v1 (key): Registering the new module.
- (Reads) ProjectConfig:ActiveConfig (key).