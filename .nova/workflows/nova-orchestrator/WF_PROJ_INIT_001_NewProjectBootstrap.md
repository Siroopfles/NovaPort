# Workflow: New Project Bootstrap (WF_PROJ_INIT_001_NewProjectBootstrap.md)

**Goal:** To establish the foundational ConPort entries and basic directory structure for an entirely new project, guided by Nova-LeadArchitect based on initial user input.

**Primary Orchestrator Actor:** Nova-LeadArchitect (Tasked by Nova-Orchestrator, typically during `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md` if no ConPort DB exists and user agrees to initialize).
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward, Nova-SpecializedSystemDesigner (for initial dir structure thoughts).

**Trigger / Recognition:**
- Nova-Orchestrator delegates this task to Nova-LeadArchitect when initializing a brand-new workspace where `context_portal/context.db` does not exist, and the user has agreed to proceed with a new project setup.

**Pre-requisites by Nova-LeadArchitect (from Nova-Orchestrator's briefing):**
- `ACTUAL_WORKSPACE_ID` is known.
- User has provided a `UserProvided_ProjectName` and `UserProvided_MainGoal`.
- ConPort DB has just been (or is about to be) created by the ConPort server itself upon first tool use.

**Phases & Steps (managed by Nova-LeadArchitect within its single active task from Nova-Orchestrator):**

**Phase BS.1: Initial ConPort Entry Creation**

1.  **Nova-LeadArchitect: Plan Bootstrap & Log Initial Progress**
    *   **Action:**
        *   Parse `Subtask Briefing Object` from Nova-Orchestrator.
        *   Log main `Progress` (integer `id`) for this bootstrap phase: "Project Bootstrap: [ProjectName]". Let this be `[BootstrapProgressID]`.
        *   Create internal plan (`CustomData LeadPhaseExecutionPlan:[BootstrapProgressID]_ArchitectPlan` (key)). Plan items:
            1.  Create Initial ProductContext (ConPortSteward).
            2.  Create Initial ActiveContext (ConPortSteward).
            3.  Log Initial High-Level Decisions (LeadArchitect or ConPortSteward).
            4.  Draft Initial ProjectRoadmap (LeadArchitect or SystemDesigner).
            5.  Suggest Basic Directory Structure (SystemDesigner).
            6.  (Optional) Log placeholder ProjectConfig/NovaSystemConfig if not handled by separate WF (ConPortSteward).
    *   **Output:** Plan ready. `[BootstrapProgressID]` known.

2.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Create Initial `ProductContext`**
    *   **Task:** "Create the initial `ProductContext` entry in ConPort for [ProjectName]."
    *   **`new_task` message for Nova-SpecializedConPortSteward:**
        ```json
        {
          "Context_Path": "[ProjectName] (Bootstrap) -> Create ProductContext (ConPortSteward)",
          "Overall_Architect_Phase_Goal": "Bootstrap new project [ProjectName] in ConPort.",
          "Specialist_Subtask_Goal": "Create and log the initial ProductContext for Project [ProjectName].",
          "Specialist_Specific_Instructions": [
            "Based on 'UserProvided_MainGoal' and 'UserProvided_ProjectName' from LeadArchitect's context:",
            "Formulate a basic ProductContext JSON object. Example:",
            "  { \"project_name\": \"[UserProvided_ProjectName]\",",
            "    \"main_goal\": \"[UserProvided_MainGoal]\",",
            "    \"high_level_features_envisioned\": [\"Feature A (brief description)\", \"Feature B (brief description)\"],",
            "    \"target_audience_profile_hint\": \"[e.g., General Consumers, Enterprise Users]\",",
            "    \"key_differentiators_ envisioned\": [] }",
            "Use `use_mcp_tool` (`tool_name: 'log_custom_data'`, `arguments: {'workspace_id': 'ACTUAL_WORKSPACE_ID', 'category': 'ProductContext', 'key': 'product_context', 'value': { /* your_json_object */ }}`) to log this. This will create or overwrite the entry."
          ],
          "Required_Input_Context_For_Specialist": {
            "UserProvided_ProjectName": "[...]",
            "UserProvided_MainGoal": "[...]"
          },
          "Expected_Deliverables_In_Attempt_Completion_From_Specialist": ["Confirmation that ProductContext was created/updated."]
        }
        ```
    *   **Nova-LeadArchitect Action:** Verify. Update plan/progress.

3.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedConPortSteward: Create Initial `ActiveContext`**
    *   **Task:** "Create the initial `ActiveContext` entry in ConPort for [ProjectName]."
    *   **Briefing:** Instruct ConPortSteward to log a basic `ActiveContext` with `state_of_the_union`: "Project [ProjectName] initialized. Awaiting initial configurations and detailed design." and an empty `open_issues` list, using `use_mcp_tool` (`tool_name: 'log_custom_data'`, `category: 'ActiveContext'`, `key: 'active_context'`).
    *   **Nova-LeadArchitect Action:** Verify. Update plan/progress.

4.  **Nova-LeadArchitect: Log Initial High-Level Decisions**
    *   **Action:** Based on initial project goal, log 1-2 very high-level `Decisions` (integer `id`) using `use_mcp_tool` (`tool_name: 'log_decision'`).
        *   Example Decision 1: "Adopt Nova Standard Project Lifecycle." Rationale: "Leverage defined best practices."
        *   Example Decision 2: "Prioritize Core Feature X for MVP." Rationale: "Based on user's stated main goal."
    *   **Output:** Initial `Decision` (integer `id`s) logged.

5.  **Nova-LeadArchitect -> Delegate to Nova-SpecializedSystemDesigner: Draft Initial `ProjectRoadmap` & Suggest Directory Structure**
    *   **Task:** "Draft a very high-level `ProjectRoadmap` (key) and suggest a basic directory structure."
    *   **Briefing:** Instruct SystemDesigner to:
        *   Create a `CustomData ProjectRoadmap:[ProjectName]_InitialRoadmap_v0_1` (key) entry. Value: `{ "phases": [{"name": "Initial Design & Setup", "goal": "Define architecture, setup configs", "timeline_hint": "Sprint 0-1"}, {"name": "MVP Feature Development", "goal": "Implement core features A, B", "timeline_hint": "Sprint 2-4"}], "overall_mvp_target_hint": "End of Sprint 4" }`. Log via `use_mcp_tool`.
        *   Suggest a basic directory structure (e.g., `src/`, `docs/`, `tests/`, `.nova/`) for the project type (hint from `ProjectConfig` if available, or generic). This is a textual suggestion in their `attempt_completion`, not actual file creation yet.
    *   **Nova-LeadArchitect Action:** Review roadmap and structure. The actual creation of directories can be a separate step if needed, or part of the first dev task. For now, the suggestion is noted.

**Phase BS.2: Basic Configuration Setup (Often triggers separate WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md)**

6.  **Nova-LeadArchitect: Trigger Project & Nova System Configuration Setup**
    *   **Action:** At this point, LeadArchitect would typically initiate the process detailed in `WF_ARCH_PROJECT_CONFIG_SETUP_001_v1.md` (or be instructed to do so by Nova-Orchestrator). This involves consulting the user (via Orchestrator) for `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) values and delegating their logging to Nova-SpecializedConPortSteward.
    *   **Output:** `ProjectConfig:ActiveConfig` (key) and `NovaSystemConfig:ActiveSettings` (key) are created in ConPort.

**Phase BS.3: Finalize Bootstrap**

7.  **Nova-LeadArchitect: Consolidate & Finalize Bootstrap**
    *   **Action:**
        *   Update main `Progress` (`[BootstrapProgressID]`) to DONE. Description: "ConPort bootstrapped with initial ProductContext, ActiveContext, Decisions, Roadmap. ProjectConfig & NovaSystemConfig established."
    *   **Output:** Bootstrap phase documented as complete.

8.  **Nova-LeadArchitect: `attempt_completion` to Nova-Orchestrator**
    *   **Action:** Report completion of bootstrap, listing key ConPort items created (ProductContext, ActiveContext keys/IDs, initial Decision IDs, ProjectRoadmap key, ProjectConfig key, NovaSystemConfig key).

**Key ConPort Items Created:**
- ProductContext (key 'product_context')
- ActiveContext (key 'active_context')
- Initial Decisions (integer `id`s)
- Progress (integer `id`s) for bootstrap & subtasks
- CustomData ProjectRoadmap:[ProjectName]_InitialRoadmap_v0_1 (key)
- CustomData LeadPhaseExecutionPlan:[BootstrapProgressID]_ArchitectPlan (key)
- CustomData ProjectConfig:ActiveConfig (key) (via triggered workflow)
- CustomData NovaSystemConfig:ActiveSettings (key) (via triggered workflow)