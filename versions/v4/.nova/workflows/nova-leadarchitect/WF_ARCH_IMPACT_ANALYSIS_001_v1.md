# Workflow: Change Impact Assessment (WF_ARCH_IMPACT_ANALYSIS_001_v1)

**Goal:** To assess and document the potential impact of a proposed significant change (e.g., major refactor, API version change, dependency upgrade, architectural shift) on the project, including effects on code, ConPort items, documentation, and project timelines/risks.

**Primary Orchestrator Actor:** Nova-LeadArchitect (receives task from Nova-Orchestrator, or initiates if a proposed architectural change warrants it).
**Primary Specialist Actors (delegated to by Nova-LeadArchitect):** Nova-SpecializedSystemDesigner (for system impact), Nova-SpecializedConPortSteward (for ConPort impact/logging), (potentially Nova-FlowAsk via LeadArchitect for broad searches).

**Trigger / Orchestrator Recognition (for Nova-Orchestrator to delegate to Nova-LeadArchitect):**
- User requests "Impact analysis for change X".
- Nova-Orchestrator or any Lead Mode proposes a significant change and deems an impact analysis necessary before approval.
- Part of a larger project planning or risk assessment workflow.

**Pre-requisites by Nova-Orchestrator (before delegating to Nova-LeadArchitect):**
- A clear description of the "Proposed Change" is available.
- The scope/boundaries of the impact analysis are reasonably defined (e.g., "focus on backend services", "assess impact on public API consumers").

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase IA.1: Initial Planning & Information Gathering by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Receive Task & Plan Analysis**
    *   **Action:** Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` ("Perform Impact Analysis for [ChangeDescription]") and `Required_Input_Context` (detailed description of the proposed change, scope of analysis).
    *   **ConPort:**
        *   Log main `Progress` (integer `id`) item: "Impact Analysis: [ChangeDescriptionShort] - [Date]".
        *   Create internal plan (`LeadPhaseExecutionPlan:[IAProgressID]_ArchitectPlan` (key)) for specialist subtasks. Example plan items:
            1.  Identify Affected ConPort Items (LeadArchitect or ConPortSteward).
            2.  Identify Affected Code Areas (LeadArchitect or SystemDesigner, potentially needs input from LeadDeveloper via Orchestrator for deep dives).
            3.  Assess Risks & Benefits (LeadArchitect).
            4.  Estimate Effort (LeadArchitect, potentially with input from other Leads via Orchestrator).
            5.  Formulate Mitigation/Recommendations (LeadArchitect).
            6.  Compile & Log Report (ConPortSteward).
    *   **Output:** Plan ready. Main `Progress` (integer `id`) created. `LeadPhaseExecutionPlan` (key) created.

**Phase IA.2: Sequential Execution of Specialist Subtasks by Nova-LeadArchitect**

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Identify Affected ConPort Items**
    *   **Task:** "Search ConPort for all items potentially impacted by the Proposed Change."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Impact Analysis for [ChangeDescriptionShort]."
          Specialist_Subtask_Goal: "Identify and list ConPort items potentially affected by: [DetailedProposedChange]."
          Specialist_Specific_Instructions:
            - "Log your own `Progress` (integer `id`) for this scan."
            - "Use `semantic_search_conport` and keyword searches (`search_decisions_fts` (integer `id`), `search_custom_data_value_fts` (key), etc.) with terms related to the change (e.g., [keywords from change description])."
            - "Search categories: `Decisions`, `SystemPatterns`, `SystemArchitecture`, `APIEndpoints`, `ConfigSettings`, `CodeSnippets`, `DefinedWorkflows`, `ProjectConfig`, `NovaSystemConfig`."
            - "For highly relevant items, use `get_linked_items` to find direct dependencies."
            - "Compile a list of all potentially impacted ConPort items (Type, ID/Key, Brief reason for impact)."
          Required_Input_Context_For_Specialist:
            - Detailed_Proposed_Change_Description: "[...]"
            - Keywords_For_Search: "[...]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "List of potentially impacted ConPort items (Type, ID/Key, Reason)."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review list. Update plan and progress.

3.  **Nova-LeadArchitect (or delegate to Nova-SpecializedSystemDesigner, possibly coordinating with Nova-LeadDeveloper via Nova-Orchestrator for deep code insights): Identify Affected Code Areas**
    *   **Task:** "Identify source code modules, files, or specific functions/classes potentially impacted by the Proposed Change."
    *   *(This might involve `search_files` with regex, `list_code_definition_names`, and analyzing dependencies. If very deep code analysis is needed beyond LeadArchitect's team capability, LeadArchitect would report this need back to Orchestrator to potentially involve LeadDeveloper for a specific sub-analysis task.)*
    *   **Output to LeadArchitect:** List of potentially impacted code areas.

4.  **Nova-LeadArchitect: Assess Risks & Benefits, Estimate Effort, Formulate Recommendations**
    *   **Action (Can be broken into further self-steps or minor specialist delegations for data gathering):**
        *   Based on affected ConPort items and code areas:
            *   List potential benefits of the change.
            *   List potential risks (regressions, breaking changes, required testing, effort). Consult ConPort `RiskAssessment` (key) for similar past changes.
            *   Provide a high-level effort estimate (S/M/L/XL) and any special resources needed.
            *   Suggest mitigation strategies for risks.
            *   Formulate a recommendation: Proceed, Proceed with Caution (listing mitigations), Reconsider, or Reject.
    *   **ConPort:** May log interim `Decisions` (integer `id`) or notes in `ImpactAnalyses` (key) work-in-progress entry.

5.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Compile & Log Impact Analysis Report**
    *   **Task:** "Compile all findings into a structured Impact Analysis Report and log it to ConPort."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Impact Analysis for [ChangeDescriptionShort]."
          Specialist_Subtask_Goal: "Compile and log the final Impact Analysis Report."
          Specialist_Specific_Instructions:
            - "Consolidate the following information into a structured Markdown document (or a complex JSON object):
                1. Proposed Change: [From LeadArchitect]
                2. Affected ConPort Items: [List from previous subtask, with IDs/keys]
                3. Affected Code Areas: [List from LeadArchitect]
                4. Potential Benefits: [From LeadArchitect]
                5. Potential Risks (incl. Likelihood/Impact): [From LeadArchitect]
                6. Estimated Effort: [From LeadArchitect]
                7. Mitigation Strategies / Recommendations: [From LeadArchitect]"
            - "Log this report in ConPort `CustomData` category `ImpactAnalyses`, key: `[ChangeDescriptionShort]_ImpactReport_[YYYYMMDD]`. Link this entry to the main `Progress` (integer `id`) for this Impact Analysis phase."
            - "Ensure the report is well-formatted and all sections are complete."
          Required_Input_Context_For_Specialist:
            - All_Analyzed_Sections_Content: "[Provided by LeadArchitect]"
            - Main_Impact_Analysis_Progress_ID: [Integer `id` of LeadArchitect's phase progress item]
            - Report_Key_Name: "[ChangeDescriptionShort]_ImpactReport_[YYYYMMDD]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "ConPort key of the logged `ImpactAnalyses` report."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged report. Update plan and progress.

**Phase IA.3: Final Reporting by Nova-LeadArchitect**

6.  **Nova-LeadArchitect: Consolidate & Finalize**
    *   **Action:** Once the report is logged by ConPortSteward:
        *   Update main `Progress` (integer `id`) for "Impact Analysis" to DONE.
        *   Update `active_context.state_of_the_union` (via `use_mcp_tool`) with a note: "Impact analysis for [ChangeDescriptionShort] completed. Report: `ImpactAnalyses:[Key]`."
    *   **Output:** Impact analysis completed and documented.

7.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, summary of the analysis (especially the recommendation), and the ConPort key of the full report.

**Key ConPort Items Created/Updated by Nova-LeadArchitect's Team:**
-   `Progress` (integer `id`): For overall phase and specialist subtasks.
-   `CustomData LeadPhaseExecutionPlan:[IAProgressID]_ArchitectPlan` (key).
-   `CustomData ImpactAnalyses:[ChangeDescriptionShort]_ImpactReport_[YYYYMMDD]` (key): The main deliverable.
-   (Potentially) Interim `Decisions` (integer `id`) made during the analysis.
-   Reads many other ConPort items across categories.
-   `ActiveContext` (key `state_of_the_union` update).