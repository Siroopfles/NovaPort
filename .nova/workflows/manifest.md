# Nova System Workflow Manifest

This file provides a discoverable index of all standard workflows within the Nova System. The AI modes can consult this manifest to understand their available capabilities and to select the appropriate process for a given task.

---

## 1. Orchestrator Workflows

**Primary Actor:** `Nova-Orchestrator`
_These workflows manage the high-level project lifecycle and coordinate between Lead modes._

| Filename                                                          | Description                                                                                                                                                                                                                                                            |
| ----------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `WF_ORCH_CRITICAL_BUG_RESOLUTION_PROCESS_001_v1.md`               | To manage the expedited investigation, fix, and verification of a critical bug that significantly impacts project functionality or stability.                                                                                                                          |
| `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`              | To guide the implementation of a new feature within an existing project, from specification through design, development, QA, and integration.                                                                                                                          |
| `WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1.md`                       | To generate a concise, high-level summary report of recent project activity and status for stakeholder review.                                                                                                                                                         |
| `WF_ORCH_MANAGE_TECH_DEBT_ITEM_001_v1.md`                         | To orchestrate the analysis, planning, and resolution of a prioritized technical debt item logged in ConPort.                                                                                                                                                          |
| `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md`                        | To guide the end-to-end process of initializing a new project, from initial user request through design, development, QA, and preparation for a first release, coordinating all Lead Modes.                                                                            |
| `WF_ORCH_ONBOARD_NEW_DEVELOPER_001_v1.md`                         | To generate a comprehensive onboarding guide for a new human developer joining the project, giving them a snapshot of the technical state and current priorities.                                                                                                      |
| `WF_ORCH_PROJECT_CONFIG_NOVA_CONFIG_SETUP_001_v1.md`              | To ensure that essential project-specific configurations (`ProjectConfig:ActiveConfig`) and Nova system behavior configurations (`NovaSystemConfig:ActiveSettings`) are established in ConPort, orchestrated by Nova-Orchestrator by delegating to Nova-LeadArchitect. |
| `WF_ORCH_RELEASE_PREPARATION_AND_GO_LIVE_001_v1.md`               | To guide all necessary steps to prepare for a software release, including final testing, documentation updates, ConPort updates, and conceptual version tagging.                                                                                                       |
| `WF_ORCH_SESSION_END_AND_SUMMARY_001_v1.md`                       | To gracefully end the current user session by ensuring critical ConPort state is updated and a session summary file is generated and saved in `.nova/summary/`.                                                                                                        |
| `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md`        | To correctly initialize Nova-Orchestrator at the start of a new user session by loading all relevant context from ConPort and the last session summary file, establishing a clear operational state.                                                                   |
| `WF_ORCH_SYSTEM_RETROSPECTIVE_AND_IMPROVEMENT_PROPOSAL_001_v1.md` | To systematically analyze ConPort data for signs of process friction, generate a structured analysis, and formulate a data-driven proposal for system improvement (e.g., workflow or prompt modifications) for user approval.                                          |
| `WF_ORCH_TRIAGE_NEW_ISSUE_REPORTED_BY_LEAD_001_v1.md`             | To systematically process a "New Issue Discovered (Out of Scope)" that a Lead Mode has reported in their `attempt_completion`, by ensuring it's tracked in ConPort and discussed with the user for prioritization.                                                     |
| `WF_PROJ_INIT_001_NewProjectBootstrap.md`                         | To establish the foundational ConPort entries and basic directory structure for an entirely new project, guided by Nova-LeadArchitect based on initial user input.                                                                                                     |

---

## 2. Lead Architect Workflows

**Primary Actor:** `Nova-LeadArchitect`
_These workflows focus on system design, architectural integrity, and ConPort management._

| Filename                                                    | Description                                                                                                                                                                                                                       |
| ----------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `WF_ARCH_CONPORT_DATA_HYGIENE_REVIEW_001_v1.md`             | To periodically scan ConPort for stale or outdated information, log these items as archival candidates, and present them to the user for a decision on whether to archive them.                                                   |
| `WF_ARCH_CONPORT_HEALTH_CHECK_001_v1.md`                    | To periodically review and maintain the quality, consistency, and utility of data within ConPort for the current workspace, executed by Nova-LeadArchitect's team.                                                                |
| `WF_ARCH_CONPORT_SCHEMA_MIGRATION_001_v1.md`                | To migrate all ConPort `CustomData` items within a specific category from an old schema version to a new one, ensuring data integrity and consistency.                                                                            |
| `WF_ARCH_CONPORT_SCHEMA_PROPOSAL_001_v1.md`                 | To formally propose a new standard `CustomData` category, or significant changes/additions to the structure or usage guidelines of existing ConPort entities, and log this proposal in ConPort for review and potential adoption. |
| `WF_ARCH_CREATE_MODULE_TEMPLATE_001_v1.md`                  | To design and create a standardized, reusable module/service template and store it in the `.nova/templates/` directory for future use.                                                                                            |
| `WF_ARCH_GENERATE_CONPORT_CHEATSHEET_001_v1.md`             | To scan the current ConPort instance and generate a helpful Markdown "cheatsheet" that summarizes key data categories and workflows for user reference.                                                                           |
| `WF_ARCH_GENERATE_KNOWLEDGE_GRAPH_VISUALIZATION_001_v1.md`  | To generate a Mermaid.js diagram representing a slice of the ConPort knowledge graph, centered on a specific item, to help visualize dependencies and relationships.                                                              |
| `WF_ARCH_IMPACT_ANALYSIS_001_v1.md`                         | To assess and document the potential impact of a proposed significant change on the project, including effects on code, ConPort items, documentation, and project timelines/risks.                                                |
| `WF_ARCH_NEW_WORKFLOW_DEFINITION_001_v1.md`                 | To define, document, and register a new standardized workflow for use by Nova-Orchestrator or Lead Modes, storing it in the appropriate `.nova/workflows/{mode_slug}/` directory and logging its existence in ConPort.            |
| `WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md`                    | To establish or update the `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` entries in ConPort, managed by Nova-LeadArchitect, typically involving user consultation for key values.                            |
| `WF_ARCH_RISK_ASSESSMENT_AND_MITIGATION_PLANNING_001_v1.md` | To systematically identify, analyze, evaluate, and plan mitigation for potential risks within a project or a specific project phase/feature.                                                                                      |
| `WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1.md`                     | To manage and execute a complete system design phase for a new project or major feature, resulting in a documented architecture, key technical decisions, and defined interfaces, all logged in ConPort.                          |
| `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1.md`           | To manage a proposed change to a Nova system prompt file (in `.roo/`) with the same rigor as application code, including rationale, user approval, and formal implementation.                                                     |
| `WF_ARCH_VALIDATE_WORKFLOW_SIMULATION_001_v1.md`            | To validate the logical flow of a Nova workflow `.md` file by using a `Test-Harness-Orchestrator` to simulate its execution with pre-scripted mock results.                                                                       |

---

## 3. Lead Developer Workflows

**Primary Actor:** `Nova-LeadDeveloper`
_These workflows cover the entire software implementation lifecycle._

| Filename                                            | Description                                                                                                                                                                                                                            |
| --------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `WF_DEV_CODE_REVIEW_SIMULATION_001_v1.md`           | To simulate a code review process for implemented code, focusing on adherence to standards, clarity, potential issues, and alternative approaches. This is a _simulated_ review to check for patterns and adherence to explicit rules. |
| `WF_DEV_DEPENDENCY_UPDATE_AND_AUDIT_001_v1.md`      | To systematically check for outdated dependencies, audit for known vulnerabilities, and safely apply updates.                                                                                                                          |
| `WF_DEV_EXTERNAL_LIBRARY_INTEGRATION_001_v1.md`     | To safely and effectively integrate a new external library/SDK into the project, including installation, configuration, creating wrappers, and documenting its use.                                                                    |
| `WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md` | To manage the complete development lifecycle of a feature or significant component, from receiving specifications to delivering tested, documented, and integrated code, by coordinating a team of development specialists.            |
| `WF_DEV_NEW_MODULE_SCAFFOLDING_AND_SETUP_001_v1.md` | To create the basic directory structure, boilerplate files, initial configuration, and basic tests for a new, independent code module or microservice.                                                                                 |
| `WF_DEV_TECHDEBT_REFACTOR_COMPONENT_001_v1.md`      | To refactor a specific code component to address identified technical debt, improving its quality attributes while ensuring no regressions.                                                                                            |

---

## 4. Lead QA Workflows

**Primary Actor:** `Nova-LeadQA`
_These workflows ensure the quality, stability, and security of the application._

| Filename                                               | Description                                                                                                                                                                                                      |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1.md`      | To manage the lifecycle of a reported bug from initial investigation, root cause analysis, coordination of fix, and verification of resolution.                                                                  |
| `WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1.md`           | To execute a comprehensive regression test suite for the entire application or a major part of it, typically before a release or after significant refactoring, to ensure existing functionality remains intact. |
| `WF_QA_PERFORMANCE_TEST_EXECUTION_001_v1.md`           | To execute defined performance tests (e.g., load, stress, soak) against specific application components or end-to-end scenarios, analyze results, and log performance metrics and issues.                        |
| `WF_QA_RELEASE_CANDIDATE_VALIDATION_001_v1.md`         | To perform comprehensive QA validation on a Release Candidate build to provide a go/no-go recommendation for release.                                                                                            |
| `WF_QA_SECURITY_VULNERABILITY_TESTING_BASIC_001_v1.md` | To perform a basic set of automated and/or checklist-based security vulnerability scans to identify common vulnerabilities. This is a preliminary check, not a full penetration test.                            |
| `WF_QA_TEST_CASE_DESIGN_FROM_SPECS_001_v1.md`          | To systematically derive and document test cases based on feature specifications, acceptance criteria, and system design documents.                                                                              |
| `WF_QA_TEST_STRATEGY_AND_PLAN_CREATION_001_v1.md`      | To define and document the overall test strategy and a detailed test plan for a new project, a major new feature, or a specific release.                                                                         |
