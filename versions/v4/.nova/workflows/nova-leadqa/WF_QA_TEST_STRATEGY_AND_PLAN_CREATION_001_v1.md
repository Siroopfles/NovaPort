# Workflow: Test Strategy and Plan Creation (WF_QA_TEST_STRATEGY_AND_PLAN_CREATION_001_v1)

**Goal:** To define and document the overall test strategy and a detailed test plan for a new project, a major new feature, or a specific release candidate, managed by Nova-LeadQA.

**Primary Orchestrator Actor:** Nova-LeadQA (receives task from Nova-Orchestrator, or initiates based on project phase or `NovaSystemConfig` for QA planning).
**Primary Specialist Actors (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor (for input on testability/effort), (potentially Nova-FlowAsk for analyzing specs).

**Trigger / Nova-LeadQA Recognition:**
- Nova-Orchestrator delegates a "Define Test Strategy for Project X" or "Create Test Plan for Feature Y" task.
- Start of a new major development phase requiring a formal QA plan.
- `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadqa.test_plan_requirement_trigger` (e.g., "on_new_epic_definition").

**Pre-requisites by Nova-LeadQA:**
- Scope of what needs to be tested is relatively clear (e.g., entire project, specific feature set, release candidate scope).
- Access to relevant ConPort items: `ProductContext` (key 'product_context'), `SystemArchitecture` (key), `FeatureScope` (key), `AcceptanceCriteria` (key), `ProjectConfig:ActiveConfig` (key), `NovaSystemConfig:ActiveSettings` (key).

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator, or as a self-contained sub-process):**

**Phase TSP.1: Strategy Definition & Scope Analysis by Nova-LeadQA**

1.  **Nova-LeadQA: Receive Task & Define Overall Test Strategy**
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator if applicable.
        *   Log main `Progress` (integer `id`) item: "Test Strategy & Plan Creation: [ScopeName]".
        *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[TestPlanProgressID]_QAPlan` (key)). Plan items:
            1.  Define Test Objectives & Scope.
            2.  Identify Test Types & Levels (Unit, Integration, System, E2E, Performance, Security).
            3.  Define Test Environments (ref `ProjectConfig`).
            4.  Define Test Data Requirements.
            5.  Identify Tools & Resources (ref `ProjectConfig`).
            6.  Define Entry/Exit Criteria for testing phases.
            7.  Risk-Based Prioritization of Test Areas.
            8.  Draft Detailed Test Plan Document/ConPort Entry.
            9.  Review Test Plan (internal or with stakeholders via Orchestrator).
            10. Log Final Test Plan.
    *   **Logic (Test Strategy - high level):**
        *   Based on `ProductContext` (key 'product_context'), `ProjectConfig:ActiveConfig` (key), `NovaSystemConfig:ActiveSettings` (key), and project risks (`RiskAssessment` (key) if available):
            *   What are the main quality goals?
            *   What types of testing are critical (e.g., functional, performance, security, usability)?
            *   What is the balance between manual and automated testing?
            *   What are the key responsibilities for testing (Dev team for unit/integ, QA team for system/E2E/exploratory)?
    *   **ConPort:** Log a `Decision` (integer `id`) for the overall Test Strategy approach (e.g., "Decision: Adopt risk-based testing approach with focus on E2E automation for critical paths for Project X.").
    *   **Output:** High-level test strategy defined. Detailed plan outline ready.

**Phase TSP.2: Detailed Test Plan Development (Nova-LeadQA & Specialists)**

2.  **Nova-LeadQA: Detail Test Scope & Objectives**
    *   **Action:**
        *   Based on `FeatureScope:[key]`, `AcceptanceCriteria:[key]`, `SystemArchitecture:[key]`, `APIEndpoints:[key]`:
            *   Clearly define what IS and IS NOT in scope for this test plan.
            *   List specific test objectives.
    *   **Output:** Documented scope and objectives (can be part of the evolving test plan document).

3.  **Nova-LeadQA (Potentially delegate parts to Nova-SpecializedTestExecutor for feasibility input): Define Test Cases / Scenarios**
    *   **Task:** "For each in-scope feature/requirement, define high-level test scenarios and/or specific test cases."
    *   **Logic:**
        *   Break down features/ACs into testable scenarios.
        *   Consider positive tests, negative tests, boundary conditions, exploratory test charters.
        *   Prioritize scenarios based on risk and business impact.
    *   **Output:** List of test scenarios/cases (can be stored temporarily or directly in a draft ConPort `CustomData TestPlan:[ScopeName]_v1` (key) entry).

4.  **Nova-LeadQA: Define Test Environment, Data, Tools, Entry/Exit Criteria**
    *   **Action:**
        *   Specify test environments needed (referencing `ProjectConfig:ActiveConfig.testing_preferences.test_env_details`).
        *   Define requirements for test data (creation, refresh, anonymization).
        *   List testing tools to be used (from `ProjectConfig:ActiveConfig` or new ones if decided).
        *   Define clear entry criteria (e.g., "Feature X dev complete and unit tested") and exit criteria (e.g., "95% test cases passed, 0 critical/high open bugs") for major testing phases covered by this plan.
    *   **Output:** These sections are added to the draft test plan.

**Phase TSP.3: Documentation & Finalization**

5.  **Nova-LeadQA (or delegate to Nova-SpecializedTestExecutor or Nova-FlowAsk for compilation): Compile Draft Test Plan Document**
    *   **Action:** Consolidate all defined sections (Strategy, Scope, Objectives, Scenarios/Cases, Environment, Data, Tools, Entry/Exit) into a comprehensive document.
    *   This document could be a detailed Markdown file saved to `.nova/reports/TestPlan_[ScopeName]_v1_Draft.md` or a structured ConPort `CustomData TestPlan:[ScopeName]_v1_Draft` (key) entry.

6.  **Nova-LeadQA: Review Test Plan (Internal / Stakeholder)**
    *   **Action:**
        *   Review the draft test plan for completeness, clarity, and coverage.
        *   (Optional, if required by Orchestrator's briefing or `NovaSystemConfig`): Share the draft plan (or its ConPort key / file path) with Nova-Orchestrator to relay for stakeholder review (e.g., Product Owner, Nova-LeadDeveloper). Incorporate feedback.
    *   **ConPort:** Log a `Decision` (integer `id`) to approve the Test Plan content after review.
    *   **Output:** Finalized Test Plan content.

7.  **Nova-LeadQA -> Delegate to Nova-SpecializedConPortSteward (via Nova-LeadArchitect if cross-Lead delegation needed, or directly if LeadQA has a ConPort specialist): Log Final Test Plan**
    *   **Task:** "Log the finalized Test Plan for [ScopeName] into ConPort."
    *   *(Note: For simplicity, assuming LeadQA can directly instruct a ConPort logging specialist for its own domain artifacts, or does it itself. If strict hierarchy requires Orchestrator for cross-Lead, LeadQA would request Orchestrator to task LeadArchitect's ConPortSteward).*
    *   **`new_task` message (conceptual, assuming direct or via Orchestrator):**
        ```
        Subtask_Briefing:
          Overall_QA_Phase_Goal: "Test Strategy & Plan Creation for [ScopeName]."
          Specialist_Subtask_Goal: "Log the finalized Test Plan to ConPort `CustomData TestPlans:[ScopeName]_v1` (key)."
          Specialist_Specific_Instructions:
            - "Test Plan Content/Path: [Finalized content or path to .md file from LeadQA]."
            - "Log as a new `CustomData` entry:"
            - "  Category: `TestPlans`"
            - "  Key: `[ScopeName]_TestPlan_v[Version]` (e.g., `FeatureZ_TestPlan_v1.0`)"
            - "  Value (JSON Object or Markdown string): 
                { 
                  \"scope\": \"[...Scope details...]\",
                  \"objectives\": [\"Objective 1...\"],
                  \"strategy_summary_ref\": \"Decision:[TestStrategyDecisionID]\", // Integer ID
                  \"test_levels\": [\"Unit\", \"Integration\", \"E2E\"],
                  \"environment_refs\": [\"ProjectConfig:ActiveConfig.testing_preferences.env_X\"],
                  \"entry_criteria\": \"...\", \"exit_criteria\": \"...\",
                  \"test_case_summary_or_link\": \"[Summary or link to .nova/reports/detailed_test_cases.csv]\"
                }"
            - "Link this `TestPlans` (key) entry to the main `Progress` (integer `id`) for this planning task."
          Required_Input_Context_For_Specialist:
            - Final_Test_Plan_Content_Or_Path: "[...]"
            - ScopeName_For_Key: "[ScopeName]"
            - Version_For_Key: "1.0"
            - Main_Planning_Progress_ID: [Integer `id` of LeadQA's phase progress item]
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "ConPort key of the created `TestPlans` entry."
        ```
    *   **Nova-LeadQA Action:** Verify ConPort entry.

8.  **Nova-LeadQA: Finalize & Report**
    *   **Action:**
        *   Update main `Progress` (integer `id`) for "Test Strategy & Plan Creation" to DONE.
        *   Update `active_context.state_of_the_union` with "Test Plan for [ScopeName] defined: `TestPlans:[Key]`."
    *   **Output:** Test Plan established and ready for execution phase.

9.  **Nova-LeadQA: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion, providing ConPort key of the `TestPlans` entry and a brief summary.

**Key ConPort Items Created/Updated:**
-   `Progress` (integer `id`): Overall phase, specialist subtasks.
-   `CustomData LeadPhaseExecutionPlan:[TestPlanProgressID]_QAPlan` (key).
-   `Decisions` (integer `id`): For overall test strategy, approval of test plan.
-   `CustomData TestPlans:[ScopeName]_TestPlan_v[Version]` (key): The main deliverable.
-   `ActiveContext` (key `state_of_the_union` update).
-   Reads: `ProductContext` (key 'product_context'), `SystemArchitecture` (key), `FeatureScope` (key), `AcceptanceCriteria` (key), `ProjectConfig` (key), `NovaSystemConfig` (key), `RiskAssessment` (key).