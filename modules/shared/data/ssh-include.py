"""Include runtime SOPS hosts without replacing an existing SSH config."""

import os
from pathlib import Path
import sys
import tempfile


def install(config: Path, secret: str) -> None:
    if config.is_symlink():
        raise SystemExit("SSH config is a symlink; add its SOPS Include in the source config")

    config.parent.mkdir(mode=0o700, parents=True, exist_ok=True)
    directive = f'Include "{secret}"'.encode()
    original = config.read_bytes() if config.exists() else b""
    if directive in original.splitlines():
        config.chmod(0o600)
        return

    if config.exists():
        backup = config.with_name("config.before-dots-ssh")
        try:
            descriptor = os.open(backup, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        except FileExistsError:
            pass
        else:
            with os.fdopen(descriptor, "wb") as stream:
                stream.write(original)

    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=config.parent, delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(directive + b"\n\n" + original)
        temporary.chmod(0o600)
        temporary.replace(config)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


if __name__ == "__main__":
    install(Path(sys.argv[1]), sys.argv[2])
