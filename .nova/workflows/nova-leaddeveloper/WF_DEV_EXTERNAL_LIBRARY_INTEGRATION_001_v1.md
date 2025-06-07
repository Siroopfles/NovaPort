# Workflow: External Library Integration (WF_DEV_EXTERNAL_LIBRARY_INTEGRATION_001_v1)

**Goal:** To safely and effectively integrate a new external library/SDK into the project, including installation, basic configuration, creating wrapper/utility functions, writing example usage, and documenting its use.

**Primary Actor:** Nova-LeadDeveloper (receives task from Nova-Orchestrator, or initiates if a feature implementation requires a new library).
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedFeatureImplementer (for installation, wrappers, examples), Nova-SpecializedTestAutomator (for testing the integration), Nova-SpecializedCodeDocumenter (for documenting usage).

**Trigger / Nova-LeadDeveloper Recognition:**
- A new feature requires functionality best provided by an external library/SDK, and Nova-LeadArchitect has approved its use or LeadDeveloper makes this `Decision`.
- A `Decision` (integer `id`) has been made (by Nova-LeadArchitect or Nova-LeadDeveloper) to adopt a specific new library.
- Updating/replacing an existing external library.

**Pre-requisites by Nova-LeadDeveloper:**
- The specific external library and its version have been chosen (and logged as a `Decision` (integer `id`) in ConPort).
- Understanding of where in the codebase the library will be primarily used (e.g., which modules/services).
- Access to the library's official documentation (URL often stored in the `Decision` or `ProjectConfig`).

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator, or as a self-contained sub-process):**

**Phase ELI.1: Planning & Setup by Nova-LeadDeveloper & Specialists**

1.  **Nova-LeadDeveloper: Define Integration Scope & Plan**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Parse `Subtask Briefing Object` or review `Decision` (integer `id`) regarding the library.
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "Integrate Library: [LibraryName] v[Version]". Let this be `[LibIntProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[LibIntProgressID]_DeveloperPlan` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Plan items:
            1.  Install Library & Update Project Dependencies (Delegate to FeatureImplementer).
            2.  Basic Configuration Setup (if any) (Delegate to FeatureImplementer).
            3.  Develop Wrapper/Utility Functions for Core Use Cases (Delegate to FeatureImplementer).
            4.  Write Basic Usage Example & Unit/Integration Tests for Wrappers (Delegate to FeatureImplementer or TestAutomator).
            5.  Document Library Usage and Configuration (Delegate to CodeDocumenter).
            6.  Log `APIUsage` and relevant `ConfigSettings` (metadata) in ConPort (LeadDeveloper or FeatureImplementer).
    *   **Logic:**
        *   Identify project's dependency management file(s) (e.g., `requirements.txt`, `package.json`, `pom.xml`) from `ProjectConfig:ActiveConfig` (key) or project structure.
        *   Determine if any specific configuration (API keys - names/locations, not values; service URLs) is needed for the library.
    *   **ConPort Action:** Ensure the `Decision` (integer `id`) to use this library (including version) is clear, detailed (rationale, alternatives considered), and linked to `[LibIntProgressID]`.
    *   **Output:** Integration plan ready. `[LibIntProgressID]` known.

2.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Install Library & Configure**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Install [LibraryName] v[Version] into the project and set up any initial configuration stubs or metadata."
    *   **`new_task` message for Nova-SpecializedFeatureImplementer:**
        ```json
        {
          "Context_Path": "[ProjectName] (LibIntegrate_[LibraryName]) -> InstallAndConfigure (FeatureImplementer)",
          "Overall_Developer_Phase_Goal": "Integrate Library: [LibraryName] v[Version].",
          "Specialist_Subtask_Goal": "Install [LibraryName] v[Version] and set up basic configuration metadata.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[LibIntProgressID]`.",
            "Library: [LibraryName], Version: [Version] (from LeadDeveloper context).",
            "1. Add the library as a project dependency using the project's package manager (e.g., `pip install \"[LibraryName]==[Version]\"`, `npm install [LibraryName]@[Version]`). Update relevant dependency files (e.g., `requirements.txt`, `package.json`). Command pattern from `ProjectConfig:ActiveConfig.dependency_management_commands.add` if available, otherwise use standard command for the project's language.",
            "2. If the library requires configuration like API keys or service URLs:",
            "   - DO NOT hardcode secrets in code.",
            "   - Identify the names of environment variables or configuration file keys the library expects (from its documentation).",
            "   - Add these key names as placeholders to the application's example configuration files (e.g., `.env.example`, `config/app_config.yaml.example`).",
            "   - Log a `CustomData ConfigSettings:[LibraryName]_ConfigKeysNeeded_v1` (key) entry in ConPort using `use_mcp_tool` (`tool_name: 'log_custom_data'`). The `value` should be a JSON object detailing: `{\"library_name\": \"[LibraryName]\", \"version\": \"[Version]\", \"required_keys\": [{\"key_name\": \"ENV_VAR_API_KEY_NAME\", \"purpose\": \"API key for service X\", \"example_location\": \".env or app_config.yaml\"}, ...], \"setup_notes\": \"User must provide actual values for these keys in their environment or config file.\"}`.",
            "3. Create a basic initialization/configuration file or section for the library if appropriate (e.g., `src/integrations/[library_name]_client.py` with a function like `initialize_[library_name]_client()` that reads from env/config). This file should contain NO secrets."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[LibIntProgressID_as_string]",
            "Library_Name_And_Version": "[...]",
            "Project_Dependency_File_Paths": "[e.g., requirements.txt, package.json]",
            "ProjectConfig_Ref_For_Dep_Mgmt_Cmd_Optional": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["dependency_management_commands"] }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation of library installation and dependency file updates.",
            "Paths to any new/modified configuration or client initialization files.",
            "ConPort key of any `ConfigSettings` entry created for required keys/placeholders."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action:** Review changes. Update plan/progress.

**Phase ELI.2: Wrapper Development & Example Usage**

3.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Develop Wrappers & Example**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Develop wrapper functions or utility classes for commonly used functionalities of [LibraryName] and create a simple usage example with unit tests."
    *   **`new_task` message for Nova-SpecializedFeatureImplementer:**
        ```json
        {
          "Context_Path": "[ProjectName] (LibIntegrate_[LibraryName]) -> DevelopWrappers (FeatureImplementer)",
          "Overall_Developer_Phase_Goal": "Integrate Library: [LibraryName] v[Version].",
          "Specialist_Subtask_Goal": "Create wrapper functions and a usage example (with unit tests) for [LibraryName].",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[LibIntProgressID]`.",
            "Library: [LibraryName].",
            "1. Based on 'Core_Functionalities_To_Wrap' (provided by LeadDeveloper), identify 2-3 key library functions.",
            "2. Create wrapper functions/classes in a suitable new utility module (e.g., `src/utils/integration_[library_name_slug].py`). These wrappers should:",
            "   - Encapsulate library-specific setup/initialization (using the client from previous step).",
            "   - Simplify the interface for common use cases within our project.",
            "   - Implement basic error handling/translation specific to this library's common errors.",
            "3. Write unit tests for your wrapper functions in the corresponding test directory (e.g., `tests/utils/test_integration_[library_name_slug].py`). Mock any external calls made by the library itself during these unit tests.",
            "4. Create a simple, illustrative usage example (can be part of the unit tests or a separate `examples/use_[library_name_slug].py` script) demonstrating how to use your wrapper functions.",
            "5. Ensure all new code passes linters.",
            "6. Log key wrapper functions or the example as a `CustomData CodeSnippets:[LibraryName]_WrapperExample_v1` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[LibIntProgressID_as_string]",
            "Library_Name": "[...]",
            "Library_Documentation_URL_Or_ConPort_Ref_If_Available": "[...]",
            "Core_Functionalities_To_Wrap_From_LeadDeveloper": "['functionA_to_simplify', 'data_transformation_B']",
            "Path_To_Library_Client_Init_File": "[e.g., src/integrations/[library_name]_client.py]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Paths to created wrapper/utility files and example/test files.",
            "ConPort key of the `CodeSnippets` entry for the example/wrapper.",
            "Confirmation of unit tests passing and linter success."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action:** Review wrappers, example, and tests. Update plan/progress.

**Phase ELI.3: Integration Testing & Documentation**

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Test Integration Points**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** Wrappers and basic unit tests are complete.
    *   **Task:** "Write and execute integration tests that specifically verify the [LibraryName]'s wrapped functionalities within a broader test context, interacting with other project components if applicable."
    *   **Briefing for TestAutomator:** Specify wrapped functions to test, expected behavior based on library docs and project use cases. Explain how to mock external calls if the library itself interacts with external services (if not already handled by wrappers). Focus on how the *project* uses the library via the wrappers.
    *   **Nova-LeadDeveloper Action:** Review test results. If issues, log `ErrorLogs` (key) or instruct TestAutomator to do so, then loop back to FeatureImplementer for fixes to wrappers or library usage. Update plan/progress.

5.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter: Document Library Usage**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** Library integrated and integration tests for wrappers pass.
    *   **Task:** "Document how to use the [LibraryName] integration (wrappers, configuration) for other developers in the project."
    *   **`new_task` message for Nova-SpecializedCodeDocumenter (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (LibIntegrate_[LibraryName]) -> DocumentUsage (CodeDocumenter)",
          "Overall_Developer_Phase_Goal": "Integrate Library: [LibraryName] v[Version].",
          "Specialist_Subtask_Goal": "Create technical documentation for using the [LibraryName] integration.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[LibIntProgressID]`.",
            "Review wrapper code (path: `[WrapperModulePath]`), example usage (`[ExamplePath]`), and ConPort `ConfigSettings:[LibraryName]_ConfigKeysNeeded_v1` (key).",
            "Create/update a Markdown document in `docs/integrations/[library_name_slug].md` (or relevant module README).",
            "Documentation should cover:",
            "  - Purpose of the library in this project.",
            "  - How to install/ensure it's available (if not centrally managed).",
            "  - How to configure it (referencing the `ConfigSettings` entry and example config files).",
            "  - How to use the primary wrapper functions/classes with clear examples.",
            "  - Basic error handling notes specific to the wrappers.",
            "  - Link to the official library documentation.",
            "Ensure documentation is clear, concise, and follows project standards (`ProjectConfig:ActiveConfig.documentation_standards`)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[LibIntProgressID_as_string]",
            "Library_Name": "[...]",
            "Wrapper_Module_Path": "[...]",
            "Example_Usage_Path": "[...]",
            "ConPort_ConfigSettings_Key": "ConfigSettings:[LibraryName]_ConfigKeysNeeded_v1",
            "ProjectConfig_Doc_Standards_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["documentation_standards"] }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": ["Path to the created/updated documentation file(s)."]
        }
        ```
    *   **Nova-LeadDeveloper Action:** Review documentation. Update plan/progress.

**Phase ELI.4: ConPort Logging & Finalization**

6.  **Nova-LeadDeveloper: Log Final ConPort Entries**
    *   **Actor:** Nova-LeadDeveloper (or delegate final logging to FeatureImplementer or CodeDocumenter as part of their last task)
    *   **Action:**
        *   Ensure a `CustomData APIUsage:[LibraryName]_IntegrationNotes_v1` (key) (or similar category like `ExternalServices` or `LibraryUsage`) entry is created in ConPort using `use_mcp_tool` (`tool_name: 'log_custom_data'`).
        *   The `value` should summarize:
            *   `library_name`: "[LibraryName]"
            *   `version_integrated`: "[Version]"
            *   `purpose_in_project`: "Used for X, Y, Z functionalities in [Module/Feature]."
            *   `official_documentation_url`: "[URL]"
            *   `internal_wrapper_module_path`: "[Path to wrapper, e.g., src/utils/integration_[library_name_slug].py]"
            *   `conport_config_keys_ref`: "CustomData ConfigSettings:[LibraryName]_ConfigKeysNeeded_v1 (key)"
            *   `internal_usage_doc_path`: "docs/integrations/[library_name_slug].md"
            *   `key_wrapper_functions_summary`: "[Brief list of main wrappers created]"
        *   Link this `APIUsage` (key) (or equivalent) entry to the original `Decision` (integer `id`) for adopting the library, and to `[LibIntProgressID]` using `use_mcp_tool` (`tool_name: 'link_conport_items'`).
    *   **Output:** Comprehensive ConPort record of the library integration.

7.  **Nova-LeadDeveloper: Finalize Library Integration**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Update main `Progress` (`[LibIntProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "Library [LibraryName] v[Version] successfully integrated, tested, and documented. See `APIUsage:[LibraryName]_IntegrationNotes_v1`."
    *   **Output:** Library integration process documented and closed.

8.  **Nova-LeadDeveloper: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Report completion, key ConPort `APIUsage` (key) (or equivalent) entry, and confirmation of successful integration testing and documentation.

**Key ConPort Items Involved:**
- Progress (integer `id`): Overall phase, specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[LibIntProgressID]_DeveloperPlan (key).
- Decisions (integer `id`): (Read) Decision to use the library. (Write) Decisions on wrapper design, configuration approach.
- CustomData ConfigSettings:[LibraryName]_ConfigKeysNeeded_v1 (key).
- CustomData CodeSnippets:[LibraryName]_WrapperExample_v1 (key).
- CustomData APIUsage:[LibraryName]_IntegrationNotes_v1 (key) (or similar like `LibraryUsage`).
- (Potentially) `ErrorLogs` (key) if integration tests reveal issues with the library or its use.