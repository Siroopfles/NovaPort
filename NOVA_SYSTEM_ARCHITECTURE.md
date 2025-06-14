# Nova System: An Architectural Deep Dive & Visualizations

## Introduction

This document provides a detailed architectural analysis of the Nova System, a sophisticated, AI-driven framework designed for managing and executing complex software development projects. The system is built upon a hierarchical model of specialized AI agents (referred to as "modes") that collaborate under the direction of a central `Nova-Orchestrator`.

The core principles of the Nova System are structured project execution, explicit knowledge retention, and efficient task delegation. Its memory and "single source of truth" is the **Context Portal (ConPort)**, a project-specific knowledge graph. All operations are guided by **Workflows**, which are standardized, documented processes stored as Markdown files.

The following visualizations dissect the system's key components, data structures, and interaction patterns to provide a clear and comprehensive understanding of its inner workings.

---

### 1. High-Level System Architecture

This C4-style context diagram provides a bird's-eye view of the Nova System's ecosystem. It illustrates the primary components and their relationships, showing how the system interacts with the user and its core data layer within its execution environment.

- **User & Environment:** The `User` interacts with the system through a `Roo Code Execution Environment` (like the VS Code extension), which is responsible for activating the appropriate AI modes.
- **Nova System Core:** The `Nova-Orchestrator` is the central point of contact, delegating entire project phases to `Lead Modes`. These Leads, in turn, break down phases into atomic sub-tasks for their teams of `Specialized Modes`.
- **Data & Knowledge Layer:** All modes interact with the `Context Portal (ConPort)`, the system's central memory. ConPort utilizes `SQLite` for structured data and `ChromaDB` for vector embeddings, enabling powerful semantic search and Retrieval Augmented Generation (RAG).

```mermaid
graph TD
    subgraph "User & Environment Layer"
        User(👤<br/>User)
        RooEnv["Roo Code<br/>Execution Environment"]
    end

    subgraph "Nova System Core"
        direction LR
        Orchestrator(Nova-Orchestrator)
        subgraph "Lead & Specialist Teams"
            LeadModes["Lead Modes<br/>(Architect, Dev, QA)"]
            SpecializedModes["Specialized Modes<br/>(Implementer, Steward, etc.)"]
        end
    end

    subgraph "Data & Knowledge Layer"
        ConPort["Context Portal (ConPort)<br/><i>Project Memory</i>"]
        subgraph "Database Backend"
            SQLite["SQLite<br/><i>Structured Data</i>"]
            ChromaDB["ChromaDB<br/><i>Vector Embeddings for RAG</i>"]
        end
    end

    User -- "User Prompt / Request" --> RooEnv
    RooEnv -- "Activates & Executes" --> Orchestrator
    Orchestrator -- "Delegates Phase" --> LeadModes
    LeadModes -- "Delegates Sub-task" --> SpecializedModes

    SpecializedModes -- "Reads/Writes Project Data" --> ConPort
    LeadModes -- "Reads/Writes Project Data" --> ConPort
    Orchestrator -- "Reads/Writes Project Data" --> ConPort

    ConPort -- "Stores/Retrieves Structured Data" --> SQLite
    ConPort -- "Stores/Retrieves Vectors" --> ChromaDB
```

---

### 2. Context Portal (ConPort) Data Model

This Entity Relationship Diagram (ERD) reveals the structure of the system's memory. It models the core data entities within ConPort's SQLite database, showcasing how project knowledge is captured and organized. The `ContextLinks` table is the critical component that transforms these entities from isolated data points into a richly interconnected knowledge graph, enabling complex queries and contextual understanding.

- **Key Entities:** `ProductContext` and `ActiveContext` hold high-level and session-specific state. `Decisions` and `Progress` track strategic choices and task status. `CustomData` is a flexible key-value store for everything from `ProjectConfig` to `ErrorLogs`.
- **The Knowledge Graph:** The `ContextLinks` entity explicitly defines relationships (e.g., "implements," "tested_by," "caused_by") between any two items in the database, forming the graph's edges.

```mermaid
erDiagram
    ProductContext {
        string key PK
        json content
        timestamp created_at
    }
    ActiveContext {
        string key PK
        json value
        timestamp created_at
    }
    Decisions {
        int id PK
        string summary
        text rationale
        text implementation_details
        string tags
    }
    Progress {
        int id PK
        string description
        string status
        int parent_id FK
    }
    CustomData {
        string category PK
        string key PK
        json value
    }
    ContextLinks {
        int id PK
        string source_item_type
        string source_item_id
        string target_item_type
        string target_item_id
        string relationship_type
    }

    Progress }|--o{ Progress : "is parent of"
    ProductContext ||--o{ ContextLinks : "can be linked"
    ActiveContext ||--o{ ContextLinks : "can be-linked"
    Decisions ||--o{ ContextLinks : "can be linked"
    Progress ||--o{ ContextLinks : "can be linked"
    CustomData ||--o{ ContextLinks : "can be linked"
```

---

### 3. Feature Implementation Lifecycle

This sequence diagram visualizes the end-to-end process of implementing a new feature, as defined in `WF_ORCH_EXISTING_PROJECT_NEW_FEATURE_E2E_001_v1.md`. It highlights the formal, hierarchical delegation from the user's request down to the specialist level. The diagram emphasizes the structured communication protocol, where `new_task` calls carry a formal `Subtask Briefing Object` and `attempt_completion` calls serve as formal reports. ConPort is actively read from and written to at every stage, acting as the shared state manager.

```mermaid
sequenceDiagram
    participant User
    participant Orchestrator as Nova-Orchestrator
    participant LeadDev as Nova-LeadDeveloper
    participant Implementer as SpecializedFeatureImplementer
    participant ConPort

    User->>Orchestrator: Request: "Add user profile page"
    activate Orchestrator
    Note right of Orchestrator: Initiates WF_ORCH_EXISTING_PROJECT...
    Orchestrator->>LeadDev: new_task (Briefing for Development Phase)
    deactivate Orchestrator

    activate LeadDev
    LeadDev->>ConPort: log_progress("Start Dev Phase")
    LeadDev->>Implementer: new_task (Briefing for 'Implement UI Component')

    activate Implementer
    Implementer->>ConPort: log_decision("Chose Vue.js for UI")
    Note over Implementer, ConPort: Writes code and unit tests...
    Implementer->>ConPort: log_custom_data("CodeSnippets:UserProfileComponent_v1")
    Implementer-->>LeadDev: attempt_completion("UI Component Done")
    deactivate Implementer

    LeadDev-->>Orchestrator: attempt_completion("Development Phase Complete")
    deactivate LeadDev

    activate Orchestrator
    Orchestrator-->>User: Report: "Development is complete, ready for QA."
    deactivate Orchestrator
```

---

### 4. The Lead Mode "Single-Step Loop"

This flowchart illustrates the fundamental execution logic for all Lead Modes (`-LeadArchitect`, `-LeadDeveloper`, `-LeadQA`) in the v3 architecture. This "Single-Step Loop" is a cornerstone of system reliability. Instead of planning and delegating a complex series of tasks upfront, the Lead Mode creates a coarse-grained plan and then iteratively determines and delegates only the _single, next, most logical sub-task_. This "just-in-time" approach makes agent behavior more predictable, reduces the risk of error in complex briefings, and increases overall system robustness.

```mermaid
flowchart TD
    A["Start: Receive Phase-Task<br/>from Orchestrator"] --> B{"Create High-Level Plan<br/>in ConPort"};
    B --> C["Start Loop: Focus on<br/>Next Milestone"];
    C --> D["Determine SINGLE, next,<br/>most logical, atomic sub-task"];
    D --> E["Delegate Sub-task to Specialist<br/>via `new_task`"];
    E --> F["Await `attempt_completion`<br/>from Specialist"];
    F --> G["Process Specialist's Result<br/>and Update ConPort (e.g., Progress)"];
    G --> H{Phase Goal Met?};
    H -- No --> C;
    H -- Yes --> I[End Loop];
    I --> J["Report Phase Completion<br/>to Orchestrator"];
    J --> K[End];
```

---

### 5. The Workflow Ecosystem

This mindmap provides a conceptual overview of the standardized processes, or "Workflows," that govern the Nova System's operations. It visualizes the division of labor, showing how workflows are owned by different actors in the hierarchy. The `Orchestrator` manages high-level, cross-functional processes, while each `Lead Mode` owns workflows specific to its domain (architecture, development, or QA), which they use to guide their teams.

```mermaid
mindmap
  root((Nova Workflows))
    ::icon(fa fa-cogs)
    Orchestrator
      ::icon(fa fa-sitemap)
      WF_ORCH_NEW_PROJECT_FULL_CYCLE
      WF_ORCH_SESSION_STARTUP
      WF_ORCH_CRITICAL_BUG_RESOLUTION
      WF_ORCH_RELEASE_PREPARATION
    LeadArchitect
      ::icon(fa fa-building)
      WF_ARCH_CONPORT_HEALTH_CHECK
      WF_ARCH_IMPACT_ANALYSIS
      WF_ARCH_NEW_WORKFLOW_DEFINITION
      WF_ARCH_SYSTEM_PROMPT_UPDATE
    LeadDeveloper
      ::icon(fa fa-code)
      WF_DEV_FEATURE_IMPLEMENTATION
      WF_DEV_TECHDEBT_REFACTOR
      WF_DEV_CODE_REVIEW_SIMULATION
    LeadQA
      ::icon(fa fa-bug)
      WF_QA_BUG_INVESTIGATION
      WF_QA_FULL_REGRESSION_TEST
      WF_QA_RELEASE_CANDIDATE_VALIDATION
```

---

### 6. The "Auditable Rationale" Protocol

This flowchart visualizes the "Auditable Rationale Protocol," a mandatory process for every agent in the v3 system. It serves as a "flight recorder" for the agent's reasoning. Before _every_ tool call, the agent must explicitly document its Goal, Justification, and Expectation in its internal `<thinking>` block. This protocol is the key to system traceability, providing invaluable insight for debugging, analysis, and understanding the system's decision-making process for every action it takes.

```mermaid
flowchart TD
    A["Agent determines next action<br/>requires a tool call"] --> B["Agent opens `<thinking>` block"];
    B --> C["Agent writes `## Rationale` section"];
    subgraph "Rationale Content"
        D["**Goal:** What to achieve"]
        E["**Justification:** Why this tool/params"]
        F["**Expectation:** What is the expected outcome"]
    end
    C --> G["Agent formulates and writes<br/>the `<tool_name>` call"];
    G --> H["Agent closes `<thinking>` block"];
    H --> I["Tool call is executed by<br/>Roo Code Environment"];
    I --> J["Agent receives `tool_output`"];
```

---

### 7. Session Start & Context Resumption

This sequence diagram models the critical boot-up procedure detailed in `WF_ORCH_SESSION_STARTUP_AND_CONTEXT_RESUMPTION_001_v1.md`. It shows how the `Nova-Orchestrator` intelligently handles the start of any new user session. The process is robust, featuring conditional logic to either load the state from an existing ConPort database or, if one is not found, to orchestrate a full project bootstrap by delegating to `Nova-LeadArchitect`. This ensures seamless continuity between sessions or a structured start for new projects.

```mermaid
sequenceDiagram
    participant User
    participant Orchestrator as Nova-Orchestrator
    participant FileSystem
    participant ConPort
    participant Architect as Nova-LeadArchitect

    User->>Orchestrator: "Start new session."
    activate Orchestrator
    Orchestrator->>FileSystem: list_files('context_portal/')
    FileSystem-->>Orchestrator: [context.db found / not found]

    alt ConPort DB Exists
        Orchestrator->>ConPort: get_product_context()
        ConPort-->>Orchestrator: ProductContext data
        Orchestrator->>ConPort: get_custom_data('ProjectConfig:ActiveConfig')
        ConPort-->>Orchestrator: ProjectConfig data
        Orchestrator->>FileSystem: read_file('.nova/summary/latest.md')
        FileSystem-->>Orchestrator: Last session summary text
        Orchestrator->>User: "Session resumed. Ready for command."
    else ConPort DB Does Not Exist
        Orchestrator->>User: ask_followup_question("Initialize new project?")
        User-->>Orchestrator: "Yes, initialize."
        Orchestrator->>Architect: new_task (Bootstrap Project)
        activate Architect
        Note over Architect: Executes WF_PROJ_INIT_001...
        Architect-->>Orchestrator: attempt_completion("Bootstrap complete")
        deactivate Architect
        Orchestrator->>User: "Project initialized. Ready for command."
    end
    deactivate Orchestrator
```

## Conclusion

The Nova System is designed around several key architectural principles:

1.  **Hierarchical Delegation:** Tasks flow from high-level user goals down to granular, specialist actions.
2.  **Structured Communication:** Formal `new_task` briefings and `attempt_completion` reports minimize ambiguity.
3.  **Centralized Knowledge:** The `Context Portal (ConPort)` acts as a single, shared brain, enabling state retention and complex contextual reasoning.
4.  **Standardized Processes:** `Workflows` codify best practices, ensuring consistent and repeatable project execution.
5.  **Auditable Rationale:** The mandatory rationale protocol provides complete transparency into the decision-making process of every agent.

Together, these principles create a robust, traceable, and highly-organized framework for AI-driven software development.
