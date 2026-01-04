#!/usr/bin/env python3
"""Package a Claude skill into a .skill file (zip archive)."""

import argparse
import sys
import zipfile
from pathlib import Path

# Fix: Import yaml with error handling
try:
    import yaml
except ImportError:
    print("Error: PyYAML is not installed.")
    print("Install it with: pip install pyyaml")
    print("Or: pip install -r requirements.txt")
    sys.exit(1)


def validate_skill(skill_dir: Path) -> bool:
    """Validate skill structure and metadata.

    Args:
        skill_dir: Path to skill directory

    Returns:
        True if valid, False otherwise
    """
    skill_md = skill_dir / "SKILL.md"

    if not skill_md.exists():
        print(f"❌ Error: SKILL.md not found in {skill_dir}")
        return False

    # Read and parse YAML frontmatter
    content = skill_md.read_text(encoding="utf-8")

    if not content.startswith("---"):
        print("❌ Error: SKILL.md missing YAML frontmatter (must start with '---')")
        return False

    # Extract YAML frontmatter
    parts = content.split("---", 2)
    if len(parts) < 3:
        print("❌ Error: Invalid YAML frontmatter format")
        return False

    try:
        metadata = yaml.safe_load(parts[1])
    except yaml.YAMLError as e:
        print(f"❌ Error: Invalid YAML in frontmatter: {e}")
        return False

    # Check required fields
    if not metadata:
        print("❌ Error: Empty YAML frontmatter")
        return False

    if "name" not in metadata:
        print("❌ Error: Missing required field: name")
        return False

    if "description" not in metadata:
        print("❌ Error: Missing required field: description")
        return False

    return True


def package_skill(skill_dir: Path, output_dir: Path) -> Path:
    """Package a skill directory into a .skill file.

    Args:
        skill_dir: Path to skill directory
        output_dir: Path to output directory

    Returns:
        Path to created .skill file
    """
    # Read skill name from SKILL.md
    skill_md = skill_dir / "SKILL.md"
    content = skill_md.read_text(encoding="utf-8")
    parts = content.split("---", 2)
    metadata = yaml.safe_load(parts[1])
    skill_name = metadata["name"]

    # Create output directory if needed
    output_dir.mkdir(parents=True, exist_ok=True)

    # Output file path
    output_file = output_dir / f"{skill_name}.skill"

    # Create zip file
    with zipfile.ZipFile(output_file, "w", zipfile.ZIP_DEFLATED) as zf:
        # Add all files from skill directory
        for file_path in skill_dir.rglob("*"):
            if file_path.is_file():
                # Calculate relative path
                arcname = file_path.relative_to(skill_dir.parent)
                zf.write(file_path, arcname)
                print(f"  Added: {arcname}")

    return output_file


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(description="Package a Claude skill into a .skill file")
    parser.add_argument("skill_dir", type=Path, help="Path to skill directory")
    parser.add_argument(
        "output_dir",
        type=Path,
        nargs="?",
        default=Path.cwd(),
        help="Output directory (default: current directory)",
    )

    args = parser.parse_args()

    # Validate paths
    if not args.skill_dir.exists():
        print(f"❌ Error: Skill directory not found: {args.skill_dir}")
        sys.exit(1)

    if not args.skill_dir.is_dir():
        print(f"❌ Error: Not a directory: {args.skill_dir}")
        sys.exit(1)

    print(f"📦 Packaging skill: {args.skill_dir}")
    print(f"   Output directory: {args.output_dir}\n")

    # Validate skill
    print("🔍 Validating skill...")
    if not validate_skill(args.skill_dir):
        sys.exit(1)

    print("✅ Skill is valid!\n")

    # Package skill
    try:
        output_file = package_skill(args.skill_dir, args.output_dir)
        print(f"\n✅ Successfully packaged skill to: {output_file}")
    except Exception as e:
        print(f"\n❌ Error packaging skill: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
