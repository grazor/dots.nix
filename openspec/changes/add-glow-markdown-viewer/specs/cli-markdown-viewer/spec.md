## ADDED Requirements

### Requirement: Terminal markdown viewer on workstation and server hosts

The system SHALL provide the `glow` terminal markdown renderer on every host that imports the shared `tools` aspect, installed via `environment.systemPackages` from the pinned `nixpkgs` input. This covers the Mac (`mac`), the desktop workstation (`desktop`), and the servers (`nas`, `asus`, `dell`).

#### Scenario: glow available on the Mac host

- **WHEN** the `mac` darwin configuration is built and activated
- **THEN** the `glow` executable is present on `PATH` and renders a markdown file passed as an argument

#### Scenario: glow available on the desktop host

- **WHEN** the `desktop` NixOS configuration is built and activated
- **THEN** the `glow` executable is present on `PATH` and renders a markdown file passed as an argument

#### Scenario: glow available on each server host

- **WHEN** any of the `nas`, `asus`, or `dell` NixOS configurations is built and activated
- **THEN** the `glow` executable is present on `PATH` and renders markdown when invoked over an SSH session

### Requirement: Raspberry Pi excluded from the markdown viewer

The system SHALL NOT install `glow` on the Raspberry Pi host (`rpi4b`). The exclusion is achieved by `rpi4b` not importing the `tools` aspect, and the change MUST NOT add `glow` to any aspect that `rpi4b` imports.

#### Scenario: glow absent on the Raspberry Pi

- **WHEN** the `rpi4b` NixOS configuration is built and activated
- **THEN** the `glow` executable is not added to the system profile by this change
