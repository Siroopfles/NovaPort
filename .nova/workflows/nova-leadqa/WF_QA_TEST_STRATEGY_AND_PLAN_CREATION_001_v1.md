# Workflow: Test Strategy and Plan Creation (WF_QA_TEST_STRATEGY_AND_PLAN_CREATION_001_v1)

**Goal:** To define and document the overall test strategy and a detailed test plan for a new project, a major new feature, or a specific release.

**Primary Actor:** Nova-LeadQA
**Primary Specialist Actors:** Nova-SpecializedTestExecutor

**Trigger / Recognition:**
- `Nova-Orchestrator` delegates a "Define Test Strategy" or "Create Test Plan" task.
- Start of a new major development phase requiring a formal QA plan.

**Reference Milestones for your Single-Step Loop:**

**Milestone TSP.1: Strategy Definition**
*   **Goal:** Define the high-level approach to testing for the given scope.
*   **Suggested Lead Action:**
    1.  Log a main `Progress` item for this planning cycle.
    2.  **Analyze Context:** Use `use_mcp_tool` to retrieve `ProductContext`, `ProjectConfig`, `RiskAssessment`, and other high-level items.
    3.  **Define Strategy:**
        *   What are the main quality goals?
        *   What types of testing are critical (functional, performance, security)?
        *   What is the balance between manual and automated testing?
    4.  Log the high-level strategy as a formal `Decision` in ConPort.

**Milestone TSP.2: Detailed Plan Development (Iterative)**
*   **Goal:** Flesh out the detailed components of the test plan.
*   **Suggested Lead Action & Specialist Sequence (delegate as atomic sub-tasks):**
    1.  **LeadQA Action: Define Scope & Objectives:** Based on `FeatureScope` and `AcceptanceCriteria`, clearly define what is in and out of scope for testing. List specific, measurable test objectives.
    2.  **Delegate Test Case Design to `Nova-SpecializedTestExecutor`:**
        *   **Subtask Goal:** "For each in-scope feature/requirement, define high-level test scenarios and detailed test cases."
        *   **Briefing Details:** Instruct to follow the process from `WF_QA_TEST_CASE_DESIGN_FROM_SPECS_001_v1.md`. This involves breaking down features, considering positive/negative paths, and defining test steps, data, and expected results.
    3.  **LeadQA Action: Define Environments & Criteria:**
        *   Specify test environments needed by referencing `ProjectConfig`.
        *   Define the test data management strategy.
        *   List all testing tools required.
        *   Define clear entry and exit criteria for the testing phase (e.g., "0 open CRITICAL bugs").

**Milestone TSP.3: Documentation & Finalization**
*   **Goal:** Compile the final test plan and log it to ConPort.
*   **Suggested Lead Action & Specialist Sequence:**
    1.  **LeadQA Action: Compile Draft:** Consolidate all defined sections into a comprehensive test plan document.
    2.  **LeadQA Action: Review:** Review the draft for completeness, clarity, and feasibility. If required, share with `Nova-Orchestrator` for stakeholder review.
    3.  **Delegate Logging to `Nova-SpecializedConPortSteward` (via LeadArchitect) or self-action:**
        *   **Subtask Goal:** "Log the finalized Test Plan for [ScopeName] into ConPort `TestPlans` category."
        *   **Briefing Details:** Provide the final, consolidated test plan content. Instruct to use `log_custom_data` to create a `CustomData TestPlans:[ScopeName]_TestPlan_v[Version]` entry. Ensure the new item is linked to the main `Progress` item for this planning cycle.
    4.  **LeadQA Action:** Finalize the cycle by updating the main `Progress` to 'DONE' and reporting completion to `Nova-Orchestrator`, providing the key of the new `TestPlans` entry.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- CustomData TestPlans:[Key] (key)
- Reads various specs, configs, and risk assessments from ConPort.