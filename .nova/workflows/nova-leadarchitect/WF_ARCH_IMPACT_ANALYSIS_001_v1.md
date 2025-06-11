# Workflow: Change Impact Assessment (WF_ARCH_IMPACT_ANALYSIS_001_v1)

**Goal:** To assess and document the potential impact of a proposed significant change (e.g., major refactor, API version change, dependency upgrade, architectural shift) on the project, including effects on code, ConPort items, documentation, and project timelines/risks.

**Primary Actor:** Nova-LeadArchitect (receives task from Nova-Orchestrator, or initiates if a proposed architectural change warrants it).
**Primary Specialist Actors (delegated to by Nova-LeadArchitect):** Nova-SpecializedSystemDesigner (for system impact), Nova-SpecializedConPortSteward (for ConPort impact/logging), (potentially Nova-FlowAsk via LeadArchitect for broad searches).

**Trigger / Recognition:**
- Nova-Orchestrator delegates "Perform Impact Analysis for change [ChangeDescription] on Project [ProjectName]".
- Nova-LeadArchitect or another Lead Mode proposes a significant change and deems an impact analysis necessary before approval.
- Part of a larger project planning or risk assessment workflow.

**Pre-requisites by Nova-LeadArchitect (from Nova-Orchestrator's briefing):**
- A clear description of the "Proposed Change" is available (potentially as a `Decision` (integer `id`) with status 'Proposed' or a `CustomData FeatureScope:[key]`).
- The scope/boundaries of the impact analysis are reasonably defined (e.g., "focus on backend services", "assess impact on public API consumers").

---

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase IA.0: Pre-flight Checks by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Verify Change Proposal is Ready for Analysis**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Before planning the analysis, perform this critical pre-flight check.
    *   **Checks:**
        1.  **Retrieve Change Proposal Item:** Your briefing from the Orchestrator must contain a `Required_Input_Context` section with a reference to the ConPort item describing the proposed change (e.g., `Decision:[ID]` or `FeatureScope:[Key]`). Use the appropriate `use_mcp_tool` command (`get_decisions` or `get_custom_data`) to retrieve this item.
        2.  **Check for Existence:**
            - **Failure:** If the specified item is not found, report to Nova-Orchestrator in your `attempt_completion`: "BLOCKER: The ConPort item `[Item Type: ID/Key]` describing the proposed change for impact analysis does not exist. Cannot proceed." Halt this workflow.
        3.  **Check for Clarity (Conceptual):**
            - Review the content of the retrieved item. Does it clearly describe the proposed change? Is it unambiguous?
            - **Failure:** If the description is too vague to perform a meaningful analysis, report to Nova-Orchestrator: "BLOCKER: The description in `[Item Type: ID/Key]` is too ambiguous for a meaningful impact analysis. Please coordinate with the author to add more detail." Halt this workflow.
    *   **Output:** The change proposal is confirmed to exist and be clear enough for analysis.

**Phase IA.1: Initial Planning & Information Gathering**

2.  **Nova-LeadArchitect: Receive Task & Plan Analysis**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` ("Perform Impact Analysis for [ChangeDescriptionShort]") and `Required_Input_Context` (detailed description/ConPort ref of the proposed change, scope of analysis).
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Impact Analysis: [ChangeDescriptionShort] - [Date]\"}`). Let this be `[IAProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[IAProgressID]_ArchitectPlan` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"LeadPhaseExecutionPlan\", \"key\": \"[IAProgressID]_ArchitectPlan\", \"value\": { /* JSON object with plan steps */ }}`). Example plan items:
            1.  Identify Affected ConPort Items (Delegate to ConPortSteward).
            2.  Identify Affected Code Areas (LeadArchitect or delegate to SystemDesigner; may need input from LeadDeveloper via Orchestrator for deep dives).
            3.  Assess Risks & Benefits (LeadArchitect).
            4.  Estimate Effort & Timeline Impact (LeadArchitect, potentially with input from other Leads via Orchestrator).
            5.  Formulate Mitigation/Recommendations (LeadArchitect).
            6.  Compile & Log Report (Delegate to ConPortSteward).
    *   **Output:** Plan ready. Main `Progress` (integer `id`) created. `LeadPhaseExecutionPlan` (key) created.

3.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Identify Affected ConPort Items**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Search ConPort for all items potentially impacted by the Proposed Change: [DetailedProposedChange]."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (ImpactAnalysis) -> Identify Affected ConPort Items (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Impact Analysis for [ChangeDescriptionShort].",
          "Specialist_Subtask_Goal": "Identify and list ConPort items potentially affected by: [DetailedProposedChange].",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[IAProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Subtask: Identify affected ConPort items for impact analysis\", \"parent_id\": [IAProgressID_as_integer]} `).",
            "Use `use_mcp_tool` (`server_name: 'conport'`, `workspace_id: 'ACTUAL_WORKSPACE_ID'`) with appropriate ConPort tools:",
            "  - Keyword searches (`search_decisions_fts`, `search_custom_data_value_fts`) with terms related to the change (e.g., [keywords from change description]).",
            "  - Search categories: `Decisions`, `SystemPatterns`, `SystemArchitecture`, `APIEndpoints`, `DBMigrations`, `ConfigSettings`, `CodeSnippets`, `DefinedWorkflows`, `ProjectConfig`, `NovaSystemConfig`, `ErrorLogs`, `LessonsLearned`, `TechDebtCandidates`, `FeatureScope`, `AcceptanceCriteria`.",
            "  - For highly relevant items, use `get_linked_items` to find direct dependencies (provide correct `item_type` and `item_id` - integer `id` as string or `category:key` string).",
            "Compile a list of all potentially impacted ConPort items (Type, ID/Key, Brief reason for impact)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Detailed_Proposed_Change_Description_Or_Ref": "[Description or ConPort Key/ID of the change proposal]",
            "Keywords_For_Search": "[Keywords relevant to the change]",
            "Parent_Progress_ID_as_integer": "[IAProgressID_as_integer]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "List of potentially impacted ConPort items (Type, ID/Key, Reason)."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review list. Update `[IAProgressID]_ArchitectPlan`.

4.  **Nova-LeadArchitect (or delegate to Nova-SpecializedSystemDesigner): Identify Affected Code Areas**
    *   **Actor:** Nova-LeadArchitect (may delegate to SystemDesigner, or request assistance from LeadDeveloper via Orchestrator for deep code analysis)
    *   **Task:** "Identify source code modules, files, or specific functions/classes potentially impacted by the Proposed Change."
    *   **Action (if self-executing or guiding SystemDesigner):**
        *   Use `search_files` with regex based on the change description (e.g., affected class names, method signatures, technology keywords).
        *   Use `list_code_definition_names` on suspected modules/files.
        *   Analyze dependencies using code understanding and ConPort `SystemArchitecture` (key) if available.
    *   **Output to LeadArchitect:** List of potentially impacted code areas (files, classes, functions). Update `[IAProgressID]_ArchitectPlan`.

**Phase IA.2: Risk Assessment & Mitigation Formulation**

5.  **Nova-LeadArchitect: Assess Risks & Benefits, Estimate Effort, Formulate Recommendations**
    *   **Actor:** Nova-LeadArchitect
    *   **Action (Can be broken into further self-steps or minor specialist delegations for data gathering):**
        *   Based on affected ConPort items and code areas:
            *   List potential benefits of the change (e.g., improved performance, new capability, tech debt reduction).
            *   List potential risks:
                *   Technical risks (e.g., regressions, breaking changes to internal/external APIs, data migration complexity, security vulnerabilities introduced).
                *   Operational risks (e.g., increased maintenance, new monitoring needs).
                *   Project risks (e.g., schedule impact, resource skill gaps, cost).
            *   Consult existing ConPort `RiskAssessment` (key) items for similar past changes or related components.
            *   Provide a high-level effort estimate (e.g., S, M, L, XL person-days/weeks) and any special resources/skills needed.
            *   Suggest mitigation strategies for key risks.
            *   Formulate a recommendation: Proceed, Proceed with Caution (listing key mitigations), Reconsider (suggesting alternatives), or Reject (with strong justification).
    *   **ConPort Action:** Log significant findings or intermediate decisions as new `Decisions` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"summary\": \"[Summary of finding]\", \"rationale\": \"...\"}`). Prepare content for the final `ImpactAnalyses` report.

**Phase IA.3: Documentation & Reporting**

6.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Compile & Log Impact Analysis Report**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Compile all findings into a structured Impact Analysis Report and log it to ConPort."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (ImpactAnalysis) -> Log Report (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Impact Analysis for [ChangeDescriptionShort].",
          "Specialist_Subtask_Goal": "Compile and log the final Impact Analysis Report.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[IAProgressID_as_integer]`, using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Subtask: Compile and log Impact Analysis report\", \"parent_id\": [IAProgressID_as_integer]} `).",
            "Use `use_mcp_tool` (`tool_name: 'log_custom_data'`) to log the structured report to ConPort. The arguments object should be:",
            "`arguments`: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"category\": \"ImpactAnalyses\", \"key\": \"IA_[ChangeDescriptionShortKeyable]_[YYYYMMDD]\", \"value\": { /* The full JSON value object provided in the context below */ }}",
            "The `value` object you log MUST contain these fields with content from LeadArchitect:",
            "  - `proposed_change_summary`: \"[...Summary...]\"",
            "  - `proposed_change_reference`: { \"type\": \"[e.g., decision]\", \"id_or_key\": \"[ID or Key of change proposal]\" }",
            "  - `affected_conport_items`: [ { \"type\": \"...\", \"id_or_key\": \"...\", \"impact_description\": \"...\" }, ... ]",
            "  - `affected_code_areas`: [ { \"path\": \"...\", \"element_type\": \"module/class/function\", \"impact_description\": \"...\" }, ... ]",
            "  - `potential_benefits`: [\"Benefit 1...\", ...]",
            "  - `potential_risks`: [ { \"risk_description\": \"...\", \"likelihood\": \"High/Medium/Low\", \"impact_severity\": \"Critical/High/Medium/Low\", \"mitigation_suggestion\": \"...\" }, ... ]",
            "  - `estimated_effort`: \"[e.g., Medium (5-10 person-days)]\"",
            "  - `recommendation`: \"[Proceed / Proceed with Caution / Reconsider / Reject]\"",
            "  - `recommendation_rationale`: \"[Justification for recommendation]\"",
            "After logging the report, link it to the main `Progress` item for this phase (`[IAProgressID_as_integer]`) using `use_mcp_tool` (`tool_name: 'link_conport_items'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"source_item_type\": \"custom_data\", \"source_item_id\": \"ImpactAnalyses:IA_[ChangeDescriptionShortKeyable]_[YYYYMMDD]\", \"target_item_type\": \"progress_entry\", \"target_item_id\": \"[IAProgressID_as_string]\", \"relationship_type\": \"documents_progress\"}`)."
          ],
          "Required_Input_Context_For_Specialist": {
            "All_Analyzed_Sections_Content_As_Structured_Data": "{ /* JSON object from LeadArchitect matching the value structure above */ }",
            "Main_Impact_Analysis_Progress_ID_as_integer": "[IAProgressID_as_integer]",
            "Report_Key_Name_Suggestion": "IA_[ChangeDescriptionShortKeyable]_[YYYYMMDD]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "ConPort key of the logged `ImpactAnalyses` report.",
            "Confirmation of link creation to Progress item."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged report. Update `[IAProgressID]_ArchitectPlan` and specialist `Progress` in ConPort.

7.  **Nova-LeadArchitect: Finalize & Report to Nova-Orchestrator**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Update main `Progress` (`[IAProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"progress_id\": [IAProgressID_as_integer], \"status\": \"DONE\", \"description\": \"Impact analysis for [ChangeDescriptionShort] completed. Report: `ImpactAnalyses:[Key]`.\"}`).
        *   To update `active_context`, first `get_active_context` with `use_mcp_tool`, then construct a new value object with the modified `state_of_the_union`, and finally use `log_custom_data` with category `ActiveContext` and key `active_context` to overwrite.
    *   **Output:** Impact analysis completed and documented.

8.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, summary of the analysis (especially the recommendation), and the ConPort key of the full `ImpactAnalyses` report.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- CustomData LeadPhaseExecutionPlan:[IAProgressID]_ArchitectPlan (key)
- CustomData ImpactAnalyses:[ChangeDescriptionShort]_ImpactReport_[YYYYMMDD] (key): The main deliverable.
- Decisions (integer `id`) (for the proposed change, and for decisions made during analysis)
- (Reads) SystemArchitecture (key), APIEndpoints (key), DBMigrations (key), ErrorLogs (key), LessonsLearned (key), etc.
- ActiveContext (`state_of_the_union` update)