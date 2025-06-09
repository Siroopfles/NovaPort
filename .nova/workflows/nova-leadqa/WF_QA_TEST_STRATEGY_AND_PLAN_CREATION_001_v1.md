# Workflow: Test Strategy and Plan Creation (WF_QA_TEST_STRATEGY_AND_PLAN_CREATION_001_v1)

**Goal:** To define and document the overall test strategy and a detailed test plan for a new project, a major new feature, or a specific release candidate, managed by Nova-LeadQA.

**Primary Actor:** Nova-LeadQA (receives task from Nova-Orchestrator, or initiates based on project phase or `NovaSystemConfig` for QA planning).
**Primary Specialist Actors (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor (for input on testability/effort for specific test cases), (potentially Nova-FlowAsk for analyzing specs if LeadQA delegates this).

**Trigger / Recognition:**
- Nova-Orchestrator delegates a "Define Test Strategy for Project [ProjectName]" or "Create Test Plan for Feature [FeatureName]" task to Nova-LeadQA.
- Start of a new major development phase requiring a formal QA plan.
- `NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadqa.test_plan_requirement_trigger` (e.g., "on_new_epic_definition") indicates a plan is needed.

**Pre-requisites by Nova-LeadQA (from Nova-Orchestrator's briefing or self-assessment):**
- Scope of what needs to be tested is relatively clear (e.g., entire project, specific feature set, release candidate scope).
- Access to relevant ConPort items using `use_mcp_tool` (`tool_name: 'get_custom_data'`, `get_product_context`, etc.): `ProductContext` (key 'product_context'), `SystemArchitecture` (key), `FeatureScope` (key), `AcceptanceCriteria` (key), `ProjectConfig:ActiveConfig` (key), `NovaSystemConfig:ActiveSettings` (key).

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator, or as a self-contained sub-process):**

**Phase TSP.1: Strategy Definition & Scope Analysis by Nova-LeadQA**

1.  **Nova-LeadQA: Receive Task & Define Overall Test Strategy**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator if applicable.
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"status\": \"IN_PROGRESS\", \"description\": \"Test Strategy & Plan Creation: [ScopeName]\"}`). Let this be `[TestPlanProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[TestPlanProgressID]_QAPlan` (key) using `use_mcp_tool`. Plan items:
            1.  Define Test Objectives & Scope.
            2.  Identify Test Types & Levels (Unit, Integration, System, E2E, Performance, Security, Usability, etc.).
            3.  Define Test Environments (referencing `ProjectConfig:ActiveConfig.testing`).
            4.  Define Test Data Management Strategy.
            5.  Identify Tools & Resources (referencing `ProjectConfig:ActiveConfig.testing.commands`).
            6.  Define Entry/Exit Criteria for major testing phases.
            7.  Perform Risk-Based Prioritization of Test Areas.
            8.  Draft Detailed Test Plan Document/ConPort Entry (potentially delegate parts to TestExecutor for scenario drafting).
            9.  Review Test Plan (internal, then with Orchestrator/stakeholders if needed).
            10. Log Final Test Plan to ConPort (delegate to ConPortSteward via LeadArchitect, or self/TestExecutor if capabilities allow direct `log_custom_data` to `TestPlans` category).
    *   **Logic (Test Strategy - high level):**
        *   Based on `ProductContext` (key 'product_context'), `ProjectConfig:ActiveConfig` (key), `NovaSystemConfig:ActiveSettings` (key), and project risks (`CustomData RiskAssessment:[key]` if available):
            *   What are the main quality goals for [ScopeName]?
            *   What types of testing are critical (e.g., functional, performance, security, usability)?
            *   What is the balance between manual and automated testing for this scope? (Refer to `ProjectConfig:ActiveConfig.testing.automation_emphasis_level`).
            *   What are the key responsibilities for testing across different teams/modes?
    *   **ConPort Action:** Log a `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"summary\": \"Adopt risk-based testing strategy for [ScopeName]\", \"rationale\": \"Focus QA effort on most critical areas.\"}`) for the overall Test Strategy approach. Link to `[TestPlanProgressID]`.
    *   **Output:** High-level test strategy defined. Detailed plan outline ready in `LeadPhaseExecutionPlan`.

**Phase TSP.2: Detailed Test Plan Development**

2.  **Nova-LeadQA: Detail Test Scope & Objectives**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Based on ConPort items like `FeatureScope:[key]`, `AcceptanceCriteria:[key]`, `SystemArchitecture:[key]`, `APIEndpoints:[key]` (retrieved via `use_mcp_tool`):
            *   Clearly define what IS and IS NOT in scope for this test plan.
            *   List specific, measurable, achievable, relevant, and time-bound (SMART) test objectives.
    *   **Output:** Documented scope and objectives (typically as sections within the evolving test plan document/ConPort entry). Update `[TestPlanProgressID]_QAPlan`.

3.  **Nova-LeadQA (Potentially delegate test case scenario drafting to Nova-SpecializedTestExecutor): Define Test Cases / Scenarios**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "For each in-scope feature/requirement for [ScopeName], define high-level test scenarios and/or specific test cases/charters."
    *   **Logic / Instructions for self or TestExecutor:**
        *   Break down features/Acceptance Criteria into testable scenarios.
        *   Consider positive tests (happy paths), negative tests (error conditions), boundary value analysis, equivalence partitioning.
        *   Define charters for exploratory testing sessions for areas requiring more ad-hoc investigation.
        *   Prioritize scenarios/cases based on risk and business impact (identified in TSP.1 or from `RiskAssessment` items).
        *   For each test case/scenario (or group): specify pre-conditions, steps, test data requirements, expected results, and pass/fail criteria.
    *   **Output:** A comprehensive list of test scenarios/cases/charters. These can be drafted in a temporary document or directly into a section of the `CustomData TestPlans:[ScopeName]_TestPlan_vX.Y` (key) entry being prepared. Update `[TestPlanProgressID]_QAPlan`.

4.  **Nova-LeadQA: Define Test Environment, Data, Tools, Entry/Exit Criteria**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Specify test environments needed (referencing `CustomData ProjectConfig:ActiveConfig.testing.environments`, e.g., `regression_env_url`, `performance_env_url`).
        *   Define requirements for test data: generation methods, refresh strategy, data privacy/masking considerations, specific datasets needed.
        *   List testing tools to be used (from `ProjectConfig:ActiveConfig.security.tools` like Bandit, or project-specific scripts).
        *   Define clear entry criteria (e.g., "Feature X development complete, unit tests passed, build X.Y.Z deployed to Staging") and exit criteria (e.g., "95% of planned test cases passed, 0 open CRITICAL bugs, <3 open HIGH severity bugs for Release Z") for major testing phases covered by this plan.
    *   **Output:** These sections are drafted for the test plan. Update `[TestPlanProgressID]_QAPlan`.

**Phase TSP.3: Documentation & Finalization**

5.  **Nova-LeadQA (or delegate compilation to Nova-SpecializedTestExecutor or Nova-SpecializedConPortSteward via LeadArchitect): Compile Draft Test Plan Document/ConPort Entry**
    *   **Actor:** Nova-LeadQA
    *   **Action:** Consolidate all defined sections (Strategy Summary, Scope, Objectives, Test Types, Scenarios/Cases/Charters, Environment, Data, Tools, Entry/Exit Criteria, Responsibilities, Schedule (high-level)) into a comprehensive document or structured ConPort entry.
    *   **Storage:**
        *   Option A (File): Save as detailed Markdown to `.nova/reports/qa/TestPlan_[ScopeName]_vX.Y_Draft.md` using `write_to_file`.
        *   Option B (ConPort): Prepare a structured JSON object for `CustomData TestPlans:[ScopeName]_TestPlan_vX.Y_Draft` (key). The `value` can contain the full plan or link to the `.md` file if too large.
    *   **Output:** Draft test plan ready for review.

6.  **Nova-LeadQA: Review Test Plan (Internal / Stakeholder)**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Review the draft test plan for completeness, clarity, coverage, and feasibility.
        *   (Optional, if required by Orchestrator's briefing or `NovaSystemConfig`): Share the draft plan (or its ConPort key / file path) with Nova-Orchestrator to relay for stakeholder review (e.g., Product Owner, Nova-LeadDeveloper, Nova-LeadArchitect). Incorporate feedback.
    *   **ConPort Action:** Log a `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`) to approve the Test Plan content after review. Summary: "Test Plan for [ScopeName] vX.Y approved."
    *   **Output:** Finalized Test Plan content.

7.  **Nova-LeadQA -> Delegate to Nova-SpecializedConPortSteward (via Nova-LeadArchitect if strict hierarchy, or self/TestExecutor if capability allows): Log Final Test Plan**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "Log the finalized Test Plan for [ScopeName] into ConPort `CustomData TestPlans` category."
    *   **`new_task` message (conceptual):**
        ```json
        {
          "Context_Path": "[ProjectName] (TestStrategyPlan_[ScopeName]) -> LogFinalTestPlan (ConPortSteward)",
          "Overall_QA_Phase_Goal": "Test Strategy & Plan Creation for [ScopeName].",
          "Specialist_Subtask_Goal": "Log the finalized Test Plan to ConPort `CustomData TestPlans:[ScopeName]_TestPlan_v[Version]` (key).",
          "Specialist_Specific_Instructions": [
            "Final Test Plan Content/Path: [Finalized content or path to .md file from LeadQA].",
            "To log or update, use `use_mcp_tool` (`tool_name: 'log_custom_data'`). The arguments for this call must be:",
            "  `arguments`: {",
            "    `\"workspace_id\"`: \"ACTUAL_WORKSPACE_ID\",",
            "    `\"category\"`: \"TestPlans\",",
            "    `\"key\"`: \"[ScopeName]_TestPlan_v[Version]\",",
            "    `\"value\"`: { ",
            "      `\"title\"`: \"Test Plan for [ScopeName] v[Version]\",",
            "      `\"scope_summary\"`: \"[...Scope details...]\",",
            "      `\"objectives_summary\"`: [\"Objective 1...\"],",
            "      `\"strategy_decision_ref\"`: \"Decision:[TestStrategyDecisionID_as_string]\", ",
            "      `\"test_levels_covered\"`: [\"Unit\", \"Integration\", \"E2E\"],",
            "      `\"key_scenarios_link_or_summary\"`: \"[Summary or link to detailed test cases]\",",
            "      `\"status\"`: \"Approved\", `\"version\"`: \"[Version]\"",
            "    }",
            "  }",
            "Link this `TestPlans` (key) entry to the main `Progress` item (`[TestPlanProgressID_as_integer]`) using `use_mcp_tool` (`tool_name: 'link_conport_items'`, `arguments: {\"workspace_id\": \"ACTUAL_WORKSPACE_ID\", \"source_item_type\": \"custom_data\", \"source_item_id\": \"TestPlans:[ScopeName]_TestPlan_v[Version]\", \"target_item_type\": \"progress_entry\", \"target_item_id\": \"[TestPlanProgressID_as_string]\", \"relationship_type\": \"defines_testing_for\"}`)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Final_Test_Plan_Content_Or_Path": "[...]",
            "ScopeName_For_Key": "[ScopeName]",
            "Version_For_Key_And_Content": "[Version]",
            "Main_Planning_Progress_ID_as_integer": "[TestPlanProgressID_as_integer]",
            "Test_Strategy_Decision_ID_String": "[TestStrategyDecisionID_as_string]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "ConPort key of the created `TestPlans` entry."
          ]
        }
        ```
    *   **Nova-LeadQA Action:** Verify ConPort entry using `use_mcp_tool` (`tool_name: 'get_custom_data'`).

8.  **Nova-LeadQA: Finalize & Report**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Update main `Progress` (`[TestPlanProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "Test Strategy & Plan for [ScopeName] v[Version] defined and logged: `TestPlans:[Key]`."
        *   Coordinate update of `active_context.state_of_the_union` (via Nova-Orchestrator) with "Test Plan for [ScopeName] defined: `TestPlans:[Key]`."
    *   **Output:** Test Plan established and ready for execution phase.

9.  **Nova-LeadQA: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadQA
    *   **Action:** Report completion, providing ConPort key of the `TestPlans` entry and a brief summary of the strategy and plan coverage.

**Key ConPort Items Involved:**
- Progress (integer `id`): Overall phase, specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[TestPlanProgressID]_QAPlan (key).
- Decisions (integer `id`): For overall test strategy, approval of test plan.
- CustomData TestPlans:[ScopeName]_TestPlan_v[Version] (key): The main deliverable.
- ActiveContext (`state_of_the_union` update).
- Reads: ProductContext (key 'product_context'), SystemArchitecture (key), FeatureScope (key), AcceptanceCriteria (key), ProjectConfig (key), NovaSystemConfig (key), RiskAssessment (key).