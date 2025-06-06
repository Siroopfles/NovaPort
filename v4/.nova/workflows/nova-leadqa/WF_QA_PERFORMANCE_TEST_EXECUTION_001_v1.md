# Workflow: Performance Test Execution (WF_QA_PERFORMANCE_TEST_EXECUTION_001_v1)

**Goal:** To execute defined performance tests (e.g., load, stress, soak) against specific application components or end-to-end scenarios, analyze results, and log performance metrics and issues.

**Primary Orchestrator Actor:** Nova-LeadQA (receives task from Nova-Orchestrator, or initiates if performance criteria are part of a feature's `AcceptanceCriteria` or if `NovaSystemConfig` mandates periodic performance checks).
**Primary Specialist Actor (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor (with skills/tools for performance testing).

**Trigger / Nova-LeadQA Recognition:**
- Nova-Orchestrator delegates: "Execute performance tests for [Component/Scenario] against build [Version]."
- `AcceptanceCriteria:[key]` for a feature includes specific performance targets (e.g., "API response time < 200ms under X load").
- Post-release monitoring or `NovaSystemConfig` triggers periodic performance health checks.

**Pre-requisites by Nova-LeadQA:**
- Application build is deployed to a dedicated performance testing environment (details in `ProjectConfig:ActiveConfig.testing_preferences.performance_test_env`).
- Performance test scripts/tools are available and configured (e.g., JMeter, k6, Locust scripts; paths/commands potentially in `ProjectConfig`).
- Clear performance targets/KPIs are defined (e.g., response time, throughput, error rate under load, resource utilization). These might be in `AcceptanceCriteria` (key) or a `CustomData PerformanceTargets:[Component]_Targets` (key) entry.

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator):**

**Phase PT.1: Planning & Setup by Nova-LeadQA**

1.  **Nova-LeadQA: Receive Task & Plan Performance Test Cycle**
    *   **Action:** Parse `Subtask Briefing Object`. Log `Progress` (integer `id`): "Performance Test: [Component/Scenario] - [Date]".
    *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[PerfTestProgressID]_QAPlan` (key)):
        1.  Verify Test Environment & Baseline Metrics (TestExecutor).
        2.  Execute Performance Test Scenario A (TestExecutor).
        3.  Analyze Results for Scenario A (TestExecutor/LeadQA).
        4.  (Repeat 2-3 for other scenarios).
        5.  Compile Performance Test Report & Log `PerformanceNotes` (TestExecutor/LeadQA).
    *   **ConPort:** Review `PerformanceTargets:[Component]_Targets` (key) or relevant `AcceptanceCriteria` (key). Log `Decision` (integer `id`) to start performance tests.
    *   **Output:** Plan ready.

**Phase PT.2: Test Execution & Analysis by Nova-SpecializedTestExecutor (Sequentially Managed)**

2.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Environment Baseline & Test Execution**
    *   **Task:** "Establish baseline server metrics, execute performance test script [ScriptName] for [ScenarioName], and collect all results."
    *   **`new_task` message for Nova-SpecializedTestExecutor:**
        ```
        Subtask_Briefing:
          Overall_QA_Phase_Goal: "Performance Test Cycle for [Component/Scenario]."
          Specialist_Subtask_Goal: "Execute performance test for [ScenarioName] using [ScriptName]."
          Specialist_Specific_Instructions:
            - "1. Connect to performance test environment: [Details from ProjectConfig]."
            - "2. (If applicable) Capture baseline server metrics (CPU, memory, network) before test."
            - "3. Execute performance test script: `[command_from_ProjectConfig_or_briefing - e.g., k6 run scripts/loadtest_scenarioA.js]`."
            - "4. Monitor server metrics during the test."
            - "5. Collect all raw output from the test tool (e.g., summary statistics, transaction times, error rates, detailed logs/CSVs)."
            - "6. Save raw results to `.nova/reports/performance/[ScenarioName]_[Date]/`."
          Required_Input_Context_For_Specialist:
            - ScenarioName_And_ScriptName: "[...]"
            - Performance_Test_Environment_Details_Ref: "ProjectConfig:ActiveConfig.testing_preferences.performance_test_env"
            - Performance_Test_Script_Command_And_Path: "[...]"
            - Performance_KPI_Targets_Ref: "ConPort CustomData PerformanceTargets:[Component]_Targets (key)" // For context
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation of test execution."
            - "Path to raw results in `.nova/reports/`."
            - "Summary of key metrics observed (e.g., avg response time, p95, error rate)."
        ```
    *   **Nova-LeadQA Action:** Monitor. If script execution fails, investigate with specialist. Update plan/progress.

3.  **Nova-LeadQA (can delegate detailed analysis to TestExecutor or Nova-FlowAsk): Analyze Results against KPIs**
    *   **Task:** "Analyze raw performance test results for [ScenarioName] against defined KPIs from `PerformanceTargets:[Component]_Targets` (key)."
    *   **Logic:** Compare observed metrics (avg/p95/p99 response times, throughput, error rates, resource utilization) against targets. Identify bottlenecks or deviations.
    *   **Output:** Analysis summary for this scenario (pass/fail against KPIs, key observations).

*(... Repeat steps 2 & 3 for other defined performance test scenarios in the plan ...)*

**Phase PT.3: Reporting & Closure by Nova-LeadQA**

4.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor (or self): Compile Overall Performance Report & Log `PerformanceNotes`**
    *   **Task:** "Compile an overall performance test report and log key findings as `PerformanceNotes` in ConPort."
    *   **`new_task` message for Nova-SpecializedTestExecutor:**
        ```
        Subtask_Briefing:
          Overall_QA_Phase_Goal: "Performance Test Cycle for [Component/Scenario]."
          Specialist_Subtask_Goal: "Compile overall performance report and log ConPort `PerformanceNotes`."
          Specialist_Specific_Instructions:
            - "1. Consolidate analysis from all executed scenarios."
            - "2. Create a summary Markdown report in `.nova/reports/performance/OverallReport_[Component]_[Date].md`. Include:
                  - Test scope, environment, tool used.
                  - For each scenario: KPIs vs. actuals, pass/fail status.
                  - Identified bottlenecks, resource contention issues.
                  - Graphs/charts if generated by tools and easily includable/linkable."
            - "3. For each significant finding (e.g., a KPI miss, a major bottleneck): Log a `CustomData PerformanceNotes:[Component]_[FindingType]_[Date]` (key) entry in ConPort. Value should include:
                  { 
                    \"component_scenario\": \"[Component/ScenarioName]\",
                    \"metric_observed\": \"e.g., P95 Response Time\",
                    \"target_value\": \"<200ms\",
                    \"actual_value\": \"550ms\",
                    \"finding_description\": \"API X shows high latency under Y load.\",
                    \"potential_cause_hypothesis\": \"Possible DB contention or inefficient query.\",
                    \"raw_data_report_ref\": \".nova/reports/performance/[ScenarioName]_[Date]/details.csv\"
                  }"
          Required_Input_Context_For_Specialist:
            - List_Of_Executed_Scenarios_And_Analysis_Summaries: "[From LeadQA]"
            - Performance_KPI_Targets_Ref_Key: "PerformanceTargets:[Component]_Targets"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Path to the overall performance report in `.nova/reports/`."
            - "List of ConPort keys for all created `PerformanceNotes` entries."
        ```
    *   **Nova-LeadQA Action:** Review report and ConPort entries.

5.  **Nova-LeadQA: Finalize Cycle & Report**
    *   **Action:** Update main `Progress` (integer `id`) for "Performance Test" to DONE (or DONE_WITH_ISSUES). Update `active_context.state_of_the_union`.
    *   **`attempt_completion` to Nova-Orchestrator:** Report completion, summary of performance (pass/fail against KPIs), reference to full report and key `PerformanceNotes` (keys). If critical performance issues, highlight them as blockers.

**Key ConPort Items Involved:**
-   `Progress` (integer `id`)
-   `CustomData LeadPhaseExecutionPlan:[PerfTestProgressID]_QAPlan` (key)
-   `Decisions` (integer `id`) (e.g., to accept certain performance deviations, or to prioritize optimization)
-   `CustomData PerformanceTargets:[Component]_Targets` (key) (Read)
-   `CustomData PerformanceNotes:[key]` (key) (multiple entries created)
-   `ActiveContext` (`state_of_the_union` update)
-   Reads `ProjectConfig:ActiveConfig` (key).