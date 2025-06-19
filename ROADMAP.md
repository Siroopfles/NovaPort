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

## Next Release: v0.4.0-beta (Finalizing the `novaport-mcp` Transition)

These are the final tasks required to complete the transition to the new `novaport-mcp` backend and finalize the v0.4.0-beta release.

- **Completed Tasks:**
  - [x] **[Prompts] Update All System Prompts:** Replaced all "ConPort" references with "NovaPort-MCP" and updated the MCP server name to `novaport-mcp` across all files in the `.roo/` directory.
  - [x] **[Config] Update `.roomodes`:** Renamed `nova-specializedconportsteward` to `nova-specializednovaportsteward` for consistency.
  - [x] **[Documentation] Update `README.md`:** Rewrote the "Dependencies & Setup" section with instructions for installing `novaport-mcp`. Update all other relevant sections to reference the new backend.
  - [x] **[Documentation] Update `GETTING_STARTED.md`:** Aligned the "Prerequisites" section with the new `novaport-mcp` setup process.
  - [x] **[Documentation] Update `NOVA_SYSTEM_ARCHITECTURE.md`:** Revised diagrams and text to explicitly name and link to `novaport-mcp`.
  - [x] **[Workflows] Update All Workflow Files:** Systematically reviewed every `.md` file in the `.nova/workflows/` subdirectories. Replaced all remaining mentions of "ConPort" with "NovaPort-MCP" or "the database" where appropriate.
  - [x] **[Final Review] Finalize `CHANGELOG.md`:** Updated the `[Unreleased]` section to include all changes for this release, then renamed the tag to `[0.4.0-beta]` and added the final release date.
  - [x] **[Release] Create GitHub Release:** Tag the final commit with `v0.4.0-beta` and publish the release on GitHub.

---

## Short-Term Goals (Post v0.4.0)

These are well-defined features and improvements that are our highest priority after the current release.

- [x] **[DX] Implement GitHub Issue & Pull Request Templates:** Create templates in the `.github/` directory to standardize bug reports, feature requests, and pull requests.
- [x] **[DX] Create a "Getting Started" Tutorial:** Develop a new `GETTING_STARTED.md` file with a "Hello World" style tutorial.
- [x] **[Intelligence] Enable Specialist-Proposed Alternatives:** Update Specialist prompts to allow them to propose a more efficient alternative.
- [x] **[Core] Implement Configurable Quality Gates:** Add a `quality_gate_level` setting to `ProjectConfig:ActiveConfig`.

---

## Medium-Term Goals (Next 1-3 Months)

These are larger, more complex features that will significantly expand Nova's capabilities. They require more design and development effort.

- [ ] **[Intelligence] Implement the Self-Improvement Cycle:**
  - **Description:** Create a new workflow, `WF_ARCH_LEARNING_CYCLE_001_v1.md`, that guides `LeadArchitect` to periodically analyze patterns in `LessonsLearned` and recurring `ErrorLogs`. Based on the analysis, `LeadArchitect` will initiate a `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL` to fix the root cause of systemic issues directly in the prompts of the relevant agents, creating a closed-loop learning mechanism.
- [ ] **[DX] Implement User Command Alias System:**
  - **Description:** Define a `CustomData UserCommands:Aliases` schema in NovaPort-MCP to map short, user-defined strings (e.g., `nova test`) to full workflow file paths. Update `Nova-Orchestrator`'s initial logic to check if user input matches an alias and, if so, immediately initiate the corresponding workflow.
- [ ] **[Core] Expand Specialist Teams with New Roles:**
  - **Description:** Introduce new specialist modes to cover critical domains. This involves creating their system prompts, adding them to `.roomodes`, updating the `README.md`, and creating initial workflows.
  - **`Nova-SpecializedSecurityAnalyst`**: (Reports to LeadQA) To interpret security scan results and triage vulnerabilities.
  - **`Nova-SpecializedDevOpsEngineer`**: (Reports to LeadArchitect/LeadDeveloper) To manage CI/CD pipelines and deployment scripts.

---

## Long-Term Vision (Future)

These are ambitious, strategic initiatives that represent the long-term direction of the Nova System. They focus on achieving higher levels of autonomy and intelligence.

- [ ] **Implement Asynchronous Orchestration:** Evolve `Nova-Orchestrator`'s logic to manage a dependency graph of project phases. When a Lead Mode completes a phase, the Orchestrator will immediately check the graph for any unblocked, subsequent phases and delegate them without waiting for explicit user instruction, minimizing idle time.
- [ ] **Implement Self-Explanation Capability:** Create `WF_ORCH_EXPLAIN_ACTION_001_v1.md` to handle user questions like "Why did you do X?". This workflow will guide the `Orchestrator` to use `Nova-FlowAsk` to trace a `Progress` item back to its motivating `Decision` via `get_linked_items` and present the `rationale` to the user as the explanation.
- [ ] **Implement Automated NovaPort-MCP Compaction/Archiving:** Create a new workflow, `WF_ORCH_NOVAPORT_MCP_COMPACTION_001_v1.md`, to orchestrate a scheduled or user-triggered task that summarizes and archives old NovaPort-MCP items to keep the active database lean and performant.
- [ ] **Formalize NovaPort-MCP Schema Versioning:** Introduce a central `CustomData ConPortSchemaVersions:Current` item in NovaPort-MCP to track the active version of all major data schemas (e.g., `{ "ErrorLogs": "1.1", "LessonsLearned": "1.0" }`). Update agent prompts to use the correct schema version when creating new entries.
