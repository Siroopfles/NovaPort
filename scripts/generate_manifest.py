import os
import re


def find_project_root(marker=".git"):
    """Finds the project root by looking for a marker."""
    path = os.path.abspath(os.path.dirname(__file__))
    while path != os.path.dirname(path):
        if os.path.isdir(os.path.join(path, marker)):
            return path
        path = os.path.dirname(path)
    raise FileNotFoundError(f"Project root with marker '{marker}' not found.")


def extract_description_from_workflow(file_path):
    """
    Extracts the 'Goal:' line from a workflow .md file.
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line in f:
                # Search for a line that starts with "Goal:", possibly with markdown bolding
                match = re.search(
                    r"^\s*(?:\*\*Goal:\*\*|Goal:)\s*(.*)", line, re.IGNORECASE
                )
                if match:
                    # Return the captured group, stripping any extra whitespace
                    return match.group(1).strip()
    except Exception:
        # If any error occurs, return a default message
        pass
    return "Description could not be automatically extracted."


def generate_manifest():
    """
    Generates a new manifest.md file by scanning the .nova/workflows directory
    and automatically extracting descriptions.
    """
    try:
        root_dir = find_project_root()
        workflows_dir = os.path.join(root_dir, ".nova", "workflows")
        manifest_path = os.path.join(workflows_dir, "manifest.md")

        print(f"Scanning for workflows in: {workflows_dir}")

        # Dictionary to hold workflows categorized by their owner
        workflows = {
            "nova-orchestrator": [],
            "nova-leadarchitect": [],
            "nova-leaddeveloper": [],
            "nova-leadqa": [],
        }

        # Scan the filesystem
        for subdir, _, files in os.walk(workflows_dir):
            owner = os.path.basename(subdir)
            if owner in workflows:
                for file in files:
                    if file.startswith("WF_") and file.endswith(".md"):
                        file_path = os.path.join(subdir, file)
                        description = extract_description_from_workflow(file_path)
                        workflows[owner].append((file, description))

        # Sort files alphabetically within each category
        for owner in workflows:
            workflows[owner].sort(key=lambda x: x[0])

        # Generate the new manifest content
        content = [
            "# Nova System Workflow Manifest\n\n",
            "This file provides a discoverable index of all standard workflows within the Nova System. The AI modes can consult this manifest to understand their available capabilities and to select the appropriate process for a given task.\n\n",
            "---\n\n",
        ]

        # --- Section Generation Function ---
        def create_section(title, actor, workflow_list):
            lines = [
                f"## {title}\n",
                f"**Primary Actor:** `{actor}`\n",
                f"_{workflow_list[1]}_\n\n",  # Using a placeholder for the description text, will be replaced
                "| Filename | Description |\n",
                "|---|---|\n",
            ]

            section_descriptions = {
                "1. Orchestrator Workflows": "_These workflows manage the high-level project lifecycle and coordinate between Lead modes._",
                "2. Lead Architect Workflows": "_These workflows focus on system design, architectural integrity, and ConPort management._",
                "3. Lead Developer Workflows": "_These workflows cover the entire software implementation lifecycle._",
                "4. Lead QA Workflows": "_These workflows ensure the quality, stability, and security of the application._",
            }

            lines[2] = f"{section_descriptions.get(title, '')}\n\n"

            for filename, desc in workflow_list[0]:
                lines.append(f"| `{filename}` | {desc} |\n")
            return lines

        # --- Orchestrator Section ---
        content.extend(
            create_section(
                "1. Orchestrator Workflows",
                "Nova-Orchestrator",
                (
                    workflows["nova-orchestrator"],
                    "_These workflows manage the high-level project lifecycle and coordinate between Lead modes._",
                ),
            )
        )

        # --- Lead Architect Section ---
        content.extend(["\n---\n\n"])
        content.extend(
            create_section(
                "2. Lead Architect Workflows",
                "Nova-LeadArchitect",
                (
                    workflows["nova-leadarchitect"],
                    "_These workflows focus on system design, architectural integrity, and ConPort management._",
                ),
            )
        )

        # --- Lead Developer Section ---
        content.extend(["\n---\n\n"])
        content.extend(
            create_section(
                "3. Lead Developer Workflows",
                "Nova-LeadDeveloper",
                (
                    workflows["nova-leaddeveloper"],
                    "_These workflows cover the entire software implementation lifecycle._",
                ),
            )
        )

        # --- Lead QA Section ---
        content.extend(["\n---\n\n"])
        content.extend(
            create_section(
                "4. Lead QA Workflows",
                "Nova-LeadQA",
                (
                    workflows["nova-leadqa"],
                    "_These workflows ensure the quality, stability, and security of the application._",
                ),
            )
        )

        # Write the new manifest
        with open(manifest_path, "w", encoding="utf-8") as f:
            f.writelines(content)

        print(
            f"\n✅ Successfully generated new manifest.md with {sum(len(v) for v in workflows.values())} total workflows and auto-extracted descriptions."
        )

    except Exception as e:
        print(f"\n❌ An error occurred: {e}")


if __name__ == "__main__":
    generate_manifest()
