# Workflow: Code Review Simulation (WF_DEV_CODE_REVIEW_SIMULATION_001_v1)

**Goal:** To simulate a code review process for implemented code, focusing on adherence to standards, clarity, potential issues, and alternative approaches. This is a _simulated_ review to check for patterns and adherence to explicit rules.

**Primary Actor:** Nova-LeadDeveloper
**Primary Specialist Actors (delegated to by Nova-LeadDeveloper):** Nova-FlowAsk (as reviewer), Nova-SpecializedFeatureImplementer (for fixes), Nova-SpecializedCodeDocumenter (for logging).

**Trigger / Recognition:**

- A specialist completes a subtask involving non-trivial code changes.
- `NovaSystemConfig` suggests a review (e.g., for complex modules).
- LeadDeveloper deems a review necessary for a critical piece of code.

**Reference Milestones for your Single-Step Loop:**

**Milestone CR.1: Context Gathering & Review Execution**

- **Goal:** Gather all necessary context and delegate the code analysis to `Nova-FlowAsk`.
- **Suggested Specialist Sequence & Lead Actions:**
  1.  **LeadDeveloper Action:** Log a main `Progress` item for this review simulation. Identify the specific file(s) and code sections for review.
  2.  **LeadDeveloper Action:** Use `use_mcp_tool` and `read_file` to gather all context: the code content itself, and relevant ConPort items like `FeatureScope`, `APIEndpoints`, `SystemPatterns` (for coding standards), and any guiding `Decisions`.
  3.  **Delegate to `Nova-FlowAsk`:**
      - **Subtask Goal:** "Perform a simulated code review of the provided code snippet against given criteria."
      - **Briefing Details:**
        - Provide the full code content, its file path, and specific focus areas for the review (e.g., "Check for input validation", "Adherence to DRY principle").
        - Provide all the contextual ConPort items you retrieved.
        - Instruct `FlowAsk` to provide structured feedback on clarity, potential bugs, efficiency, and adherence to standards, with specific line references.
        - `FlowAsk` should return a Markdown report with its findings.

**Milestone CR.2: Process Feedback & Delegate Fixes**

- **Goal:** Analyze the review feedback and, if necessary, delegate corrective actions.
- **Suggested Specialist Sequence & Lead Actions:**
  1.  **LeadDeveloper Action:** Carefully review `Nova-FlowAsk`'s feedback.
  2.  **Decision Point:**
      - **If significant issues are found:** Log a `Decision` mandating the required changes. Then, delegate a new subtask to the original `Nova-SpecializedFeatureImplementer` or `Nova-SpecializedCodeRefactorer` to apply the fixes, update unit tests, and re-run linters.
      - **If minor issues or future improvements:** Note them and consider logging them as new `TechDebtCandidates`.
      - **If no issues:** Proceed to the next milestone.

**Milestone CR.3: Documentation & Closure**

- **DoR Check:** All required code changes from the review have been implemented and verified.
- **Goal:** Log a summary of the code review in ConPort and finalize the cycle.
- **Suggested Specialist Sequence & Lead Actions:**
  1.  **Delegate to `Nova-SpecializedCodeDocumenter`:**
      - **Subtask Goal:** "Log a summary of the code review for [ComponentName/File] to the ConPort `CodeReviewSummaries` category."
      - **Briefing Details:**
        - Provide a concise summary of the review feedback and the actions taken.
        - Reference the file path, version/commit hint, and the `Decision` ID for any mandated changes.
        - Instruct the specialist to use `log_custom_data` to create the `CodeReviewSummaries` entry.
  2.  **LeadDeveloper Action:**
      - Verify the ConPort log entry.
      - Update the main `Progress` item for the review cycle to 'DONE'.
      - Report completion to `Nova-Orchestrator` if this was a standalone phase.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- CustomData CodeReviewSummaries:[Key] (key)
- Decisions (integer `id`)
- Reads various specs and standards from ConPort.
