import os
import re
import sys

def find_project_root(marker=".git"):
    """Finds the project root by looking for a marker."""
    path = os.path.abspath(os.getcwd())
    while path != os.path.dirname(path):
        if os.path.isdir(os.path.join(path, marker)):
            return path
        path = os.path.dirname(path)
    raise FileNotFoundError(f"Project root with marker '{marker}' not found.")

def validate_manifest(root_dir):
    """
    Validates that all workflows in the filesystem exist in the manifest.md and vice-versa.
    """
    print("--- Running Workflow Manifest Validation ---")
    errors = []
    manifest_path = os.path.join(root_dir, '.nova', 'workflows', 'manifest.md')
    workflows_dir = os.path.join(root_dir, '.nova', 'workflows')

    # 1. Get files from manifest
    try:
        with open(manifest_path, 'r', encoding='utf-8') as f:
            content = f.read()
        manifest_files = set(re.findall(r"\| `(WF_.*?.md)` \|", content))
        print(f"Found {len(manifest_files)} workflow files listed in the manifest.")
    except FileNotFoundError:
        print(f"ERROR: Manifest file not found at {manifest_path}")
        return [f"Manifest file not found at {manifest_path}"]

    # 2. Get files from filesystem
    fs_files = set()
    for root, _, files in os.walk(workflows_dir):
        for file in files:
            if file.startswith('WF_') and file.endswith('.md'):
                fs_files.add(file)
    print(f"Found {len(fs_files)} workflow files in the filesystem.")

    # 3. Compare sets
    missing_in_manifest = fs_files - manifest_files
    missing_in_fs = manifest_files - fs_files

    if missing_in_manifest:
        for f in sorted(list(missing_in_manifest)):
            errors.append(f"File '{f}' exists in filesystem but is MISSING from manifest.md.")
    
    if missing_in_fs:
        for f in sorted(list(missing_in_fs)):
            errors.append(f"File '{f}' is listed in manifest.md but does NOT EXIST in the filesystem.")
    
    if not errors:
        print("✅ Manifest validation successful.")
    
    return errors

def validate_prompts(root_dir):
    """
    Validates that all system prompts contain mandatory sections.
    """
    print("\n--- Running System Prompt Validation ---")
    errors = []
    prompts_dir = os.path.join(root_dir, '.roo')
    mandatory_patterns = [
        re.compile(r"^identity:", re.MULTILINE),
        re.compile(r"^tool_use_protocol:", re.MULTILINE),
        re.compile(r"^core_behavioral_rules:", re.MULTILINE),
        re.compile(r"^objective:", re.MULTILINE),
        re.compile(r"## Rationale", re.MULTILINE), # Key part of the protocol
    ]

    if not os.path.isdir(prompts_dir):
        print(f"WARNING: Prompts directory not found at {prompts_dir}. Skipping.")
        return []

    prompt_files = [f for f in os.listdir(prompts_dir) if f.startswith('system-prompt-')]
    print(f"Found {len(prompt_files)} prompt files to validate.")

    for filename in prompt_files:
        file_path = os.path.join(prompts_dir, filename)
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            missing_patterns = []
            for pattern in mandatory_patterns:
                if not pattern.search(content):
                    missing_patterns.append(f"'{pattern.pattern}'")
            
            if missing_patterns:
                errors.append(f"Prompt '{filename}' is MISSING mandatory sections: {', '.join(missing_patterns)}.")

        except Exception as e:
            errors.append(f"Could not read or parse prompt '{filename}': {e}")
            
    if not errors:
        print("✅ System prompt validation successful.")
        
    return errors


def main():
    """Main execution function."""
    try:
        project_root = find_project_root()
        all_errors = []
        
        all_errors.extend(validate_manifest(project_root))
        all_errors.extend(validate_prompts(project_root))
        
        if all_errors:
            print("\n❌ VALIDATION FAILED. Issues found:")
            for error in all_errors:
                print(f"- {error}")
            sys.exit(1)
        else:
            print("\n🎉 All Nova validations passed successfully!")
            sys.exit(0)
            
    except Exception as e:
        print(f"\n❌ An unexpected error occurred during validation: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()