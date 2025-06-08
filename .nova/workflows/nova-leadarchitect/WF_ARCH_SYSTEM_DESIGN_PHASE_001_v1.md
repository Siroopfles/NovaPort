# Workflow: System Design Phase Management (WF_ARCH_SYSTEM_DESIGN_PHASE_001_v1)

**Goal:** To manage and execute a complete system design phase for a new project or major feature, resulting in a documented architecture, key technical decisions, and defined interfaces, all logged in ConPort.

**Primary Actor:** Nova-LeadArchitect (receives phase task from Nova-Orchestrator)
**Primary Specialist Actors (delegated to by Nova-LeadArchitect):** Nova-SpecializedSystemDesigner, Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- Nova-Orchestrator delegates: "Define system architecture and detailed design for Project [ProjectName] / Feature [FeatureName]".
- Output of a `WF_ORCH_NEW_PROJECT_FULL_CYCLE_001_v1.md` or `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md` indicating the design phase is next.

**Pre-requisites by Nova-LeadArchitect (from Nova-Orchestrator's briefing):**
- A clear overall project goal or feature request exists (potentially in ConPort `CustomData ProjectFeatures:[key]` or `CustomData FeatureScope:[key]`).
- Relevant `CustomData ProjectConfig:ActiveConfig` (key) and `CustomData NovaSystemConfig:ActiveSettings` (key) are available in ConPort.
- User (via Nova-Orchestrator) has confirmed readiness to start the design phase.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase SD.1: Initial Planning & Decomposition by Nova-LeadArchitect**

1.  **Nova-LeadArchitect: Receive Phase Task & Initial Planning**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator. Understand `Phase_Goal` (e.g., "Define system architecture for Project Alpha"), `Required_Input_Context` (e.g., user requirements summary, `ProjectConfig:ActiveConfig` (key) JSON string), and `Expected_Deliverables_In_Attempt_Completion_From_Lead`.
        *   Log a main `Progress` (integer `id`) item for this entire "System Design Phase: [Project/Feature Name]" using `use_mcp_tool` (`tool_name: 'log_progress'`). Let this be `[DesignPhaseProgressID]`.
        *   Create an internal plan (sequence of specialist subtasks). Log this plan to `CustomData LeadPhaseExecutionPlan:[DesignPhaseProgressID]_ArchitectPlan` (key) using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Example plan items:
            1.  Define High-Level Architecture & Key Technologies (Delegate to SystemDesigner, review and log Decisions).
            2.  Detail Component A (Delegate to SystemDesigner).
            3.  Detail Component B (Delegate to SystemDesigner).
            4.  Define Core APIs for Component A & B (Delegate to SystemDesigner).
            5.  Define Core Database Schema(s) (Delegate to SystemDesigner).
            6.  Log Key Architectural Decisions (Delegate to ConPortSteward or self).
            7.  Review & Finalize Overall Architecture Document (LeadArchitect self).
    *   **Output:** Internal plan ready. Main `Progress` (`[DesignPhaseProgressID]`) item created. `LeadPhaseExecutionPlan` (key) created.

**Phase SD.2: Sequential Execution of Specialist Design Subtasks by Nova-LeadArchitect**

*(Nova-LeadArchitect iterates through its `LeadPhaseExecutionPlan`, delegating one subtask at a time using `new_task` to the appropriate specialist, awaiting their `attempt_completion`, processing results, and then initiating the next subtask.)*

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedSystemDesigner: Define High-Level Architecture**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Define and document the high-level system architecture, main components, their interactions, and propose key technology choices for [Project/Feature Name]."
    *   **`new_task` message for Nova-SpecializedSystemDesigner:**
        ```json
        {
          "Context_Path": "[ProjectName] (DesignPhase) -> HighLevelArchitecture (SystemDesigner)",
          "Overall_Architect_Phase_Goal": "Define system architecture for Project [ProjectName].",
          "Specialist_Subtask_Goal": "Draft high-level system architecture and propose key technology choices for Project [ProjectName].",
          "Specialist_Specific_Instructions": [
            "Based on requirements (e.g., `FeatureScope:[ProjectName_Scope_Key]`), identify major system components (e.g., Web Frontend, API Gateway, User Service, Product Service, Database).",
            "Create a textual or PlantUML/MermaidJS representation of component interactions and high-level data flows.",
            "Propose choices for key technologies (e.g., primary backend language/framework, database type, messaging queue if needed) based on `ProjectConfig:ActiveConfig` hints and project needs. Justify proposals.",
            "Log this as a new `CustomData SystemArchitecture:[ProjectName]_HighLevelArch_v1` (key) entry using `use_mcp_tool` (`tool_name: 'log_custom_data'`). Include description, diagram source, and technology proposals.",
            "Identify 2-3 critical architectural decisions that need final approval from LeadArchitect (e.g., Monolith vs. Microservices, specific DB product choice) and list them in your `attempt_completion` or in the `SystemArchitecture` notes."
          ],
          "Required_Input_Context_For_Specialist": {
            "Feature_Scope_Ref": { "type": "custom_data", "category": "FeatureScope", "key": "[ProjectName_Scope_Key]" },
            "ProjectConfig_Ref": { "type": "custom_data", "category": "ProjectConfig", "key": "ActiveConfig" }
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "ConPort key of the created `SystemArchitecture` entry.",
            "List of proposed key technologies and critical architectural decision points for LeadArchitect's review."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action after Specialist's `attempt_completion`:** Review logged `SystemArchitecture` (key). Make and log initial high-level `Decisions` (integer `id`) regarding technology choices and architectural style using `use_mcp_tool` (`tool_name: 'log_decision'`). Update `[DesignPhaseProgressID]_ArchitectPlan` and specialist `Progress` in ConPort.

3.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedSystemDesigner: Detail Specific Component & Its APIs**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Define detailed design for [Specific Component, e.g., UserService] and its API endpoints based on approved high-level architecture and decisions."
    *   **`new_task` message for Nova-SpecializedSystemDesigner (schematic):**
        ```json
        {
          "Context_Path": "[ProjectName] (DesignPhase) -> Detail [UserService] (SystemDesigner)",
          "Overall_Architect_Phase_Goal": "Define system architecture for Project [ProjectName].",
          "Specialist_Subtask_Goal": "Define detailed design for [UserService] and its API endpoints.",
          "Specialist_Specific_Instructions": [
            "Refer to `SystemArchitecture:[ProjectName_HighLevelArch_v1]` (key) and relevant `Decisions` (integer `id`s like `[DecisionID_for_API_Style]`).",
            "Detail internal structure of [UserService], its responsibilities, and interactions with other components. Log as `CustomData SystemArchitecture:[ProjectName_UserService_Detail_v1]` (key).",
            "Define all necessary API endpoints for [UserService] (e.g., CRUD for users, authentication). For each, specify: HTTP method, path, request/response schemas, error responses. Log each as `CustomData APIEndpoints:[UserService_EndpointName_v1]` (key)."
          ],
          "Required_Input_Context_For_Specialist": {
            "HighLevelArch_Ref": { "type": "custom_data", "category": "SystemArchitecture", "key": "[ProjectName_HighLevelArch_v1]" },
            "Relevant_Decisions_Refs": [{ "type": "decision", "id": "[integer_id_as_string]" }, ...]
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": [
            "ConPort key of the detailed `SystemArchitecture` entry for [UserService].",
            "List of ConPort keys for all created `APIEndpoints` entries for [UserService]."
          ]
        }
        ```
    *   **Nova-LeadArchitect Action:** Review. Update plan/progress. (Repeat for other components/services).

4.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedSystemDesigner: Define Database Schema(s)**
    *   **Actor:** Nova-LeadArchitect
    *   **Task:** "Define and document the database schema(s) required for [ProjectName / Specific Service]."
    *   **Briefing for SystemDesigner:** Refer to component designs, API data models, and `Decision` (integer `id`) on DB technology. Instruct to define tables, columns, types, relationships, and indexes. Log as `CustomData DBMigrations:[ProjectName_SchemaName_v1]` (key), with `value` containing DDL or structured schema description.
    *   **Nova-LeadArchitect Action:** Review. Update plan/progress.

5.  **Nova-LeadArchitect (or delegate to Nova-SpecializedConPortSteward): Log Consolidated Key Architectural Decisions**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Throughout the design phase, ensure all major architectural choices (tech stack, patterns, protocols, COTS product selections) are logged as formal `Decisions` (integer `id`) in ConPort with full rationale and implications (DoD met), using `use_mcp_tool` (`tool_name: 'log_decision'`). Link these decisions to relevant `SystemArchitecture` (key) entries using `use_mcp_tool` (`tool_name: 'link_conport_items'`).
    *   **Output:** Key `Decisions` (integer `id`s) logged and linked.

**Phase SD.3: Final Review & Reporting by Nova-LeadArchitect**

6.  **Nova-LeadArchitect: Consolidate & Finalize Design Documentation**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Once all specialist subtasks in `LeadPhaseExecutionPlan` (key) are DONE:
        *   Review all created ConPort items (`SystemArchitecture` (key), `APIEndpoints` (key), `DBMigrations` (key), `Decisions` (integer `id`)) for consistency, completeness (DoD), and correctness.
        *   To update a main `CustomData SystemArchitecture:[ProjectName]_OverallArch_v1` (key) document, first `get_custom_data`, modify the value to link to all artifacts, then `log_custom_data` to overwrite.
        *   Update main phase `Progress` (`[DesignPhaseProgressID]`) to DONE using `use_mcp_tool` (`tool_name: 'update_progress'`). Update description: "System design for [ProjectName] complete. Key artifacts: SystemArchitecture:[ProjectName]_OverallArch_v1, APIEndpoints tagged #[ProjectName]_APIs_v1."
        *   To update `active_context`, first `get_active_context` with `use_mcp_tool`, then construct a new value object with the modified `state_of_the_union`, and finally use `log_custom_data` with category `ActiveContext` and key `active_context` to overwrite.
    *   **Output:** Design phase completed. All relevant artifacts logged and interlinked in ConPort. `active_context.state_of_the_union` updated.

7.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Actor:** Nova-LeadArchitect
    *   **Action:** Prepare and send `attempt_completion` message including all `Expected_Deliverables_In_Attempt_Completion_From_Lead` specified by Nova-Orchestrator (summary, list of CRITICAL ConPort items created/updated with their correct ID/key types, new issues, critical outputs like key to overall architecture doc).

**Key ConPort Items Created/Updated by Nova-LeadArchitect's Team in this Workflow:**
- Progress (integer `id`): For the overall phase and each specialist subtask.
- CustomData LeadPhaseExecutionPlan:[DesignPhaseProgressID]_ArchitectPlan (key): The LeadArchitect's internal plan.
- CustomData SystemArchitecture:[Key] (key): High-level and detailed architectural designs.
- CustomData APIEndpoints:[Key] (key): API specifications.
- CustomData DBMigrations:[Key] (key): Database schema designs.
- Decisions (integer `id`): Key architectural choices, technology selections.
- ActiveContext (`state_of_the_union` key update).
- (Potentially) `ErrorLogs` (key): If specialists encounter issues they need to log.
- (Potentially) Links between these items using `link_conport_items`.