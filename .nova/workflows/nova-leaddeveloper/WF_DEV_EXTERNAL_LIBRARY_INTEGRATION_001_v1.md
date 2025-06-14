# Workflow: External Library Integration (WF_DEV_EXTERNAL_LIBRARY_INTEGRATION_001_v1)

**Goal:** To safely and effectively integrate a new external library/SDK into the project, including installation, configuration, creating wrappers, and documenting its use.

**Primary Actor:** Nova-LeadDeveloper
**Primary Specialist Actors:** Nova-SpecializedFeatureImplementer, Nova-SpecializedTestAutomator, Nova-SpecializedCodeDocumenter

**Trigger / Recognition:**

- A new feature requires functionality best provided by an external library.
- A `Decision` has been made to adopt a specific new library.

**Reference Milestones for your Single-Step Loop:**

**Milestone ELI.0: Pre-flight & Readiness Check**

- **Goal:** Verify that the integration is approved and the project is properly configured.
- **Suggested Lead Action:**
  1.  Your first action MUST be a "Definition of Ready" check.
  2.  Use `use_mcp_tool` to retrieve the `Decision` that approves using this library.
  3.  Use `use_mcp_tool` to retrieve `ProjectConfig:ActiveConfig` and verify that dependency management commands are defined.
  4.  **Gated Check:** If the approval `Decision` is missing or dependency commands are not configured, `attempt_completion` with a `BLOCKER:` status. Do not proceed.

**Milestone ELI.1: Installation & Configuration**

- **Goal:** Install the library and set up any required configuration metadata.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **LeadDeveloper Action:** Log a main `Progress` item for this integration.
  2.  **Delegate to `Nova-SpecializedFeatureImplementer`:**
      - **Subtask Goal:** "Install [LibraryName] v[Version] and set up basic configuration metadata."
      - **Briefing Details:**
        - Instruct to use the project's package manager command (from `ProjectConfig`) to add the library.
        - If the library needs config keys, they must be added as placeholders to example config files (e.g., `.env.example`).
        - A `CustomData ConfigSettings:[LibraryName]_ConfigKeysNeeded_v1` item must be logged to ConPort with details of the required keys.
        - A basic initialization file (e.g., `src/integrations/[library_name]_client.py`) should be created.

**Milestone ELI.2: Wrapper Development & Testing**

- **Goal:** Develop and test wrapper functions to provide a stable internal API for the new library.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **Delegate to `Nova-SpecializedFeatureImplementer`:**
      - **Subtask Goal:** "Create wrapper functions and a usage example (with unit tests) for [LibraryName]."
      - **Briefing Details:**
        - Provide a list of core functionalities to wrap.
        - Instruct to create wrappers that encapsulate setup and simplify the interface.
        - Unit tests for the wrappers are mandatory and must mock external calls.
        - An illustrative `CodeSnippets` entry for the wrapper should be logged to ConPort.
  2.  **Delegate to `Nova-SpecializedTestAutomator`:**
      - **Subtask Goal:** "Write and execute integration tests for the wrapped library functions."
      - **Briefing Details:**
        - Specify the wrapped functions to test and their expected behavior in the context of the project.
        - If new bugs are found, they must be logged as new `ErrorLogs`.

**Milestone ELI.3: Documentation & Closure**

- **Goal:** Document the new integration and finalize the process.
- **Suggested Specialist Sequence & Lead Actions:**
  1.  **Delegate to `Nova-SpecializedCodeDocumenter`:**
      - **Subtask Goal:** "Create technical documentation for using the [LibraryName] integration."
      - **Briefing Details:**
        - Instruct to create a Markdown document in the project's `docs/` directory.
        - The document should cover purpose, configuration, and usage examples of the wrappers.
  2.  **LeadDeveloper Action:**
      - Ensure a final `CustomData APIUsage:[LibraryName]_IntegrationNotes_v1` (or similar) entry is logged to ConPort, summarizing the integration and linking to all related artifacts.
      - Update the main `Progress` item to 'DONE'.
      - Report completion to `Nova-Orchestrator`.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData (`ConfigSettings`, `CodeSnippets`, `APIUsage`)
- ErrorLogs (key)
