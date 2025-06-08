# Workflow: Risk Assessment and Mitigation Planning (WF_ARCH_RISK_ASSESSMENT_AND_MITIGATION_PLANNING_001_v1)

**Goal:** To systematically identify, analyze, evaluate, and plan mitigation for potential risks within a project or a specific project phase/feature.

**Primary Orchestrator Actor:** Nova-LeadArchitect (Typically tasked by Nova-Orchestrator when a new high-risk phase starts, a significant change is proposed, or as a periodic review).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward (for data gathering and logging), (potentially Nova-FlowAsk for analysis).

**Trigger / Orchestrator Recognition (for Nova-Orchestrator to delegate to Nova-LeadArchitect):**
- Start of a new major project or phase identified as high-risk.
- A significant change proposal (triggering impact analysis which then leads to risk assessment).
- Periodic project health review as per `NovaSystemConfig:ActiveSettings`.
- User explicitly requests a "Risk Assessment for X".

**Pre-requisites by Nova-Orchestrator (before delegating this phase to Nova-LeadArchitect):**
- ConPort is `[CONPORT_ACTIVE]`.
- The scope of the risk assessment is defined (e.g., "Project Alpha overall", "Feature Beta integration", "Dependency Upgrade Gamma").

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase RA.1: Planning & Risk Identification by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Receive Task & Plan Assessment**
    *   **Action:** Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` ("Perform Risk Assessment for [Scope]") and `Required_Input_Context`.
    *   **ConPort:**
        *   Log main `Progress` (integer `id`) item: "Risk Assessment: [Scope] - [Date]".
        *   Create internal plan (`LeadPhaseExecutionPlan:[RAProgressID]_ArchitectPlan` (key)). Plan items:
            1.  Gather Context & Identify Potential Risks (LeadArchitect, ConPortSteward, FlowAsk).
            2.  Analyze & Evaluate Risks (Likelihood/Impact) (LeadArchitect).
            3.  Define Mitigation Strategies (LeadArchitect).
            4.  Log `RiskAssessment` Items & Summary (ConPortSteward).
    *   **Output:** Plan ready. Main `Progress` (integer `id`) created.

2.  **Nova-LeadArchitect -> Delegate Data Gathering to Nova-SpecializedConPortSteward / Nova-FlowAsk**
    *   **Task (to ConPortSteward):** "Retrieve relevant ConPort data for risk identification related to [Scope]."
        *   **Briefing:** Instruct to search `Decisions` (integer `id`), `SystemArchitecture` (key), `ProjectRoadmap` (key), `ImpactAnalyses` (key), existing `RiskAssessment` (key) items, `LessonsLearned` (key), `ErrorLogs` (key) (especially recurring or critical ones), `TechDebtCandidates` (key), and `ProjectConfig:ActiveConfig` (key) (e.g., for external dependencies listed).
    *   **Task (to Nova-FlowAsk, optional):** "Analyze provided project documents [paths or ConPort content] and identify potential risk areas related to [Scope]."
    *   **Nova-LeadArchitect Action:** Consolidate gathered data. Brainstorm additional potential risks based on expertise and project context (technical, schedule, resource, external).
    *   **Output:** A raw list of potential risks.

**Phase RA.2: Risk Analysis, Evaluation & Mitigation by Nova-LeadArchitect**

3.  **Nova-LeadArchitect: Analyze and Evaluate Risks**
    *   **Action:** For each identified potential risk:
        *   Describe the risk event and its potential negative consequences.
        *   Estimate Likelihood (e.g., Low, Medium, High).
        *   Estimate Impact (e.g., Low, Medium, High, Critical).
        *   Calculate Risk Level (e.g., using a simple matrix: High Likelihood + High Impact = Severe Risk).
    *   **ConPort:** May log interim notes or draft `Decision` (integer `id`) points.

4.  **Nova-LeadArchitect: Define Mitigation & Contingency Strategies**
    *   **Action:** For each significant risk (e.g., Medium level or higher):
        *   Brainstorm and define **Mitigation Actions:** Steps to reduce likelihood or impact.
        *   Brainstorm and define **Contingency Plans:** Actions if the risk materializes.
        *   Assign (conceptually) an owner or responsible Lead mode for mitigation actions.
    *   **ConPort:** Log key mitigation strategies as `Decisions` (integer `id`).

**Phase RA.3: Documentation & Reporting by Nova-LeadArchitect & Nova-SpecializedConPortSteward**

5.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Risk Items**
    *   **Task:** "Log each identified and evaluated risk, along with its mitigation/contingency, as a separate `CustomData RiskAssessment:[RiskID_ShortDesc]` (key) item in ConPort."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Risk Assessment for [Scope]."
          Specialist_Subtask_Goal: "Log all identified risks and mitigation plans to ConPort `RiskAssessment` category."
          Specialist_Specific_Instructions:
            - "For each risk provided by LeadArchitect:"
            - "  Log a new `CustomData` entry in category `RiskAssessment`."
            - "  Key: `[YYYYMMDD_ScopeAbbreviation_RiskNumber]` (e.g., `20240115_ProjX_R001_TechStackObsolescence`)."
            - "  Value (JSON Object): 
                {
                  \"risk_description\": \"[Detailed description]\",
                  \"likelihood\": \"High|Medium|Low\",
                  \"impact\": \"Critical|High|Medium|Low\",
                  \"risk_level\": \"Severe|High|Medium|Low\",
                  \"mitigation_actions\": [\"Action 1...\", \"Action 2...\"],
                  \"mitigation_owner_hint\": \"Nova-LeadDeveloper\",
                  \"contingency_plan\": \"If risk occurs, do X...\",
                  \"status\": \"Identified|Mitigating|Monitoring|Closed\",
                  \"related_conport_items\": [ {type: 'decision', id: 123}, {type: 'custom_data', category: 'ImpactAnalyses', key: 'SomeReportKey'} ] // Optional
                }"
            - "Ensure all fields are complete and use consistent terminology for likelihood/impact."
          Required_Input_Context_For_Specialist:
            - List_Of_Risks_With_Details: "[Structured list from LeadArchitect]"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "List of ConPort keys for all created `RiskAssessment` entries."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged items.

6.  **Nova-LeadArchitect: Create Risk Summary & Finalize**
    *   **Action:**
        *   Create a summary of the risk assessment (e.g., top 3-5 risks, overall risk posture). This could be a new `CustomData` entry (e.g., `RiskAssessment:[Scope]_SummaryReport_Date` (key)) or part of the `attempt_completion` to Nova-Orchestrator.
        *   Update main `Progress` (integer `id`) for "Risk Assessment" to DONE.
        *   Update `active_context.state_of_the_union` with a note about the risk assessment completion.
    *   **Output:** Risk assessment documented.

7.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, provide the risk summary (or key to it), and list the `RiskAssessment` (keys) logged. Highlight any severe risks requiring immediate attention or decision from Nova-Orchestrator.

**Key ConPort Items Created/Updated:**
-   `Progress` (integer `id`)
-   `CustomData LeadPhaseExecutionPlan:[RAProgressID]_ArchitectPlan` (key)
-   `CustomData RiskAssessment:[Key]` (key) (multiple entries, one per risk)
-   (Potentially) `CustomData RiskAssessment:[Scope]_SummaryReport_Date` (key)
-   `Decisions` (integer `id`) (for mitigation strategies or accepting risks)
-   `ActiveContext` (key `state_of_the_union` update)