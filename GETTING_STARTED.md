# Getting Started with the Nova System: Your First Project

Welcome to the Nova System! This guide will walk you through building your very first project: a simple Python command-line tool that prints a random quote.

This tutorial will show you the power of Nova's collaborative AI agents by guiding you through project setup, design, implementation, and testing, all using natural language prompts.

## Prerequisites

Before you begin, please make sure you have completed the following steps from our main `README.md`:

1.  **Installed the Nova System files** into an empty directory for this project.
2.  **Installed and configured the `novaport-mcp` server** in your Roo Code environment. This is the backend database that Nova depends on for its memory.

Let's begin!

---

## Step 1: Project Initialization

First, we'll ask the `Nova-Orchestrator` to set up our new project.

1.  Open your empty project folder in Visual Studio Code.
2.  Open the Roo Code Chat View.
3.  From the AI mode dropdown, select **`Nova-Orchestrator`**.
4.  Send the following prompt:

> `This is a new project. Let's set it up. It will be a simple Python command-line tool that prints a random quote.`

**What's happening?**
The `Nova-Orchestrator` will detect that this is a new, empty workspace. It will ask for your confirmation and then delegate the entire project setup to `Nova-LeadArchitect`. The architect's team will create the initial project structure in the NovaPort-MCP database and guide you through setting up a basic `ProjectConfig` file. Answer its questions about the primary language (`Python`) and testing framework (`pytest`).

---

## Step 2: System Design

Now that the project is initialized, let's have the system design itself.

1.  With `Nova-Orchestrator` still selected, send the following prompt:

> `Okay, let's design the application. It's very simple. We only need one main function that will contain a list of hardcoded quotes. This function should select one quote at random and print it to the console.`

**What's happening?**
The orchestrator will delegate this design phase to `Nova-LeadArchitect`. The architect's team will analyze your request and create a simple design artifact in the database, likely in the `SystemArchitecture` category, describing this single-function structure.

---

## Step 3: Code Implementation

With a clear design, it's time to write the code.

1.  Send the following prompt to `Nova-Orchestrator`:

> `The design is perfect. Please delegate the implementation of the main function to the development team. The code should be in a file named `quote_tool.py`.`

**What's happening?**
The orchestrator will now hand over the development phase to `Nova-LeadDeveloper`. The lead developer will analyze the design and your instructions, then delegate the specific task of writing the Python code to `Nova-SpecializedFeatureImplementer`. The implementer will write the `quote_tool.py` file with the requested function and a few example quotes.

---

## Step 4: Writing a Test

Quality is key! Let's ask for a simple test to ensure our tool works as expected.

1.  Send the following prompt to `Nova-Orchestrator`:

> `Great, the code is implemented. Now, please have the team write a simple unit test for our `quote_tool.py`. The test should check that the main function runs without errors and returns one of the hardcoded quotes.`

**What's happening?**
`Nova-LeadDeveloper` (or `Nova-LeadQA`, depending on the configured workflow) will be tasked with testing. A specialist, likely `Nova-SpecializedTestAutomator`, will be briefed to create a test file (e.g., `test_quote_tool.py`). This test will verify the core functionality of your application.

---

## Congratulations!

You have successfully completed your first project with the Nova System!

You've witnessed the entire workflow:

- **Orchestration:** `Nova-Orchestrator` managed the project phases.
- **Architecture:** `Nova-LeadArchitect` handled project setup and design.
- **Development:** `Nova-LeadDeveloper`'s team implemented the code.
- **Quality Assurance:** A test was created to verify the functionality.

All significant decisions, designs, and code snippets have been automatically logged into the **NovaPort-MCP** database, creating a rich history of your project.

### What's Next?

- Explore the `.nova/` directory to see the workflows that guided the agents.
- Check out `examples/example-user-prompts.md` for more advanced commands.
- Try asking the `Nova-Orchestrator`: `Generate a project digest of what we just did.`
