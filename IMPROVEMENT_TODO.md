# Nova System - Improvement TODO List (v2)

This document outlines the next generation of strategic improvements for the Nova system, building upon the previous refactoring. The focus of this iteration is on **eliminating ambiguity**, **hardening tool and workflow interactions**, and enhancing the system's **intelligence and maintainability**.

## 1. Core: Prompt & Tooling Hygiene (Highest Priority)

These items directly address observed inconsistencies and potential sources of error for the LLM agents, ensuring maximum precision and reliability.

- [X] **1.4. Standardize `log_progress` and `update_progress` Examples**
    *   **Rationale:** Many prompts use vague placeholders like `arguments: {'workspace_id': '{{workspace}}', ...}` for `log_progress` and `update_progress`. This is ambiguous and does not sufficiently guide the LLM on which other parameters (like `description`, `status`, `parent_id`) are expected, leading to inconsistent or incomplete progress logging.
    *   **Action Item:** Systematically review all `system-prompt-nova-*.md` files. For every instance where `log_progress` or `update_progress` is mentioned in an example or instruction, replace vague argument placeholders like `...` with a complete, illustrative JSON object. The example should include typical parameters like `description` and `status`, and optionally `parent_id` for specialist prompts, to provide a clear, syntactically correct template for the LLM. For example: `{\"workspace_id\": \"{{workspace}}\", \"description\": \"Subtask: [Goal] (Assigned: [mode])\", \"status\": \"IN_PROGRESS\", \"parent_id\": \"[Parent_Progress_ID_as_string]\"}`.

- [X] **1.5. Standardize All `use_mcp_tool` Examples Across All Prompts**
    *   **Rationale:** Building on 1.4, many other `use_mcp_tool` examples for various ConPort tools (`log_decision`, `log_custom_data`, `link_conport_items`, etc.) also use ambiguous placeholders. This leads to the LLM potentially omitting required fields or misformatting the `arguments` JSON, causing tool failures.
    *   **Action Item:** Systematically review all `system-prompt-nova-*.md` files. For every example of a `use_mcp_tool` call, ensure the `arguments` field contains a complete, illustrative, and syntactically correct JSON object based on the strict Pydantic model definitions for that specific ConPort tool. A new `conport_tool_reference` section has been added to all prompts for this purpose.

- [ ] **1.6. Standardize `Subtask Briefing Object` Examples in Workflows**
    *   **Rationale:** While the system prompts are now standardized, the workflow files (`.nova/workflows/**/*.md`) contain many examples of `Subtask Briefing Object`s within `new_task` delegations. These examples may still contain outdated or vague instructions for ConPort interactions.
    *   **Action Item:** Systematically review all `WF_*.md` files in the `.nova/workflows/` subdirectories. For every `new_task` message example, ensure that the `Specialist_Specific_Instructions` for any ConPort operation align with the newly standardized `use_mcp_tool` calls. Replace vague instructions like "Log this to ConPort" with explicit instructions like "Log this as `CustomData SystemArchitecture:[key]` using `use_mcp_tool` with `tool_name: 'log_custom_data'` and a complete `arguments` object...".

## 2. Advanced Workflow & Process Logic

These improvements focus on increasing the robustness and intelligence of the core system workflows.

- [X] **2.1. Introduce Proactive "Pre-flight Checks" in Critical Workflows**
    *   **Rationale:** The current "Failure Scenarios" are reactive. A proactive check before beginning a complex phase can prevent entire classes of errors, saving time and computation.
    *   **Action Item:** Add a new section `## Pre-flight Checks` to the beginning of critical workflows (e.g., `WF_ORCH_RELEASE_PREPARATION...`, `WF_DEV_FEATURE_IMPLEMENTATION...`). This section must instruct the Lead Mode to perform verifications *before* delegating the first sub-task. Checks should include:
        *   Using `use_mcp_tool` (`get_custom_data`, etc.) to verify that all prerequisite ConPort items (e.g., `ProjectConfig:ActiveConfig`, `AcceptanceCriteria:[key]`) exist.
        *   Checking that prerequisite items have the correct status (e.g., the `SystemArchitecture` design is 'APPROVED', not 'DRAFT').
        *   If a check fails, the workflow must instruct the Lead to report a specific, actionable blocker to the Orchestrator.
- [ ] **2.2. Implement Retry Logic in Lead Mode Prompts**
    *   **Rationale:** Delegation failures due to transient issues (e.g., temporary network errors) are inefficient. Building simple retry logic into the Lead modes' behavior increases system resilience without requiring system-level changes.
    *   **Action Item:** Update the `task_execution_protocol` in the prompts for all Lead Modes (`Nova-LeadArchitect`, `Nova-LeadDeveloper`, `Nova-LeadQA`). Add a rule stating: "If a delegated specialist sub-task fails with an error you assess as potentially transient (e.g., a network timeout, temporary API unavailability), you are authorized to retry the delegation ONE time after a short delay. If the task fails a second time, treat it as a permanent failure, ensure an `ErrorLog` is created, and escalate the issue as per standard failure recovery procedures."

- [ ] **2.3. Formalize "Definition of Ready" (DoR) Checks**
    *   **Rationale:** "Definition of Ready" is a key agile principle that is currently only implicitly assumed. Formalizing it will prevent phases from starting with incomplete prerequisites, improving quality and reducing rework.
    *   **Action Item:** Modify the primary orchestration workflows (`WF_ORCH_NEW_PROJECT...`, `WF_ORCH_EXISTING_PROJECT...`). Before delegating a major phase (like 'Development' or 'QA'), the `Nova-Orchestrator` must now perform an explicit DoR check. This involves retrieving the `CustomData ProjectStandards:DefaultDoR` item and verifying that each criterion is met by checking other ConPort items. If the DoR fails, the Orchestrator must delegate a preparatory task (typically to `Nova-LeadArchitect`) to fulfill the missing criteria.

## 3. Enhanced AI Agent Intelligence & Autonomy

Making the agents smarter and more efficient within their strictly defined roles.

- [ ] **3.1. Bounded Autonomy for Trivial Fixes by Specialists**
    *   **Rationale:** A specialist finding a trivial, directly related error (e.g., a typo in a comment, an obvious off-by-one error in code they just wrote) and having to fail their entire sub-task is inefficient. Granting bounded autonomy for such minor fixes streamlines the process.
    *   **Action Item:** Add a specific rule to the prompts of `Nova-SpecializedFeatureImplementer` and `Nova-SpecializedCodeRefactorer`: "If you find a trivial, directly related, and demonstrably correctable issue *in the code you are currently working on*, you are authorized to fix it, log a `Decision` item in ConPort with the rationale for the fix, and report both the original task completion and the trivial fix in your `attempt_completion`."

- [ ] **3.2. Implement a System Self-Improvement Cycle**
    *   **Rationale:** The system should learn from its own operations. Currently, improvements are externally driven. A formal retrospective cycle will enable the system to identify and propose its own enhancements.
    *   **Action Item:** Create a new workflow: `WF_ORCH_SYSTEM_RETROSPECTIVE_AND_IMPROVEMENT_PROPOSAL_001_v1.md`. This workflow will guide the `Nova-Orchestrator` to:
        1.  Delegate a task to `Nova-FlowAsk` to analyze ConPort for patterns indicative of process friction (e.g., frequently failing workflows, sub-tasks with high retry counts, clusters of `ErrorLogs` in a specific domain).
        2.  Based on this analysis, delegate a follow-up task to `Nova-LeadArchitect` to perform a formal `ImpactAnalysis` and log a `Decision` item. This decision will contain a concrete proposal for a system improvement (e.g., a prompt modification, a workflow optimization) for the user to approve.

## 4. Developer Experience & System Visibility

Improving the human-computer interface and providing better insight into the system's state.

- [ ] **4.1. ConPort "Cheatsheet" Generation**
    *   **Rationale:** The growing number of ConPort categories and workflows can be difficult for a human user to track. An auto-generated "cheatsheet" would significantly improve usability and discoverability.
    *   **Action Item:** Create a new workflow: `WF_ARCH_GENERATE_CONPORT_CHEATSHEET_001_v1.md`. This workflow guides `Nova-LeadArchitect` to task its `ConPortSteward` to scan ConPort (using `get_conport_schema` and `get_custom_data` on the `DefinedWorkflows` category) and generate a Markdown file at `.nova/docs/conport_cheatsheet.md`. This file will summarize all active `CustomData` categories, their purpose, and a list of the most important workflows with their descriptions.

- [ ] **4.2. Knowledge Graph Visualization Workflow**
    *   **Rationale:** The value of the ConPort knowledge graph is primarily conceptual. A visual representation would make dependencies and relationships tangible, aiding in impact analysis and onboarding.
    *   **Action Item:** Create a new workflow: `WF_ARCH_GENERATE_KNOWLEDGE_GRAPH_VISUALIZATION_001_v1.md`. This workflow will:
        1.  Take a central ConPort item (e.g., a `FeatureScope` key) as input.
        2.  Instruct `ConPortSteward` to recursively use `get_linked_items` (1-2 levels deep) to fetch all related items.
        3.  Generate a Mermaid.js `graph TD` diagram syntax representing the fetched items and their `relationship_type` links.
        4.  Save the resulting diagram source to a `.md` file in `.nova/reports/graph_visuals/` for easy rendering.

- [ ] **4.3. New Developer Onboarding Workflow**
    *   **Rationale:** Onboarding a new human developer onto a complex, AI-managed project is a critical challenge. A dedicated workflow can automate the generation of a personalized briefing package.
    *   **Action Item:** Create a new workflow: `WF_ORCH_ONBOARD_NEW_DEVELOPER_001_v1.md`. This workflow instructs `Nova-FlowAsk` to generate a comprehensive onboarding guide by querying ConPort for:
        1.  The overall `SystemArchitecture` summary.
        2.  The full content of `ProjectConfig` and `NovaSystemConfig`.
        3.  The summaries of the 5 most recent, important `Decisions`.
        4.  A list of all current `IN_PROGRESS` tasks.
        5.  A list of the 3 most critical open `ErrorLogs`.
        The output is a single, consolidated Markdown file saved to `.nova/reports/onboarding/` that gives a new developer a complete snapshot of the project's technical state and current priorities.

- [ ] **4.4. Structured "Decision Support Briefings"**
    *   **Rationale:** Key strategic decisions are often presented to the user with a simple question. This can lack the necessary context for the user to make a well-informed choice quickly, slowing down the project.
    *   **Action Item:** Update the `ask_followup_question` usage instructions in all **Lead Mode** prompts. Add the following rule: "When a strategic choice must be made by the user, you MUST format your question as a 'Decision Support Briefing'. This includes a clear context, 2-3 distinct options, a summary of pros and cons for each, and your team's recommendation. This structured format helps the user make faster, better-informed decisions."

- [ ] **4.5. Implement ConPort Data Hygiene Workflow**
    *   **Rationale:** Over time, ConPort can accumulate outdated or irrelevant information (e.g., `Decisions` for a feature that was deprecated). This "noise" can reduce the effectiveness of semantic searches and make it harder for agents and users to find current, relevant information. This can be addressed with a process-based solution without requiring server-side changes.
    *   **Action Item:** Create a new workflow: `WF_ARCH_CONPORT_DATA_HYGIENE_REVIEW_001_v1.md`. This workflow will guide `Nova-LeadArchitect` to have its `ConPortSteward`:
        1.  Periodically scan for items that meet "staleness" criteria (e.g., `Decisions` or `SystemArchitecture` components not updated or linked to in over X months).
        2.  Log these items as `ArchivalCandidates` in a new `CustomData` category. The `key` of the new item will reference the original (e.g., 'Decision_123') and the `value` will contain the rationale.
        3.  Present this list of `ArchivalCandidates` to the user for a decision.
        4.  If the user approves, the `ConPortSteward` will then update the original item's summary/description with an `[ARCHIVED ON YYYY-MM-DD]` prefix, effectively removing it from most operational views without deleting the historical data.

---

## Completed Tasks

- **1.4. Standardize `log_progress` and `update_progress` Examples:** Completed. All system prompts have been updated with explicit, standardized JSON examples for these tools, clarifying the expected parameters like `description`, `status`, and `parent_id`.
- **1.5. Standardize All `use_mcp_tool` Examples Across All Prompts:** Completed. All system prompts now contain a `conport_tool_reference` section or updated examples in-line to provide clear, complete, and syntactically correct JSON templates for all relevant ConPort tool arguments.
- **2.1. Introduce Proactive "Pre-flight Checks" in Critical Workflows:** Completed. A new `Phase 0: Pre-flight Checks` section was added to all identified critical workflows to validate prerequisites before execution.