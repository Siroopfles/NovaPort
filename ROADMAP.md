# Nova System - Project Roadmap

Welcome to the official roadmap for the Nova System! This document outlines our vision for the future, detailing the short-term goals for upcoming releases and our long-term strategic ambitions. Our mission is to evolve Nova into a more intelligent, autonomous, and user-friendly framework for AI-driven software development.

We are an open-source project and welcome contributions from the community. If you see an item that excites you, we encourage you to get involved!

---

## How to Contribute

Interested in helping us build the future of Nova? We'd love to have you!

1.  **Find an Item:** Look through the "Short-Term Goals" or "Medium-Term Goals" for an item marked with `[ ]`.
2.  **Read the Guidelines:** Please review our `CONTRIBUTING.md` for details on our development process and coding standards.
3.  **Start a Discussion:** Before you start coding, please open a **GitHub Issue** to discuss the item you'd like to work on. This helps us coordinate efforts, provide context, and ensure your proposed solution aligns with the project's architecture.

---

## Short-Term Goals (Next 1-2 Releases)

These are well-defined features and improvements that are our highest priority. They focus on enhancing system reliability, developer experience (DX), and core agent intelligence.

- [ ] **[DX] Implement GitHub Issue & Pull Request Templates:** Create templates in the `.github/` directory to standardize bug reports, feature requests, and pull requests, making it easier for the community to contribute effectively.
- [ ] **[DX] Create a "Getting Started" Tutorial:** Develop a new `GETTING_STARTED.md` file with a "Hello World" style tutorial that guides new users through building a very simple project from scratch.
- [ ] **[Intelligence] Enable Specialist-Proposed Alternatives:** Update Specialist prompts to allow them to propose a more efficient alternative if a briefed task is flawed. Update Lead prompts to recognize and formally approve or reject these proposals via a ConPort `Decision`.
- [ ] **[Core] Implement Configurable Quality Gates:** Add a `quality_gate_level: 'strict' | 'moderate' | 'lean'` setting to `ProjectConfig:ActiveConfig`. Update `LeadDeveloper` and `LeadQA` prompts to read this setting and adjust their "Definition of Done" checks accordingly for more flexible project governance.

---

## Medium-Term Goals (Next 1-3 Months)

These are larger, more complex features that will significantly expand Nova's capabilities. They require more design and development effort.

- [ ] **[Intelligence] Implement the Self-Improvement Cycle:**
    - **Description:** Create a new workflow, `WF_ARCH_LEARNING_CYCLE_001_v1.md`, that guides `LeadArchitect` to periodically analyze patterns in `LessonsLearned` and recurring `ErrorLogs`. Based on the analysis, `LeadArchitect` will initiate a `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL` to fix the root cause of systemic issues directly in the prompts of the relevant agents, creating a closed-loop learning mechanism.
- [ ] **[DX] Implement User Command Alias System:**
    - **Description:** Define a `CustomData UserCommands:Aliases` schema in ConPort to map short, user-defined strings (e.g., `nova test`) to full workflow file paths. Update `Nova-Orchestrator`'s initial logic to check if user input matches an alias and, if so, immediately initiate the corresponding workflow.
- [ ] **[Core] Expand Specialist Teams with New Roles:**
    - **Description:** Introduce new specialist modes to cover critical domains. This involves creating their system prompts, adding them to `.roomodes`, updating the `README.md`, and creating initial workflows.
    - **`Nova-SpecializedSecurityAnalyst`**: (Reports to LeadQA) To interpret security scan results and triage vulnerabilities.
    - **`Nova-SpecializedDevOpsEngineer`**: (Reports to LeadArchitect/LeadDeveloper) To manage CI/CD pipelines and deployment scripts.

---

## Long-Term Vision (Future)

These are ambitious, strategic initiatives that represent the long-term direction of the Nova System. They focus on achieving higher levels of autonomy and intelligence.

- [ ] **Implement Asynchronous Orchestration:** Evolve `Nova-Orchestrator`'s logic to manage a dependency graph of project phases. When a Lead Mode completes a phase, the Orchestrator will immediately check the graph for any unblocked, subsequent phases and delegate them without waiting for explicit user instruction, minimizing idle time.
- [ ] **Implement Self-Explanation Capability:** Create `WF_ORCH_EXPLAIN_ACTION_001_v1.md` to handle user questions like "Why did you do X?". This workflow will guide the `Orchestrator` to use `Nova-FlowAsk` to trace a `Progress` item back to its motivating `Decision` via `get_linked_items` and present the `rationale` to the user as the explanation.
- [ ] **Implement Automated ConPort Compaction/Archiving:** Create a new workflow, `WF_ORCH_CONPORT_COMPACTION_001_v1.md`, to orchestrate a scheduled or user-triggered task that summarizes and archives old ConPort items to keep the active database lean and performant.
- [ ] **Formalize ConPort Schema Versioning:** Introduce a central `CustomData ConPortSchemaVersions:Current` item in ConPort to track the active version of all major data schemas (e.g., `{ "ErrorLogs": "1.1", "LessonsLearned": "1.0" }`). Update agent prompts to use the correct schema version when creating new entries.