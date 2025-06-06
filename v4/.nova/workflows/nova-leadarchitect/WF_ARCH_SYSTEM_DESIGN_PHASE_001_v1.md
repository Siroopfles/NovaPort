# Workflow: System Design Phase Management (WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1)

**Goal:** To manage and execute a complete system design phase for a new project or major feature, resulting in a documented architecture, key technical decisions, and defined interfaces, all logged in ConPort.

**Primary Orchestrator Actor:** Nova-LeadArchitect (receives phase task from Nova-Orchestrator)
**Primary Specialist Actors (delegated to by Nova-LeadArchitect):** Nova-SpecializedSystemDesigner, Nova-SpecializedConPortSteward

**Trigger / Orchestrator Recognition (for Nova-Orchestrator to delegate to Nova-LeadArchitect):**
- User requests initiation of a new project requiring full design.
- User requests a major new feature that requires significant architectural design/changes.
- Output of a `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001.md` indicating the design phase is next.

**Pre-requisites by Nova-Orchestrator (before delegating this phase to Nova-LeadArchitect):**
-   A clear overall project goal or feature request exists (potentially in ConPort `ProjectFeatures:[key]` or `FeatureScope:[key]`).
-   Relevant `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` are available in ConPort.
-   User has confirmed readiness to start the design phase.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase 1.1: Initial Planning & Decomposition by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Receive Phase Task & Initial Planning**
    *   **Action:** Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` (e.g., "Define system architecture for Project Alpha"), `Required_Input_Context` (e.g., user requirements summary, `ProjectConfig:ActiveConfig` JSON string), and `Expected_Deliverables_In_Attempt_Completion_From_Lead`.
    *   **ConPort:**
        *   Log a main `Progress` (integer `id`) item for this entire "System Design Phase".
        *   Create an internal plan (sequence of specialist subtasks). Log this plan to `CustomData LeadPhaseExecutionPlan:[YourPhaseProgressID]_ArchitectPlan` (key). Example plan items:
            1.  Define High-Level Architecture (LeadArchitect self, or SystemDesigner).
            2.  Detail Component A (SystemDesigner).
            3.  Detail Component B (SystemDesigner).
            4.  Define Core APIs (SystemDesigner).
            5.  Define Database Schema (SystemDesigner).
            6.  Log Key Architectural Decisions (LeadArchitect self, or ConPortSteward).
            7.  Review & Finalize Architecture Document (LeadArchitect self).
    *   **Output:** Internal plan ready. Main `Progress` (integer `id`) item created. `LeadPhaseExecutionPlan` (key) created.

**Phase 1.2: Sequential Execution of Specialist Subtasks by Nova-LeadArchitect**

*(Nova-LeadArchitect iterates through its `LeadPhaseExecutionPlan`, delegating one subtask at a time using `new_task` to the appropriate specialist, awaiting their `attempt_completion`, processing results, and then initiating the next subtask. Below are examples for a few key specialist subtasks within this phase.)*

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedSystemDesigner: Define High-Level Architecture**
    *   **Task:** "Define and document the high-level system architecture, main components, and their interactions for [Project/Feature Name]."
    *   **`new_task` message for Nova-SpecializedSystemDesigner:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Define system architecture for Project Alpha."
          Specialist_Subtask_Goal: "Draft high-level system architecture for Project Alpha."
          Specialist_Specific_Instructions:
            - "Based on requirements ([ConPort FeatureScope:Alpha_Scope_Key]), identify major system components (e.g., Web Frontend, API Gateway, User Service, Product Service, Database)."
            - "Create a textual or PlantUML/MermaidJS representation of component interactions."
            - "Log this as a new `CustomData SystemArchitecture:[ProjectAlpha_HighLevelArch_v1]` (key) entry. Include description and diagram source."
            - "Identify 2-3 key architectural decisions that need to be made (e.g., Monolith vs Microservices, DB choice, primary communication protocol) and list them as questions or preliminary thoughts in the `SystemArchitecture` entry's notes, for LeadArchitect to finalize."
          Required_Input_Context_For_Specialist:
            - Feature_Scope_Ref: { type: "custom_data", category: "FeatureScope", key: "Alpha_Scope_Key" }
            - ProjectConfig_Ref: { type: "custom_data", category: "ProjectConfig", key: "ActiveConfig" } # For tech stack hints
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "ConPort key of the created `SystemArchitecture` entry."
            - "List of 2-3 identified key architectural decision points."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged `SystemArchitecture` (key). Update `LeadPhaseExecutionPlan` (key) and specialist `Progress` (integer `id`). Make and log initial high-level `Decisions` (integer `id`) based on specialist's input and own expertise.

3.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedSystemDesigner: Detail API Endpoints**
    *   **Task:** "Define detailed API endpoint specifications for [Specific Service/Module] based on approved high-level design and decisions."
    *   **`new_task` message for Nova-SpecializedSystemDesigner:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Define system architecture for Project Alpha."
          Specialist_Subtask_Goal: "Define and document API endpoints for User Service of Project Alpha."
          Specialist_Specific_Instructions:
            - "Refer to `SystemArchitecture:[ProjectAlpha_UserServiceDesign_Key]` and `Decision:[Decision_ID_for_API_Style]`."
            - "Define endpoints for: User Registration, Login, GetProfile, UpdateProfile."
            - "For each endpoint, specify: HTTP method, path, request parameters/body schema, success response schema, common error response schemas (ref `SystemPatterns:[StdErrorPattern_ID]`)."
            - "Log each endpoint as a separate `CustomData APIEndpoints:[UserService_EndpointName_v1]` (key) entry."
          Required_Input_Context_For_Specialist:
            - UserService_Design_Ref: { type: "custom_data", category: "SystemArchitecture", key: "ProjectAlpha_UserServiceDesign_Key" }
            - API_Style_Decision_Ref: { type: "decision", id: [integer_id_of_decision] }
            - Standard_Error_Pattern_Ref: { type: "system_pattern", id: [integer_id_of_pattern] }
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "List of ConPort keys for all created `APIEndpoints` entries."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged `APIEndpoints` (key). Update plan and progress.

4.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Log Project Configuration**
    *   **(If Nova-Orchestrator indicated `ProjectConfig` or `NovaSystemConfig` are missing or need user consultation for this new project design phase).**
    *   **Task:** "Consult user (simulated via LeadArchitect providing pre-discussed values) and log/update `ProjectConfig:ActiveConfig` and `NovaSystemConfig:ActiveSettings` in ConPort."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```
        Subtask_Briefing:
          Overall_Architect_Phase_Goal: "Finalize initial project setup artifacts."
          Specialist_Subtask_Goal: "Log/Update ProjectConfig:ActiveConfig and NovaSystemConfig:ActiveSettings in ConPort."
          Specialist_Specific_Instructions:
            - "ProjectConfig values to log/update: [JSON object provided by LeadArchitect based on Orchestrator briefing/user discussion]."
            - "NovaSystemConfig values to log/update: [JSON object provided by LeadArchitect]."
            - "Use `log_custom_data` or `update_custom_data` for category `ProjectConfig`, key `ActiveConfig`."
            - "Use `log_custom_data` or `update_custom_data` for category `NovaSystemConfig`, key `ActiveSettings`."
            - "Ensure entries meet Definition of Done (all expected fields present, clearly structured)."
          Required_Input_Context_For_Specialist:
            - ProjectConfig_JSON_Values: "{...}"
            - NovaSystemConfig_JSON_Values: "{...}"
          Expected_Deliverables_In_Attempt_Completion_From_Specialist:
            - "Confirmation that `ProjectConfig:ActiveConfig` (key) was logged/updated."
            - "Confirmation that `NovaSystemConfig:ActiveSettings` (key) was logged/updated."
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Verify logs. Update plan and progress.

*(... Other specialist subtasks for DB design, component details, etc., would follow a similar pattern ...)*

**Phase 1.3: Final Review & Reporting by Nova-LeadArchitect**

5.  **Nova-LeadArchitect: Consolidate & Finalize**
    *   **Action:** Once all specialist subtasks in `LeadPhaseExecutionPlan` (key) are DONE:
        *   Review all created ConPort items (`SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key), `Decisions` (integer `id`), `ProjectConfig` (key), `NovaSystemConfig` (key)) for consistency, completeness (DoD), and correctness.
        *   Make any final `Decisions` (integer `id`) or update the main `SystemArchitecture:[OverallArchKey]` (key) entry.
        *   Update main phase `Progress` (integer `id`) to DONE.
        *   Update `active_context.state_of_the_union` (via `use_mcp_tool`) to reflect completion of design phase (e.g., "System architecture for Project Alpha defined, core APIs specified. Ready for development planning.").
    *   **Output:** Design phase completed. All relevant artifacts logged in ConPort. `active_context.state_of_the_union` updated.

6.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Prepare and send `attempt_completion` message including all `Expected_Deliverables_In_Attempt_Completion_From_Lead` specified by Nova-Orchestrator (summary, list of CRITICAL ConPort items created/updated with their correct ID/key types, new issues, critical outputs).

**Key ConPort Items Created/Updated by Nova-LeadArchitect's Team in this Workflow:**
-   `Progress` (integer `id`): For the overall phase and each specialist subtask.
-   `CustomData LeadPhaseExecutionPlan:[PhaseProgressID]_ArchitectPlan` (key): The LeadArchitect's internal plan.
-   `CustomData SystemArchitecture:[Key]` (key): High-level and detailed architectural designs.
-   `CustomData APIEndpoints:[Key]` (key): API specifications.
-   `CustomData DBMigrations:[Key]` (key): Database schema designs.
-   `Decisions` (integer `id`): Key architectural choices, technology selections.
-   `CustomData ProjectConfig:ActiveConfig` (key): If setting up for a new project.
-   `CustomData NovaSystemConfig:ActiveSettings` (key): If setting up for a new project.
-   `ActiveContext` (specifically `state_of_the_union` key update).
-   (Potentially) `ErrorLogs` (key): If specialists encounter issues they need to log.