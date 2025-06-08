# Nova System - Improvement TODO List (v2)

This document outlines the next generation of strategic improvements for the Nova system, building upon the previous refactoring. The focus of this iteration is on **eliminating ambiguity**, **hardening tool and workflow interactions**, and enhancing the system's **intelligence and maintainability**.

## 1. Core: Prompt & Tooling Hygiene (Highest Priority)

These items directly address observed inconsistencies and potential sources of error for the LLM agents, ensuring maximum precision and reliability.

-   [ ] **1.1. Audit & Align `use_mcp_tool` Parameters Across All Prompts**
    *   **Rationale:** There are minor but critical discrepancies between the formal `conport_mcp_deep_dive.md` documentation and the tool examples within the system prompts. This is a primary source of potential LLM error and must be eradicated for system stability.
    *   **Action Item:** Perform a systematic audit of **every `system-prompt-nova-*.md` file**. For each prompt, meticulously compare every example and instruction related to `use_mcp_tool` against the Pydantic models and tool definitions in `conport_mcp_deep_dive.md`. Correct **all** parameter names, JSON structures, and argument types to ensure 100% consistency with the formal specification.

-   [ ] **1.2. Eliminate All Placeholder Syntax (`...}`) in Examples**
    *   **Rationale:** A placeholder like `value: { ... }` is too ambiguous for an LLM. It can lead to incomplete, syntactically incorrect, or logically flawed output. The AI must always be shown a complete, syntactically correct example to guide its generation.
    *   **Action Item:** Systematically search all `system-prompt-*.md` files for incomplete examples. Replace every instance of placeholder syntax (e.g., `...`, `/* ... */`, `{ ... }`) within tool examples or `Subtask Briefing Object` illustrations with **fully-formed, albeit illustrative, JSON objects or code blocks**. For example, a briefing for logging an `APIEndpoint` must show a complete, small, but valid schema object, not a truncated version.

-   [ ] **1.3. Harden ConPort Item ID Usage Instructions in Prompts**
    *   **Rationale:** The `conport_mcp_deep_dive.md` documentation specifies that the `item_id` parameter is a string, but its required *content* format depends on the `item_type`. This is a subtle but critical point of potential failure for the LLM. The instructions must be made explicit and unambiguous to prevent these failures.
    *   **Action Item:** Add a new, prominent `CRITICAL USAGE NOTE` to the `use_mcp_tool` definition in **all** `system-prompt-*.md` files, placed directly under the parameter descriptions. This note must read:
        > **CRITICAL USAGE NOTE for `item_id`:** The format of the `item_id` string **depends entirely** on the `item_type`:
        > - If `item_type` is 'decision', 'progress_entry', or 'system_pattern', the `item_id` MUST be its **integer ID, passed as a string**. (e.g., `"123"`)
        > - If `item_type` is 'custom_data', the `item_id` MUST be its **string key**. (e.g., `"ProjectConfig:ActiveConfig"`)
        > - If `item_type` is 'product_context' or 'active_context', the `item_id` MUST be its name. (e.g., `"product_context"`)
        > Incorrectly formatted `item_id`s for the given `item_type` will cause tool failure.

## 2. Advanced Workflow & Process Logic

These improvements focus on increasing the robustness and intelligence of the core system workflows.

-   [ ] **2.1. Introduce Proactive "Pre-flight Checks" in Critical Workflows**
    *   **Rationale:** The current "Failure Scenarios" are reactive. A proactive check before beginning a complex phase can prevent entire classes of errors, saving time and computation.
    *   **Action Item:** Add a new section `## Pre-flight Checks` to the beginning of critical workflows (e.g., `WF_ORCH_RELEASE_PREPARATION...`, `WF_DEV_FEATURE_IMPLEMENTATION...`). This section must instruct the Lead Mode to perform verifications *before* delegating the first sub-task. Checks should include:
        *   Using `use_mcp_tool` (`get_custom_data`, etc.) to verify that all prerequisite ConPort items (e.g., `ProjectConfig:ActiveConfig`, `AcceptanceCriteria:[key]`) exist.
        *   Checking that prerequisite items have the correct status (e.g., the `SystemArchitecture` design is 'APPROVED', not 'DRAFT').
        *   If a check fails, the workflow must instruct the Lead to report a specific, actionable blocker to the Orchestrator.

-   [ ] **2.2. Implement Parallel Task Management Simulation**
    *   **Rationale:** Real-world projects involve parallel workstreams (e.g., backend and frontend development). While the Nova system's execution remains sequential (one mode active at a time), its *planning and strategic overview* can be enhanced by acknowledging parallelism. This gives the Orchestrator a more accurate view of the project's complexity and potential bottlenecks.
    *   **Action Item:**
        1.  **Update Lead Mode Prompts:** Instruct Lead modes (especially `Nova-LeadDeveloper`) that their `LeadPhaseExecutionPlan` should be structured to represent conceptually parallel workstreams. The briefing MUST explicitly state: "While you will still delegate these tasks sequentially, marking them as parallel in the plan provides crucial strategic insight for the Orchestrator and helps in better progress visualization."
        2.  **Define New `LeadPhaseExecutionPlan` Schema:** Create a new `CustomData` schema for `LeadPhaseExecutionPlan` that supports this. The schema should be an object with a `tracks` array, where each element represents a parallel track. E.g., `{'tracks': [{'name': 'backend', 'tasks': [...]}, {'name': 'frontend', 'tasks': [...]}]}`. Update all relevant prompts and workflows with examples that use this new, richer structure.

-   [ ] **2.3. Formalize "Definition of Ready" (DoR) Checks**
    *   **Rationale:** "Definition of Ready" is a key agile principle that is currently only implicitly assumed. Formalizing it will prevent phases from starting with incomplete prerequisites, improving quality and reducing rework.
    *   **Action Item:** Modify the primary orchestration workflows (`WF_ORCH_NEW_PROJECT...`, `WF_ORCH_EXISTING_PROJECT...`). Before delegating a major phase (like 'Development' or 'QA'), the `Nova-Orchestrator` must now perform an explicit DoR check. This involves retrieving the `CustomData ProjectStandards:DefaultDoR` item and verifying that each criterion is met by checking other ConPort items. If the DoR fails, the Orchestrator must delegate a preparatory task (typically to `Nova-LeadArchitect`) to fulfill the missing criteria.

## 3. Enhanced AI Agent Intelligence & Autonomy

Making the agents smarter and more efficient within their strictly defined roles.

-   [ ] **3.1. Bounded Autonomy for Trivial Fixes by Specialists**
    *   **Rationale:** A specialist finding a trivial, directly related error (e.g., a typo in a comment, an obvious off-by-one error in code they just wrote) and having to fail their entire sub-task is inefficient. Granting bounded autonomy for such minor fixes streamlines the process.
    *   **Action Item:** Add a specific rule to the prompts of `Nova-SpecializedFeatureImplementer` and `Nova-SpecializedCodeRefactorer`: "If you find a trivial, directly related, and demonstrably correctable issue *in the code you are currently working on*, you are authorized to fix it, log a `Decision` item in ConPort with the rationale for the fix, and report both the original task completion and the trivial fix in your `attempt_completion`."

-   [ ] **3.2. Implement a System Self-Improvement Cycle**
    *   **Rationale:** The system should learn from its own operations. Currently, improvements are externally driven. A formal retrospective cycle will enable the system to identify and propose its own enhancements.
    *   **Action Item:** Create a new workflow: `WF_ORCH_SYSTEM_RETROSPECTIVE_AND_IMPROVEMENT_PROPOSAL_001_v1.md`. This workflow will guide the `Nova-Orchestrator` to:
        1.  Delegate a task to `Nova-FlowAsk` to analyze ConPort for patterns indicative of process friction (e.g., frequently failing workflows, sub-tasks with high retry counts, clusters of `ErrorLogs` in a specific domain).
        2.  Based on this analysis, delegate a follow-up task to `Nova-LeadArchitect` to perform a formal `ImpactAnalysis` and log a `Decision` item. This decision will contain a concrete proposal for a system improvement (e.g., a prompt modification, a workflow optimization) for the user to approve.

## 4. Developer Experience & System Visibility

Improving the human-computer interface and providing better insight into the system's state.

-   [ ] **4.1. ConPort "Cheatsheet" Generation**
    *   **Rationale:** The growing number of ConPort categories and workflows can be difficult for a human user to track. An auto-generated "cheatsheet" would significantly improve usability and discoverability.
    *   **Action Item:** Create a new workflow: `WF_ARCH_GENERATE_CONPORT_CHEATSHEET_001_v1.md`. This workflow guides `Nova-LeadArchitect` to task its `ConPortSteward` to scan ConPort (using `get_conport_schema` and `get_custom_data` on the `DefinedWorkflows` category) and generate a Markdown file at `.nova/docs/conport_cheatsheet.md`. This file will summarize all active `CustomData` categories, their purpose, and a list of the most important workflows with their descriptions.

-   [ ] **4.2. Knowledge Graph Visualization Workflow**
    *   **Rationale:** The value of the ConPort knowledge graph is primarily conceptual. A visual representation would make dependencies and relationships tangible, aiding in impact analysis and onboarding.
    *   **Action Item:** Create a new workflow: `WF_ARCH_GENERATE_KNOWLEDGE_GRAPH_VISUALIZATION_001_v1.md`. This workflow will:
        1.  Take a central ConPort item (e.g., a `FeatureScope` key) as input.
        2.  Instruct `ConPortSteward` to recursively use `get_linked_items` (1-2 levels deep) to fetch all related items.
        3.  Generate a Mermaid.js `graph TD` diagram syntax representing the fetched items and their `relationship_type` links.
        4.  Save the resulting diagram source to a `.md` file in `.nova/reports/graph_visuals/` for easy rendering.

-   [ ] **4.3. New Developer Onboarding Workflow**
    *   **Rationale:** Onboarding a new human developer onto a complex, AI-managed project is a critical challenge. A dedicated workflow can automate the generation of a personalized briefing package.
    *   **Action Item:** Create a new workflow: `WF_ORCH_ONBOARD_NEW_DEVELOPER_001_v1.md`. This workflow instructs `Nova-FlowAsk` to generate a comprehensive onboarding guide by querying ConPort for:
        1.  The overall `SystemArchitecture` summary.
        2.  The full content of `ProjectConfig` and `NovaSystemConfig`.
        3.  The summaries of the 5 most recent, important `Decisions`.
        4.  A list of all current `IN_PROGRESS` tasks.
        5.  A list of the 3 most critical open `ErrorLogs`.
        The output is a single, consolidated Markdown file saved to `.nova/reports/onboarding/` that gives a new developer a complete snapshot of the project's technical state and current priorities.