# Nova System - Improvement TODO List (v3)
# Nova System - Improvement TODO List (v3)

This document outlines the next generation of strategic improvements for the Nova system. The core focus of v3 is to enhance agent reliability and system robustness by enforcing **task granularity**, improving **dynamic planning**, and increasing **traceability and testability**.

## 1. Core Agent & Workflow Logic: Enforcing Granularity

**Rationale:** Large, multi-step briefings for specialists increase the risk of errors and unpredictable behavior. The v3 goal is to shift Lead agents from "big upfront planning" to a more reliable, iterative "just-in-time" execution model.

- [ ] **1.1. Refactor Lead Mode Execution Protocol to a "Single-Step-Loop":**
    - **Action Item:** This is a core behavioral change. Refactor the `task_execution_protocol` in all Lead Mode prompts (`LeadArchitect`, `LeadDeveloper`, `LeadQA`) to follow a strict, iterative, one-step-at-a-time loop.
    - **New Protocol Logic:**
        1.  Upon receiving a phase-task, the Lead creates a **high-level, coarse-grained** `LeadPhaseExecutionPlan` with only 2-4 major milestones (e.g., "1. Design API", "2. Implement Logic", "3. Write Tests"). This is a quick and simple initial step.
        2.  The Lead then enters a core execution loop. In each iteration of the loop, the Lead MUST:
            a. **Focus only on the current milestone.**
            b. **Determine the *single, next, most logical, atomic* specialist sub-task** required to make progress. (e.g., "The very next action is for the SystemDesigner to define just the GET endpoint").
            c. **Delegate ONLY this single, atomic sub-task** to the appropriate specialist.
            d. Await `attempt_completion`, process the result, and update ConPort `Progress`.
            e. **Return to step (b)** to determine the next single atomic step.
    - **Benefit:** This forces the Lead to have a very small "cognitive window", dramatically reducing the chance of creating overly complex or bundled tasks. It makes the agent's behavior more predictable and robust.

- [ ] **1.2. Workflow Validation Suite:**
    - **Action Item 1.2.1:** Design a new `Test-Harness-Orchestrator` mode prompt. This mode is a "dummy" orchestrator whose only purpose is to execute a workflow `.md` file by providing pre-scripted `attempt_completion` results instead of calling real Lead modes, allowing for a "dry run" of the workflow's logic.
    - **Action Item 1.2.2:** Create the corresponding `WF_ARCH_VALIDATE_WORKFLOW_SIMULATION_001_v1.md`. This workflow will guide `LeadArchitect` in setting up and instructing the `Test-Harness-Orchestrator` to run a specific workflow file against a set of mock results.

## 2. ConPort & Knowledge Management: Deeper Integration

**Rationale:** The knowledge in ConPort can be more actively used and maintained. We will add capabilities for schema evolution and more intelligent analysis.

- [ ] **2.1. ConPort Schema Migration Workflow:**
    - **Action Item:** Create a new workflow file: `WF_ARCH_CONPORT_SCHEMA_MIGRATION_001_v1.md`.
    - **Details:** This workflow guides `LeadArchitect` to delegate a migration task to `ConPortSteward`. The `ConPortSteward`'s instructions will be to:
        1. Retrieve all items from a specified `CustomData` category.
        2. Loop through each item, apply a specified transformation logic (provided in the briefing) to its `value` object to match the new schema.
        3. Use the `batch_log_items` ConPort tool to efficiently write all the updated items back to ConPort.

- [ ] **2.2. Analytical Graph Query Workflow:**
    - **Action Item 2.2.1:** Create a new workflow file: `WF_ORCH_ANALYTICAL_GRAPH_QUERY_001_v1.md`. This workflow will guide the Orchestrator in delegating a complex, multi-step query to `Nova-FlowAsk`.
    - **Action Item 2.2.2:** Enhance the `Nova-FlowAsk` prompt. Add an explicit capability statement: "I can execute a sequence of `use_mcp_tool` calls as defined in my `Subtask Briefing Object`. This allows me to perform multi-hop analysis of the ConPort knowledge graph by using the results of one query as input for the next."

- [ ] **2.3. Proactive ConPort Linking Suggestion Protocol:**
    - **Action Item:** Add a new mandatory section to the `attempt_completion` instructions in all **Specialist** prompts.
    - **Example Wording:** "In your `attempt_completion` `result` field, you MUST include a section named `Suggested_ConPort_Links`. Here, you will list potential links between the ConPort item(s) you created and other relevant items. For example: `{ source_item: 'CodeSnippets:MyNewFunction', target_item: 'APIEndpoints:TheApiItImplements', relationship: 'implements' }`. Your Lead will be responsible for reviewing and actioning these suggestions."

## 3. System Traceability & Debugging

**Rationale:** The biggest weakness of the current system is the "black box" nature of agent reasoning. Making this explicit is the highest priority for improving maintainability.

- [ ] **3.1. Auditable Rationale Protocol:**
    - **Action Item:** Systematically update **all** agent prompts (Orchestrator, Leads, Specialists) with a new, mandatory rule in their `tool_use_protocol`.
    - **Example Wording:** "**Mandatory Rationale:** Before *every* tool call, your `<thinking>` block MUST contain a markdown-formatted section `## Rationale`. This section must concisely explain: 1. **Goal:** What you are trying to achieve with this tool call. 2. **Justification:** *Why* you chose this specific tool and its parameters, explicitly referencing the user's request, your briefing from a superior, or the result of a previous tool call. 3. **Expectation:** What you expect the outcome of the tool call to be."
    - **Benefit:** This creates a structured, self-documented "flight recorder" log of the agent's reasoning for every single action it takes, which is invaluable for debugging and analysis.

# Nova System - Improvement TODO List (v4)

This document outlines the next evolutionary steps for the Nova system, focusing on enhancing agent intelligence, process efficiency, and user experience.

## 1. Agent Intelligence & Autonomy
- [ ] **1.1. Implement Self-Improvement Cycle:**
    - **Action Item:** Create `WF_ARCH_LEARNING_CYCLE_001_v1.md`.
    - **Description:** This workflow will guide the `LeadArchitect` to periodically use `Nova-FlowAsk` to analyze patterns in `LessonsLearned` and recurring `ErrorLogs`. Based on this analysis, the `LeadArchitect` will be prompted to initiate a `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1.md` to fix the root cause of systemic issues directly in the prompts of the relevant agents, creating a closed-loop learning mechanism.

- [ ] **1.2. Enable Specialist-Proposed Alternatives:**
    - **Action Item 1:** Update all Specialist prompts to include a new protocol. If a briefed task is deemed impossible or highly inefficient, the specialist can return an `attempt_completion` with a `Proposed_Alternative` section, detailing a better approach.
    - **Action Item 2:** Update all Lead prompts to recognize and handle the `Proposed_Alternative` field. The Lead must then log a `Decision` to either `APPROVE` or `REJECT` the specialist's suggestion before delegating the next sub-task (either the original one or the newly approved alternative).

## 2. Workflow & Process Optimization
- [ ] **2.1. Introduce Configurable Quality Gates:**
    - **Action Item 1:** Add a `quality_gate_level: 'strict' | 'moderate' | 'lean'` setting to the `ProjectConfig:ActiveConfig` schema in `conport_standards.md`.
    - **Action Item 2:** Update `LeadDeveloper` and `LeadQA` prompts. They must now read this setting from `ProjectConfig` at the start of their phase and adjust their team's "Definition of Done" checks accordingly. For example, a `lean` gate might relax test coverage requirements, while `strict` would enforce them rigidly.

- [ ] **2.2. Implement Workflow Parameterization:**
    - **Action Item 1:** Refactor key `nova-orchestrator` and `nova-leadarchitect` workflows to replace hardcoded names with `{{placeholder}}` variables (e.g., `{{FEATURE_NAME}}`, `{{TARGET_RELEASE_VERSION}}`).
    - **Action Item 2:** Update the `new_task` briefing format for `Nova-Orchestrator` to include an optional `parameters` dictionary. The Orchestrator will be responsible for populating this dictionary to fill in the placeholders when initiating a parameterized workflow.

## 3. ConPort & Data Strategy
- [ ] **3.1. Automated ConPort Compaction Workflow:**
    - **Action Item:** Create `WF_ORCH_CONPORT_COMPACTION_001_v1.md`.
    - **Description:** This workflow orchestrates a scheduled task. First, it delegates to `Nova-FlowAsk` to read all `Progress` items with status `DONE` older than a configured threshold (e.g., 90 days). `FlowAsk` generates a Markdown summary of these items. `LeadArchitect`'s `ConPortSteward` then logs this summary to a new `CustomData ArchivedProgressSummary:[DateRange]` item. Upon user confirmation, a final task is delegated to delete the original, now-summarized, `Progress` items, keeping the active database clean and efficient.

## 4. Developer/User Experience (DX/UX)
- [ ] **4.1. Implement User Command Alias System:**
    - **Action Item 1:** Define the schema for `CustomData UserCommands:Aliases` in ConPort. This will be a simple JSON object mapping short, user-defined strings to full workflow file paths (e.g., `{"run digest": ".nova/workflows/nova-orchestrator/WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1.md"}`).
    - **Action Item 2:** Update the `Nova-Orchestrator`'s initial prompt logic (`task_execution_protocol`, step 2). Before proceeding with normal analysis, the Orchestrator must first check if the user's input exactly matches a key in the `UserCommands:Aliases` map. If it does, it will immediately initiate the corresponding workflow.

- [ ] **4.2. Implement Self-Explanation Capability:**
    - **Action Item:** Create `WF_ORCH_EXPLAIN_ACTION_001_v1.md`.
    - **Description:** This workflow is triggered when a user asks "Why did [action X] happen?". It guides the `Orchestrator` to use `Nova-FlowAsk` to find the relevant `Progress` item for the action. `FlowAsk` will then use `get_linked_items` to trace this `Progress` item back to a motivating `Decision` item and present the `rationale` from that `Decision` to the user as the explanation.
