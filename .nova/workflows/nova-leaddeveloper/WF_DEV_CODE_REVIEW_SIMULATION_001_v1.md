# Workflow: Code Review Simulation (WF_DEV_CODE_REVIEW_SIMULATION_001_v1)

**Goal:** To simulate a code review process for a piece of implemented code, focusing on adherence to standards, clarity, potential issues, and alternative approaches, managed by Nova-LeadDeveloper. This is a *simulated* review as AI modes cannot truly review like humans but can check for patterns and adherence to explicit rules.

**Primary Actor:** Nova-LeadDeveloper (initiates this after a specialist implements a significant or complex piece of code, or as per `NovaSystemConfig`).
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedFeatureImplementer (as author if fixes needed), Nova-FlowAsk (as reviewer for specific aspects), Nova-SpecializedCodeDocumenter (to log review outcomes).

**Trigger / Nova-LeadDeveloper Recognition:**
- A Nova-SpecializedFeatureImplementer or Nova-SpecializedCodeRefactorer completes a subtask involving non-trivial code changes.
- `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leaddeveloper.code_review_simulation_trigger` (e.g., "on_complex_module_completion", "random_sample_percentage:10") suggests a review.
- Nova-LeadDeveloper deems a review necessary for quality assurance or knowledge sharing for a critical piece of code.

**Pre-requisites by Nova-LeadDeveloper:**
- Code to be reviewed is available at a specific file path.
- Relevant ConPort items (Specs: `FeatureScope` (key), `APIEndpoints` (key); Design: `SystemArchitecture` (key); Standards: `SystemPatterns` (integer `id`/name) for coding standards; relevant `Decisions` (integer `id`)) are available.

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator, or as a self-contained sub-process within a larger development phase):**

**Phase CR.1: Preparation & Context Gathering**

1.  **Nova-LeadDeveloper: Identify Code for Review & Gather Context**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Identify specific file(s) and code sections for review (e.g., `src/auth/service.py`, lines 50-150).
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Code Review Simulation: [ComponentName/File]\"}`). Let this be `[ReviewProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[ReviewProgressID]_DeveloperPlan` (key) using `use_mcp_tool`. Plan items:
            1.  Brief Nova-FlowAsk with code & review focus areas.
            2.  Nova-FlowAsk performs analysis and returns feedback.
            3.  LeadDeveloper reviews Nova-FlowAsk's feedback.
            4.  (If issues found) Delegate fixes/updates to original Implementer/Refactorer.
            5.  Log review summary (Delegate to CodeDocumenter).
    *   **ConPort Action:**
        *   Use `use_mcp_tool` (`tool_name: 'get_custom_data'`, `get_decisions`, `get_system_patterns`) to retrieve relevant `FeatureScope` (key), `APIEndpoints` (key) (if applicable), `SystemPatterns` (integer `id`/name) for coding standards, and any specific `Decisions` (integer `id`) that guided the implementation of the code under review.
        *   Use `read_file` to get the content of the code to be reviewed.
    *   **Output:** Code content and all contextual ConPort information ready for briefing Nova-FlowAsk. `[ReviewProgressID]` known.

**Phase CR.2: Simulated Review using Nova-FlowAsk**

2.  **Nova-LeadDeveloper -> Delegate to Nova-FlowAsk: Perform Code Analysis**
    *   **Actor:** Nova-LeadDeveloper
    *   **Task:** "Analyze the provided code snippet against given criteria (e.g., adherence to standards, clarity, potential bugs, efficiency) and provide feedback."
    *   **`new_task` message for Nova-FlowAsk:**
        ```json
        {
          "Context_Path": "[ProjectName] (DevPhase_[FeatureName]) -> CodeReviewSim [File] (FlowAsk)",
          "Subtask_Goal": "Perform a simulated code review of the provided code snippet and context.",
          "Mode_Specific_Instructions": [
            "You are acting as a code reviewer.",
            "Analyze the 'Code_To_Review_Content' based on the 'Review_Focus_Areas' and 'Contextual_Information'.",
            "Provide feedback on:",
            "  - Adherence to Coding Standards (see `SystemPatterns:[CodingStd_ID_or_Name]`).",
            "  - Clarity and Readability (e.g., naming conventions, comments, complexity).",
            "  - Potential Bugs or Edge Cases missed (based on logic and specs, if provided).",
            "  - Efficiency or Performance considerations (high-level, conceptual).",
            "  - Alternative approaches (if significantly better and aligned with project constraints).",
            "  - Adherence to original specifications (if `FeatureScope`/`APIEndpoints` context provided).",
            "Structure your feedback clearly with specific code line references where possible."
          ],
          "Required_Input_Context": {
            "Code_To_Review_Content_From_File": "[Full text content of the code snippet/file from read_file]",
            "Code_File_Path_For_Reference": "[Original path, for context in feedback]",
            "Review_Focus_Areas_From_LeadDeveloper": ["Security vulnerabilities (e.g., input validation)", "Adherence to DRY principle", "Error handling completeness", "Correct use of [SpecificLibrary/Pattern]"],
            "Contextual_Information_From_ConPort": {
                "FeatureScope_Ref": { "type": "custom_data", "category": "FeatureScope", "key": "[Optional_Key]" },
                "APIEndpoint_Spec_Ref": { "type": "custom_data", "category": "APIEndpoints", "key": "[Optional_Key]" },
                "CodingStandard_Pattern_Ref": { "type": "system_pattern", "id_or_name": "[ID or Name of relevant SystemPattern]" },
                "Guiding_Decision_Refs": [{ "type": "decision", "id": "[Optional_integer_id_as_string]" }, ...]
              }
          },
          "Expected_Deliverables_In_Attempt_Completion": [
            "Structured Markdown feedback with sections for each review aspect.",
            "Specific suggestions for improvement with line numbers if applicable.",
            "Overall assessment (e.g., Looks Good, Minor Revisions Needed, Major Revisions Recommended)."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action after Nova-FlowAsk's `attempt_completion`:**
        *   Carefully review Nova-FlowAsk's feedback.
        *   Update `[ReviewProgressID]_DeveloperPlan` and FlowAsk's `Progress` (if one was logged for FlowAsk's task) in ConPort.

**Phase CR.3: Action & Documentation**

3.  **Nova-LeadDeveloper: Process Review Feedback & Delegate Actions (if needed)**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:**
        *   Based on Nova-FlowAsk's feedback, decide on necessary actions.
        *   If significant issues are found that require code changes:
            *   Log a `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"summary\": \"Mandate code changes based on review of [File]\", \"rationale\": \"[Summary of review findings]\"}`) summarizing the review outcome and mandating changes.
            *   Delegate a new subtask to the original `Nova-SpecializedFeatureImplementer` or `Nova-SpecializedCodeRefactorer`:
                *   **Briefing for Implementer/Refactorer (schematic):**
                    ```json
                    {
                      "Context_Path": "[ProjectName] (DevPhase_[FeatureName]) -> ApplyReviewFeedback [File] (Implementer/Refactorer)",
                      "Overall_Developer_Phase_Goal": "Ensure code quality for [ComponentName/File].",
                      "Specialist_Subtask_Goal": "Address code review feedback for [ComponentName/File].",
                      "Specialist_Specific_Instructions": [
                        "Code File: [path/to/code].",
                        "Review Feedback to Address: [Specific actionable points from Nova-FlowAsk's report, filtered/prioritized by LeadDeveloper].",
                        "Refer to `Decision:[ReviewDecisionID_as_integer]` for mandated changes.",
                        "Update code as required. Update/add unit tests. Re-run linters and all relevant tests until they pass."
                      ],
                      "Required_Input_Context_For_Specialist": { "Code_File_Path": "[...]", "Review_Feedback_Details": "[...]", "Review_Decision_ID_as_integer": "[Integer_id_as_integer]" },
                      "Expected_Deliverables_In_Attempt_Completion_From_Specialist": ["Confirmation of changes, test/lint pass status, paths to modified files."]
                    }
                    ```
            *   Await their `attempt_completion` and re-verify (potentially another, more focused, review loop with Nova-FlowAsk on the changed parts).
        *   If minor issues or suggestions for future: Note them, potentially log as new `TechDebtCandidates` (key) if appropriate.
    *   **Output:** Code updated if necessary, or decision made on feedback.

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter: Log Review Summary**
    *   **Actor:** Nova-LeadDeveloper
    *   **DoR Check:** Review feedback processed, any necessary code changes made and verified.
    *   **Task:** "Log a summary of the code review for [ComponentName/File] in ConPort."
    *   **`new_task` message for Nova-SpecializedCodeDocumenter:**
        ```json
        {
          "Context_Path": "[ProjectName] (DevPhase_[FeatureName]) -> LogReviewSummary [File] (CodeDocumenter)",
          "Overall_Developer_Phase_Goal": "Ensure code quality for [ComponentName/File].",
          "Specialist_Subtask_Goal": "Log code review summary for [ComponentName/File] to ConPort `CodeReviewSummaries` category.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[ReviewProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Subtask: Log code review summary for [File]\", \"parent_id\": [ReviewProgressID_as_integer]} `).",
            "Use `use_mcp_tool` (`tool_name: 'log_custom_data'`) to create a `CustomData` entry. The arguments for the call MUST be:",
            "`arguments`: {",
            "  \"workspace_id\": \"ACTUAL_WORKSPACE_ID\",",
            "  \"category\": \"CodeReviewSummaries\",",
            "  \"key\": \"CR_[FilePath_SafeKey]_[YYYYMMDD]\",",
            "  \"value\": {",
            "    \"file_path\": \"[path/to/reviewed/code]\",",
            "    \"version_reviewed_hint\": \"[Commit SHA or version if available from LeadDeveloper context]\",",
            "    \"reviewer_mode\": \"Nova-FlowAsk (instructed by Nova-LeadDeveloper)\",",
            "    \"review_date\": \"[Current YYYY-MM-DD]\",",
            "    \"key_feedback_points_summary\": \"[Concise summary of FlowAsk's feedback from LeadDeveloper]\",",
            "    \"actions_taken_decision_ref\": \"Decision:[Decision_ID_for_changes_if_any_as_string]\",",
            "    \"overall_assessment_after_actions\": \"[e.g., All Major Issues Addressed, Minor Suggestions Noted]\"",
            "  }",
            "}",
            "After logging, link this `CodeReviewSummaries` entry to the main `Progress` item (`[ReviewProgressID_as_integer]`) using `use_mcp_tool` (`tool_name: 'link_conport_items'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"source_item_type\": \"custom_data\", \"source_item_id\": \"CodeReviewSummaries:CR_[FilePath_SafeKey]_[YYYYMMDD]\", \"target_item_type\": \"progress_entry\", \"target_item_id\": \"[ReviewProgressID_as_string]\", \"relationship_type\": \"summarizes_review_for_progress\"}`)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_as_integer": "[ReviewProgressID_as_integer]",
            "File_Path_Reviewed": "[...]",
            "Version_Hint": "[...]",
            "Review_Feedback_Summary_For_Log": "[...]",
            "Decision_ID_For_Actions_Taken_String": "[Optional_integer_id_as_string]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "ConPort key of the created `CodeReviewSummaries` entry."
          ]
        }
        ```
    *   **Nova-LeadDeveloper Action:** Verify log. Update plan/progress.

5.  **Nova-LeadDeveloper: Finalize Code Review Cycle**
    *   **Actor:** Nova-LeadDeveloper
    *   **Action:** Update main `Progress` (`[ReviewProgressID]`) for "Code Review Simulation" to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"progress_id\": [ReviewProgressID_as_integer], \"status\": \"DONE\"}`).
    *   **Output:** Code review process documented and completed for this component.

**Key ConPort Items Involved:**
- Progress (integer `id`): For overall review cycle and specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[ReviewProgressID]_DeveloperPlan (key).
- Decisions (integer `id`): Regarding actions taken based on review feedback.
- CustomData CodeReviewSummaries:[Key] (key): The main deliverable logging the review.
- (Reads) FeatureScope (key), APIEndpoints (key), SystemPatterns (integer `id`/name), Decisions (integer `id`).
- (Potentially) Updates to code by Nova-SpecializedFeatureImplementer and their related ConPort items if fixes were needed.
- (Potentially) New `TechDebtCandidates` (key) if review identifies issues for later.