# Nova System - Example User Prompts

This file provides a collection of example prompts that a user can send to the `Nova-Orchestrator`. These prompts are designed to trigger various workflows and demonstrate the capabilities of the Nova system across different project phases.

---

## 1. Session & Project Initialization

These prompts are typically used at the beginning of a session or when starting a new project from scratch.

### Starting a New Session

> `Start a new session and give me the current project status.`

- **Expected Behavior:** Triggers `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md`. The orchestrator will load context from ConPort, summarize the last session's state, and await your next command.

### Bootstrapping a Brand New Project

> `This is a new project. Let's set it up. It's a "Python-based API for a real-time chat application".`

- **Expected Behavior:** The orchestrator will detect no existing ConPort database. It will ask for confirmation to start a new project. Upon confirmation, it will delegate the entire setup process (`WF_PROJ_INIT_001_NewProjectBootstrap.md`) to `Nova-LeadArchitect`, who will then guide you through setting up `ProjectConfig` and `NovaSystemConfig`.

### Reviewing or Updating Configuration

> `I need to review and update the project's testing configuration.`

- **Expected Behavior:** The orchestrator will recognize the intent to manage configuration and delegate a task to `Nova-LeadArchitect` to initiate the `WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md` workflow, focusing on the `testing` section of the `ProjectConfig`.

---

## 2. Feature Development & Design

Prompts related to adding new functionality or performing architectural tasks.

### Implementing a New Feature (End-to-End)

> `Let's start work on a new feature: "User Profile Avatars". This should allow users to upload and manage their profile picture.`

- **Expected Behavior:** Triggers `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`. The orchestrator will first delegate the specification and design phase to `Nova-LeadArchitect`, then the development phase to `Nova-LeadDeveloper`, and finally the QA phase to `Nova-LeadQA`.

### Performing an Impact Analysis

> `Before we commit to migrating our database from PostgreSQL to CockroachDB, I need a full impact analysis.`

- **Expected Behavior:** The orchestrator will delegate this task to `Nova-LeadArchitect`, who will initiate the `WF_ARCH_IMPACT_ANALYSIS_001_v1.md` workflow to assess the technical, operational, and project-level impacts of the proposed change.

---

## 3. Quality Assurance & Bug Management

Prompts for testing, bug investigation, and release validation.

### Resolving a Critical Bug

> `Critical bug reported: "Users are getting a 500 error when trying to check out with an expired coupon." Please start the critical bug resolution process immediately.`

- **Expected Behavior:** Triggers `WF_ORCH_CRITICAL_BUG_RESOLUTION_PROCESS_001_v1.md`. The orchestrator will fast-track the delegation to `Nova-LeadQA` for rapid root cause analysis, followed by an expedited fix delegation to `Nova-LeadDeveloper` and final verification.

### Kicking Off a Full Regression Cycle

> `We're preparing for the v2.1 release. Please initiate a full regression test cycle on the staging environment.`

- **Expected Behavior:** The orchestrator delegates this task to `Nova-LeadQA`, who will initiate the `WF_QA_FULL_REGRESSION_TEST_CYCLE_001_v1.md` workflow. Their team will execute all automated regression tests and report the results, including any new `ErrorLogs`.

### Validating a Release Candidate

> `Release candidate v2.1.0-rc1 is now deployed to the validation environment. Please perform the full release candidate validation.`

- **Expected Behavior:** The orchestrator delegates to `Nova-LeadQA`, who will execute `WF_QA_RELEASE_CANDIDATE_VALIDATION_001_v1.md`. This comprehensive workflow provides a final "GO" or "NO_GO" recommendation for the release.

---

## 4. System Maintenance & Reporting

Prompts for interacting with the system's meta-processes, such as reporting, documentation, and self-improvement.

### Generating a Project Digest

> `Can you generate a project digest for this week's activities for our stakeholder meeting?`

- **Expected Behavior:** Triggers `WF_ORCH_GENERATE_PROJECT_DIGEST_001_v1.md`. The orchestrator will delegate this task to `Nova-FlowAsk`, who will query ConPort for recent activity and generate a summary report.

### Onboarding a New Team Member

> `A new developer is joining the team tomorrow. Can you generate an onboarding guide for them?`

- **Expected Behavior:** Triggers `WF_ORCH_ONBOARD_NEW_DEVELOPER_001_v1.md`. `Nova-FlowAsk` will be tasked with querying ConPort for key architectural documents, project configurations, and current work items to create a comprehensive briefing package.

### Visualizing a Part of the System

> `I need to understand the dependencies related to the "PaymentGateway" component. Can you generate a knowledge graph visualization for it?`

- **Expected Behavior:** The orchestrator delegates this to `Nova-LeadArchitect`, who will initiate `WF_ARCH_GENERATE_KNOWLEDGE_GRAPH_VISUALIZATION_001_v1.md`. The architect's team will traverse the ConPort links starting from the "PaymentGateway" and generate a Mermaid diagram.

### Running a System Retrospective

> `We've just completed a major milestone. Let's run a system retrospective to identify potential process improvements.`

- **Expected Behavior:** Triggers `WF_ORCH_SYSTEM_RETROSPECTIVE_AND_IMPROVEMENT_PROPOSAL_001_v1.md`. This advanced workflow uses `Nova-FlowAsk` to analyze ConPort for signs of process friction and `Nova-LeadArchitect` to propose data-driven improvements to system prompts or workflows.

---

## 5. Ending a Session

A simple prompt to gracefully close the interaction.

> `That's all for today. Please end the session.`

- **Expected Behavior:** Triggers `WF_ORCH_SESSION_END_AND_SUMMARY_001_v1.md`. The orchestrator ensures the final project state is saved to ConPort's `ActiveContext` and a summary of the session's activities is written to a file in `.nova/summary/`.
