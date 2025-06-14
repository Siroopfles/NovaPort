# Workflow: Onboard New Developer (WF_ORCH_ONBOARD_NEW_DEVELOPER_001_v1)

**Goal:** To generate a comprehensive onboarding guide for a new human developer joining the project, giving them a snapshot of the technical state and current priorities.

**Primary Actor:** Nova-Orchestrator
**Delegated Utility Mode Actor:** Nova-FlowAsk

**Trigger / Recognition:**

- A user (e.g., a project manager or lead developer) explicitly asks to generate a briefing package for a new team member: "Onboard a new developer," or "Generate a project introduction package."

**Pre-requisites by Nova-Orchestrator:**

- The project is established and ConPort contains sufficient data (`SystemArchitecture`, `ProjectConfig`, `Decisions`, `Progress`, `ErrorLogs`).

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase OND.1: Briefing Generation**

1.  **Nova-Orchestrator: Plan Onboarding Guide Generation**

    - **Action:**
      - Log a main `Progress` (integer `id`) item for this task: "Generate New Developer Onboarding Guide - [Date]" using `use_mcp_tool`. Let this be `[OnboardingProgressID]`.
      - Delegate the data gathering and document generation to Nova-FlowAsk.

2.  **Nova-Orchestrator -> Delegate to Nova-FlowAsk: Query & Generate Guide**
    - **Actor:** Nova-Orchestrator
    - **Task:** "Query ConPort for key project information and synthesize it into a comprehensive Markdown onboarding guide. Save the guide to `.nova/reports/onboarding/`."
    - **`new_task` message for Nova-FlowAsk:**
      ```json
      {
        "Context_Path": "UserRequest (Orchestrator) -> OnboardingGuide (FlowAsk)",
        "Subtask_Goal": "Generate a developer onboarding guide by querying ConPort and save it to a file.",
        "Mode_Specific_Instructions": [
          "1. **Query ConPort:** Use `use_mcp_tool` with `server_name: 'conport'` and `workspace_id: 'ACTUAL_WORKSPACE_ID'` to retrieve the following information:",
          "   - **System Architecture:** Get the main `SystemArchitecture` summary (e.g., from key `[ProjectName]_Overall_v1`).",
          "   - **Project Config:** Get the full JSON content of `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings`.",
          "   - **Recent Decisions:** Get the 5 most recent `Decisions` using `get_decisions` with a `limit`.",
          "   - **Active Work:** Get all `Progress` items with status `IN_PROGRESS`.",
          "   - **Critical Open Issues:** Get the top 3-5 `ErrorLogs` from `active_context.open_issues` with severity 'CRITICAL' or 'HIGH'.",
          "2. **Synthesize Onboarding Guide:** Create a comprehensive Markdown report with the following sections:",
          "   - `# Onboarding Guide: [Project Name] - [Date]`",
          "   - `## 1. System Overview`: Paste the `SystemArchitecture` summary.",
          "   - `## 2. Technical Stack & Configuration`: Paste the `ProjectConfig` and `NovaSystemConfig` JSON inside code blocks.",
          "   - `## 3. Key Recent Decisions`: List the summaries of the 5 decisions retrieved.",
          "   - `## 4. Current Work in Progress`: List the descriptions of all `IN_PROGRESS` tasks.",
          "   - `## 5. Critical Open Issues`: List the summaries of the critical `ErrorLogs`.",
          "3. **Save Report:** Use `write_to_file` to save the generated Markdown content to a new file at path: `.nova/reports/onboarding/OnboardingGuide_[YYYYMMDD].md`."
        ],
        "Required_Input_Context": {
          "ProjectName": "[ProjectName]",
          "Report_File_Path": ".nova/reports/onboarding/OnboardingGuide_[YYYYMMDD].md"
        },
        "Expected_Deliverables_In_Attempt_Completion": [
          "Confirmation that the onboarding guide was written.",
          "The full path to the saved guide file."
        ]
      }
      ```

**Phase OND.2: Closure**

3.  **Nova-Orchestrator: Inform User**
    - **Actor:** Nova-Orchestrator
    - **Action:**
      - Update `[OnboardingProgressID]` to 'DONE'.
      - Inform the user: "The New Developer Onboarding Guide has been generated and saved to `[.nova/reports/onboarding/OnboardingGuide_YYYYMMDD.md]`."
    - **Output:** User is informed and has access to the onboarding guide.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- Reads: SystemArchitecture, ProjectConfig, NovaSystemConfig, Decisions, ErrorLogs, ActiveContext.
- (Writes to file system, not ConPort)
