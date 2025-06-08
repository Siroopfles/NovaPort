# Workflow: Performance Test Execution (WF_QA_PERFORMANCE_TEST_EXECUTION_001_v1)

**Goal:** To execute defined performance tests (e.g., load, stress, soak) against specific application components or end-to-end scenarios, analyze results, and log performance metrics and issues.

**Primary Actor:** Nova-LeadQA (receives task from Nova-Orchestrator, or initiates if performance criteria are part of a feature's `AcceptanceCriteria` or if `NovaSystemConfig` mandates periodic performance checks).
**Primary Specialist Actor (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor (with skills/tools for performance testing).

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Execute performance tests for [Component/Scenario] on Project [ProjectName] against build [Version]."
- `CustomData AcceptanceCriteria:[FeatureKey]` (key) for a feature includes specific performance targets (e.g., "API response time < 200ms under X load").
- Post-release monitoring or `CustomData NovaSystemConfig:ActiveSettings.mode_behavior.nova-leadqa.performance_check_schedule` triggers periodic performance health checks.

**Pre-requisites by Nova-LeadQA (from Nova-Orchestrator's briefing or ConPort):**
- Application build is deployed to a dedicated performance testing environment (details in `CustomData ProjectConfig:ActiveConfig.testing_preferences.performance_test_env` (key)).
- Performance test scripts/tools are available and configured (e.g., JMeter, k6, Locust scripts; paths/commands potentially in `ProjectConfig:ActiveConfig.testing_preferences.performance_tools.[tool_name]_command`).
- Clear performance targets/KPIs are defined (e.g., in `AcceptanceCriteria` (key) or a `CustomData PerformanceTargets:[Component]_Targets_vX` (key) entry).

**Phases & Steps (managed by Nova-LeadQA within its single active task from Nova-Orchestrator):**

**Phase PT.1: Planning & Setup**

1.  **Nova-LeadQA: Receive Task & Plan Performance Test Cycle**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Identify Target Component/Scenario and Build/Version.
        *   Log main `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "Performance Test: [Component/Scenario] - [Date]". Let this be `[PerfTestProgressID]`.
        *   Create internal plan in `CustomData LeadPhaseExecutionPlan:[PerfTestProgressID]_QAPlan` (key) using `use_mcp_tool`. Plan items:
            1.  Verify Test Environment & Baseline Metrics (Delegate to TestExecutor).
            2.  Execute Performance Test Scenario A (Delegate to TestExecutor).
            3.  Analyze Results for Scenario A (LeadQA, with TestExecutor input).
            4.  (Repeat 2-3 for other scenarios if defined in plan).
            5.  Compile Performance Test Report & Log `PerformanceNotes` (Delegate report drafting to TestExecutor or ConPortSteward).
    *   **ConPort Action:**
        *   Retrieve `CustomData PerformanceTargets:[Component]_Targets_vX` (key) or relevant `AcceptanceCriteria` (key) using `use_mcp_tool` (`tool_name: 'get_custom_data'`).
        *   Retrieve `CustomData ProjectConfig:ActiveConfig` (key) for environment and tool command details.
        *   Log `Decision` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`) to start performance tests, noting scope, target KPIs, and tools. Link to `[PerfTestProgressID]`.
    *   **Output:** Plan ready. `[PerfTestProgressID]` known.

**Phase PT.2: Test Execution & Analysis by Nova-SpecializedTestExecutor (Sequentially Managed)**

2.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor: Environment Baseline & Test Execution**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "Establish baseline server metrics, execute performance test script [ScriptName] for [ScenarioName], and collect all results."
    *   **`new_task` message for Nova-SpecializedTestExecutor:**
        ```json
        {
          "Context_Path": "[ProjectName] (PerfTest_[Component/Scenario]) -> ExecuteScenario_[ScenarioName] (TestExecutor)",
          "Overall_QA_Phase_Goal": "Performance Test Cycle for [Component/Scenario].",
          "Specialist_Subtask_Goal": "Execute performance test for [ScenarioName] using [ScriptName_or_Tool].",
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[PerfTestProgressID]`.",
            "Performance Test Scenario: [ScenarioName_From_LeadQA]. Script/Tool: [ScriptName_From_LeadQA].",
            "Target Environment: [Perf_Env_URL_From_ProjectConfig]. Build: [Target_Build_From_LeadQA].",
            "1. Connect to performance test environment. Verify correct build is deployed and environment is stable.",
            "2. (If applicable and tools available) Capture baseline server metrics (CPU, memory, network I/O, DB connections) before test execution.",
            "3. Execute performance test script/tool using command: [`ProjectConfig:ActiveConfig.testing_preferences.performance_tools.[tool_name]_command [script_path] [load_parameters]` - LeadQA to provide specific command and parameters]. Use `execute_command`.",
            "4. Monitor server metrics during the test, if possible.",
            "5. Collect all raw output from the test tool (e.g., summary statistics table, transaction times per request, error rates, detailed logs/CSVs).",
            "6. Save raw results to `.nova/reports/qa/performance/[ScenarioName]_[Date]/[specific_file.csv_or_log]` using `write_to_file` if output is large or structured."
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[PerfTestProgressID_as_string]",
            "Scenario_Name_And_Script_Tool_Details": "[...]",
            "Performance_Test_Environment_Details_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig", "fields_needed": ["testing_preferences.performance_test_env", "testing_preferences.performance_tools"] },
            "Target_Build_Information": "[...]",
            "Performance_KPI_Targets_Ref_For_Context": { "type": "custom_data", "category": "PerformanceTargets", "key": "[Component]_Targets_vX" }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation of test execution.",
            "Path(s) to raw results/reports in `.nova/reports/qa/performance/` (if saved).",
            "Summary of key metrics observed directly from tool output (e.g., average response time, p95 latency, error rate, requests/sec)."
          ]
        }
        ```
    *   **Nova-LeadQA Action after Specialist's `attempt_completion`:** Review execution summary and raw data. If script execution failed, investigate with specialist. Update plan/progress.

3.  **Nova-LeadQA (can delegate detailed analysis to TestExecutor or Nova-FlowAsk if data is complex): Analyze Results against KPIs**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "Analyze raw performance test results for [ScenarioName] against defined KPIs from `PerformanceTargets:[Component]_Targets_vX` (key)."
    *   **Action:**
        *   Compare observed metrics (avg/p95/p99 response times, throughput, error rates, resource utilization) against defined targets.
        *   Identify any KPIs that were not met.
        *   Look for performance bottlenecks, trends (e.g., degradation over time in a soak test), or resource contention issues.
        *   Document findings clearly for this scenario.
    *   **Output:** Analysis summary for this scenario (pass/fail against KPIs, key observations, identified bottlenecks). Update `[PerfTestProgressID]_QAPlan`.

*(... Repeat steps 2 & 3 for other defined performance test scenarios in the plan ...)*

**Phase PT.3: Reporting & Closure**

4.  **Nova-LeadQA -> Delegate to Nova-SpecializedTestExecutor (or ConPortSteward via LeadArchitect): Compile Overall Performance Report & Log `PerformanceNotes`**
    *   **Actor:** Nova-LeadQA
    *   **Task:** "Compile an overall performance test report and log key findings or KPI misses as `PerformanceNotes` in ConPort."
    *   **`new_task` message (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (PerfTest_[Component/Scenario]) -> CompileReportAndLogNotes (TestExecutor/ConPortSteward)",
          // ... Overall Goal, Specialist Goal ...
          "Specialist_Specific_Instructions": [
            "Log your own `Progress` (integer `id`), parented to `[PerfTestProgressID]`.",
            "1. Consolidate analysis from all executed performance test scenarios (provided by LeadQA).",
            "2. Create a summary Markdown report in `.nova/reports/qa/performance/OverallPerformanceReport_[Component]_[Date].md` using `write_to_file`. Include:",
            "   - Test scope, environment details, tools used.",
            "   - For each scenario: Target KPIs vs. actual observed metrics, pass/fail status.",
            "   - Summary of identified bottlenecks, resource contention issues, or significant performance deviations.",
            "   - Graphs/charts if generated by tools and easily includable or linkable from the raw reports path.",
            "3. For each significant finding (e.g., a KPI miss, a major bottleneck, resource exhaustion): Log a `CustomData PerformanceNotes:[Component]_[FindingType]_[Date]` (key) entry in ConPort using `use_mcp_tool` (`tool_name: 'log_custom_data'`). The `value` (JSON object) should include fields like:",
            "   { ",
            "     \"component_scenario\": \"[Component/ScenarioName]\",",
            "     \"metric_observed\": \"e.g., P95 Response Time for /api/resource\",",
            "     \"target_kpi_value\": \"<200ms under 100 RPS\",",
            "     \"actual_value_observed\": \"550ms at 80 RPS\",",
            "     \"finding_description\": \"API /api/resource shows high latency and fails to meet throughput target.\",",
            "     \"potential_cause_hypothesis\": \"Possible DB query inefficiency or thread contention in service X.\",",
            "     \"raw_data_report_reference\": \".nova/reports/qa/performance/[ScenarioName]_[Date]/details.csv\"",
            "   }"
          ],
          "Required_Input_Context_For_Specialist": {
            "Parent_Progress_ID_String": "[PerfTestProgressID_as_string]",
            "List_Of_Executed_Scenarios_And_Analysis_Summaries_From_LeadQA": "[...]",
            "Performance_KPI_Targets_Ref_Key_For_Context": "PerformanceTargets:[Component]_Targets_vX"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Path to the overall performance report in `.nova/reports/qa/performance/`.",
            "List of ConPort keys for all created `PerformanceNotes` entries."
          ]
        }
        ```
    *   **Nova-LeadQA Action:** Review report and ConPort `PerformanceNotes` (key) entries.

5.  **Nova-LeadQA: Finalize Cycle & Report to Nova-Orchestrator**
    *   **Actor:** Nova-LeadQA
    *   **Action:**
        *   Update main `Progress` (`[PerfTestProgressID]`) to DONE (or DONE_WITH_PERFORMANCE_ISSUES_NOTED) using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description to summarize key outcomes.
        *   To update `active_context`, first `get_active_context` with `use_mcp_tool`, then construct a new value object with the modified `state_of_the_union`, and finally use `log_custom_data` with category `ActiveContext` and key `active_context` to overwrite.
    *   **`attempt_completion` to Nova-Orchestrator:** Report completion, summary of performance (pass/fail against KPIs), reference to full report and key `PerformanceNotes` (keys). If critical performance issues are identified that block a release or violate NFRs, highlight them as blockers.

**Key ConPort Items Involved:**
- Progress (integer `id`): Overall cycle, specialist subtasks.
- CustomData LeadPhaseExecutionPlan:[PerfTestProgressID]_QAPlan (key).
- Decisions (integer `id`) (e.g., to accept certain performance deviations if justified, or to prioritize optimization efforts).
- CustomData PerformanceTargets:[Component]_Targets_vX (key) (Read).
- CustomData PerformanceNotes:[key] (key) (multiple entries created for findings).
- ActiveContext (`state_of_the_union` update).
- Reads `ProjectConfig:ActiveConfig` (key) (for environment, tools).
- (Potentially) `ErrorLogs` (key) if performance tests lead to functional errors under load.