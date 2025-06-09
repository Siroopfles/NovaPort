# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.html).

## [0.2.0-beta] - 2024-05-17

This is a major hardening and feature-enhancement release focused on improving system reliability, standardization, and adding new core capabilities. The changes address the core items from the `IMPROVEMENT_TODO.md` v2 list.

### ✨ New Features & Capabilities

-   **ConPort Data Standards:** Introduced a formal `conport_standards.md` document in `.nova/docs/`. This document defines standard JSON schemas for critical `CustomData` categories like `ErrorLogs` (R20), `LessonsLearned` (R21), and `ProjectStandards` (DoD), enhancing data consistency and quality.
-   **System Prompt Management Workflow:** Added `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1.md`, a new workflow enabling `Nova-LeadArchitect` to formally manage changes to `.roo/` system prompts, including an approval process.
-   **Module Template Workflow:** Added `WF_ARCH_CREATE_MODULE_TEMPLATE_001_v1.md` to automate the design and creation of standardized, reusable module and service templates.
-   **Dependency Management Workflow:** Added `WF_DEV_DEPENDENCY_UPDATE_AND_AUDIT_001_v1.md` to systematically check project dependencies for outdated versions and known vulnerabilities.
-   **Project Digest Workflow:** Added `WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1.md` to have `Nova-FlowAsk` generate a high-level project summary report.

### 🚀 Improvements & Hardening

-   **Prompt & Tooling Hygiene:**
    -   **Standardized `use_mcp_tool` Calls:** All `use_mcp_tool` examples in all `system-prompt-*.md` files have been updated with complete, syntactically correct, and illustrative JSON `arguments`. This eliminates ambiguity for the LLM and reduces the likelihood of tool errors.
    -   **`conport_tool_reference` Section:** A new, explicit reference list for ConPort tools has been added to agent prompts, serving as a direct 'cheatsheet' for correct tool calls.
    -   **Clarified `item_id` Usage:** Prompts now include explicit notes on the correct format of `item_id` (integer ID as string vs. `category:key` string) based on `item_type`, addressing a common source of errors.

-   **Workflow Hardening:**
    -   **Standardized Briefings:** All `Subtask Briefing Object` examples within `.nova/workflows/**/*.md` files have been updated to reflect the new, standardized `use_mcp_tool` calls, making instructions for specialists clearer and more reliable.
    -   **Proactive "Pre-flight Checks":** Critical workflows (such as `WF_ARCH_IMPACT_ANALYSIS`, `WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE`, and `WF_QA_RELEASE_CANDIDATE_VALIDATION`) now include a `Phase 0: Pre-flight Checks` section. This instructs Lead modes to verify prerequisites (like the existence and status of required ConPort items) *before* execution, proactively preventing errors.

### 📖 Documentation

-   **README Update:** The `README.md` has been updated for clarity, featuring a revised "Dependencies & Setup" section and a more accurate "Quick Start" guide aligned with the VS Code Roo extension.
-   **Roadmap Visibility:** Added `IMPROVEMENT_TODO.md` to the repository to make planned and completed improvements to the Nova system transparent.

## [0.1.1-beta] - Previous Release

-   Initial beta release with foundational Nova modes and workflows.