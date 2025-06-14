# Workflow: System Retrospective and Improvement Proposal (WF_ORCH_SYSTEM_RETROSPECTIVE_AND_IMPROVEMENT_PROPOSAL_001_v1)

**Goal:** To systematically analyze ConPort data for signs of process friction, generate a structured analysis, and formulate a data-driven proposal for system improvement (e.g., workflow or prompt modifications) for user approval.

**Primary Orchestrator Actor:** Nova-Orchestrator
**Delegated Actors:** Nova-FlowAsk, Nova-LeadArchitect

**Trigger / Recognition:**

- User explicitly requests a system retrospective: "Run a system health check and suggest improvements," or "Let's do a retrospective on our processes."
- Can be configured in `NovaSystemConfig:ActiveSettings` to run periodically (e.g., after a major release is completed).

**Pre-requisites by Nova-Orchestrator:**

- A sufficient amount of project history (Progress, Decisions, ErrorLogs) exists in ConPort for meaningful analysis.
- `CustomData NovaSystemConfig:ProcessFrictionHeuristics_v1` is defined in ConPort. If not, this workflow cannot proceed and the Orchestrator should inform the user.

---

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase RETRO.1: Friction Analysis (Orchestrator -> Nova-FlowAsk)**

1.  **Nova-Orchestrator: Delegate Friction Analysis**
    - **Action:** Log main `Progress` (integer `id`) item: "System Retrospective Cycle - [Date]" using `use_mcp_tool`. Let this be `[RetroProgressID]`.
    - **Task:** "Delegate the analysis of process friction to Nova-FlowAsk based on predefined heuristics."
    - **`new_task` message for Nova-FlowAsk:**
      ```json
      {
        "Context_Path": "SystemRetrospective (Orchestrator) -> FrictionAnalysis (FlowAsk)",
        "Subtask_Goal": "Analyze ConPort for signs of process friction based on heuristics and return a structured JSON analysis object.",
        "Mode_Specific_Instructions": [
          "1. **Retrieve Heuristics:** Use `use_mcp_tool` (`tool_name: 'get_custom_data'`) to retrieve the analysis queries from `CustomData NovaSystemConfig:ProcessFrictionHeuristics_v1`. If this item does not exist, immediately fail your subtask and report this in your `attempt_completion`.",
          "2. **Execute Analysis:** Sequentially execute the analysis steps defined in the `heuristics` array of the retrieved object. This will involve using various ConPort `use_mcp_tool` read/search calls (e.g., `get_progress`, `search_custom_data_value_fts` on `ErrorLogs`).",
          "3. **Synthesize Findings:** Consolidate your findings from all heuristic queries into a single, structured JSON object with the keys `analysis_summary`, `key_findings` (an array of objects, where each object details a specific finding), and `potential_root_cause_hypothesis`.",
          "4. **Return Result:** Your final `attempt_completion` result MUST be this structured JSON object. Do NOT log it to ConPort yourself. Do NOT add any conversational text, only the JSON object."
        ],
        "Required_Input_Context": {
          "Heuristics_Config_Ref": {
            "type": "custom_data",
            "category": "NovaSystemConfig",
            "key": "ProcessFrictionHeuristics_v1"
          }
        },
        "Expected_Deliverables_In_Attempt_Completion": [
          "A single, raw, structured JSON object containing the complete analysis."
        ]
      }
      ```

**Phase RETRO.2: Improvement Proposal (Orchestrator -> Nova-LeadArchitect)**

2.  **Nova-Orchestrator: Log Analysis and Delegate Proposal**
    - **Action:**
      - Receive the JSON analysis object from Nova-FlowAsk's `attempt_completion`.
      - Generate a timestamp (e.g., `20240517_103000`).
      - Use `use_mcp_tool` (`tool_name: 'log_custom_data'`) to log this object to ConPort as `CustomData RetrospectiveAnalysis:[Timestamp]`. Let the key be `[AnalysisKey]`.
    - **Task:** "Delegate the creation of a formal improvement proposal to Nova-LeadArchitect based on the logged analysis."
    - **`new_task` message for Nova-LeadArchitect:**
      ```json
      {
        "Context_Path": "SystemRetrospective (Orchestrator) -> ImprovementProposal (LeadArchitect)",
        "Overall_Project_Goal": "Improve system efficiency through self-analysis.",
        "Phase_Goal": "Analyze the process friction report `[AnalysisKey]` and formulate a concrete, actionable improvement proposal logged as a ConPort `Decision`.",
        "Lead_Mode_Specific_Instructions": [
          "1. Your team is to retrieve and study the friction analysis report from `CustomData RetrospectiveAnalysis:[AnalysisKey]` using `use_mcp_tool` (`tool_name: 'get_custom_data'`).",
          "2. Instruct your team to perform a focused `ImpactAnalysis` on the findings. This should result in a new `ImpactAnalyses` item in ConPort.",
          "3. Based on the analysis, formulate a concrete proposal for system improvement (e.g., 'Modify prompt X', 'Add pre-flight check to workflow Y').",
          "4. Log this proposal as a new, detailed `Decision` (integer `id`) in ConPort. The `summary` must be the proposal itself, and the `rationale` must reference both `[AnalysisKey]` and the key of the new `ImpactAnalyses` item, explaining how the change addresses the identified friction."
        ],
        "Required_Input_Context": {
          "Friction_Analysis_Report_Key": "[AnalysisKey]"
        },
        "Expected_Deliverables_In_Attempt_Completion_From_Lead": [
          "The integer `id` of the newly created `Decision` item containing the improvement proposal."
        ]
      }
      ```

**Phase RETRO.3: User Approval (Orchestrator)**

3.  **Nova-Orchestrator: Present Proposal to User**
    - **Action:**
      - Receive the `Decision` ID from Nova-LeadArchitect's `attempt_completion`.
      - Use `use_mcp_tool` (`tool_name: 'get_decisions'`) to retrieve the proposal summary from the `Decision`.
      - Use `ask_followup_question` to present the proposal to the user for approval.
        - **Question:** "The system retrospective has identified a potential improvement: '[Proposal Summary from Decision]'. The full details are in ConPort `Decision:[ID]`. Do you approve implementing this change?"
        - **Suggestions:** ["Yes, I approve the change.", "No, reject the change.", "I have questions about the implications."]

**Phase RETRO.4: Closure and Follow-up**

4.  **Nova-Orchestrator: Finalize Cycle**
    - **Action:**
      - Based on user response, use `use_mcp_tool` (`tool_name: 'update_decision'`) to update the `status` of the `Decision` to `APPROVED` or `REJECTED`.
      - **If APPROVED:** Delegate a new task to `Nova-LeadArchitect` to _implement_ the change (e.g., by executing `WF_ARCH_NEW_WORKFLOW_DEFINITION_001_v1.md` or `WF_ARCH_SYSTEM_PROMPT_UPDATE_PROPOSAL_001_v1.md`), providing the `Decision` ID as context.
      - **If REJECTED:** Inform the user the proposal has been recorded but will not be actioned.
      - Update main `Progress` (`[RetroProgressID]`) to `DONE`.

## Failure Scenarios

- **Scenario:** `CustomData NovaSystemConfig:ProcessFrictionHeuristics_v1` is not found.
  - **Orchestrator Action:** `FlowAsk`'s subtask will fail. The Orchestrator will catch this, inform the user "Cannot run retrospective: The `ProcessFrictionHeuristics_v1` configuration is missing from `NovaSystemConfig` in ConPort.", and halt this workflow.
- **Scenario:** `Nova-FlowAsk` finds no significant friction.
  - **Orchestrator Action:** `FlowAsk`'s `attempt_completion` will return an empty `key_findings` array. The Orchestrator logs this, informs the user "No significant process friction found based on current heuristics," and concludes the workflow successfully.
- **Scenario:** `Nova-LeadArchitect` cannot formulate a concrete proposal from the analysis.
  - **Orchestrator Action:** `LeadArchitect`'s `attempt_completion` should state this clearly. The Orchestrator informs the user, logs the analysis as "Needs further human review," and concludes the workflow.
