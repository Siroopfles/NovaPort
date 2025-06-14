# Workflow: System Design Phase Management (WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1)

**Goal:** To manage and execute a complete system design phase for a new project or major feature, resulting in a documented architecture, key technical decisions, and defined interfaces, all logged in ConPort.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actors (delegated to by Nova-LeadArchitect):** Nova-SpecializedSystemDesigner, Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Define system architecture and detailed design for Project [ProjectName] / Feature [FeatureName]".
- Part of `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md` or `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`.

**Pre-requisites by Nova-LeadArchitect (from Nova-Orchestrator's briefing):**
- A clear overall project goal or feature request exists (e.g., `FeatureScope`, `AcceptanceCriteria`).
- `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` are available.

**Reference Milestones for your Single-Step Loop:**

**Milestone SD.0: Pre-flight & Readiness Check**
*   **Goal:** Verify that all required specifications are finalized and approved before starting design work.
*   **Suggested Lead Action:**
    1.  Your first action MUST be to perform a "Definition of Ready" check.
    2.  Use `use_mcp_tool` to retrieve all prerequisite specification items from your briefing (e.g., `FeatureScope:[Key]`, `AcceptanceCriteria:[Key]`).
    3.  **Gated Check:**
        *   **Failure:** If any required spec is missing or its `status` is not 'APPROVED'/'FINAL', immediately `attempt_completion` with a `BLOCKER:` status to `Nova-Orchestrator`. Do not proceed.
        *   **Success:** If all specs are ready, proceed to the next milestone.

**Milestone SD.1: High-Level Architecture**
*   **Goal:** Define the high-level system architecture, main components, and key technology choices.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **LeadArchitect Action:** Log a main `Progress` item for the System Design Phase.
    2.  **Delegate to `Nova-SpecializedSystemDesigner`:**
        *   **Subtask Goal:** "Draft the high-level system architecture and propose key technology choices."
        *   **Briefing Details:**
            *   Instruct to identify major components based on requirements.
            *   Request a textual or diagrammatic representation of component interactions.
            *   Request justified proposals for key technologies.
            *   The specialist should log this as a new `CustomData SystemArchitecture:[ProjectName]_HighLevelArch_v1` item.
            *   They should also list critical architectural decision points for your review.
    3.  **LeadArchitect Action:** Review the high-level design. Log formal `Decisions` for the key technology choices and architectural style (e.g., Monolith vs. Microservices).

**Milestone SD.2: Detailed Component & API Design (Iterative)**
*   **Goal:** Sequentially define the detailed design for each component and its interfaces.
*   **Suggested Specialist Sequence & Briefing Guidance (run this sequence for each major component):**
    1.  **Delegate to `Nova-SpecializedSystemDesigner`:**
        *   **Subtask Goal:** "Define the detailed internal design for [Component Name]."
        *   **Briefing Details:** Instruct to detail the component's responsibilities and internal structure, logging it as a new `SystemArchitecture:[ComponentName]_Detail_v1` item.
    2.  **Delegate to `Nova-SpecializedSystemDesigner`:**
        *   **Subtask Goal:** "Define the API endpoints for [Component Name]."
        *   **Briefing Details:** Instruct to define HTTP method, path, request/response schemas, and error responses for each endpoint, logging each as a separate `APIEndpoints:[Component_EndpointName_v1]` item.

**Milestone SD.3: Data Schema Design**
*   **Goal:** Define and document the database schema(s) required for the project.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **Delegate to `Nova-SpecializedSystemDesigner`:**
        *   **Subtask Goal:** "Define and document the required database schema(s)."
        *   **Briefing Details:** Instruct to define tables, columns, types, and relationships based on component designs and data models. This should be logged as a `DBMigrations:[ProjectName_Schema_v1]` item.

**Milestone SD.4: Finalize & Report**
*   **Goal:** Consolidate all design artifacts and report completion of the phase.
*   **Suggested Lead Action:**
    1.  Review all created ConPort items (`SystemArchitecture`, `APIEndpoints`, `DBMigrations`, `Decisions`) for consistency and completeness.
    2.  Update a main `SystemArchitecture:[ProjectName]_OverallArch_v1` document to link to all other artifacts.
    3.  Update the main phase `Progress` item to 'DONE'.
    4.  Update the `active_context.state_of_the_union`.
    5.  In your `attempt_completion` to `Nova-Orchestrator`, summarize the phase outcome and provide keys to the most important design artifacts as `Critical_Output_For_Orchestrator`.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- CustomData (`SystemArchitecture`, `APIEndpoints`, `DBMigrations`)
- Decisions (integer `id`)
- ContextLinks (integer `id`)