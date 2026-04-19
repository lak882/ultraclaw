#!/usr/bin/env python3
"""Permission/safety mode system for the orchestrator.

Provides graduated permission levels that control confirmation requirements
and safety guardrails across all orchestrator commands and scripts.

Modes (from most restrictive to most permissive):
  strict                      - Confirm everything, dry-run first
  normal (default)            - Confirm destructive ops, allow standard edits
  permissive                  - Allow edits freely, confirm only resets/deletes
  dangerously-skip-permissions - No confirmations, full auto

Usage in scripts:
    from permissions import get_permissions, check_permission

    perms = get_permissions()
    if perms.requires_confirmation("push"):
        # ask for confirmation
    if not perms.is_allowed("server_edits"):
        print("Server edits not allowed in current mode")
        sys.exit(1)

Usage from CLI:
    python permissions.py --mode                 # show current mode
    python permissions.py --set-mode permissive  # change mode
    python permissions.py --check push           # check if push needs confirmation
    python permissions.py --list                 # list all modes
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import argparse
import json
import os
import sys

# Map operation names to config keys
OPERATION_MAP = {
    "push": "confirmBeforePush",
    "reset": "confirmBeforeReset",
    "delete": "confirmBeforeDelete",
    "production_state": "confirmBeforeProductionStateChange",
    "send": "confirmBeforeSend",
}

ALLOW_MAP = {
    "file_edits": "allowFileEdits",
    "server_edits": "allowServerEdits",
}


def _find_config_path():
    """Find config/orchestrator.json relative to project root."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.abspath(os.path.join(script_dir, "..", "..", "..", "..", ".."))
    return os.path.join(project_root, "config", "orchestrator.json")


def _load_config():
    """Load orchestrator.json and return the full config dict."""
    config_path = _find_config_path()
    if not os.path.exists(config_path):
        return {}
    with open(config_path) as f:
        return json.load(f)


def _save_config(config):
    """Save orchestrator.json."""
    config_path = _find_config_path()
    with open(config_path, "w") as f:
        json.dump(config, f, indent=4)
        f.write("\n")


class Permissions:
    """Represents the resolved permission state for the current mode."""

    def __init__(self, mode_name, mode_config, guardrails):
        self.mode = mode_name
        self._config = mode_config
        self.guardrails = guardrails
        self.description = mode_config.get("description", "")

    def requires_confirmation(self, operation):
        """Check if an operation requires user confirmation.

        Args:
            operation: One of 'push', 'reset', 'delete', 'production_state', 'send'

        Returns:
            True if confirmation is required, False otherwise.
        """
        config_key = OPERATION_MAP.get(operation)
        if config_key is None:
            # Unknown operation -- be safe, require confirmation
            return True
        return self._config.get(config_key, True)

    def is_allowed(self, capability):
        """Check if a capability is allowed in the current mode.

        Args:
            capability: One of 'file_edits', 'server_edits'

        Returns:
            True if allowed, False otherwise.
        """
        config_key = ALLOW_MAP.get(capability)
        if config_key is None:
            return False
        return self._config.get(config_key, False)

    @property
    def dry_run_first(self):
        """Whether destructive operations should do a dry run first."""
        return self._config.get("dryRunFirst", True)

    def check_guardrail(self, guardrail):
        """Check if a safety guardrail is active.

        Guardrails are ALWAYS enforced regardless of permission mode.

        Args:
            guardrail: One of 'neverDeleteWithRunningProduction',
                      'alwaysBackupBeforeDeploy', 'requireNamespaceMatch'

        Returns:
            True if the guardrail is active (it should be enforced).
        """
        return self.guardrails.get(guardrail, True)

    def summary(self):
        """Return a human-readable summary of the current permissions."""
        lines = [f"Mode: {self.mode}", f"  {self.description}", ""]
        lines.append("Confirmations required:")
        for op, key in OPERATION_MAP.items():
            required = self._config.get(key, True)
            lines.append(f"  {op:25s} {'yes' if required else 'no'}")
        lines.append("")
        lines.append("Capabilities:")
        for cap, key in ALLOW_MAP.items():
            allowed = self._config.get(key, False)
            lines.append(f"  {cap:25s} {'allowed' if allowed else 'blocked'}")
        lines.append("")
        lines.append(f"Dry run first: {'yes' if self.dry_run_first else 'no'}")
        lines.append("")
        lines.append("Guardrails (always enforced):")
        for g, v in self.guardrails.items():
            lines.append(f"  {g:40s} {'active' if v else 'inactive'}")
        return "\n".join(lines)


# Default mode config if orchestrator.json is missing or incomplete
DEFAULT_MODE_CONFIG = {
    "confirmBeforePush": False,
    "confirmBeforeReset": True,
    "confirmBeforeDelete": True,
    "confirmBeforeProductionStateChange": False,
    "confirmBeforeSend": False,
    "allowFileEdits": True,
    "allowServerEdits": True,
    "dryRunFirst": True,
    "description": "Default mode (normal)",
}

DEFAULT_GUARDRAILS = {
    "neverDeleteWithRunningProduction": True,
    "alwaysBackupBeforeDeploy": True,
    "maxResetPackagesPerCommand": 3,
    "requireNamespaceMatch": True,
}


def get_permissions(mode_override=None):
    """Get the current Permissions object.

    Args:
        mode_override: If set, use this mode instead of the configured one.
                      Supports CLI flags like --dangerously-skip-permissions.

    Returns:
        Permissions instance for the active mode.
    """
    config = _load_config()
    perm_config = config.get("permissions", {})
    modes = perm_config.get("modes", {})
    guardrails = perm_config.get("guardrails", DEFAULT_GUARDRAILS)

    # Determine which mode to use
    mode_name = mode_override or perm_config.get("mode", "normal")

    # CLI flag aliases
    if mode_name in ("bypass", "skip", "auto", "yolo"):
        mode_name = "dangerously-skip-permissions"

    mode_config = modes.get(mode_name, DEFAULT_MODE_CONFIG)
    return Permissions(mode_name, mode_config, guardrails)


def check_permission(operation, mode_override=None):
    """Quick check: does this operation need confirmation?

    Returns True if confirmation is needed, False if it can proceed.
    """
    perms = get_permissions(mode_override)
    return perms.requires_confirmation(operation)


def set_mode(new_mode):
    """Change the active permission mode in orchestrator.json.

    Args:
        new_mode: Mode name to set.

    Returns:
        True if successful, raises ValueError if mode doesn't exist.
    """
    config = _load_config()
    perm_config = config.get("permissions", {})
    modes = perm_config.get("modes", {})

    if new_mode not in modes:
        valid = ", ".join(sorted(modes.keys()))
        raise ValueError(f"Unknown mode '{new_mode}'. Valid modes: {valid}")

    perm_config["mode"] = new_mode
    config["permissions"] = perm_config
    _save_config(config)
    return True


def list_modes():
    """Return a list of available modes with descriptions."""
    config = _load_config()
    perm_config = config.get("permissions", {})
    modes = perm_config.get("modes", {})
    current = perm_config.get("mode", "normal")

    result = []
    for name, cfg in modes.items():
        marker = " (active)" if name == current else ""
        result.append(f"  {name}{marker}: {cfg.get('description', '')}")
    return "\n".join(result)


def main():
    parser = argparse.ArgumentParser(description="Orchestrator permission modes")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--mode", action="store_true", help="Show current mode")
    group.add_argument("--set-mode", metavar="MODE", help="Set permission mode")
    group.add_argument("--check", metavar="OPERATION",
                       help="Check if operation needs confirmation (push/reset/delete/send/production_state)")
    group.add_argument("--list", action="store_true", help="List all available modes")
    group.add_argument("--summary", action="store_true", help="Show full permission summary")

    args = parser.parse_args()

    if args.mode:
        config = _load_config()
        current = config.get("permissions", {}).get("mode", "normal")
        print(current)

    elif args.set_mode:
        try:
            set_mode(args.set_mode)
            print(f"Permission mode set to: {args.set_mode}")
        except ValueError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)

    elif args.check:
        perms = get_permissions()
        needs_confirm = perms.requires_confirmation(args.check)
        print(f"{'yes' if needs_confirm else 'no'}")
        sys.exit(0 if not needs_confirm else 2)

    elif args.list:
        print("Available permission modes:")
        print(list_modes())

    elif args.summary:
        perms = get_permissions()
        print(perms.summary())


if __name__ == "__main__":
    main()
