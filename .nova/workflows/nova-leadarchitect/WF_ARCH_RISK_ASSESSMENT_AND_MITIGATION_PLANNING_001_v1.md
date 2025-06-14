# Workflow: Risk Assessment and Mitigation Planning (WF_ARCH_RISK_ASSESSMENT_AND_MITIGATION_PLANNING_001_v1)

**Goal:** To systematically identify, analyze, evaluate, and plan mitigation for potential risks within a project or a specific project phase/feature.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward, (potentially Nova-FlowAsk).

**Trigger / Recognition:**

- Tasked by `Nova-Orchestrator` to perform a risk assessment for a specific scope.
- A significant change proposal triggers the need for this assessment.
- A periodic project health review as per `NovaSystemConfig`.

**Reference Milestones for your Single-Step Loop:**

**Milestone RA.1: Risk Identification**

- **Goal:** Gather relevant context and brainstorm a comprehensive list of potential risks.
- **Suggested Specialist Sequence & Lead Actions:**
  1.  **LeadArchitect Action:** Log a main `Progress` item for this Risk Assessment cycle.
  2.  **Delegate to `Nova-SpecializedConPortSteward` or `Nova-FlowAsk`:**
      - **Subtask Goal:** "Retrieve relevant ConPort data for risk identification related to scope: [Scope]."
      - **Briefing Details:** Instruct the specialist to use ConPort search tools to find information in categories like `SystemArchitecture`, `ImpactAnalyses`, `LessonsLearned`, `ErrorLogs` (critical/recurring), and `TechDebtCandidates`. They should return a summary of relevant items.
  3.  **LeadArchitect Action: Brainstorming:**
      - Consolidate the data from the specialist.
      - Brainstorm additional risks based on expertise, categorizing them (e.g., Technical, Schedule, Security, External).

**Milestone RA.2: Risk Analysis & Mitigation Planning**

- **Goal:** Analyze each identified risk and define appropriate response strategies.
- **Suggested Lead Action:**
  1.  **Analyze & Evaluate:** For each risk, describe it clearly, estimate its Likelihood and Impact, and determine an overall Risk Level.
  2.  **Define Mitigation:** For significant risks (Medium level or higher), brainstorm and define specific **Mitigation Actions** (to reduce likelihood/impact) and **Contingency Plans** (if the risk occurs).
  3.  **Log Decisions:** Log key mitigation strategies or risk acceptance choices as formal `Decisions` in ConPort.

**Milestone RA.3: Documentation**

- **Goal:** Log each identified risk and its associated analysis and plans as a structured item in ConPort.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **Delegate to `Nova-SpecializedConPortSteward`:**
      - **Subtask Goal:** "Log all identified risks and mitigation plans to the ConPort `RiskAssessment` category."
      - **Briefing Details:**
        - Provide a list of structured objects, one for each risk.
        - Instruct the specialist to loop through the list and use `log_custom_data` to create a new `CustomData RiskAssessment:[RiskID]` entry for each.
        - The `value` object for each entry must be comprehensive, including fields for `risk_description`, `category`, `likelihood`, `impact_severity`, `mitigation_actions_planned`, `contingency_plan_summary`, `status`, etc.
        - Instruct them to link each new `RiskAssessment` item to the main `Progress` item for this cycle.
        - The specialist should return a list of all created `RiskAssessment` keys.

**Milestone RA.4: Finalize Cycle**

- **Goal:** Close out the assessment process and report completion.
- **Suggested Lead Action:**
  1.  Create a high-level summary of the risk assessment (e.g., top 3-5 risks, overall risk posture).
  2.  Update the main `Progress` item to 'DONE'.
  3.  Update the `active_context.state_of_the_union` with a summary of the project's risk posture.
  4.  In your `attempt_completion` to `Nova-Orchestrator`, provide the risk summary and reference the keys of the logged `RiskAssessment` items.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- CustomData RiskAssessment:[Key] (key)
- Decisions (integer `id`)
- Reads various other ConPort items for context.
