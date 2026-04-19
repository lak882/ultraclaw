#!/usr/bin/env python3
"""Query or initialize the IRIS instance identity.

On first run, generates a UUID and stores it in ^InterClaw("InstanceID").
Always returns the instance ID and unique instance name as JSON.
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))
import argparse
import json
import sys

from iris_terminal import ws_run_objectscript


COS_CODE = """\
set id=$get(^InterClaw("InstanceID"))
set new=0
if id="" set id=$system.Util.CreateGUID() set ^InterClaw("InstanceID")=id set new=1
write $select(new:"created",1:"existing"),!
write id,!
write ##class(%SYS.System).GetUniqueInstanceName(),!
"""


def main():
    parser = argparse.ArgumentParser(description="Query/initialize IRIS instance identity")
    parser.add_argument("--server", "-s", required=True, help="Server name")
    parser.add_argument("--namespace", "-n", default="%SYS", help="Namespace (default: %%SYS)")
    parser.add_argument("--config", "-c", default=None, help="Path to servers.json")
    args = parser.parse_args()

    try:
        output = ws_run_objectscript(
            COS_CODE,
            server=args.server,
            namespace=args.namespace,
            config_path=args.config,
        )
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

    lines = [l.strip() for l in output.strip().splitlines() if l.strip()]
    if len(lines) < 3:
        print(json.dumps({"error": f"Unexpected output: {output}"}))
        sys.exit(1)

    status = lines[0]       # "created" or "existing"
    instance_id = lines[1]  # UUID
    unique_name = lines[2]  # HOSTNAME:INSTANCE

    result = {
        "instanceId": instance_id,
        "uniqueInstanceName": unique_name,
        "status": status,
    }
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
