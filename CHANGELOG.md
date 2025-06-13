# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.html).

## [0.3.0-beta] - 2024-05-20

### 🚀 System Architecture & Agent Logic v3 Overhaul

This is a major release focused on fundamentally improving agent reliability, system robustness, and traceability by implementing the entire v3 improvement roadmap.

#### ✨ New Features & Capabilities

- **Workflow Validation Suite:** Introduced a new `Test-Harness-Orchestrator` mode and a corresponding `WF_ARCH_VALIDATE_WORKFLOW_SIMULATION_001_v1.md` workflow. This enables "dry-runs" of workflow logic for validation and debugging before live execution.
- **ConPort Schema Migration:** Added a new `WF_ARCH_CONPORT_SCHEMA_MIGRATION_001_v1.md` workflow to guide the `LeadArchitect` and `ConPortSteward` through the process of migrating `CustomData` items to new schemas.
- **Analytical Graph Query:** Enabled complex, multi-hop analysis of the ConPort knowledge graph.
  - Added a new `WF_ORCH_ANALYTICAL_GRAPH_QUERY_001_v1.md` workflow for the Orchestrator to delegate multi-step queries.
  - Enhanced the `Nova-FlowAsk` prompt with an explicit capability to execute a sequence of `use_mcp_tool` calls as part of a single subtask.

#### 🚀 Improvements & Hardening

- **Granular Single-Step Execution Loop (Lead Modes):** Re-engineered the core `task_execution_protocol` for all Lead Modes (`LeadArchitect`, `LeadDeveloper`, `LeadQA`). They no longer plan entire phases upfront. Instead, they create a high-level plan and then enter an iterative loop, determining and delegating only the single, next, most logical atomic sub-task to a specialist at a time. This dramatically improves reliability and reduces the risk of complex, error-prone specialist briefings.
- **Mandatory Auditable Rationale Protocol:** System-wide hardening of all 15 agent prompts (`Orchestrator`, `Leads`, `Specialists`, `FlowAsk`). Before *every* tool call, agents must now include a `## Rationale` section in their `<thinking>` block, detailing the goal, justification, and expected outcome of the tool call. This creates an invaluable "flight recorder" log for debugging and analysis.
- **Proactive ConPort Linking (Specialist Modes):** All 10 Specialist Mode prompts have been updated to include a mandatory `Suggested_ConPort_Links` section in their `attempt_completion` reports. Specialists are now required to proactively suggest potential links between the ConPort items they create and other relevant items, enriching the knowledge graph for their Leads to review and action.

### 📖 Documentation & Prompts

- **System-Wide Prompt Re-engineering:** All 15 system prompts in the `.roo/` directory have been updated to implement the new "Auditable Rationale" protocol. All Lead prompts have their core logic updated for the "Single-Step Loop". All Specialist prompts have been updated with the "Proactive ConPort Linking" protocol.
- **README Update:** The main `README.md` was updated to reflect the new operational principles of Granular Tasking and Auditable Reasoning. The descriptions of Lead and Specialist modes have been updated to reflect their new responsibilities and logic.
- **New Workflows Added to Manifest:** The `.nova/workflows/manifest.md` has been updated to include the new validation, migration, and query workflows.

## [0.2.8-beta] - 2024-05-20

### 🚀 Improvements & Hardening

- **System-Wide Tooling Modernization:** Updated the definitions for the `read_file` and `apply_diff` tools across all system prompts (`.roo/system-prompt-nova-*.md`). This modernization aligns agent capabilities with the latest Roo Code features for multi-file operations.
  - The `read_file` tool now reflects the capability to read multiple files in a single request using the `<args>` format.
  - The `apply_diff` tool now reflects the experimental capability to apply diffs to multiple files in a single request using the `<args>` format.
- **Holistic Prompt Consistency Review:** As part of the tooling update, all prompts were reviewed and refined for consistency, clarity, and to ensure all examples conform to the modernized tool specifications.

## [0.2.7-beta] - 2024-05-19

### ⚖️ Legal
- **Re-licensed Project to Apache 2.0:** Changed the project license from MIT to Apache License, Version 2.0. This change was made to ensure full compliance with the license of the upstream work (RooFlow) on which this project is based. A NOTICE file has been added for clear attribution.

## [0.2.6-beta] - 2024-05-19

### 🚀 Improvements & Hardening
- **ConPort Tool Reference Refactoring:** Conducted a comprehensive refactoring and enhancement of the `conport_tool_reference` sections across all relevant system prompts (`.roo/system-prompt-nova-*.md`). This update improves the clarity, accuracy, and usability of tool definitions for all AI agents. Key changes include standardizing example arguments, enhancing tool descriptions and guidelines, and refining instructions for ConPort operations, leading to more reliable and predictable AI behavior when interacting with the ConPort server.

## [0.2.5-beta] - 2024-05-19

### 🚀 Improvements & Hardening

- **System-Wide Prompt & Tooling Synchronization:** Performed a comprehensive audit and update of all system prompts (`.roo/system-prompt-nova-*.md`). The `conport_tool_reference` section in each prompt has been corrected, completed, and synchronized with the master ConPort API specification. This resolves numerous inconsistencies, adds previously missing tool definitions, and ensures all AI agents (Orchestrator, Leads, Specialists) operate with a consistent and accurate understanding of the available ConPort tools and their parameters. This significantly improves the reliability and predictability of AI-driven ConPort interactions.

## [0.2.2-beta] - 2024-05-18

This release focuses on implementing the strategic recommendations from the v2 system audit and creating new Developer Experience (DX) and system maintenance workflows.

### ✨ New Features & Capabilities
- **New System & DX Workflows:** Added several new workflows to improve system maintainability and developer experience:
    - `WF_ARCH_CONPORT_DATA_HYGIENE_REVIEW_001_v1.md`: For periodically identifying and archiving stale ConPort data.
    - `WF_ARCH_GENERATE_KNOWLEDGE_GRAPH_VISUALIZATION_001_v1.md`: For generating Mermaid.js diagrams of ConPort item relationships.
    - `WF_ARCH_GENERATE_CONPORT_CHEATSHEET_001_v1.md`: For creating a summary of active ConPort categories and workflows.
    - `WF_ORCH_ONBOARD_NEW_DEVELOPER_001_v1.md`: For generating a comprehensive project briefing for new team members.
- **System Retrospective Capability:** Enabled the system's self-improvement cycle by updating the `WF_PROJ_INIT_001_NewProjectBootstrap.md` to log the necessary `ProcessFrictionHeuristics_v1` configuration by default.

### 🚀 Improvements & Hardening
- **"Definition of Ready" (DoR) Gating in Workflows:** Hardened key workflows by adding mandatory, tool-based "Definition of Ready" pre-flight checks. This ensures phases do not start without necessary prerequisites.
    - Updated: `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md`
    - Updated: `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`
    - Updated: `WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md`
    - Updated: `WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1.md`
    - Updated: `WF_QA_RELEASE_CANDIDATE_VALIDATION_001_v1.md`
    - Updated: `WF_QA_TEST_CASE_DESIGN_FROM_SPECS_001_v1.md`
    - Updated: `WF_DEV_TECHDEBT_REFACTOR_COMPONENT_001_v1.md`
    - Updated: `WF_DEV_EXTERNAL_LIBRARY_INTEGRATION_001_v1.md`
    - Updated: `WF_ARCH_IMPACT_ANALYSIS_001_v1.md`
    - Updated: `WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1.md`
- **System-Wide Prompt Hardening:** Re-engineered all Lead and Orchestrator prompts (`nova-orchestrator`, `nova-leadarchitect`, `nova-leaddeveloper`, `nova-leadqa`) to enforce the new hardened protocols, including structured delegation, DoR/DoD checks, and robust failure recovery.

### 📖 Documentation & Prompts
- **README Update:** The main `README.md` was updated to reflect the newly formalized, more robust system architecture and operational principles.
- **CONTRIBUTING.md Update:** The contributing guide was updated to align with the project's more mature and structured nature.

## [0.2.1-beta] - 2024-05-18

This was a comprehensive hardening and process-improvement release. The primary focus was on increasing system robustness by formalizing agent interaction protocols, introducing proactive quality gates (DoD/DoR), and enhancing the intelligence and autonomy of the agents within their defined roles. This release implemented the core strategic recommendations from the v2 system audit.

### 🚀 Improvements & Hardening
- **Hardened Delegation Protocol:** The `new_task` tool across all delegating prompts (`Orchestrator`, `Leads`) has been re-engineered. The `message` parameter now MANDATES a structured YAML/JSON `Subtask Briefing Object`, drastically reducing ambiguity and improving the reliability of the entire delegation chain.
- **Proactive "Definition of Ready" (DoR) Gating:** All Lead Mode prompts now include a mandatory, tool-based "Definition of Ready" check in their `task_execution_protocol`. They must verify that all prerequisites for their assigned phase exist and are in the correct state in ConPort *before* starting their planning. This prevents entire work cycles from being wasted on unready tasks.
- **Enforced "Definition of Done" (DoD) Checks:** The `attempt_completion` instructions for all Lead Modes have been updated to require a final "Definition of Done" verification on their phase's deliverables before reporting completion to the Orchestrator, formalizing a final quality gate.
- **Robust Failure Handling & Retry Logic:** The failure recovery rules (`R14`) in all Lead Mode prompts have been enhanced. They now include explicit instructions for logging non-transient failures as `ErrorLogs` in ConPort, updating their internal execution plan, and a "retry-once" policy for potentially transient errors to increase system resilience.

### ✨ New Features & Capabilities
- **Bounded Autonomy for Trivial Fixes:** Relevant specialist prompts (`Nova-SpecializedFeatureImplementer`, `Nova-SpecializedCodeRefactorer`) now include a rule granting them bounded autonomy to fix trivial, in-scope issues, provided they log the action as a `Decision`. This improves efficiency by reducing unnecessary failure/re-delegation loops.
- **Proactive Tech Debt Identification (R23):** The prompts for developer-side specialists now include an explicit instruction to identify and log new, out-of-scope technical debt to ConPort as a `TechDebtCandidates` item, improving long-term code health.
- **Enhanced System Observability & DX:** The `nova-orchestrator` prompt has been updated with capabilities to initiate new "Developer Experience" workflows for knowledge graph visualization and new developer onboarding, making the system's state more transparent to the user.

### 📖 Documentation & Prompts
- **System-Wide Prompt Re-engineering:** All system prompts (`system-prompt-nova-*.md`) have been updated with the new, hardened protocols (DoR, DoD, Structured Briefings, Failure Handling).
- **README Enhancement:** The main `README.md` has been updated to reflect the newly formalized concepts of Structured Delegation, DoD/DoR, and the improved system architecture.
- **Contributing Guide Update:** The `CONTRIBUTING.md` has been updated to align with the more mature, structured nature of the project.
- **Finalized `IMPROVEMENT_TODO.md`:** The v2 TODO list has been fully updated, marking the completion of the core prompt and process logic hardening tasks.

## [0.2.0-beta] - 2024-05-17

This was a major feature-enhancement release focused on adding new core capabilities and standardizing data structures.

### ✨ New Features & Capabilities
- **ConPort Data Standards:** Introduced a formal `conport_standards.md` document in `.nova/docs/`.
- **System Prompt Management Workflow:** Added `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1.md`.
- **Module Template Workflow:** Added `WF_ARCH_CREATE_MODULE_TEMPLATE_001_v1.md`.
- **Dependency Management Workflow:** Added `WF_DEV_DEPENDENCY_UPDATE_AND_AUDIT_001_v1.md`.
- **Project Digest Workflow:** Added `WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1.md`.
- **System Retrospective Workflow:** Added `WF_ORCH_SYSTEM_RETROSPECTIVE_AND_IMPROVEMENT_PROPOSAL_001_v1.md`.

### 🚀 Improvements & Hardening
- **Prompt & Tooling Hygiene:** Standardized all `use_mcp_tool` examples and `Subtask Briefing Object` examples across all prompts and workflows.
- **Workflow Hardening:** Introduced `Phase 0: Pre-flight Checks` to critical workflows.

## [0.1.1-beta] - Previous Release
- Initial beta release with foundational Nova modes and workflows.
