# Workflow: Performance Test Execution (WF_QA_PERFORMANCE_TEST_EXECUTION_001_v1)

**Goal:** To execute defined performance tests (e.g., load, stress, soak) against specific application components or end-to-end scenarios, analyze results, and log performance metrics and issues.

**Primary Actor:** Nova-LeadQA
**Primary Specialist Actor (delegated to by Nova-LeadQA):** Nova-SpecializedTestExecutor

**Trigger / Recognition:**

- `Nova-Orchestrator` delegates: "Execute performance tests for [Component/Scenario]".
- `AcceptanceCriteria` for a feature includes specific performance targets.
- A periodic performance health check is scheduled.

**Pre-requisites by Nova-LeadQA (from Nova-Orchestrator's briefing or ConPort):**

- Application build is deployed to a dedicated performance testing environment (`ProjectConfig`).
- Performance test scripts/tools are available and configured (`ProjectConfig`).
- Clear performance targets/KPIs are defined (e.g., in `AcceptanceCriteria` or `PerformanceTargets`).

**Reference Milestones for your Single-Step Loop:**

**Milestone PT.1: Test Execution**

- **Goal:** Execute the defined performance test script(s) and collect all raw results.
- **Suggested Specialist Sequence & Briefing Guidance:**
  1.  **LeadQA Action:** Log a main `Progress` item for this performance test cycle and a `Decision` to begin.
  2.  **Delegate to `Nova-SpecializedTestExecutor` (for each scenario):**
      - **Subtask Goal:** "Execute performance test for [ScenarioName] using [ScriptName]."
      - **Briefing Details:**
        - Provide the scenario, script, target environment URL, and build version.
        - Instruct to verify the environment and capture baseline server metrics if possible.
        - They must execute the performance test command from `ProjectConfig`.
        - They must collect all raw output (summary stats, transaction times, error rates) and save detailed reports to `.nova/reports/qa/performance/`.
        - Return a summary of key metrics and paths to raw results.

**Milestone PT.2: Results Analysis & Reporting**

- **Goal:** Analyze the results against KPIs and log any significant findings.
- **Suggested Lead Action & Specialist Sequence:**
  1.  **LeadQA Action: Analyze Results:**
      - For each completed scenario, compare the observed metrics (e.g., p95 latency, throughput, error rate) against the defined KPI targets from ConPort (`PerformanceTargets` or `AcceptanceCriteria`).
      - Identify any KPIs that were not met and any potential performance bottlenecks.
  2.  **Delegate to `Nova-SpecializedTestExecutor` (or ConPortSteward):**
      - **Subtask Goal:** "Compile an overall performance report and log key findings as `PerformanceNotes` in ConPort."
      - **Briefing Details:**
        - Provide the consolidated analysis from all scenarios.
        - Instruct to create a summary Markdown report.
        - For each significant finding (e.g., a KPI miss), instruct them to log a structured `CustomData PerformanceNotes:[Component]_[Finding]` item to ConPort, detailing the metric, target, actual value, and a link to the raw data.
        - The specialist should return the path/key of the report and a list of all `PerformanceNotes` keys created.

**Milestone PT.3: Finalize Cycle**

- **Goal:** Close out the performance test cycle and report the outcome.
- **Suggested Lead Action:**
  1.  Review the final report and `PerformanceNotes`.
  2.  Update the main `Progress` item to 'DONE' or 'DONE_WITH_ISSUES_NOTED'.
  3.  Update the `active_context.state_of_the_union`.
  4.  Use `attempt_completion` to report the summary, pass/fail status against KPIs, and references to the report and `PerformanceNotes` to `Nova-Orchestrator`. Highlight any critical performance blockers.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- CustomData (`PerformanceTargets`, `PerformanceNotes`, `TestExecutionReports`)
- Decisions (integer `id`)
- ErrorLogs (key) (if performance tests cause functional errors)
