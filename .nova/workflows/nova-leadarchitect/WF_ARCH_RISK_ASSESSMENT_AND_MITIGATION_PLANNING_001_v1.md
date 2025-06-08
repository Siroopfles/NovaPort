# Workflow: Risk Assessment and Mitigation Planning (WF_ARCH_RISK_ASSESSMENT_AND_MITIGATION_PLANNING_001_v1)

**Goal:** To systematically identify, analyze, evaluate, and plan mitigation for potential risks within a project or a specific project phase/feature, managed by Nova-LeadArchitect.

**Primary Actor:** Nova-LeadArchitect (Typically tasked by Nova-Orchestrator when a new high-risk phase starts, a significant change is proposed, or as a periodic review).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward (for data gathering and logging), (potentially Nova-FlowAsk for analysis, delegated by LeadArchitect).

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Perform Risk Assessment for [Scope] of Project [ProjectName]".
- A significant change proposal (triggering `WF_ARCH_IMPACT_ANALYSIS_001_v1.md` which then identifies need for this risk assessment).
- Periodic project health review as per `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadarchitect.risk_assessment_frequency_months`.

**Pre-requisites by Nova-LeadArchitect (from Nova-Orchestrator's briefing or self-assessment):**
- ConPort is `[CONPORT_ACTIVE]`.
- The scope of the risk assessment is defined (e.g., "Project Alpha overall", "Feature Beta integration", "Dependency Upgrade Gamma").
- Relevant project context is available in ConPort (e.g., `ProductContext`, `SystemArchitecture`, `ProjectRoadmap`).

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase RA.1: Planning & Risk Identification**

1.  **Nova-LeadArchitect: Receive Task & Plan Assessment**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` ("Perform Risk Assessment for [Scope]") and `Required_Input_Context`.
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "Risk Assessment: [Scope] - [Date]". Let this be `[RAProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[RAProgressID]_ArchitectPlan` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Plan items:
            1.  Gather Context & Brainstorm Potential Risks (LeadArchitect, delegate data gathering to ConPortSteward/FlowAsk).
            2.  Analyze & Evaluate Risks (Likelihood/Impact) (LeadArchitect).
            3.  Define Mitigation & Contingency Strategies (LeadArchitect, log as Decisions).
            4.  Log Individual `RiskAssessment` Items & Summary (Delegate to ConPortSteward).
    *   **Output:** Plan ready. Main `Progress` (`[RAProgressID]`) created. `LeadPhaseExecutionPlan` logged.

2.  **Nova-LeadArchitect: Gather Context & Brainstorm Potential Risks**
    *   **Actor:** Nova-LeadArchitect
    *   **Delegate Data Gathering to Nova-SpecializedConPortSteward (or Nova-FlowAsk):**
        *   **Task (to ConPortSteward):** "Retrieve relevant ConPort data for risk identification related to [Scope]."
        *   **Briefing for ConPortSteward (schematic):**
            ```json
            {
              "Context_Path": "[ProjectName] (RiskAssessment) -> GatherData (ConPortSteward)",
              "Overall_Architect_Phase_Goal": "Risk Assessment for [Scope].",
              "Specialist_Subtask_Goal": "Retrieve ConPort data relevant to identifying risks for [Scope].",
              "Specialist_Specific_Instructions": [
                "Log your own `Progress` (integer `id`), parented to `[RAProgressID]`.",
                "Use `use_mcp_tool` (`server_name: 'conport'`, `workspace_id: 'ACTUAL_WORKSPACE_ID'`) with tools like `get_custom_data`, `get_decisions`, `semantic_search_conport` to find information related to [Scope] in categories: `SystemArchitecture`, `ProjectRoadmap`, `ImpactAnalyses`, existing `RiskAssessment`, `LessonsLearned`, `ErrorLogs` (critical/recurring), `TechDebtCandidates`, `ProjectConfig` (external dependencies), `ExternalServices`.",
                "Compile a summary of findings or list of relevant item IDs/Keys."
              ],
              "Required_Input_Context_For_Specialist": { "Scope_Description": "[...]", "Parent_Progress_ID_String": "[RAProgressID_as_string]" },
              "Expected_Deliverables_In_Attempt_Completion_From_Specialist": ["Summary of relevant ConPort data/items found."]
            }
            ```
    *   **Nova-LeadArchitect Action after specialist(s) complete:**
        *   Consolidate gathered data.
        *   Brainstorm additional potential risks based on expertise and project context (technical, schedule, resource, external, security, performance).
        *   Categorize risks (e.g., Technical, Project Management, External Dependency, Security).
    *   **Output:** A raw, categorized list of potential risks. Update `[RAProgressID]_ArchitectPlan`.

**Phase RA.2: Risk Analysis, Evaluation & Mitigation Planning**

3.  **Nova-LeadArchitect: Analyze and Evaluate Risks**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** For each identified potential risk:
        *   Describe the risk event and its potential negative consequences clearly.
        *   Estimate Likelihood (e.g., Very Low, Low, Medium, High, Very High).
        *   Estimate Impact (e.g., Negligible, Minor, Moderate, Significant, Severe).
        *   Determine Risk Level (e.g., using a predefined risk matrix based on Likelihood x Impact).
        *   Document this analysis (can be as fields within the `value` of eventual `RiskAssessment` items).
    *   **ConPort Action:** May log interim notes or draft `Decision` (integer `id`) points for complex risk evaluations.

4.  **Nova-LeadArchitect: Define Mitigation & Contingency Strategies**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** For each significant risk (e.g., Medium level or higher):
        *   Brainstorm and define **Mitigation Actions:** Specific steps to reduce likelihood or impact.
        *   Brainstorm and define **Contingency Plans:** Actions to take if the risk materializes.
        *   Assign a conceptual owner or responsible Lead mode for mitigation actions/monitoring.
    *   **ConPort Action:** Log key mitigation strategies or risk acceptance decisions as formal `Decisions` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`).

**Phase RA.3: Documentation & Reporting**

5.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Risk Items**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Log each identified and evaluated risk, along with its mitigation/contingency, as a separate `CustomData RiskAssessment:[RiskID_ShortDesc]` (key) item in ConPort."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (RiskAssessment) -> Log Risk Items (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Risk Assessment for [Scope].",
          "Specialist_Subtask_Goal": "Log all identified risks and mitigation plans to ConPort `RiskAssessment` category.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[RAProgressID]`.",
            "For each risk provided by LeadArchitect (structure will be a list of objects):",
            "  - Log a new `CustomData` entry using `use_mcp_tool` (`tool_name: 'log_custom_data'`, `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'category': 'RiskAssessment', ...}`).",
            "  - Key: `RA_[YYYYMMDD]_[ScopeAbbrev]_[RiskNum]` (e.g., `RA_20240115_ProjX_R001_TechStackObsolescence`).",
            "  - Value (JSON Object): ",
            "    {",
            "      \"risk_id_human\": \"[e.g., ProjX-R001]\",",
            "      \"risk_description\": \"[Detailed description from LeadArchitect]\",",
            "      \"risk_category\": \"[e.g., Technical, Schedule, Security from LeadArchitect]\",",
            "      \"likelihood\": \"High|Medium|Low|Very Low|Very High\",",
            "      \"impact_severity\": \"Severe|Significant|Moderate|Minor|Negligible\",",
            "      \"risk_level_calculated\": \"[e.g., Severe, High, Medium, Low]\",",
            "      \"mitigation_actions_planned\": [{\"action_description\": \"...\", \"owner_hint\": \"Nova-LeadDeveloper\", \"status\": \"TODO\"}, ...],",
            "      \"contingency_plan_summary\": \"If risk occurs, do X...\",",
            "      \"status\": \"Identified\", // Other statuses: Mitigating, Monitoring, Realized, Closed_Mitigated, Closed_Accepted",
            "      \"date_identified\": \"[YYYY-MM-DD]\",",
            "      \"last_reviewed_date\": \"[YYYY-MM-DD]\",",
            "      \"related_conport_items\": [ {\"type\": \"decision\", \"id\": \"123\"}, {\"type\": \"custom_data\", \"id_or_key\": \"ImpactAnalyses:SomeReportKey\"} ]",
            "    }",
            "  - Link this new `RiskAssessment` (key) entry to the main `Progress` item (`[RAProgressID]`) for this Risk Assessment phase using `use_mcp_tool` (`tool_name: 'link_conport_items'`, `relationship_type: 'identified_by_progress'`)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[RAProgressID_as_string]",
            "List_Of_Risks_With_Structured_Details": "[List of JSON objects from LeadArchitect, matching the value structure above]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "List of ConPort keys for all created `RiskAssessment` entries.",
            "Confirmation of links to main Progress item."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged items. Update `[RAProgressID]_ArchitectPlan` and specialist `Progress`.

6.  **Nova-LeadArchitect: Create Risk Summary & Finalize**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Create a summary of the risk assessment (e.g., top 3-5 risks, overall risk posture, key mitigation decisions). This could be a new `CustomData` entry (e.g., `RiskAssessment:[Scope]_SummaryReport_[Date]` (key)) logged via ConPortSteward, or directly included in the `attempt_completion` to Nova-Orchestrator.
        *   Update main `Progress` (`[RAProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "Risk assessment for [Scope] completed. See `RiskAssessment` category, key `[SummaryReportKey]` if applicable."
        *   To update `active_context`, first `get_active_context` with `use_mcp_tool`, then construct a new value object with the modified `state_of_the_union`, and finally use `log_custom_data` with category `ActiveContext` and key `active_context` to overwrite.
    *   **Output:** Risk assessment documented.

7.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Report completion, provide the risk summary (or key to it), and list the `RiskAssessment` (keys) logged. Highlight any severe risks requiring immediate attention or decision from Nova-Orchestrator.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- CustomData LeadPhaseExecutionPlan:[RAProgressID]_ArchitectPlan (key)
- CustomData RiskAssessment:[Key] (key) (multiple entries, one per risk)
- (Potentially) CustomData RiskAssessment:[Scope]_SummaryReport_Date (key)
- Decisions (integer `id`) (for mitigation strategies or accepting risks)
- ActiveContext (`state_of_the_union` update)
- (Reads) SystemArchitecture (key), ProjectRoadmap (key), ImpactAnalyses (key), LessonsLearned (key), ErrorLogs (key), TechDebtCandidates (key), ProjectConfig (key).