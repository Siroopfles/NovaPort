# Workflow: Code Review Simulation (WF_DEV_CODE_REVIEW_SIMULATION_001_v1)

**Goal:** To simulate a code review process for a piece of implemented code, focusing on adherence to standards, clarity, potential issues, and alternative approaches, managed by Nova-LeadDeveloper. This is a *simulated* review as AI modes cannot truly review like humans.

**Primary Orchestrator Actor:** Nova-LeadDeveloper (initiates this after a specialist implements a significant or complex piece of code).
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-SpecializedFeatureImplementer (as author), Nova-FlowAsk (as reviewer for specific aspects), Nova-SpecializedCodeDocumenter (to log review outcomes).

**Trigger / Nova-LeadDeveloper Recognition:**
- A Nova-SpecializedFeatureImplementer or Nova-SpecializedCodeRefactorer completes a subtask involving non-trivial code changes.
- `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leaddeveloper.code_review_simulation_trigger` (e.g., "on_complex_module_completion", "random_sample") suggests a review.
- Nova-LeadDeveloper deems a review necessary for quality assurance or knowledge sharing.

**Pre-requisites by Nova-LeadDeveloper:**
- Code to be reviewed is committed (conceptually) or available at a specific path.
- Relevant ConPort items (Specs: `FeatureScope` (key), `APIEndpoints` (key); Design: `SystemArchitecture` (key); Standards: `SystemPatterns` (integer `id`/name) for coding standards) are available.

**Phases & Steps (managed by Nova-LeadDeveloper within its single active task from Nova-Orchestrator, or as a self-contained sub-process within a larger development phase):**

**Phase CR.1: Preparation & Context Gathering by Nova-LeadDeveloper**

1.  **Nova-LeadDeveloper: Identify Code for Review & Gather Context**
    *   **Action:**
        *   Identify specific file(s) and code sections for review.
        *   Log main `Progress` (integer `id`) item: "Code Review Simulation: [ComponentName/File]".
        *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[ReviewProgressID]_DeveloperPlan` (key)). Plan items:
            1.  Brief Nova-FlowAsk with code & review focus areas.
            2.  Nova-FlowAsk performs analysis.
            3.  LeadDeveloper reviews Nova-FlowAsk's feedback.
            4.  (If issues found) Delegate fixes/updates to original Implementer/Refactorer.
            5.  Log review summary (CodeDocumenter or ConPortSteward via LeadArchitect).
    *   **ConPort:**
        *   Retrieve relevant `FeatureScope` (key), `APIEndpoints` (key) (if applicable), `SystemPatterns` (integer `id`/name) for coding standards, and any specific `Decisions` (integer `id`) that guided the implementation.
        *   Use `read_file` to get the content of the code to be reviewed.
    *   **Output:** Code content and all contextual ConPort information ready.

**Phase CR.2: Simulated Review using Nova-FlowAsk**

2.  **Nova-LeadDeveloper -> Delegate to Nova-FlowAsk: Perform Code Analysis**
    *   **Task:** "Analyze the provided code snippet against given criteria (e.g., adherence to standards, clarity, potential bugs, efficiency) and provide feedback."
    *   **`new_task` message for Nova-FlowAsk:**
        ```
        Subtask_Briefing:
          Subtask_Goal: "Perform a simulated code review of the provided code snippet and context."
          Mode_Specific_Instructions:
            - "You are acting as a code reviewer."
            - "Analyze the 'Code_To_Review' based on the 'Review_Focus_Areas' and 'Contextual_Information'."
            - "Provide feedback on:
                - Adherence to Coding Standards (see `SystemPatterns:[CodingStd_ID]`).
                - Clarity and Readability.
                - Potential Bugs or Edge Cases missed.
                - Efficiency or Performance considerations (high-level).
                - Alternative approaches (if significantly better).
                - Adherence to original specifications (if `FeatureScope`/`APIEndpoints` provided)."
            - "Structure your feedback clearly with specific code line references where possible."
          Required_Input_Context:
            - Code_To_Review_Content: "[Full text content of the code snippet/file]"
            - Code_File_Path: "[Original path, for context]"
            - Review_Focus_Areas: ["Security vulnerabilities", "Adherence to DRY principle", "Error handling completeness"] // Example areas from LeadDeveloper
            - Contextual_Information: {
                "FeatureScope_Ref_Key": "[Optional, ConPort key]",
                "APIEndpoint_Spec_Ref_Key": "[Optional, ConPort key]",
                "CodingStandard_Pattern_Ref_ID": "[Integer ID of relevant SystemPattern]",
                "Guiding_Decision_Refs_IDs": ["[Optional, list of relevant Decision integer IDs]"]
              }
          Expected_Deliverables_In_Attempt_Completion:
            - "Structured Markdown feedback with sections for each review aspect."
            - "Specific suggestions for improvement with line numbers if applicable."
            - "Overall assessment (e.g., Looks Good, Minor Revisions Needed, Major Revisions Recommended)."
        ```
    *   **Nova-LeadDeveloper Action after Nova-FlowAsk's `attempt_completion`:**
        *   Carefully review Nova-FlowAsk's feedback.
        *   Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`).

**Phase CR.3: Action & Documentation by Nova-LeadDeveloper & Specialists**

3.  **Nova-LeadDeveloper: Process Review Feedback & Delegate Actions**
    *   **Action:**
        *   Based on Nova-FlowAsk's feedback, decide on necessary actions.
        *   If significant issues are found:
            *   Delegate a new subtask to the original `Nova-SpecializedFeatureImplementer` or `Nova-SpecializedCodeRefactorer`: "Address code review feedback for [ComponentName/File]. Feedback: [Specific points from Nova-FlowAsk]. Update code and re-run tests/linters."
            *   Await their `attempt_completion` and re-verify (potentially another, more focused, review loop with Nova-FlowAsk on the changed parts).
        *   If minor issues or suggestions for future: Note them.
    *   **ConPort:** Log a `Decision` (integer `id`) summarizing the outcome of the review and any mandated changes.

4.  **Nova-LeadDeveloper -> Delegate to Nova-SpecializedCodeDocumenter (or ConPortSteward via LeadArchitect): Log Review Summary**
    *   **Task:** "Log a summary of the code review for [ComponentName/File] in ConPort."
    *   **`new_task` message:**
        ```
        Subtask_Briefing:
          Overall_Developer_Phase_Goal: "Ensure code quality for [ComponentName/File]."
          Specialist_Subtask_Goal: "Log code review summary for [ComponentName/File] to ConPort."
          Specialist_Specific_Instructions:
            - "Create a `CustomData` entry in category `CodeReviewSummaries` (key: `[FilePath_SafeKey]_[YYYYMMDD]_Review`)."
            - "Value (JSON Object):
                {
                  \"file_path\": \"[path/to/reviewed/code]\",
                  \"version_reviewed_hint\": \"[Commit SHA or version if available]\",
                  \"reviewer_mode\": \"Nova-FlowAsk (instructed by Nova-LeadDeveloper)\",
                  \"review_date\": \"[Current YYYY-MM-DD]\",
                  \"key_feedback_points\": [\"Point 1 from FlowAsk...\", \"Point 2...\"],
                  \"actions_taken_refs\": [\"Decision:[Decision_ID_for_changes]\", \"Progress:[Implementer_Fix_Progress_ID]\"], // Optional
                  \"overall_assessment\": \"[From FlowAsk, e.g., Minor Revisions Implemented]\"
                }"
            - "Link this `CodeReviewSummaries` (key) entry to the relevant code `Progress` (integer `id`) item or `FeatureScope` (key) item."
          Required_Input_Context_For_Specialist:
            - File_Path_Reviewed: "[...]"
            - Review_Feedback_Summary_From_FlowAsk: "[...]"
            - Related_ConPort_Item_To_Link_To: "{ type: 'progress_entry', id: [integer_id] }" // Example
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "ConPort key of the created `CodeReviewSummaries` entry."
        ```
    *   **Nova-LeadDeveloper Action:** Verify log. Update plan/progress.

5.  **Nova-LeadDeveloper: Finalize Code Review Cycle**
    *   **Action:**
        *   Update main `Progress` (integer `id`) for "Code Review Simulation" to DONE.
    *   **Output:** Code review process documented.

**Key ConPort Items Created/Updated:**
-   `Progress` (integer `id`): For overall review cycle and specialist subtasks.
-   `CustomData LeadPhaseExecutionPlan:[ReviewProgressID]_DeveloperPlan` (key).
-   `Decisions` (integer `id`): Regarding actions taken based on review feedback.
-   `CustomData CodeReviewSummaries:[Key]` (key): The main deliverable.
-   (Potentially) Updates to code by Nova-SpecializedFeatureImplementer and their related ConPort items.
