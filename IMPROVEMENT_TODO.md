# Nova System - Improvement TODO List

## Completed in v0.3.x
**Rationale:** These tasks were identified during a deep-dive review of the v3.0 implementation. They harden agent interactions, make implicit protocols explicit, and optimize data flow to maximize system reliability and prevent common failure modes.

- [x] **3.1.1. Harden Delegation Flow Protocol:**
    - **Action Item:** Adjust the `task_execution_protocol` in all delegating agent prompts (Orchestrator, Leads). Add a "CRITICAL DELEGATION FLOW" instruction that explicitly states that after calling `new_task`, the agent's execution will pause and the sub-agent's `attempt_completion` result will be returned as the `tool_output` for the `new_task` call.
    - **Benefit:** Prevents agent confusion and stalled loops where the agent would incorrectly state it was still waiting for a separate signal.

- [x] **3.1.2. Mitigate Context Overload from ConPort:**
    - **Action Item:** Harden the `get_custom_data` tool definition in all relevant prompts. Add a strong warning forbidding calls without at least a `category` argument. Instruct agents to use `search_custom_data_value_fts` with a `limit` for discovery.
    - **Benefit:** Prevents accidental context window overloads from broad queries, a major source of instability.

- [x] **3.1.3. Optimize Bulk File Operation Protocols:**
    - **Action Item:** Harden the usage protocols for `read_file` and `apply_diff` across all system prompts. Instruct agents to follow an "Intelligent Batching and Verification" strategy (read/apply in small batches, with a `read_file` verification step after each `apply_diff` batch).
    - **Benefit:** Creates a robust, self-correcting loop for multi-file edits, significantly improving reliability.

- [x] **3.1.4. Harden ConPort Tool Specificity:**
    - **Action Item:** Refactor the `conport_tool_reference` section in all relevant prompts to add explicit warnings to each `get_` tool, clarifying which entity type it is for (e.g., "Use `get_decisions` ONLY for 'Decision' items, not for `CustomData`").
    - **Benefit:** Reduces the likelihood of agents using the wrong tool for a given ConPort entity type, a common source of errors.

- [x] **3.1.5. Update `Nova-SpecializedConPortSteward` Prompt:**
    - **Action Item:** Add the missing tool definitions for `get_product_context`, `update_product_context`, `get_active_context`, and `update_active_context` to the steward's prompt.
    - **Benefit:** Restores the agent's ability to perform its core duties as required by key bootstrap and session management workflows.

- [x] **3.2. Update Lead Mode Prompts for Link Processing:**
    - **Action Item:** Adjust the `task_execution_protocol` (specifically the 'Process Result' step) in all three Lead Mode prompts (`-LeadArchitect`, `-LeadDeveloper`, `-LeadQA`). Add an explicit instruction to process the `Suggested_ConPort_Links` section from a specialist's `attempt_completion`.

- [x] **3.3. Align Orchestrator Workflows with Single-Step Loop Logic:**
    - **Action Item:** Conduct a review of the `new_task` `message` blocks within the main `WF_ORCH_*` workflow files. Ensure the `Lead_Mode_Specific_Instructions` direct the Lead towards their *Phase_Goal* and encourage them to follow their new iterative "Single-Step Loop" protocol.

- [x] **3.4. Finalize Documentation for v3 Release:**
    - **Action Item 3.4.1:** Update the `README.md` to clearly explain the new v3 concepts, particularly the "Single-Step Loop" for Leads and the "Auditable Rationale Protocol" for all agents.
    - **Action Item 3.4.2:** Update the `CHANGELOG.md` with a detailed description of the v3.0.0-beta release, highlighting all major architectural changes.

---

## Future Roadmap (v4 and Beyond)

This document outlines the next evolutionary steps for the Nova system, focusing on enhancing agent intelligence, process efficiency, and user experience.

### 1. Agent Intelligence & Autonomy
- [ ] **1.1. Implement Self-Improvement Cycle:**
    - **Description:** Create a new workflow, `WF_ARCH_LEARNING_CYCLE_001_v1.md`, that guides `LeadArchitect` to periodically use `Nova-FlowAsk` to analyze patterns in `LessonsLearned` and recurring `ErrorLogs`. Based on the analysis, `LeadArchitect` will initiate a `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL` to fix the root cause of systemic issues directly in the prompts of the relevant agents, creating a closed-loop learning mechanism.

- [ ] **1.2. Enable Specialist-Proposed Alternatives:**
    - **Description:** Update all Specialist prompts to include a new protocol allowing them to return an `attempt_completion` with a `Proposed_Alternative` section if a briefed task is deemed impossible or highly inefficient. Update Lead prompts to recognize and formally `APPROVE` or `REJECT` these proposals via a ConPort `Decision` before proceeding.

### 2. Workflow & Process Optimization
- [ ] **2.1. Introduce Configurable Quality Gates:**
    - **Description:** Add a `quality_gate_level: 'strict' | 'moderate' | 'lean'` setting to the `ProjectConfig:ActiveConfig` schema. Update `LeadDeveloper` and `LeadQA` prompts to read this setting and adjust their team's "Definition of Done" checks accordingly, allowing for more flexible project governance.

- [ ] **2.2. Implement Workflow Parameterization:**
    - **Description:** Refactor key orchestrator and architect workflows to replace hardcoded values with `{{placeholder}}` variables. Update the `new_task` briefing format for `Nova-Orchestrator` to include an optional `parameters` dictionary to dynamically populate these placeholders, making workflows more reusable.

### 3. ConPort & Data Strategy
- [ ] **3.1. Automated ConPort Compaction Workflow:**
    - **Description:** Create `WF_ORCH_CONPORT_COMPACTION_001_v1.md` to orchestrate a scheduled task. The workflow will use `Nova-FlowAsk` to find old, completed `Progress` items, summarize them into a new `ArchivedProgressSummary` item, and upon user confirmation, delete the original items to keep the active database lean.

### 4. Developer/User Experience (DX/UX)
- [ ] **4.1. Implement User Command Alias System:**
    - **Description:** Define a `CustomData UserCommands:Aliases` schema in ConPort to map short, user-defined strings to full workflow file paths. Update `Nova-Orchestrator`'s initial logic to check if user input matches an alias and, if so, immediately initiate the corresponding workflow.

- [ ] **4.2. Implement Self-Explanation Capability:**
    - **Description:** Create `WF_ORCH_EXPLAIN_ACTION_001_v1.md` to handle user questions like "Why did you do X?". This workflow will guide the `Orchestrator` to use `Nova-FlowAsk` to trace a `Progress` item back to its motivating `Decision` via `get_linked_items` and present the `rationale` to the user as the explanation.