# Workflow: Generate Project Digest (WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1)

**Goal:** To generate a concise, high-level summary report of recent project activity and status for stakeholder review.

**Primary Actor:** Nova-Orchestrator
**Delegated Utility Mode Actor:** Nova-FlowAsk

**Trigger / Recognition:**
- User asks for a project summary, status report, or digest (e.g., "Give me a digest of the last week's activities.", "Generate a project status report.").
- Can be triggered periodically by `NovaSystemConfig:ActiveSettings` if configured.

**Pre-requisites by Nova-Orchestrator:**
- ConPort is `[CONPORT_ACTIVE]`.
- Recent activity has been logged in ConPort by the team.

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase PD.1: Information Gathering & Summarization**

1.  **Nova-Orchestrator: Plan Digest Generation**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Log a `Progress` (integer `id`) item for this task: "Generate Project Digest - [Date]". Let this be `[DigestProgressID]`.
        *   Determine the time frame for the digest (e.g., last 7 days, since last release) based on the user's request or a default.

2.  **Nova-Orchestrator -> Delegate to Nova-FlowAsk: Query & Summarize**
    *   **Actor:** Nova-Orchestrator
    *   **Task:** "Retrieve recent, significant ConPort activity and synthesize it into a structured Markdown digest report. Save the report to `.nova/reports/digests/`."
    *   **`new_task` message for Nova-FlowAsk:**
        ```json
        {
          "Context_Path": "UserQuery (Orchestrator) -> ProjectDigest (FlowAsk)",
          "Subtask_Goal": "Generate a project digest report for the last [TimeFrame, e.g., 7 days] and save it to a file.",
          "Mode_Specific_Instructions": [
            "1. **Query ConPort:** Use `use_mcp_tool` with `server_name: 'conport'` and `workspace_id: 'ACTUAL_WORKSPACE_ID'` to execute the following queries:",
            "   - `get_recent_activity_summary` with `hours_ago: 168` (or other timeframe from Orchestrator) to get recently created/updated items (Decisions, Progress, ErrorLogs, etc.).",
            "   - `get_custom_data` for `category: 'ActiveContext'`, `key: 'active_context'` to get the current `state_of_the_union` and `open_issues`.",
            "   - `get_custom_data` for `category: 'Dashboard'`, `key: 'ProjectStatus_v1'` if available.",
            "2. **Synthesize Digest:** Based on the query results, create a concise Markdown report with the following sections:",
            "   - `## Project Digest - [Date]`",
            "   - `### Overall Status`: Include the `state_of_the_union` and a summary of the `Dashboard` item.",
            "   - `### Key Accomplishments (Last 7 Days)`: Summarize key `Progress` items marked as 'DONE'.",
            "   - `### Major Decisions Logged`: List summaries of important recent `Decisions` (integer `id`).",
            "   - `### Open Critical/High Issues`: List summaries of critical/high severity `ErrorLogs` (key) from `open_issues` or recent activity.",
            "   - `### Current Focus`: Describe the main `Progress` items currently 'IN_PROGRESS'.",
            "3. **Save Report:** Use `write_to_file` to save the generated Markdown content to a new file at path: `.nova/reports/digests/ProjectDigest_[YYYYMMDD].md`."
          ],
          "Required_Input_Context": {
            "TimeFrame_For_Digest": "7 days",
            "Report_File_Path": ".nova/reports/digests/ProjectDigest_[YYYYMMDD].md"
          },
          "Expected_Deliverables_In_Attempt_Completion": [
            "Confirmation that the digest report was written.",
            "The full path to the saved report file."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Nova-FlowAsk's `attempt_completion`:**
        *   Review the confirmation and file path.
        *   Update `[DigestProgressID]` to 'DONE'.

**Phase PD.2: Present Information to User**

3.  **Nova-Orchestrator: Inform User**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Inform the user: "The project digest has been generated and saved to `[.nova/reports/digests/ProjectDigest_YYYYMMDD.md]`."
        *   (Optional) Present a very high-level summary from the report directly in the chat.
    *   **Output:** User is informed and has access to the report.

**Key ConPort Items Involved:**
- (Read) Progress, Decisions, ErrorLogs, ActiveContext, Dashboard.
- (Write) Progress (for the digest generation task itself).
