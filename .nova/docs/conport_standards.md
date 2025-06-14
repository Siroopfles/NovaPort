# Nova System - ConPort Data Standards

This document defines the standard structures and guidelines for key `CustomData` entities within the Context Portal (ConPort). Adherence to these standards is mandatory for all Nova modes to ensure data consistency, quality, and interoperability.

## 1. `ErrorLogs` (R20)

**Category:** `ErrorLogs`
**Key Format:** `EL_[YYYYMMDD]_[Symptom/Module]_[Identifier]` e.g., `EL_20240120_LoginFail_AuthSvc`
**Purpose:** To log a unique, verifiable defect, bug, or system error.

**JSON Value Structure (`ErrorLogs_v1` Template):**

```json
{
  "schema_version": "1.0",
  "error_id_human": "PROJ-BUG-123",
  "timestamp_reported": "YYYY-MM-DDTHH:MM:SSZ",
  "status": "OPEN | INVESTIGATING | AWAITING_FIX | AWAITING_VERIFICATION | RESOLVED | REOPENED | FAILED_VERIFICATION | CLOSED_WONTFIX | CLOSED_DUPLICATE",
  "severity": "CRITICAL | HIGH | MEDIUM | LOW | TRIVIAL",
  "priority": "HIGHEST | HIGH | MEDIUM | LOW | LOWEST",
  "summary": "A concise, one-line summary of the issue.",
  "description": "A more detailed description of the problem and its observed impact.",
  "environment_snapshot": {
    "application_version": "v1.2.3-rc1",
    "test_environment_url": "https://staging.example.com",
    "browser": "Chrome 120.0",
    "os": "macOS Sonoma",
    "details": "Any other relevant environment details."
  },
  "reproduction_steps": [
    "1. Navigate to the login page.",
    "2. Enter a valid username.",
    "3. Enter a password with a special character (e.g., '@').",
    "4. Click the 'Login' button."
  ],
  "expected_behavior": "The user should be logged in successfully or receive a clear error message about invalid characters if they are not allowed.",
  "actual_behavior": "The application hangs, and a 500 Internal Server Error is returned to the client.",
  "attachments": [
    {
      "type": "log_file",
      "path": ".nova/reports/qa/logs/login_fail_20240120.log"
    },
    {
      "type": "screenshot_description",
      "description": "Screenshot of the browser console showing the 500 error."
    }
  ],
  "initial_reporter_mode_slug": "nova-specializedtestexecutor",
  "source_task_progress_id": "P-123",
  "investigation_notes": "Initial investigation shows a potential SQL injection vulnerability in the login handler. More analysis needed.",
  "root_cause_analysis": "Root cause confirmed: Improper sanitization of the password field in `auth_service.py` at line 95 leads to a database query error.",
  "fix_details": {
    "fix_commit_sha": "a1b2c3d4e5f6",
    "fixed_in_version": "v1.2.4",
    "fix_description": "Added proper input sanitization and parameterized queries.",
    "related_decision_id": "78"
  },
  "verification_notes": "Verified on build v1.2.4 in staging. Original steps no longer cause an error. Login with special characters now works as expected. No regressions found in related login flows.",
  "related_conport_items": [
    {
      "type": "decision",
      "id_or_key": "D-75",
      "relationship": "potentially_caused_by"
    },
    {
      "type": "custom_data",
      "id_or_key": "TestPlans:LoginScenarios_v1",
      "relationship": "tested_by"
    }
  ]
}
```

---

## 2. `LessonsLearned` (R21)

**Category:** `LessonsLearned`
**Key Format:** `LL_[YYYYMMDD]_[Topic]` e.g., `LL_20240120_AuthServiceDeadlock`
**Purpose:** To capture valuable insights from events (e.g., major bugs, successful releases, process failures) to improve future work.

**JSON Value Structure (`LessonsLearned_v1` Template):**

```json
{
  "schema_version": "1.0",
  "title": "Database Deadlock in Authentication Service during High Load",
  "date_logged": "YYYY-MM-DD",
  "source_event_description": "During pre-release performance testing for v1.3, the system experienced critical database deadlocks when simulating over 500 concurrent login attempts.",
  "root_cause_analysis_summary": "The root cause was identified as two separate database transactions (one for updating `last_login_timestamp`, another for logging the login event) acquiring locks on the same user row in a non-deterministic order, leading to a classic deadlock.",
  "impact_of_event": "This was a CRITICAL issue that blocked the v1.3 release. If it occurred in production, it would have resulted in widespread login failures.",
  "resolution_summary": "The two transactions were combined into a single, atomic database transaction within the `handle_login` function. See `Decision:D-88` for details.",
  "lessons_learned": [
    "All database operations on the same logical entity (e.g., a 'user') within a single business process should be encapsulated in a single transaction to prevent race conditions and deadlocks.",
    "Our performance test suite needs a specific scenario to test high-concurrency writes on critical path tables like `users`."
  ],
  "preventative_actions_or_recommendations": [
    {
      "action": "Update the 'Database Transaction Management' `SystemPattern` to include a rule about atomic business processes.",
      "owner_hint": "Nova-LeadArchitect",
      "status": "TODO"
    },
    {
      "action": "Add a new high-concurrency login test case to the performance test suite.",
      "owner_hint": "Nova-LeadQA",
      "status": "TODO"
    }
  ],
  "related_conport_items": [
    {
      "type": "custom_data",
      "id_or_key": "ErrorLogs:EL_20240119_AuthDeadlock",
      "relationship": "documents_learnings_for"
    },
    {
      "type": "decision",
      "id_or_key": "D-88",
      "relationship": "resulted_from"
    }
  ]
}
```

---

## 3. `ProjectStandards`

**Category:** `ProjectStandards`
**Key Format:** `DefaultDoD`, `DefaultDoR`
**Purpose:** To define project-wide standards for "Definition of Done" and "Definition of Ready".

**JSON Value Structure (`DefaultDoD_v1` Template):**

```json
{
  "schema_version": "1.0",
  "standard_name": "Default Definition of Done",
  "applies_to": "Features, User Stories, Major Components",
  "criteria": [
    "Code implemented per specifications and architectural design.",
    "Code adheres to standards in `ProjectConfig:ActiveConfig.code_style_guide_ref` and passes all linters.",
    "Unit and integration tests are written and achieve configured coverage targets (from `ProjectConfig:ActiveConfig.testing_preferences.coverage_thresholds`).",
    "All tests (unit, integration, regression) are passing.",
    "All new/modified code has been peer-reviewed (simulated via `WF_DEV_CODE_REVIEW_SIMULATION_001_v1.md`).",
    "Technical documentation (inline and module-level) is complete and accurate.",
    "All related ConPort items (Decisions, CodeSnippets, etc.) are logged.",
    "Feature passes all QA tests and meets `AcceptanceCriteria`.",
    "No new CRITICAL or HIGH severity bugs have been introduced."
  ]
}
```
