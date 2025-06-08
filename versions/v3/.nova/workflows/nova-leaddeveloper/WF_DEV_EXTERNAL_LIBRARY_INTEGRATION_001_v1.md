# Workflow: External Library Integration (WF_DEV_EXTERNAL_LIBRARY_INTEGRATION_001_v1)

**Goal:** To safely and effectively integrate a new external library/SDK into the project, including installation, basic configuration, creating wrapper/utility functions, writing example usage, and documenting its use.

**Primary Orchestrator Actor:** Nova-LeadDeveloper (receives task from Nova-Orchestrator, or initiates if a feature implementation requires a new library).
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedFeatureImplementer (for installation, wrappers, examples), Nova-SpecializedTestAutomator (for testing the integration), Nova-SpecializedCodeDocumenter (for documenting usage).

**Trigger / Nova-LeadDeveloper Recognition:**
- A new feature requires functionality best provided by an external library/SDK.
- A `Decision` (integer `id`) has been made (by Nova-LeadArchitect or Nova-LeadDeveloper) to adopt a specific new library.
- Updating/replacing an existing external library.

**Pre-requisites by Nova-LeadDeveloper:**
- The specific external library and its version have been chosen (and logged as a `Decision` (integer `id`)).
- Understanding of where in the codebase the library will be primarily used.
- Access to the library's documentation.

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator, or as a self-contained sub-process):**

**Phase ELI.1: Planning & Setup by Nova-LeadDeveloper & Specialists**

1.  **Nova-LeadDeveloper: Define Integration Scope & Plan**
    *   **Action:**
        *   Parse `Subtask Briefing Object` or `Decision` (integer `id`) regarding the library.
        *   Log main `Progress` (integer `id`) item: "Integrate Library: [LibraryName] v[Version]".
        *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[LibIntProgressID]_DeveloperPlan` (key)). Plan items:
            1.  Install Library & Update Dependencies (FeatureImplementer).
            2.  Basic Configuration Setup (FeatureImplementer).
            3.  Develop Wrapper/Utility Functions (FeatureImplementer).
            4.  Write Basic Usage Example/Test (FeatureImplementer or TestAutomator).
            5.  Document Library Usage (CodeDocumenter).
            6.  Log `APIUsage` or `ConfigSettings` in ConPort (FeatureImplementer or LeadDeveloper).
    *   **Logic:**
        *   Identify project's dependency management file(s) (e.g., `requirements.txt`, `package.json`, `pom.xml`).
        *   Determine if any specific configuration (API keys - not values, just names/locations; service URLs) is needed for the library, to be stored in project's config files or ConPort `ConfigSettings` (key) (for metadata about config, not secrets).
    *   **ConPort:** Ensure the `Decision` (integer `id`) to use this library is clear and linked.
    *   **Output:** Integration plan ready.

2.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Install Library & Configure**
    *   **Task:** "Install [LibraryName] v[Version] into the project and set up any initial configuration stubs."
    *   **`new_task` message for Nova-SpecializedFeatureImplementer:**
        ```
        Subtask_Briefing:
          Overall_Developer_Phase_Goal: "Integrate Library: [LibraryName] v[Version]."
          Specialist_Subtask_Goal: "Install [LibraryName] v[Version] and set up basic configuration."
          Specialist_Specific_Instructions:
            - "Library: [LibraryName], Version: [Version]."
            - "1. Add the library as a project dependency using the project's package manager (e.g., `pip install [LibraryName]==[Version]`, `npm install [LibraryName]@[Version]`). Update dependency files (e.g., `requirements.txt`, `package.json`). Command from `ProjectConfig:ActiveConfig.dependency_management_commands.add` if available."
            - "2. If the library requires API keys or service URLs:
                  - DO NOT hardcode secrets.
                  - Add placeholders or environment variable names to the application's configuration files (e.g., `.env.example`, `config/app_config.py`).
                  - Log a `CustomData ConfigSettings:[LibraryName]_ConfigKeys_Needed` (key) entry in ConPort detailing the names of env vars or config keys required, their purpose, and where they should be set by the user/ops, but NOT their values."
            - "3. Create a basic initialization/configuration file or section for the library if appropriate (e.g., `src/integrations/[library_name]_client.py` with a function to init the client using config values)."
          Required_Input_Context_For_Specialist:
            - Library_Name_And_Version: "[...]"
            - Project_Dependency_File_Paths: "[e.g., requirements.txt, package.json]"
            - (Optional) ProjectConfig_Ref_Key: "ProjectConfig:ActiveConfig" (for dep management commands)
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation of library installation and dependency file updates."
            - "Paths to any new/modified configuration or client initialization files."
            - "ConPort key of any `ConfigSettings` entry created for required keys/placeholders."
        ```
    *   **Nova-LeadDeveloper Action:** Review changes. Update plan/progress.

**Phase ELI.2: Wrapper Development & Example Usage by Nova-SpecializedFeatureImplementer**

3.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedFeatureImplementer: Develop Wrappers & Example**
    *   **Task:** "Develop wrapper functions or utility classes for commonly used functionalities of [LibraryName] and create a simple usage example."
    *   **`new_task` message for Nova-SpecializedFeatureImplementer:**
        ```
        Subtask_Briefing:
          Overall_Developer_Phase_Goal: "Integrate Library: [LibraryName] v[Version]."
          Specialist_Subtask_Goal: "Create wrapper functions and a usage example for [LibraryName]."
          Specialist_Specific_Instructions:
            - "Library: [LibraryName]."
            - "1. Identify 2-3 core functionalities of the library that will be frequently used in this project."
            - "2. Create wrapper functions/classes in a suitable utility module (e.g., `src/utils/[library_name]_helpers.py`) to simplify using these functionalities and to encapsulate library-specific logic. These wrappers should handle initialization and basic error handling."
            - "3. Write a small, self-contained example script or unit test (`tests/examples/test_use_[library_name].py`) demonstrating how to use your wrapper functions for a common use case."
            - "4. Log key wrapper functions or the example as a `CustomData CodeSnippets:[LibraryName]_WrapperExample` (key)."
          Required_Input_Context_For_Specialist:
            - Library_Name: "[...]"
            - Library_Documentation_URL_Or_ConPort_Ref: "[...]"
            - Core_Functionalities_To_Wrap: "[List from LeadDeveloper]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Paths to created wrapper/utility files and example/test files."
            - "ConPort key of the `CodeSnippets` entry for the example/wrapper."
        ```
    *   **Nova-LeadDeveloper Action:** Review wrappers and example. Update plan/progress.

**Phase ELI.3: Testing & Documentation by Specialists**

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedTestAutomator: Test Integration Points**
    *   **Task:** "Write and execute tests that specifically verify the integration of [LibraryName]'s wrapped functionalities within a test context."
    *   **Briefing for TestAutomator:** Specify wrapped functions, expected behavior based on library docs, and how to mock external calls if the library talks to a service. Expect test pass/fail report.
    *   **Nova-LeadDeveloper Action:** Review test results. If issues, loop back to FeatureImplementer. Update plan/progress.

5.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter: Document Library Usage**
    *   **Task:** "Document how to use the [LibraryName] integration (wrappers, configuration) for other developers in the project."
    *   **Briefing for CodeDocumenter:** Point to wrapper code, example script, ConPort `ConfigSettings` (key) entry. Instruct to create/update a page in `/docs/integrations/[LibraryName].md` or relevant module README.
    *   **Nova-LeadDeveloper Action:** Review documentation. Update plan/progress.

**Phase ELI.4: ConPort Logging & Finalization by Nova-LeadDeveloper**

6.  **Nova-LeadDeveloper: Log Final ConPort Entries**
    *   **Action:**
        *   Ensure a `CustomData APIUsage:[LibraryName]_IntegrationNotes_v1` (key) entry is created in ConPort summarizing:
            *   Purpose of the library in the project.
            *   Version used.
            *   Link to official documentation.
            *   Link to internal wrapper/utility module (`CodeSnippets` (key) or file path).
            *   Link to `ConfigSettings` (key) for setup.
            *   Link to internal documentation (`/docs/integrations/[LibraryName].md`).
        *   Link this `APIUsage` (key) entry to the original `Decision` (integer `id`) for adopting the library.
    *   **Output:** Comprehensive ConPort record of the library integration.

7.  **Nova-LeadDeveloper: Finalize Library Integration**
    *   **Action:** Update main `Progress` (integer `id`) for "Integrate Library" to DONE.
    *   **Output:** Library integration process documented and closed.

8.  **Nova-LeadDeveloper: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, key ConPort `APIUsage` (key) entry, and confirmation of successful integration testing.

**Key ConPort Items Created/Updated:**
-   `Progress` (integer `id`): Overall phase, specialist subtasks.
-   `CustomData LeadPhaseExecutionPlan:[LibIntProgressID]_DeveloperPlan` (key).
-   `Decisions` (integer `id`): (Read) Decision to use the library. (Write) Decisions on wrapper design.
-   `CustomData ConfigSettings:[LibraryName]_ConfigKeys_Needed` (key).
-   `CustomData CodeSnippets:[LibraryName]_WrapperExample` (key).
-   `CustomData APIUsage:[LibraryName]_IntegrationNotes_v1` (key).
-   (Potentially) `ErrorLogs` (key) if integration tests reveal issues.