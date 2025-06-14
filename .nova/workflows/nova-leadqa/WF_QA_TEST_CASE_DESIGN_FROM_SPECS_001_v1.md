# Workflow: Test Case Design from Specifications (WF_QA_TEST_CASE_DESIGN_FROM_SPECS_001_v1)

**Goal:** To systematically derive and document test cases based on feature specifications, acceptance criteria, and system design documents.

**Primary Actor:** Nova-LeadQA
**Primary Specialist Actors:** Nova-SpecializedTestExecutor, (potentially Nova-FlowAsk).

**Trigger / Recognition:**

- `Nova-Orchestrator` tasks LeadQA to prepare for testing a new feature.
- Part of the larger `WF_QA_TEST_STRATEGY_AND_PLAN_CREATION_001_v1.md` workflow.
- A new `FeatureScope` or `AcceptanceCriteria` is finalized.

**Reference Milestones for your Single-Step Loop:**

**Milestone TCD.0: Pre-flight & Readiness Check**

- **Goal:** Verify that all required specifications are finalized and approved before designing tests.
- **Suggested Lead Action:**
  1.  Your first action MUST be a "Definition of Ready" check.
  2.  Use `use_mcp_tool` to retrieve all prerequisite specification items (`FeatureScope`, `AcceptanceCriteria`).
  3.  **Gated Check:**
      - **Failure:** If any required spec is missing or its `status` is not 'APPROVED'/'FINAL', immediately `attempt_completion` with a `BLOCKER:` status to `Nova-Orchestrator`. Do not proceed.
      - **Success:** If all specs are ready, proceed.

**Milestone TCD.1: Scenario Identification & Test Case Elaboration**

- **Goal:** Analyze specifications and create a comprehensive set of detailed test cases.
- **Suggested Lead Action & Specialist Sequence:**
  1.  **LeadQA Action:** Log a main `Progress` item for this test design task. Analyze the specs and decompose them into testable requirements and high-level test scenarios (e.g., "User Registration Scenarios", "Payment Processing Scenarios").
  2.  **Delegate to `Nova-SpecializedTestExecutor` (can be looped for multiple scenarios):**
      - **Subtask Goal:** "For Test Scenario '[ScenarioName]', elaborate detailed test cases."
      - **Briefing Details:**
        - Provide the scenario objective and references to the relevant ConPort specifications.
        - Instruct the specialist to design detailed test cases, each including: Test Case ID, Title, Pre-conditions, Step-by-step instructions, Test Data, and Expected Results.
        - They should consider positive paths, negative paths, and boundary conditions.
        - The specialist should return a structured list or document of the detailed test cases for the assigned scenario.

**Milestone TCD.2: Review & Consolidation**

- **Goal:** Review all drafted test cases for quality and log the final test plan to ConPort.
- **Suggested Lead Action & Specialist Sequence:**
  1.  **LeadQA Action:** Collect and review all drafted test cases from the specialist(s). Check for completeness, correctness, clarity, and coverage against the original specs. Consolidate into a final set.
  2.  **Delegate to `Nova-SpecializedConPortSteward` (via LeadArchitect) or self-action:**
      - **Subtask Goal:** "Log the consolidated test cases as a new `TestPlans` item in ConPort."
      - **Briefing Details:** Provide the consolidated test cases. Instruct to use `log_custom_data` to create a `CustomData TestPlans:[ScopeName]_TestPlan_vX.Y` entry. The `value` should be a structured object containing the test plan details. Also, instruct to link this new `TestPlans` item to the relevant `FeatureScope`.
  3.  **LeadQA Action:** Finalize the cycle by updating the main `Progress` item to 'DONE' and reporting completion to `Nova-Orchestrator`, providing the key of the new `TestPlans` entry.

**Key ConPort Items Involved:**

- Progress (integer `id`)
- CustomData TestPlans:[Key] (key)
- Reads `FeatureScope`, `AcceptanceCriteria`, `SystemArchitecture`.
