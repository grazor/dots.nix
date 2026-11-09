"""Move the former root-level agent-skills bundle into its own namespace."""

import json
from pathlib import Path
import sys


def migrate(root: Path) -> None:
    marker = root / ".agent-skills-managed.json"
    if root.is_symlink() or marker.is_symlink() or not marker.is_file():
        return

    metadata = json.loads(marker.read_text())
    if (
        metadata.get("schemaVersion") != 1
        or metadata.get("managedBy") != "agent-skills-nix"
        or metadata.get("mode") != "global"
        or metadata.get("target") != "agents"
        or metadata.get("structure") not in ("copy-tree", "symlink-tree")
    ):
        return

    bundle = Path(metadata["bundle"])
    if bundle.parent != Path("/nix/store") or not bundle.is_dir():
        raise RuntimeError(f"Cannot migrate skills: previous bundle unavailable: {bundle}")

    destination = root / "dots"
    if destination.is_symlink() or (destination.exists() and not destination.is_dir()):
        raise RuntimeError(f"Cannot migrate skills into {destination}")

    bundle_names = {entry.name for entry in bundle.iterdir()}
    if destination.is_dir():
        for entry in destination.iterdir():
            if entry.name not in bundle_names:
                raise RuntimeError(f"Cannot migrate skills: unmanaged destination entry: {entry}")

    # Preflight all entries before moving any. On a retry, already moved
    # entries no longer exist at the root and are left in place.
    entries = [root / name for name in sorted(bundle_names)]
    entries = [entry for entry in entries if entry.exists() or entry.is_symlink()]
    for entry in entries:
        target = destination / entry.name
        if entry.name == "dots" or target.exists() or target.is_symlink():
            raise RuntimeError(f"Cannot migrate skills: destination conflict: {target}")
    destination.mkdir(exist_ok=True)
    for entry in entries:
        entry.rename(destination / entry.name)

    # The marker moves last so an interrupted migration can be retried.
    marker.rename(destination / marker.name)


if __name__ == "__main__":
    migrate(Path(sys.argv[1]))
