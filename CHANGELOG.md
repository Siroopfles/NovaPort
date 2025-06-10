# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.html).

## [0.2.1-beta] - 2024-05-18

This is a comprehensive hardening and process-improvement release. The primary focus is on increasing system robustness by formalizing agent interaction protocols, introducing proactive quality gates (DoD/DoR), and enhancing the intelligence and autonomy of the agents within their defined roles. This release implements the core strategic recommendations from the v2 system audit.

### 🚀 Improvements & Hardening

-   **Hardened Delegation Protocol:** The `new_task` tool across all delegating prompts (`Orchestrator`, `Leads`) has been re-engineered. The `message` parameter now MANDATES a structured YAML/JSON `Subtask Briefing Object`, drastically reducing ambiguity and improving the reliability of the entire delegation chain.
-   **Proactive "Definition of Ready" (DoR) Gating:** All Lead Mode prompts now include a mandatory, tool-based "Definition of Ready" check in their `task_execution_protocol`. They must verify that all prerequisites for their assigned phase exist and are in the correct state in ConPort *before* starting their planning. This prevents entire work cycles from being wasted on unready tasks.
-   **Enforced "Definition of Done" (DoD) Checks:** The `attempt_completion` instructions for all Lead Modes have been updated to require a final "Definition of Done" verification on their phase's deliverables before reporting completion to the Orchestrator, formalizing a final quality gate.
-   **Robust Failure Handling & Retry Logic:** The failure recovery rules (`R14`) in all Lead Mode prompts have been enhanced. They now include explicit instructions for logging non-transient failures as `ErrorLogs` in ConPort, updating their internal execution plan, and a "retry-once" policy for potentially transient errors to increase system resilience.

### ✨ New Features & Capabilities

-   **Bounded Autonomy for Trivial Fixes:** Relevant specialist prompts (`Nova-SpecializedFeatureImplementer`, `Nova-SpecializedCodeRefactorer`) now include a rule granting them bounded autonomy to fix trivial, in-scope issues, provided they log the action as a `Decision`. This improves efficiency by reducing unnecessary failure/re-delegation loops.
-   **Proactive Tech Debt Identification (R23):** The prompts for developer-side specialists now include an explicit instruction to identify and log new, out-of-scope technical debt to ConPort as a `TechDebtCandidates` item, improving long-term code health.
-   **Enhanced System Observability & DX:** The `nova-orchestrator` prompt has been updated with capabilities to initiate new "Developer Experience" workflows for knowledge graph visualization and new developer onboarding, making the system's state more transparent to the user.

### 📖 Documentation & Prompts

-   **System-Wide Prompt Re-engineering:** All system prompts (`system-prompt-nova-*.md`) have been updated with the new, hardened protocols (DoR, DoD, Structured Briefings, Failure Handling).
-   **README Enhancement:** The main `README.md` has been updated to reflect the newly formalized concepts of Structured Delegation, DoD/DoR, and the improved system architecture.
-   **Contributing Guide Update:** The `CONTRIBUTING.md` has been updated to align with the more mature, structured nature of the project.
-   **Finalized `IMPROVEMENT_TODO.md`:** The v2 TODO list has been fully updated, marking the completion of the core prompt and process logic hardening tasks.

## [0.2.0-beta] - 2024-05-17

This was a major feature-enhancement release focused on adding new core capabilities and standardizing data structures.

### ✨ New Features & Capabilities

-   **ConPort Data Standards:** Introduced a formal `conport_standards.md` document in `.nova/docs/`.
-   **System Prompt Management Workflow:** Added `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1.md`.
-   **Module Template Workflow:** Added `WF_ARCH_CREATE_MODULE_TEMPLATE_001_v1.md`.
-   **Dependency Management Workflow:** Added `WF_DEV_DEPENDENCY_UPDATE_AND_AUDIT_001_v1.md`.
-   **Project Digest Workflow:** Added `WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1.md`.
-   **System Retrospective Workflow:** Added `WF_ORCH_SYSTEM_RETROSPECTIVE_AND_IMPROVEMENT_PROPOSAL_001_v1.md`.

### 🚀 Improvements & Hardening

-   **Prompt & Tooling Hygiene:** Standardized all `use_mcp_tool` examples and `Subtask Briefing Object` examples across all prompts and workflows.
-   **Workflow Hardening:** Introduced `Phase 0: Pre-flight Checks` to critical workflows.

## [0.1.1-beta] - Previous Release

-   Initial beta release with foundational Nova modes and workflows.