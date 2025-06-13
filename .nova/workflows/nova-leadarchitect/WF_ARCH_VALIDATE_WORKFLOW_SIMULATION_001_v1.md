# Workflow: Workflow Validation Simulation (WF_ARCH_VALIDATE_WORKFLOW_SIMULATION_001_v1)

**Goal:** To validate the logical flow of a Nova workflow `.md` file by using a `Test-Harness-Orchestrator` to simulate its execution with pre-scripted mock results, thereby catching logical errors or inconsistencies without engaging real Lead modes.

**Primary Actor:** Nova-LeadArchitect (initiates this to test a new or complex workflow)
**Delegated Specialist Actor:** Nova-SpecializedWorkflowManager (to prepare mock data if needed)
**Delegated Test Harness Actor:** Nova-TestHarnessOrchestrator

**Trigger / Recognition:**
- A new, complex workflow has been created (e.g., `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md`).
- An existing workflow is being significantly modified.
- Nova-LeadArchitect wants to ensure the logical flow, conditional branching, and delegation steps of a workflow are sound before deploying it for live use.

**Pre-requisites by Nova-LeadArchitect:**
- The workflow `.md` file to be tested exists at a known path.
- A conceptual understanding of the expected sequence of `new_task` delegations and the mock `attempt_completion` results needed to drive the workflow through its various paths (success, failure, etc.).

**Phases & Steps (managed by Nova-LeadArchitect):**

**Phase VS.1: Test Setup**

1.  **Nova-LeadArchitect: Plan Simulation**
    *   **Action:**
        *   Log a main `Progress` (integer `id`) item: "Workflow Simulation for: [WorkflowFileName]" using `use_mcp_tool`.
        *   Identify the workflow file to be tested (e.g., `.nova/workflows/nova-orchestrator/WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`).
        *   Design the test case. This involves defining a sequence of mock `attempt_completion` results that the `Test-Harness-Orchestrator` will provide in response to the `new_task` calls it "receives" from the workflow logic it's simulating.
        *   Delegate the creation of this mock data file to Nova-SpecializedWorkflowManager.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedWorkflowManager: Create Mock Results File**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Create a JSON file containing a sequence of mock `attempt_completion` results for the simulation."
    *   **`new_task` message for Nova-SpecializedWorkflowManager:**
        ```json
        {
          "Context_Path": "[ProjectName] (WorkflowSim) -> CreateMockData (WorkflowManager)",
          "Overall_Architect_Phase_Goal": "Simulate and validate workflow [WorkflowFileName].",
          "Specialist_Subtask_Goal": "Create a JSON file with mock `attempt_completion` results.",
          "Specialist_Specific_Instructions": [
            "Create a new file at `.nova/reports/simulations/[WorkflowFileName]_mock_results.json` using `write_to_file`.",
            "The file content must be a JSON array of objects.",
            "Each object represents a mock `attempt_completion` result to be returned sequentially by the Test-Harness-Orchestrator.",
            "The structure of each object should be: `{\"expected_delegated_mode\": \"nova-leadarchitect\", \"mock_result\": \"Phase X completed successfully. Key deliverables: ...\"}`.",
            "Use the mock data sequence provided by LeadArchitect."
          ],
          "Required_Input_Context_For_Specialist": {
            "Target_File_Path": ".nova/reports/simulations/[WorkflowFileName]_mock_results.json",
            "Mock_Data_Sequence_JSON": "[... Full JSON content from LeadArchitect ...]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "Confirmation that the mock results JSON file was created.",
            "The full path to the created file."
          ]
        }
        ```

**Phase VS.2: Simulation Execution**

3.  **Nova-LeadArchitect -> Delegate to Nova-TestHarnessOrchestrator: Run Simulation**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Execute a simulated run of the workflow `[WorkflowFilePath]` using the mock results from `[MockResultsFilePath]`."
    *   **`new_task` message for Nova-TestHarnessOrchestrator:**
        ```json
        {
          "Context_Path": "[ProjectName] (WorkflowSim) -> RunSimulation (TestHarnessOrchestrator)",
          "Overall_Architect_Phase_Goal": "Simulate and validate workflow [WorkflowFileName].",
          "Specialist_Subtask_Goal": "Simulate the execution of `[WorkflowFilePath]` by providing mock results.",
          "Mode_Specific_Instructions": [
            "This is a dry run. Do not execute any real `new_task` delegations.",
            "1. Read the workflow content from the `Workflow_File_To_Simulate` path.",
            "2. Read the mock results from the `Mock_Results_File_Path`.",
            "3. Begin executing the workflow's logic step-by-step from Phase 1.",
            "4. Whenever the workflow logic indicates a `new_task` delegation to a Lead mode:",
            "   a. Instead of calling the tool, print to your output: 'SIMULATING: `new_task` to [mode]. Phase Goal: [goal]'.",
            "   b. Take the next mock result from your loaded mock results file.",
            "   c. Print to your output: 'SIMULATING: Received mock `attempt_completion` from [mode]: [mock_result]'.",
            "   d. Continue to the next step in the workflow logic using this mock result as the input.",
            "5. Continue until the workflow reaches an end state or you run out of mock results.",
            "6. Your final `attempt_completion` should contain the full, ordered transcript of your simulation steps."
          ],
          "Required_Input_Context_For_Specialist": {
            "Workflow_File_To_Simulate": "[.nova/workflows/.../workflow.md]",
            "Mock_Results_File_Path": "[.nova/reports/simulations/.../mock_results.json]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "A full, ordered transcript of the simulation, showing each delegated task and the mock result provided."
          ]
        }
        ```

**Phase VS.3: Analysis & Closure**

4.  **Nova-LeadArchitect: Analyze Simulation Transcript**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Review the transcript from the Test Harness.
        *   Check if the sequence of delegations was as expected.
        *   Verify that conditional logic in the workflow (e.g., DoR checks, failure paths) behaved correctly based on the mock data.
        *   Identify any logical flaws, dead-ends, or incorrect delegation targets in the workflow file.
    *   **If flaws are found:** Initiate a new subtask to `Nova-SpecializedWorkflowManager` to `apply_diff` fixes to the workflow `.md` file.
    *   **If successful:** Update the `Progress` item for the simulation to 'DONE'.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- (Writes to file system, not ConPort)
- (Reads workflow `.md` files)

