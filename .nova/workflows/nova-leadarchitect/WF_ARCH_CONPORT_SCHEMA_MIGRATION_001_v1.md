# Workflow: ConPort Schema Migration (WF_ARCH_CONPORT_SCHEMA_MIGRATION_001_v1)

**Goal:** To migrate all ConPort `CustomData` items within a specific category from an old schema version to a new one, ensuring data integrity and consistency.

**Primary Actor:** Nova-LeadArchitect
**Primary Specialist Actor (delegated to by Nova-LeadArchitect):** Nova-SpecializedConPortSteward

**Trigger / Recognition:**
- A `CustomData ConPortSchema:[key]` entry proposing a schema change has its status updated to `Approved`.
- Nova-LeadArchitect determines that existing data in the affected category needs to be back-filled or transformed.

**Reference Milestones for your Single-Step Loop:**

**Milestone SM.1: Plan & Execute Migration**
*   **Goal:** Retrieve all items from the target category, apply the transformation logic, and update them in ConPort.
*   **Suggested Specialist Sequence & Briefing Guidance:**
    1.  **LeadArchitect Action:**
        *   Log a main `Progress` item for this migration task.
        *   Log a `Decision` to formally start the migration, referencing the approved `ConPortSchema` proposal.
        *   Clearly define the transformation logic (e.g., "Rename field X to Y", "Add new field Z with default value 'abc'").
    2.  **Delegate to `Nova-SpecializedConPortSteward`:**
        *   **Subtask Goal:** "Execute the schema migration for `CustomData` category '[CategoryName]' based on the provided transformation logic."
        *   **Briefing Details:** Instruct the specialist to:
            *   Log their own `Progress` item.
            *   **Retrieve All Items:** Use `get_custom_data` to fetch all items from the target category.
            *   **Transform Data:** In their internal logic, iterate through the retrieved items and apply the `Transformation_Logic` to each `value` object.
            *   **Batch Update Items:** Use the `batch_log_items` ConPort tool to efficiently write all the updated items back to ConPort in a single call. This will overwrite the old items.
            *   **Verification:** Retrieve a small sample (2-3 items) to confirm the new schema was applied correctly.
            *   Return the number of items migrated and a confirmation of the verification step.

**Milestone SM.2: Finalize & Report**
*   **Goal:** Close out the migration process and document its completion.
*   **Suggested Lead Action:**
    1.  Review the specialist's report to confirm the migration was successful.
    2.  Delegate a task to `Nova-SpecializedConPortSteward` to update the status of the original `ConPortSchema:[key]` proposal item to 'Implemented'.
    3.  Update the main `Progress` item for the migration to 'DONE'.
    4.  Report completion of the phase to `Nova-Orchestrator` in your `attempt_completion`.

**Key ConPort Items Involved:**
- Progress (integer `id`)
- Decisions (integer `id`)
- ConPortSchema (key) (read for schema, update status)
- CustomData items within the target category (read and batch updated)