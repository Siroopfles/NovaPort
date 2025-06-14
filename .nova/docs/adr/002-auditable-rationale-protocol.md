# 2. Auditable Rationale Protocol

*   **Status:** Accepted
*   **Date:** 2024-05-20 (Date from Changelog)

## Context and Problem Statement

A significant challenge in operating multi-agent AI systems is a lack of transparency and traceability. When a tool call failed or produced an unexpected result, it was often difficult to determine *why* the agent chose that specific tool with those specific parameters. This "black box" behavior made debugging inefficient and hindered our ability to analyze and improve agent performance systematically.

## Decision

We will implement a mandatory "Auditable Rationale Protocol" for all agents in the Nova System (`Orchestrator`, all `Leads`, and all `Specialists`).

The protocol requires that before **every** tool call, the agent MUST include a markdown-formatted `## Rationale` section within its `<thinking>` block. This section must concisely explain three things:

1.  **Goal:** What the agent is trying to achieve with this tool call.
2.  **Justification:** *Why* the agent chose this specific tool and its parameters, explicitly referencing its briefing, user request, or the result of a previous tool call.
3.  **Expectation:** What the agent expects the outcome of the tool call to be.

## Consequences

**Positive:**
*   **Complete Traceability:** This creates a "flight recorder" log of the agent's reasoning for every single action it takes.
*   **Simplified Debugging:** When a tool call fails, its rationale provides immediate context, making it much easier to diagnose the root cause of the agent's mistake.
*   **Enhanced System Analysis:** The collected rationales provide a rich dataset for analyzing agent behavior, identifying common failure patterns, and driving data-driven improvements to system prompts and workflows.
*   **Improved "Explainability" (XAI):** The system becomes inherently more explainable, as its decision-making process is explicitly documented in real-time.

**Negative:**
*   **Slight Increase in Token Usage:** Each tool call will now be preceded by a small amount of explanatory text, slightly increasing the token count for LLM interactions.
*   **Increased Prompt Verbosity:** The rule adds to the length and complexity of the system prompts.

This trade-off is considered highly favorable for the substantial gains in system observability and robustness.