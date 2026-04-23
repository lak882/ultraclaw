#!/usr/bin/env python3
"""Submit feedback to the InterClaw GitHub issue tracker via the chatbot backend.

Usage:
  feedback.py --category bug --comment "DTL editor crashes on repeating segments"
  feedback.py --category feature-request --comment "Add FHIR R4 support" --rating 4
  feedback.py --category praise --comment "The /poc command saved me hours"
"""

import sys as _sys, os as _os; _sys.path.insert(0, _os.path.join(_os.path.dirname(_os.path.abspath(__file__)), '..', 'lib'))

import argparse
import json
import sys
import urllib.request
import urllib.error


CATEGORIES = ["bug", "feature-request", "general", "praise"]
BACKEND_URL = "http://localhost:8765/api/feedback"


def submit_feedback(category, comment, rating=None, namespace=None, model=None,
                    backend_url=None):
    """Submit feedback and return (success, result_dict_or_error_string)."""
    url = backend_url or BACKEND_URL
    payload = {
        "category": category,
        "comment": comment,
    }
    if rating is not None:
        payload["rating"] = rating
    if namespace:
        payload["namespace"] = namespace
    if model:
        payload["model"] = model

    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST")
    req.add_header("Content-Type", "application/json")

    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            result = json.loads(resp.read().decode())
            return True, result
    except urllib.error.HTTPError as e:
        try:
            body = json.loads(e.read().decode())
            return False, body.get("error", str(body))
        except Exception:
            return False, f"HTTP {e.code}: {e.reason}"
    except urllib.error.URLError as e:
        return False, f"Connection failed: {e.reason}"


def main():
    parser = argparse.ArgumentParser(description="Submit feedback to InterClaw tracker")
    parser.add_argument("--category", "-c", required=True, choices=CATEGORIES,
                        help="Feedback category")
    parser.add_argument("--comment", "-m", required=True,
                        help="Feedback comment (free text, max 2000 chars)")
    parser.add_argument("--rating", "-r", type=int, choices=range(1, 6),
                        help="Rating 1-5 (optional)")
    parser.add_argument("--namespace",
                        help="Current IRIS namespace (optional)")
    parser.add_argument("--model",
                        help="Current model name (optional)")
    parser.add_argument("--backend-url",
                        help=f"Backend API URL (default: {BACKEND_URL})")
    args = parser.parse_args()

    if len(args.comment) > 2000:
        print("ERROR: Comment must be 2000 characters or fewer.", file=sys.stderr)
        sys.exit(1)

    success, result = submit_feedback(
        category=args.category,
        comment=args.comment,
        rating=args.rating,
        namespace=args.namespace,
        model=args.model,
        backend_url=args.backend_url,
    )

    if success:
        issue_url = result.get("issue_url", result.get("url", ""))
        if issue_url:
            print(f"Feedback submitted — {issue_url}")
        else:
            print(f"Feedback submitted — {json.dumps(result)}")
    else:
        print(f"ERROR: {result}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
