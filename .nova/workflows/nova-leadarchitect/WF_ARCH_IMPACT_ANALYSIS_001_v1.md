# Workflow: Change Impact Assessment (WF_ARCH_IMPACT_ANALYSIS_001_v1)

**Goal:** To assess and document the potential impact of a proposed significant change on the project, including effects on code, ConPort items, documentation, and project timelines/risks.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actors (delegated to by Nova-LeadArchitect):** Nova-SpecializedSystemDesigner, Nova-SpecializedConPortSteward, (potentially Nova-FlowAsk).

**Trigger / Recognition:**
- Nova-Orchestrator delegates "Perform Impact Analysis for change [ChangeDescription]".
- Another Lead Mode proposes a significant change, warranting an impact analysis before approval.
- Part of a larger project planning or risk assessment workflow.

**Reference Milestones for your Single-Step Loop:**

**Milestone IA.0: Pre-flight & Readiness Check**
*   **Goal:** Verify that the proposed change is clearly defined in ConPort before starting the analysis.
*   **Suggested Lead Action:**
    1.  Your first action MUST be to perform a "Definition of Ready" check.
    2.  Retrieve the ConPort item describing the proposed change (e.g., `Decision:[ID]` or `FeatureScope:[Key]`) using `use_mcp_tool`.
    3.  **Gated Check:**
        *   **Failure:** If the item does not exist or is too ambiguous, immediately `attempt_completion` with a `BLOCKER:` status to `Nova-Orchestrator`. Do not proceed.
        *   **Success:** If the item exists and is clear, proceed to the next milestone.

**Milestone IA.1: Information Gathering**
*   **Goal:** Identify all potentially affected ConPort items and source code areas.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **LeadArchitect Action:** Log a main `Progress` item for this Impact Analysis cycle.
    2.  **Delegate to `Nova-SpecializedConPortSteward`:**
        *   **Subtask Goal:** "Identify and list all ConPort items potentially affected by the proposed change."
        *   **Briefing Details:** Instruct the specialist to use keyword searches (`search_decisions_fts`, `search_custom_data_value_fts`) and `get_linked_items` to find related `Decisions`, `SystemArchitecture`, `APIEndpoints`, `DefinedWorkflows`, etc. They should return a structured list of impacted items.
    3.  **Delegate to `Nova-SpecializedSystemDesigner` (or self-analyze):**
        *   **Subtask Goal:** "Identify source code modules, files, or functions potentially impacted by the proposed change."
        *   **Briefing Details:** Instruct the specialist to use `search_files` and `list_code_definition_names` to analyze code dependencies and identify affected areas. They should return a list of impacted code paths.

**Milestone IA.2: Analysis & Formulation**
*   **Goal:** Analyze the gathered data to assess risks, benefits, and formulate recommendations.
*   **Suggested Lead Action:**
    1.  Consolidate the lists of impacted ConPort items and code areas from your specialists.
    2.  **Analyze & Assess:**
        *   List potential benefits of the change.
        *   List potential risks (technical, operational, project).
        *   Provide a high-level effort estimate (e.g., S, M, L).
        *   Formulate mitigation strategies for key risks.
    3.  **Formulate Recommendation:** Based on the analysis, decide on a final recommendation: `Proceed`, `Proceed with Caution`, `Reconsider`, or `Reject`.
    4.  Log any significant intermediate findings or the final recommendation strategy as a formal `Decision` in ConPort.

**Milestone IA.3: Documentation & Reporting**
*   **Goal:** Compile all findings into a structured Impact Analysis Report and log it to ConPort.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedConPortSteward`:**
        *   **Subtask Goal:** "Compile and log the final Impact Analysis Report to ConPort."
        *   **Briefing Details:** Provide all analyzed sections (affected items, risks, benefits, recommendation, etc.) in a structured format. Instruct the specialist to log this to `CustomData` category `ImpactAnalyses` with a descriptive key (e.g., `IA_[ChangeDescriptionShort]_[YYYYMMDD]`). They should also link this new report to the main `Progress` item for the analysis cycle.
        *   Return the ConPort key of the logged `ImpactAnalyses` report.

**Milestone IA.4: Finalize Cycle**
*   **Goal:** Close out the analysis process and report completion.
*   **Suggested Lead Action:**
    1.  Update the main `Progress` item to 'DONE'.
    2.  Update the `active_context.state_of_the_union` with a summary of the analysis outcome.
    3.  Report completion of the phase to `Nova-Orchestrator`, providing the key of the full `ImpactAnalyses` report and the final recommendation.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- CustomData ImpactAnalyses:[Key] (key)
- Decisions (integer `id`)
- Reads various other ConPort items for context.