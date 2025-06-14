# Workflow: Workflow Validation Simulation (WF_ARCH_VALIDATE_WORKFLOW_SIMULATION_001_v1)

**Goal:** To validate the logical flow of a Nova workflow `.md` file by using a `Test-Harness-Orchestrator` to simulate its execution with pre-scripted mock results.

**Primary Actor:** Nova-LeadArchitect
**Delegated Specialist Actor:** Nova-SpecializedWorkflowManager
**Delegated Test Harness Actor:** Nova-TestHarnessOrchestrator

**Trigger / Recognition:**
- A new, complex workflow has been created or an existing one is significantly modified.
- LeadArchitect wants to ensure the logical flow and conditional branching are sound before live deployment.

**Reference Milestones for your Single-Step Loop:**

**Milestone VS.1: Test Setup**
*   **Goal:** Create a mock results file that will drive the simulation.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **LeadArchitect Action:** Log a main `Progress` item for the simulation. Design the test case by defining a sequence of mock `attempt_completion` results.
    2.  **Delegate to `Nova-SpecializedWorkflowManager`:**
        *   **Subtask Goal:** "Create a JSON file containing the sequence of mock `attempt_completion` results."
        *   **Briefing Details:**
            *   Provide the target file path, e.g., `.nova/reports/simulations/[WorkflowFileName]_mock_results.json`.
            *   Provide the full JSON content for the mock data sequence.
            *   The specialist should use `write_to_file` to create this file and return the path.

**Milestone VS.2: Simulation Execution**
*   **DoR Check:** The workflow file to be tested and the mock results file both exist.
*   **Goal:** Run the simulation using the `Test-Harness-Orchestrator`.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-TestHarnessOrchestrator`:**
        *   **Subtask Goal:** "Execute a simulated run of the workflow `[WorkflowFilePath]` using the mock results from `[MockResultsFilePath]`."
        *   **Briefing Details:**
            *   Instruct the harness to read both the workflow and mock results files.
            *   It should step through the workflow's logic.
            *   When it encounters a `new_task` step, it must *not* execute it, but instead log the simulated delegation and consume the next mock result from the input file.
            *   The final `attempt_completion` from the harness must contain the full, ordered transcript of the simulation.

**Milestone VS.3: Analysis & Closure**
*   **Goal:** Analyze the simulation results and finalize the process.
*   **Suggested Lead Action:**
    1.  **Analyze Transcript:** Review the transcript from the Test Harness to check if the sequence of delegations and conditional logic behaved as expected.
    2.  **Fix Flaws (if any):** If logical flaws are found, delegate a new task to `Nova-SpecializedWorkflowManager` to `apply_diff` fixes to the original workflow `.md` file.
    3.  **Update Progress:** Update the main `Progress` item for the simulation to 'DONE'.
    4.  **Report Completion:** Report the outcome to `Nova-Orchestrator`.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Reads workflow `.md` files.