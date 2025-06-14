# Nova System Workflow Manifest

This file provides a discoverable index of all standard workflows within the Nova System. The AI modes can consult this manifest to understand their available capabilities and to select the appropriate process for a given task.

---

## 1. Orchestrator Workflows
**Primary Actor:** `Nova-Orchestrator`
_These workflows manage the high-level project lifecycle and coordinate between Lead modes._

| Filename | Description |
|---|---|
| `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md` | Guides the end-to-end setup of a new project from scratch. |
| `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md` | Manages the lifecycle of adding a new feature to an existing project. |
| `WF_ORCH_CRITICAL_BUG_RESOLUTION_PROCESS_001_v1.md` | Expedited process for investigating and resolving critical bugs. |
| `WF_ORCH_MANAGE_TECH_DEBT_ITEM_001_v1.md`| Orchestrates the analysis, planning, and resolution of a prioritized technical debt item. |
| `WF_ORCH_ANALYTICAL_GRAPH_QUERY_001_v1.md` | Guides the delegation of a complex, multi-hop analytical query to Nova-FlowAsk to traverse the ConPort knowledge graph. |
| `WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1.md` | Generates a high-level project summary report for stakeholders. |
| `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md` | Initializes a user session by loading the project context from ConPort. |
| `WF_ORCH_SESSION_END_AND_SUMMARY_001_v1.md` | Properly ends a user session and generates a summary of the activities. |

---

## 2. Lead Architect Workflows
**Primary Actor:** `Nova-LeadArchitect`
_These workflows focus on system design, architectural integrity, and ConPort management._

| Filename | Description |
|---|---|
| `WF_ARCH_IMPACT_ANALYSIS_001_v1.md` | Assesses the impact of a proposed change on the project's architecture, code, and ConPort. |
| `WF_ARCH_CONPORT_HEALTH_CHECK_001_v1.md` | Performs a periodic review of the ConPort data integrity, consistency, and quality. |
| `WF_ARCH_CONPORT_SCHEMA_MIGRATION_001_v1.md`| Guides the migration of `CustomData` items from one schema version to another. |
| `WF_ARCH_VALIDATE_WORKFLOW_SIMULATION_001_v1.md` | Uses a Test Harness to perform a "dry run" of a workflow's logic against mock data for validation. |
| `WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md` | Manages the creation and updating of the critical `ProjectConfig` and `NovaSystemConfig` items. |
| `WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1.md` | Manages a complete system design phase for a new project or major feature. |
| `WF_ARCH_CONPORT_SCHEMA_PROPOSAL_001_v1.md` | Formalizes a proposal for a new or modified ConPort data schema. |
| `WF_ARCH_NEW_WORKFLOW_DEFINITION_001_v1.md`| Defines, documents, and registers a new standardized workflow for any mode. |
| `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1.md` | Manages a proposed change to a Nova system prompt file with formal approval. |
| `WF_ARCH_CREATE_MODULE_TEMPLATE_001_v1.md` | Designs and creates a standardized, reusable module/service template. |
| `WF_ARCH_RISK_ASSESSMENT_AND_MITIGATION_PLANNING_001_v1.md` | Systematically identifies, analyzes, and plans mitigation for project risks. |

---

## 3. Lead Developer Workflows
**Primary Actor:** `Nova-LeadDeveloper`
_These workflows cover the entire software implementation lifecycle._

| Filename | Description |
|---|---|
| `WF_DEV_FEATURE_IMPLEMENTATION_LIFECYCLE_001_v1.md` | Manages the development of a feature, from component creation to final testing. |
| `WF_DEV_TECHDEBT_REFACTOR_COMPONENT_001_v1.md` | Manages the refactoring of a specific component to address technical debt. |
| `WF_DEV_NEW_MODULE_SCAFFOLDING_AND_SETUP_001_v1.md`| Creates the basic directory structure and boilerplate files for a new code module. |
| `WF_DEV_EXTERNAL_LIBRARY_INTEGRATION_001_v1.md` | Manages the safe integration of a new external library or SDK. |
| `WF_DEV_CODE_REVIEW_SIMULATION_001_v1.md`| Simulates a code review process to check for adherence to standards and potential issues. |
| `WF_DEV_DEPENDENCY_UPDATE_AND_AUDIT_001_v1.md`| Systematically checks for outdated dependencies, audits for vulnerabilities, and applies updates. |

---

## 4. Lead QA Workflows
**Primary Actor:** `Nova-LeadQA`
_These workflows ensure the quality, stability, and security of the application._

| Filename | Description |
|---|---|
| `WF_QA_RELEASE_CANDIDATE_VALIDATION_001_v1.md`| Performs comprehensive validation on a release candidate to provide a go/no-go recommendation. |
| `WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1.md` | Executes a complete regression test suite to ensure existing functionality remains intact. |
| `WF_QA_BUG_INVESTIGATION_TO_RESOLUTION_001_v1.md`| Manages a bug's lifecycle, from root cause analysis to fix verification. |
| `WF_QA_TEST_STRATEGY_AND_PLAN_CREATION_001_v1.md` | Defines the overall test strategy and detailed test plan for a project or feature. |
| `WF_QA_TEST_CASE_DESIGN_FROM_SPECS_001_v1.md` | Systematically derives and documents test cases from feature specifications. |
| `WF_QA_PERFORMANCE_TEST_EXECUTION_001_v1.md` | Executes performance tests (load, stress, etc.) against application components. |
| `WF_QA_SECURITY_VULNERABILITY_TESTING_BASIC_001_v1.md`| Performs a basic set of automated security vulnerability scans. |