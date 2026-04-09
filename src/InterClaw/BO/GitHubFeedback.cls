/// InterClaw.BO.GitHubFeedback — Creates GitHub issues from feedback messages.
///
/// Reads the GitHub PAT from Ens.Config.Credentials (SystemName: GitHubFeedback).
/// The target repo is configured via the Repo setting.
Class InterClaw.BO.GitHubFeedback Extends Ens.BusinessOperation
{

Parameter ADAPTER = "Ens.OutboundAdapter";

Parameter INVOCATION = "Queue";

/// GitHub repo in owner/name format (e.g., lak882/claude-connector-gitlab-mirror).
Property Repo As %String;

/// Credential ID for the GitHub PAT. Must exist in Ens.Config.Credentials.
Property CredentialId As %String [ InitialExpression = "GitHubFeedback" ];

/// Comma-separated default labels applied to all feedback issues.
Property DefaultLabels As %String [ InitialExpression = "feedback" ];

Parameter SETTINGS = "Repo:Basic,CredentialId:Basic,DefaultLabels:Basic";

/// Create a GitHub issue from a FeedbackRequest.
Method CreateIssue(pRequest As InterClaw.Msg.FeedbackRequest, Output pResponse As InterClaw.Msg.FeedbackResponse) As %Status
{
    set pResponse = ##class(InterClaw.Msg.FeedbackResponse).%New()

    // Read token from credentials
    set token = ##class(Ens.Config.Credentials).GetValue(..CredentialId, "Password")
    if token = "" {
        set pResponse.Status = "error"
        set pResponse.ErrorMessage = "No token found in credential '" _ ..CredentialId _ "'"
        return $$$OK
    }

    if ..Repo = "" {
        set pResponse.Status = "error"
        set pResponse.ErrorMessage = "Repo setting is empty"
        return $$$OK
    }

    // Call Python to do the HTTP request
    set result = ..CallGitHub(token, ..Repo, ..DefaultLabels, pRequest)

    set pResponse.Status = result."__getitem__"("status")
    set pResponse.IssueURL = result."__getitem__"("issue_url")
    set pResponse.IssueNumber = result."__getitem__"("issue_number")
    set pResponse.ErrorMessage = result."__getitem__"("error")

    if pResponse.Status = "ok" {
        $$$LOGINFO("Created issue #" _ pResponse.IssueNumber _ ": " _ pResponse.IssueURL)
    } else {
        $$$LOGERROR(pResponse.ErrorMessage)
    }

    return $$$OK
}

/// Python helper — makes the GitHub API call and returns a dict.
ClassMethod CallGitHub(token As %String, repo As %String, defaultLabels As %String, pRequest As InterClaw.Msg.FeedbackRequest) As %SYS.Python [ Language = python ]
{
    import json
    from urllib.request import Request, urlopen
    from urllib.error import HTTPError, URLError
    from datetime import datetime

    rating = int(pRequest.Rating) if pRequest.Rating else None
    category = str(pRequest.Category or "general")
    comment = str(pRequest.Comment or "")
    namespace = str(pRequest.Namespace or "N/A")
    model = str(pRequest.Model or "N/A")

    first_line = comment.split("\n")[0][:80] if comment else (f"Rating {rating}/5" if rating else "General feedback")
    title = f"[Feedback] {category}: {first_line}"

    stars = ("*" * (rating or 0)) + ("-" * (5 - (rating or 0))) if rating else "N/A"
    rating_display = f"{rating}/5" if rating else "N/A"
    lines = [
        "## Feedback",
        "",
        "| Field | Value |",
        "|-------|-------|",
        f"| **Rating** | {stars} ({rating_display}) |",
        f"| **Category** | {category} |",
        f"| **Namespace** | {namespace} |",
        f"| **Model** | {model} |",
        f"| **Timestamp** | {datetime.utcnow().isoformat()}Z |",
        "",
        "### Comment",
        "",
        comment or "_No comment provided._",
        "",
        "---",
        "_Submitted via InterClaw production._",
    ]
    body = "\n".join(lines)

    labels = [l.strip() for l in (defaultLabels or "feedback").split(",") if l.strip()]
    if category and category not in labels:
        labels.append(category)

    issue_data = json.dumps({
        "title": title,
        "body": body,
        "labels": labels,
    }).encode("utf-8")

    api_url = f"https://api.github.com/repos/{repo}/issues"
    req = Request(api_url, data=issue_data, method="POST")
    req.add_header("Content-Type", "application/json")
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Accept", "application/vnd.github+json")

    try:
        with urlopen(req, timeout=15) as http_resp:
            result = json.loads(http_resp.read().decode("utf-8"))
            return {
                "status": "ok",
                "issue_url": result.get("html_url", ""),
                "issue_number": int(result.get("number", 0)),
                "error": "",
            }
    except HTTPError as e:
        error_body = e.read().decode("utf-8", errors="replace")[:500]
        return {
            "status": "error",
            "issue_url": "",
            "issue_number": 0,
            "error": f"GitHub API returned {e.code}: {error_body}",
        }
    except (URLError, OSError) as e:
        return {
            "status": "error",
            "issue_url": "",
            "issue_number": 0,
            "error": f"Could not reach GitHub: {e}",
        }
}

XData MessageMap
{
<MapItems>
    <MapItem MessageType="InterClaw.Msg.FeedbackRequest">
        <Method>CreateIssue</Method>
    </MapItem>
</MapItems>
}

}
