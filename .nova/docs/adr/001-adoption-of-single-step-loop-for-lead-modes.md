# 1. Adoption of Single-Step Loop for Lead Modes

- **Status:** Accepted
- **Date:** 2024-05-20 (Date from Changelog)

## Context and Problem Statement

The previous execution model for Lead Modes involved creating a large, comprehensive, upfront plan for their entire assigned phase. This plan would then be executed sequentially. This approach proved to be brittle and error-prone in practice. A single misunderstanding early in the planning phase could cascade into a sequence of incorrect or inefficiently bundled specialist sub-tasks. The complexity of these multi-step sub-tasks also made the system's behavior difficult to predict and debug, leading to a higher rate of stalled loops and failed phase executions.

## Decision

We will replace the upfront planning model with a "Single-Step Execution Loop" for all Lead Modes (`-LeadArchitect`, `-LeadDeveloper`, `-LeadQA`). The new protocol is as follows:

1.  Upon receiving a phase-task, the Lead creates a **coarse-grained** `LeadPhaseExecutionPlan` with only 2-4 major milestones and logs it to ConPort.
2.  The Lead then enters an iterative loop. In each iteration, the Lead MUST:
    a. Focus on the current milestone.
    b. Determine the **single, next, most logical, and atomic** specialist sub-task required to make progress.
    c. Delegate only that single, atomic sub-task to the appropriate specialist via `new_task`.
    d. Await the specialist's `attempt_completion`, process the result, update ConPort, and handle any suggestions.
    e. Loop back to determine the very next action.

## Consequences

**Positive:**

- **Increased Reliability:** By breaking work into the smallest possible atomic units, the chance of a complex, error-prone delegation is dramatically reduced.
- **Enhanced Predictability:** The agent's "cognitive window" is small and focused, making its next action much easier to predict and debug.
- **Improved Adaptability:** The system can adapt to the results of one sub-task before deciding on the next, allowing for more dynamic and intelligent execution paths.
- **Simplified Specialist Briefings:** Briefings for specialists become simpler and more focused, reducing the chance of misinterpretation.

**Negative:**

- **Potential for Increased Overhead:** For very simple, linear phases, this model might introduce slightly more delegation overhead (more `new_task` calls) compared to a single, bundled instruction. This is considered an acceptable trade-off for the massive gains in robustness.
