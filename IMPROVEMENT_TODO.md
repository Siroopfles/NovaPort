# Nova System - Consolidated & Extended Improvement TODO List

This document outlines a comprehensive list of proposed improvements for the Nova system. It combines direct feedback with further analysis to enhance the system's robustness, efficiency, intelligence, and maintainability. This list can be seen as a strategic roadmap for evolving the system.

## 1. Core: Prompt Engineering & Mode Behavior (Highest Priority)

These items address the fundamental reliability and logic of the AI agents.

-   [ ] **1.1. Stricter ConPort Tool Instructions and Error Handling**
    *   **Rationale:** The current prompts can lead to ambiguity when using `use_mcp_tool`, and the error handling and task sizing can be made more explicit.
    *   **Action Item:**
        *   **a. Unambiguous ID/Key Usage:** In all prompts, add a standardized section explicitly defining the required format for ConPort identifiers (e.g., `integer id` for `Decisions`, `category:key` format for `CustomData` in linking tools).
        *   **b. Robust Error Handling:** Strengthen the `R14_...FailureRecovery` rules in all prompts with a clear escalation procedure: Specialist -> Lead -> Orchestrator -> User.
        *   **c. Granular Task Decomposition:** Reinforce in Lead Mode prompts that they MUST break down phases into a sequence of small, single-responsibility subtasks for their specialists.

-   [ ] **1.2. Introduce Explicit 'Self-Correction/Verification' Step for Specialists**
    *   **Rationale:** Modes currently rely on external checks. A final self-check could catch errors earlier.
    *   **Action Item:** Add a "Final Self-Verification" step to the `task_execution_protocol` for all Specialist modes. Before `attempt_completion`, they must perform a final review against their goal and the project's 'Definition of Done', explicitly stating the checks in their `<thinking>` block.

## 2. Governance: ConPort Strategy & Project Standards

Improving how project knowledge and standards are structured and governed.

-   [ ] **2.1. Formalize Core ConPort Standards (`R20`, `R21`, `DoD`, `DoR`)**
    *   **Rationale:** Key standards like `R20` (ErrorLogs), `R21` (LessonsLearned), DoD, and DoR are referenced but not formally defined, leading to inconsistency.
    *   **Action Items:**
        1.  Create `.nova/docs/conport_standards.md` to define the mandatory JSON structure for `R20` and `R21` artifacts.
        2.  Update the `WF_PROJ_INIT_001_NewProjectBootstrap.md` workflow to include a step where `Nova-LeadArchitect`, in consultation with the user, creates `CustomData` entries for `ProjectStandards:DefaultDoD` and `ProjectStandards:DefaultDoR`.
        3.  Update all relevant prompts to refer to these new standard documents/entries as the "single source of truth".

-   [ ] **2.2. Implement ConPort Item Templates during Project Setup**
    *   **Rationale:** To enforce consistency from the start, item structures should be defined as templates.
    *   **Action Item:** Modify `WF_PROJ_INIT_001_NewProjectBootstrap.md`. `Nova-LeadArchitect` must create a `CustomData` category named `Templates` and populate it with standard JSON structures (e.g., `Templates:ErrorLog_v1`, `Templates:Decision_v1`). All specialist prompts must be updated to instruct them to first fetch and then fill out these templates when creating new items.

-   [ ] **2.3. Introduce Proactive ConPort Link Suggestions**
    *   **Rationale:** The knowledge graph's value depends on its links, which are currently a manual responsibility for Leads. Specialists have the best context at the moment of creation.
    *   **Action Item:** Update `attempt_completion` guidelines for all Specialist modes to include an optional `Suggested_ConPort_Links` section. The Lead Mode is then responsible for reviewing these suggestions and delegating the actual link creation to their `ConPortSteward` or `WorkflowManager`.

-   [ ] **2.4. Introduce On-Demand Project Digest Generation**
    *   **Rationale:** Getting a quick, high-level project overview is valuable for stakeholders.
    *   **Action Item:** Create a new Orchestrator workflow: `WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1.md`. This workflow guides the Orchestrator to delegate a summarization task to `Nova-FlowAsk`, which queries recent ConPort activity (`Progress`, `Decisions`, `ErrorLogs`) and saves a summary report to `.nova/reports/digests/`.

## 3. System & Process Optimization

Improving the core execution flows and development processes.

-   [ ] **3.1. Add "Failure Scenarios" to Workflows**
    *   **Rationale:** The current workflows primarily describe the "happy path," making them less robust.
    *   **Action Item:** Review all `.md` workflow files and add a new section: `## Failure Scenarios / Error Handling`. This section must guide the Lead Mode on what to do if a step fails or a blocker is encountered.

-   [ ] **3.2. Implement an 'Orchestrator-Mediated Inter-Lead Query' Pattern**
    *   **Rationale:** Direct communication between Leads is not allowed, but an explicit pattern for mediated queries would improve efficiency.
    *   **Action Item:** Document this pattern: Lead A reports a need for information from Lead B to the Orchestrator. The Orchestrator pauses Lead A's work, delegates a small, focused information-gathering phase to Lead B, and uses the result to unblock Lead A. Update Lead and Orchestrator prompts to reflect this capability.

-   [ ] **3.3. Formalize Dependency Management**
    *   **Rationale:** Software dependencies are a critical part of any project but are not explicitly managed.
    *   **Action Item:** Create a new Developer workflow: `WF_DEV_DEPENDENCY_UPDATE_AND_AUDIT_001_v1.md`. This workflow guides `Nova-LeadDeveloper`'s team to run dependency audit tools (e.g., `npm audit`, `pip check`), report findings, and log critical vulnerabilities or outdated packages as `RiskAssessment` or `TechDebtCandidates` items.

## 4. System Governance & Maintainability

Treating the Nova System itself as a product that needs maintenance and evolution.

-   [ ] **4.1. Create a Workflow for Updating System Prompts**
    *   **Rationale:** The system prompts are the "source code" of the AI. Changes should be managed with the same rigor as application code.
    *   **Action Item:** Create a new Architect workflow: `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1.md`. This guides `Nova-LeadArchitect` to propose a prompt change, log the rationale as a `Decision`, get user approval, and delegate the file modification to `Nova-SpecializedWorkflowManager`, expanding its role to cover `.roo/` prompt files.

-   [ ] **4.2. Introduce System Observability & a Project Dashboard**
    *   **Rationale:** There is no central, "at-a-glance" view of the project's health and status.
    *   **Action Item:**
        1.  Introduce a `CustomData` entry: `Dashboard:ProjectStatus_v1`.
        2.  Update the `Orchestrator`'s `task_execution_protocol` to update this item after every major phase completion. The dashboard should contain a snapshot of the current state, active lead, next phase, and key metrics (e.g., number of open critical bugs).
        3.  Create a simple workflow where the user can ask "Show me the dashboard", and `FlowAsk` is tasked to fetch and render this ConPort item as a clean Markdown table.

## 5. User Interaction & Developer Experience

Improving the interface between the human user and the system.

-   [ ] **5.1. Refine Project Initialization into an Interactive "Wizard"**
    *   **Rationale:** The initial project setup can be daunting. A more guided, step-by-step process would be more user-friendly.
    *   **Action Item:** Modify the `WF_PROJ_INIT_001_NewProjectBootstrap.md` workflow. Instead of one large delegation, instruct `LeadArchitect` to use a sequence of `ask_followup_question` calls (relayed by the Orchestrator) to ask the user for each critical `ProjectConfig` field one by one, before logging the completed configuration.

-   [ ] **5.2. Formalize Module Templates**
    *   **Rationale:** Starting new services or modules from scratch is inefficient and error-prone.
    *   **Action Item:**
        1.  Establish a `.nova/templates/` directory.
        2.  Create a workflow `WF_ARCH_CREATE_MODULE_TEMPLATE_001_v1.md` where `LeadArchitect`'s team designs and creates standardized templates (e.g., for a Python API service, a React component library) and places them in this directory.
        3.  Update the `WF_DEV_NEW_MODULE_SCAFFOLDING_AND_SETUP_001_v1.md` workflow to instruct `LeadDeveloper`'s team to first check for a relevant template before creating files from scratch.

-   [ ] **5.3. Refine `README.md` Language and Focus**
    *   **Rationale:** The `README.md` can be more focused on the "Nova System" identity.
    *   **Action Item:** Review the `README.md` and replace where logical "Roo Code/RooFlow" with "Nova System", while preserving the credits in the "Foundations and Acknowledgements" section.