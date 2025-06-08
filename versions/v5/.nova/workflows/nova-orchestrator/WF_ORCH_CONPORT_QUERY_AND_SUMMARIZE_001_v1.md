# Workflow: ConPort Query and Summarization (WF_ORCH_CONPORT_QUERY_AND_SUMMARIZE_001_v1)

**Goal:** To answer a user's complex question or fulfill an information request by querying ConPort for relevant data and having Nova-FlowAsk summarize or analyze it.

**Primary Actor:** Nova-Orchestrator
**Delegated Utility Mode Actor:** Nova-FlowAsk

**Trigger / Recognition:**
- User asks a question that requires retrieving and synthesizing information from multiple ConPort entries or performing analysis beyond simple retrieval (e.g., "What were the key decisions leading to the current architecture of Module X?", "Summarize all `ErrorLogs` related to the Payment Gateway from the last month and their current status.", "Are there any `SystemPatterns` relevant to implementing a caching layer?").
- Nova-Orchestrator determines the query is best handled by focused retrieval and summarization rather than full phase delegation to a Lead.

**Pre-requisites by Nova-Orchestrator:**
- ConPort is `[CONPORT_ACTIVE]`.
- The user's question or information request is reasonably clear.

**Phases & Steps (managed by Nova-Orchestrator):**

**Phase CQS.1: Query Formulation & Delegation**

1.  **Nova-Orchestrator: Analyze User Request & Formulate ConPort Query Strategy**
    *   **Actor:** Nova-Orchestrator
    *   **Action:**
        *   Parse the user's question/request. Identify key entities, keywords, desired information type, and potential ConPort categories or item types.
        *   Log a `Progress` (integer `id`) item using `use_mcp_tool` (`tool_name: 'log_progress'`): "ConPort Query & Summarize: [Brief User Question/Topic]". Let this be `[QueryProgressID]`.
        *   Determine the best ConPort tools for Nova-FlowAsk to use (e.g., `get_custom_data` for specific keys, `search_decisions_fts` for keyword search in decisions, `semantic_search_conport` for conceptual queries, `get_linked_items` for relationships).
    *   **Output:** Strategy for ConPort query defined. `[QueryProgressID]` known.

2.  **Nova-Orchestrator -> Delegate to Nova-FlowAsk: Execute Query & Summarize**
    *   **Actor:** Nova-Orchestrator
    *   **Task:** "Retrieve relevant information from ConPort based on the specified query/criteria and provide a concise summary or answer to the user's original question."
    *   **`new_task` message for Nova-FlowAsk:**
        ```json
        {
          "Context_Path": "UserQuery (Orchestrator) -> ConPortQueryAndSummarize (FlowAsk)",
          "Subtask_Goal": "Answer user question: '[User_Question_Truncated]' by querying ConPort and summarizing findings.",
          "Mode_Specific_Instructions": [
            "User's full question/request: '[Full_User_Question_Or_Request]'.",
            "Based on the 'ConPort_Query_Strategy' below, use `use_mcp_tool` (`server_name: 'conport'`, `workspace_id: 'ACTUAL_WORKSPACE_ID'`) with the specified ConPort `tool_name`(s) and `arguments` to retrieve the necessary information.",
            "If multiple tools/steps are needed, execute them sequentially, using the output of one to inform the next.",
            "Analyze the retrieved ConPort data.",
            "Formulate a concise, direct answer to the user's original question. If the question asks for a summary, provide a structured summary (e.g., bullet points).",
            "If relevant, include clickable links to the ConPort items (e.g., `Decision:[ID]`, `CustomData Category:[Key]`) in your answer using Markdown format `[item_name](conport_item_type:item_identifier)`."
          ],
          "Required_Input_Context": {
            "Full_User_Question_Or_Request": "[...]",
            "ConPort_Query_Strategy": [ // Array of query steps for FlowAsk
              {
                "step_description": "Retrieve all decisions tagged with '#ModuleX' and '#architecture'.",
                "conport_tool_to_use": "get_decisions",
                "arguments": { "workspace_id": "ACTUAL_WORKSPACE_ID", "tags_filter_include_all": ["#ModuleX", "#architecture"], "limit": 10 }
              },
              {
                "step_description": "From the above decisions, extract rationales and summarize.",
                "analysis_needed": "Extract 'rationale' field, synthesize common themes."
              }
              // Or for semantic search:
              // {
              //   "step_description": "Find system patterns related to caching.",
              //   "conport_tool_to_use": "semantic_search_conport",
              //   "arguments": { "workspace_id": "ACTUAL_WORKSPACE_ID", "query_text": "system patterns for caching layer", "filter_item_types": ["system_pattern"], "top_k": 3 }
              // }
            ]
          },
          "Expected_Deliverables_In_Attempt_Completion": [
            "Concise answer or summary addressing the user's question/request.",
            "List of key ConPort items (Type:ID/Key) referenced in the answer."
          ]
        }
        ```
    *   **Nova-Orchestrator Action after Nova-FlowAsk's `attempt_completion`:**
        *   Review the answer/summary from Nova-FlowAsk.
        *   Update `[QueryProgressID]` status using `use_mcp_tool` (`tool_name: 'update_progress'`) to "DONE".

**Phase CQS.2: Present Information to User**

3.  **Nova-Orchestrator: Relay Answer/Summary to User**
    *   **Actor:** Nova-Orchestrator
    *   **Action:** Present the `result` from Nova-FlowAsk's `attempt_completion` directly to the user.
    *   If Nova-FlowAsk included suggestions for ConPort logging, Nova-Orchestrator may choose to:
        *   Discuss these with the user.
        *   Delegate a task to the appropriate Lead Mode to evaluate and potentially log the suggested item.
    *   Ask the user if their question is sufficiently answered or if they need further clarification.
    *   **Output:** User receives information. Workflow concludes if question answered, or may lead to new tasks/workflows.

**Key ConPort Items Involved:**
- Progress (integer `id`): For Orchestrator's tracking of this query task.
- (Reads by Nova-FlowAsk) Various ConPort items depending on the query (Decisions, CustomData, SystemPatterns, etc.).