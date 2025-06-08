# Workflow: Test Case Design from Specifications (WF_QA_TEST_CASE_DESIGN_FROM_SPECS_001_v1)

**Goal:** To systematically derive and document test cases (or high-level test scenarios/charters) based on feature specifications, acceptance criteria, and system design documents, managed by Nova-LeadQA.

**Primary Actor:** Nova-LeadQA
**Primary Specialist Actors (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor (for drafting detailed test steps or contributing to scenario identification), (potentially Nova-FlowAsk for analyzing specs if LeadQA delegates this for complex parts).

**Trigger / Recognition:**
- Nova-LeadQA is tasked by Nova-Orchestrator to prepare for testing a new feature, and a `TestPlans:[key]` item is needed.
- As part of `WF_QA_TEST_STRATEGY_AND_PLAN_CREATION_001_v1.md`, this workflow can be a sub-process for the "Define Test Cases / Scenarios" step.
- New `FeatureScope:[key]` or `AcceptanceCriteria:[key]` are finalized and ready for QA test design.

**Pre-requisites by Nova-LeadQA:**
- Relevant specifications are available and stable in ConPort:
    - `CustomData FeatureScope:[FeatureName_ScopeKey]` (key)
    - `CustomData AcceptanceCriteria:[FeatureName_ACKey]` (key)
    - (Optional) `CustomData SystemArchitecture:[ComponentKey]` (key) for components involved.
    - (Optional) `CustomData APIEndpoints:[APIKey]` (key) if APIs are part of the scope.
- The overall test strategy (e.g., risk areas, types of testing needed) is understood by LeadQA.

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator, or as a self-contained sub-process):**

**Phase TCD.1: Analysis & Scenario Identification**

1.  **Nova-LeadQA: Review Specifications & Identify Testable Requirements**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Log `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "Test Case Design for [FeatureName/Scope]". Let this be `[TestCaseDesignProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[TestCaseDesignProgressID]_QAPlan` (key) using `use_mcp_tool`. Plan items:
            1.  Analyze Specs & Decompose Requirements (LeadQA, potentially delegate parts to TestExecutor or FlowAsk for spec summarization).
            2.  Draft High-Level Test Scenarios/Categories (LeadQA).
            3.  Detail Test Cases for Scenario Group A (Delegate to TestExecutor).
            4.  Detail Test Cases for Scenario Group B (Delegate to TestExecutor).
            5.  Review & Consolidate Test Cases (LeadQA).
            6.  Log Test Cases to `TestPlans` or a test case management system concept (LeadQA or delegate to ConPortSteward/TestExecutor).
    *   **ConPort Action:**
        *   Use `use_mcp_tool` (`tool_name: 'get_custom_data'`) to retrieve `FeatureScope:[FeatureName_ScopeKey]`, `AcceptanceCriteria:[FeatureName_ACKey]`, and any relevant `SystemArchitecture` or `APIEndpoints` items.
        *   Analyze these documents to identify specific functional requirements, user stories, acceptance criteria, business rules, and technical constraints that need to be tested.
    *   **Output:** List of testable requirements/criteria. `[TestCaseDesignProgressID]` known.

2.  **Nova-LeadQA: Draft High-Level Test Scenarios & Categories**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Based on the decomposed requirements, group them into logical test scenarios or categories.
        *   Examples: "User Registration Scenarios", "Payment Processing Scenarios", "Error Handling for API X", "Performance under Peak Load for Module Y".
        *   For each scenario/category, define its objective.
        *   Prioritize scenarios based on risk and importance (from `RiskAssessment` (key) if available, or LeadQA's judgment).
    *   **Output:** A structured list of high-level test scenarios/categories with objectives and priorities. Update `[TestCaseDesignProgressID]_QAPlan`.

**Phase TCD.2: Detailed Test Case Elaboration (Potentially Delegated)**

3.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Detail Test Cases for Specific Scenarios**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "For Test Scenario '[ScenarioName]', elaborate detailed test cases including steps, expected results, and pre-conditions."
    *   **`new_task` message for Nova-SpecializedTestExecutor (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (TestCaseDesign_[FeatureName]) -> DetailCases_[ScenarioName] (TestExecutor)",
          "Overall_QA_Phase_Goal": "Design Test Cases for [FeatureName/Scope].",
          "Specialist_Subtask_Goal": "Elaborate detailed test cases for scenario: '[ScenarioName]'.",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[TestCaseDesignProgressID]`.",
            "Scenario Objective: [Objective_From_LeadQA].",
            "Relevant Specs: `FeatureScope:[FS_Key]`, `AcceptanceCriteria:[AC_Key]`, (any other relevant component/API keys).",
            "For this scenario, design detailed test cases. Each test case should ideally include:",
            "  - Test Case ID (e.g., TC_[ScenarioShortName]_001).",
            "  - Test Case Title/Summary.",
            "  - Pre-conditions.",
            "  - Detailed step-by-step execution instructions.",
            "  - Test Data requirements (specific inputs, user roles, etc.).",
            "  - Expected Result for each step or overall.",
            "  - Pass/Fail Criteria.",
            "  - Priority (High/Medium/Low).",
            "  - Test Type (e.g., Functional, Negative, UI, API).",
            "Consider positive paths, negative paths, boundary conditions.",
            "Document these test cases in a structured format (e.g., Markdown table, list of objects for later import into a Test Plan)."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[TestCaseDesignProgressID_as_string]",
            "Scenario_Name_And_Objective": "[...]",
            "Relevant_Specification_ConPort_Refs": [{ "type": "custom_data", "category": "FeatureScope", "key": "[FS_Key]" }, ...]
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": ["Structured list/document of detailed test cases for the assigned scenario."]
        }
        ```
    *   **Nova-LeadQA Action after Specialist's `attempt_completion`:** Review drafted test cases. Update plan/progress. (Repeat for other scenarios).

**Phase TCD.3: Review, Consolidation & Logging**

4.  **Nova-LeadQA: Review & Consolidate All Test Cases**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Collect all detailed test cases drafted by TestExecutor(s) or self.
        *   Review for completeness, correctness, clarity, and coverage against the original specifications.
        *   Ensure consistency in format and terminology.
        *   Remove duplicates, refine steps, and ensure traceability to requirements/ACs.
    *   **Output:** A consolidated and reviewed set of test cases for [FeatureName/Scope].

5.  **Nova-LeadQA (or delegate to Nova-SpecializedConPortSteward via LeadArchitect): Log Test Plan / Test Cases**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   The consolidated test cases now form the core of the detailed test plan for this scope.
        *   Log this test plan to ConPort. This might involve:
            *   Creating/updating a `CustomData TestPlans:[ScopeName]_TestPlan_vX.Y` (key) entry using `use_mcp_tool` (`tool_name: 'log_custom_data'`).
            *   The `value` of this `TestPlans` entry could be a JSON object containing:
                *   `title`, `scope_summary`, `version`.
                *   A list of test scenarios, each with a list of detailed test case objects (ID, title, steps, expected results, etc.).
                *   Or, if very extensive, the `value` might contain a summary and a link to a detailed test case document stored in `.nova/reports/qa/testcases_[ScopeName]_vX.Y.md` (or a CSV/XML if preferred for tool import).
        *   Link this `TestPlans` (key) entry to relevant `FeatureScope` (key), `AcceptanceCriteria` (key), and the `[TestCaseDesignProgressID]` `Progress` item using `use_mcp_tool` (`tool_name: 'link_conport_items'`).
    *   **Output:** Test cases/plan logged in ConPort.

6.  **Nova-LeadQA: Finalize Test Case Design Phase**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Update main `Progress` (`[TestCaseDesignProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "Test case design for [FeatureName/Scope] complete. Logged as `TestPlans:[TestPlanKey]`."
        *   If this was part of a larger QA planning effort, this output feeds into the overall `TestStrategyAndPlan`.
    *   **Output:** Test case design phase completed.

7.  **Nova-LeadQA: `attempt_completion` to Nova-Orchestrator (if this was a top-level delegated phase)**
    *   **Actor:** Nova-LeadQA
    *   **Action:** Report completion, providing the ConPort key of the `TestPlans` entry (or main test plan document) and a summary of test coverage achieved by the designed cases.

**Key ConPort Items Involved:**
- Progress (integer `id`): Overall phase, specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[TestCaseDesignProgressID]_QAPlan (key).
- CustomData TestPlans:[ScopeName]_TestPlan_vX.Y (key): The primary deliverable.
- (Reads) FeatureScope (key), AcceptanceCriteria (key), SystemArchitecture (key), APIEndpoints (key), ProjectConfig (key).
- (Potentially) Links created between `TestPlans` and `FeatureScope`/`AcceptanceCriteria`.